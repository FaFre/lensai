/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/settings/domain/providers/settings_export_directory.dart';
import 'package:weblibre/features/settings/domain/services/settings_transfer_service.dart';
import 'package:weblibre/features/settings/presentation/dialogs/settings_import_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// MIME type an export is written and picked with. Kept plain `application/json`
/// so other apps — a file manager, a mail client, a bug tracker — recognise it.
const _exportMimeType = 'application/json';

/// Writes [bytes] into [target] and returns the name the file ended up with.
///
/// The same two-step publication a profile backup uses: a `.partial` name
/// first, its size checked against what was sent, and only then the rename that
/// claims the real one. `writeFileBytes` creates the destination before it
/// writes to it and leaves it there if the write dies half way, so without this
/// a full volume produces a truncated export wearing a finished file's name —
/// which is worse than no export at all, because it will be imported one day.
Future<String> _publishExport({
  required Uri target,
  required String fileName,
  required Uint8List bytes,
}) async {
  final util = SafUtil();

  final partial = await SafStream().writeFileBytes(
    target.toString(),
    '$fileName$partialArchiveSuffix',
    _exportMimeType,
    bytes,
    overwrite: true,
  );

  // SAF may hand back a different name than the one asked for, so the returned
  // uri is the only reliable handle on what was actually created.
  final partialUri = partial.uri.toString();

  try {
    final stat = await util.stat(partialUri, false);
    if (stat == null) {
      throw const BackupPublicationFailure(
        'The written export could not be found afterwards',
      );
    }

    if (stat.length != bytes.length) {
      throw BackupPublicationFailure(
        'Wrote ${bytes.length} bytes but the destination holds ${stat.length}',
      );
    }

    final finished = await util.rename(partialUri, false, fileName);

    return finished.name;
  } catch (_) {
    try {
      await util.delete(partialUri, false);
    } catch (error, stackTrace) {
      logger.w(
        'Could not remove a partial export',
        error: error,
        stackTrace: stackTrace,
      );
    }
    rethrow;
  }
}

/// Whether the export folder is still a folder that can be written to.
///
/// Asked only after a write has already failed, to tell "the folder is gone"
/// apart from "the write did not work this time" — the first is worth
/// forgetting the folder over, the second is not.
Future<bool> _targetIsStillThere(Uri target) async {
  try {
    final util = SafUtil();

    // Deliberately not `safTargetIsWritable`, which answers false for a folder
    // it merely could not ask about — it is built for deciding whether to try,
    // where caution means "no". Here the same false would throw away a folder
    // that is fine, so the two questions are asked separately and only a real
    // answer counts.
    final permitted = await util.hasPersistedPermission(
      target.toString(),
      checkRead: true,
      checkWrite: true,
    );
    if (!permitted) return false;

    return await util.exists(target.toString(), true);
  } catch (error, stackTrace) {
    logger.w(
      'Could not check the export folder',
      error: error,
      stackTrace: stackTrace,
    );
    // Unknown is not gone. Keeping a folder that might be fine costs one error
    // message; dropping one that was fine costs the user a folder picker every
    // time the disk is briefly full.
    return true;
  }
}

class SettingsTransferScreen extends HookConsumerWidget {
  const SettingsTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final selected = useState<Set<SettingsTransferSection>>(
      SettingsTransferSection.values.toSet(),
    );
    final busy = useState(false);

    // Held across the folder picker rather than read after it: the picker is a
    // different activity, and this screen is not guaranteed to still be mounted
    // when it returns.
    final exportDirectory = ref.read(
      settingsExportDirectoryUriProvider.notifier,
    );

    Future<String> buildExport() {
      final info = ref.read(packageInfoProvider).value;

      return ref
          .read(settingsTransferServiceProvider.notifier)
          .export(
            sections: selected.value,
            appVersion: info == null
                ? null
                : '${info.version}+${info.buildNumber}',
          );
    }

    /// Resolves the folder exports are written to, asking for one only when
    /// there is nothing usable remembered.
    ///
    /// Re-checked rather than trusted: a grant survives a reboot but not the
    /// user revoking it, the volume being unmounted, or the folder being
    /// deleted.
    Future<Uri?> resolveTargetFolder() async {
      final remembered = ref.read(settingsExportDirectoryUriProvider);
      if (remembered != null && await safTargetIsWritable(remembered)) {
        return remembered;
      }

      final picked = await SafUtil().pickDirectory(
        writePermission: true,
        persistablePermission: true,
      );
      if (picked == null) return null;

      final uri = Uri.parse(picked.uri);
      exportDirectory.set(uri);

      return uri;
    }

    /// Lets the user move exports somewhere else without having to make one
    /// fail first.
    Future<void> chooseExportFolder() async {
      final picked = await SafUtil().pickDirectory(
        writePermission: true,
        persistablePermission: true,
      );
      if (picked == null) return;

      exportDirectory.set(Uri.parse(picked.uri));

      if (!context.mounted) return;
      showInfoMessage(context, 'Exports will be saved to ${picked.name}');
    }

    Future<void> exportToFile() async {
      busy.value = true;
      var targetForgotten = false;

      try {
        final text = await buildExport();

        final target = await resolveTargetFolder();
        if (target == null) return;

        final String written;
        try {
          written = await _publishExport(
            target: target,
            fileName: settingsExportFileName(DateTime.now()),
            bytes: Uint8List.fromList(utf8.encode(text)),
          );
        } catch (_) {
          // The grant outlives the folder: a target that was deleted, or lives
          // on a volume that is gone, still answers "yes, you may write here",
          // so `safTargetIsWritable` keeps handing back the same dead uri and
          // every export fails the same way with no picker in sight.
          //
          // But a full disk fails here too, and forgetting a perfectly good
          // folder over that is a worse answer than the error. So the target is
          // asked whether it still exists before it is given up on.
          if (!await _targetIsStillThere(target)) {
            exportDirectory.set(null);
            targetForgotten = true;
          }
          rethrow;
        }

        if (!context.mounted) return;
        // The name SAF actually created, which is not always the one asked
        // for — a second export in the same second gets a suffix.
        showInfoMessage(context, 'Saved as $written');
      } catch (error, stackTrace) {
        logger.e(
          'Failed to export settings to a file',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(
            context,
            targetForgotten
                ? 'The export folder is no longer there. Choose one again and '
                      'retry.'
                : 'Could not save the export: $error',
          );
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> exportToClipboard() async {
      busy.value = true;
      try {
        await Clipboard.setData(ClipboardData(text: await buildExport()));

        if (!context.mounted) return;
        showInfoMessage(context, 'Settings copied to the clipboard');
      } catch (error, stackTrace) {
        logger.e(
          'Failed to copy settings to the clipboard',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Could not copy the export: $error');
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> applyImport(String text) async {
      final service = ref.read(settingsTransferServiceProvider.notifier);

      final SettingsExportDocument document;
      try {
        document = decodeSettingsExport(text);
      } on SettingsExportFormatException catch (error) {
        if (context.mounted) showErrorMessage(context, error.message);
        return;
      }

      final available = service.availableSections(document);
      if (available.isEmpty) {
        if (context.mounted) {
          showErrorMessage(
            context,
            'This export holds nothing this version of WebLibre can apply.',
          );
        }
        return;
      }

      if (!context.mounted) return;
      final sections = await showSettingsImportDialog(
        context,
        document: document,
        available: available,
      );
      if (sections == null || sections.isEmpty) return;

      busy.value = true;
      try {
        await service.import(document: document, sections: sections);

        if (!context.mounted) return;
        showInfoMessage(context, 'Settings imported');
      } on SettingsImportPartialFailure catch (error, stackTrace) {
        logger.e(
          'Settings import applied only some sections',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          // Deliberately not "the import failed": part of it did not, and a
          // user told otherwise would go looking for settings that are already
          // replaced.
          showErrorMessage(context, error.message, persist: true);
        }
      } catch (error, stackTrace) {
        logger.e(
          'Failed to import settings',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(
            context,
            error is SettingsExportFormatException
                ? error.message
                : 'Could not import the settings: $error',
          );
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> importFromFile() async {
      busy.value = true;
      try {
        final picked = await SafUtil().pickFile(
          mimeTypes: const [_exportMimeType],
        );
        if (picked == null) return;

        final bytes = await SafStream().readFileBytes(picked.uri);
        await applyImport(utf8.decode(bytes));
      } on FormatException {
        // Reached when the picked file is not even text.
        if (context.mounted) {
          showErrorMessage(context, 'That file is not a settings export.');
        }
      } catch (error, stackTrace) {
        logger.e(
          'Failed to read a settings export',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Could not read the file: $error');
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> importFromClipboard() async {
      busy.value = true;
      try {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text == null || text.trim().isEmpty) {
          if (context.mounted) {
            showErrorMessage(context, 'The clipboard is empty.');
          }
          return;
        }

        await applyImport(text);
      } catch (error, stackTrace) {
        // The file path has always had this. Without it here, anything the
        // decoder does not turn into a SettingsExportFormatException — a
        // clipboard full of something else entirely — leaves the button
        // callback with an unhandled exception and the user with no message.
        logger.e(
          'Failed to import settings from the clipboard',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Could not read the clipboard: $error');
        }
      } finally {
        busy.value = false;
      }
    }

    return SettingsCustomScrollScaffold(
      title: 'Export & Import',
      actions: [
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: busy.value ? null : chooseExportFolder,
              child: const Text('Change export folder'),
            ),
          ],
          builder: (context, controller, child) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  'Move settings between profiles or devices, or attach them '
                  'to a bug report. This carries settings only — no tabs, '
                  'history, bookmarks or logins. For those, back up the whole '
                  'profile.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // Said out loud rather than discovered: these live outside the
                // settings repositories an export reads, so neither this nor
                // account sync carries them yet.
                Text(
                  'Web search preferences, home and new-tab layout, menu '
                  'order and pinned add-ons stay on this device. Saved '
                  'credentials are stripped out — but a token buried in a '
                  'custom URL cannot be told apart from the URL, so read the '
                  'file before you share it.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: theme.colorScheme.surfaceContainerHigh,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListTile(
                    leading: Icon(MdiIcons.fileExportOutline),
                    title: Text('Export'),
                    subtitle: Text(
                      'Write the sections you pick as a file you '
                      'can read',
                    ),
                  ),
                  for (final section in SettingsTransferSection.values)
                    CheckboxListTile(
                      value: selected.value.contains(section),
                      onChanged: busy.value
                          ? null
                          : (checked) {
                              selected.value = {
                                for (final candidate
                                    in SettingsTransferSection.values)
                                  if (candidate == section
                                      ? checked ?? false
                                      : selected.value.contains(candidate))
                                    candidate,
                              };
                            },
                      title: Text(section.title),
                      subtitle: Text(section.description),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: busy.value || selected.value.isEmpty
                                ? null
                                : exportToFile,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save file'),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: busy.value || selected.value.isEmpty
                                ? null
                                : exportToClipboard,
                            icon: const Icon(Icons.copy_outlined),
                            label: const Text('Copy'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Card(
              color: theme.colorScheme.surfaceContainerHigh,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListTile(
                    leading: Icon(MdiIcons.fileImportOutline),
                    title: Text('Import'),
                    subtitle: Text(
                      'You choose what to apply after the file is '
                      'read',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: busy.value ? null : importFromFile,
                            icon: const Icon(Icons.folder_open_outlined),
                            label: const Text('Open file'),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: busy.value ? null : importFromClipboard,
                            icon: const Icon(Icons.paste_outlined),
                            label: const Text('Paste'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
