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

class SettingsTransferScreen extends HookConsumerWidget {
  const SettingsTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final selected = useState<Set<SettingsTransferSection>>(
      SettingsTransferSection.values.toSet(),
    );
    final busy = useState(false);

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
      ref.read(settingsExportDirectoryUriProvider.notifier).set(uri);

      return uri;
    }

    Future<void> exportToFile() async {
      busy.value = true;
      try {
        final text = await buildExport();

        final target = await resolveTargetFolder();
        if (target == null) return;

        final written = await SafStream().writeFileBytes(
          target.toString(),
          settingsExportFileName(DateTime.now()),
          _exportMimeType,
          Uint8List.fromList(utf8.encode(text)),
        );

        if (!context.mounted) return;
        // The name SAF actually created, which is not always the one asked
        // for — a second export in the same second gets a suffix.
        showInfoMessage(context, 'Saved as ${written.fileName}');
      } catch (error, stackTrace) {
        logger.e(
          'Failed to export settings to a file',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Could not save the export: $error');
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
      } catch (error, stackTrace) {
        logger.e(
          'Failed to import settings',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Could not import the settings: $error');
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
      } finally {
        busy.value = false;
      }
    }

    return SettingsCustomScrollScaffold(
      title: 'Export & Import',
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Move settings between profiles or devices, or attach them to a '
              'bug report. This carries settings only — no tabs, history, '
              'bookmarks or logins. For those, back up the whole profile.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
                    subtitle: Text('Write the sections you pick as a file you '
                        'can read'),
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
                    subtitle: Text('You choose what to apply after the file is '
                        'read'),
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
