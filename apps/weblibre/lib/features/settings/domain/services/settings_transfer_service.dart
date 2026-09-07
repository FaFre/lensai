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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
import 'package:weblibre/features/account/domain/services/prefs_js_reader.dart';
import 'package:weblibre/features/account/domain/services/prefs_sync_service.dart';
import 'package:weblibre/features/account/domain/services/settings_sync_service.dart';
import 'package:weblibre/features/account/domain/services/sync_document_service.dart';
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'settings_transfer_service.g.dart';

/// What a settings file can carry, one entry per [SyncDocumentKind] that has a
/// [SyncDocumentService] behind it.
///
/// These are the categories the user picks from. They are deliberately the
/// same units account sync moves rather than a finer grouping of individual
/// settings: `GeneralSettings` alone has ninety-odd fields, and a hand-kept map
/// from field to category is a list that silently goes stale — a new setting
/// left out of it would just quietly stop being exported.
enum SettingsTransferSection {
  settings(
    SyncDocumentKind.weblibreSettings,
    'App settings',
    'Appearance, browsing, tabs, privacy, Tor and web engine settings',
  ),
  geckoPrefs(
    SyncDocumentKind.geckoUserJs,
    'Gecko preferences',
    'Advanced engine preferences you changed by hand',
  );

  const SettingsTransferSection(this.kind, this.title, this.description);

  final SyncDocumentKind kind;
  final String title;
  final String description;

  static SettingsTransferSection? forKindValue(String value) {
    for (final section in SettingsTransferSection.values) {
      if (section.kind.value == value) return section;
    }
    return null;
  }
}

/// An import stopped part way through.
///
/// Not an error the caller can treat as "nothing happened": the profile is in a
/// state neither the file nor the device asked for, and the only honest thing
/// to do is say so.
///
/// Raised for the failing section itself, not only for earlier ones that
/// succeeded — a section is not atomic either. Applying app settings runs
/// separate general, engine and Tor writes, and applying preferences resets
/// before it replaces, so a failure inside one leaves that section half done
/// with nothing to roll it back. Preflighting everything first (see
/// [SettingsTransferService.import]) is what keeps this rare; it cannot make it
/// impossible.
class SettingsImportPartialFailure implements Exception {
  const SettingsImportPartialFailure({
    required this.applied,
    required this.failed,
    required this.cause,
  });

  final List<SettingsTransferSection> applied;
  final SettingsTransferSection failed;
  final Object cause;

  String get message {
    final done = applied.map((section) => section.title).join(', ');
    final start = done.isEmpty ? '' : '$done was imported, but ';

    return '$start${failed.title} failed part way through and may be '
        'half-applied: $cause';
  }

  @override
  String toString() => message;
}

/// Reads and writes settings as a plain file, next to — and independent of —
/// account sync.
///
/// Everything that knows how to turn settings into bytes and back already
/// exists as [SyncDocumentService] implementations; sync just happens to send
/// those bytes to a server. This does the same two calls with a file or the
/// clipboard on the other end, so the two paths cannot drift apart in what
/// they consider a setting.
///
/// What it adds on top is everything that follows from the file being
/// *readable* and portable, which sync's encrypted per-user blobs are not:
/// credentials and profile-local references are scrubbed on the way out and
/// taken from the device on the way in, and a file that did not come from here
/// is refused before any of it is applied.
///
/// A caveat the UI has to keep saying out loud: these are the same units sync
/// moves, so settings persisted outside those repositories — search language
/// and region, home and new-tab module order, menu layout — are not carried by
/// either path. Adding them belongs in `SettingsSyncPayload`, so that sync and
/// this gain them together.
@Riverpod(keepAlive: true)
class SettingsTransferService extends _$SettingsTransferService {
  @override
  void build() {}

  SyncDocumentService _documentService(SettingsTransferSection section) {
    return switch (section) {
      SettingsTransferSection.settings => ref.read(
        settingsSyncServiceProvider.notifier,
      ),
      SettingsTransferSection.geckoPrefs => ref.read(
        prefsSyncServiceProvider.notifier,
      ),
    };
  }

  /// Serializes [sections] into an export file's text.
  Future<String> export({
    required Set<SettingsTransferSection> sections,
    String? appVersion,
    DateTime? at,
  }) async {
    final documents = <String, SettingsExportEntry>{};
    final redacted = <String>[];

    // Ordered by the enum rather than by the caller's set, so two exports of
    // the same selection are the same file.
    for (final section in SettingsTransferSection.values) {
      if (!sections.contains(section)) continue;

      final service = _documentService(section);
      final plaintext = await service.serializeCurrent();

      final Object content;
      switch (section) {
        case SettingsTransferSection.settings:
          final envelope =
              jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
          redacted.addAll(_scrubEnvelope(envelope));
          content = envelope;
        case SettingsTransferSection.geckoPrefs:
          final scrubbed = scrubGeckoPrefs(
            utf8.decode(plaintext),
            schemaVersion: service.schemaVersion,
          );
          redacted.addAll(scrubbed.names.map((name) => 'prefs.$name'));
          content = scrubbed.content;
      }

      documents[section.kind.value] = SettingsExportEntry(
        schemaVersion: service.schemaVersion,
        content: content,
      );
    }

    return encodeSettingsExport(
      documents: documents,
      exportedAt: at ?? DateTime.now(),
      redacted: redacted,
      appVersion: appVersion,
    );
  }

  /// Takes the things that must not leave the device out of a settings
  /// envelope, in place, returning the dotted paths of what went.
  ///
  /// Two passes, because there are two ways a value can be one of those things.
  /// The named keys are fields that are *only* a credential or a local file
  /// reference. The URL pass then walks everything — engine and Tor settings
  /// included, not just `general` — because any setting holding a URL can hold
  /// a password in its authority, and a DoH resolver is worth carrying with
  /// that half removed rather than not carrying at all.
  List<String> _scrubEnvelope(Map<String, dynamic> envelope) {
    final payload = envelope['payload'];
    if (payload is! Map<String, dynamic>) return const [];

    final paths = <String>[];

    final general = payload['general'];
    if (general is Map<String, dynamic>) {
      final result = scrubGeneralSettings(general);
      payload['general'] = result.values;
      paths.addAll(result.keys.map((key) => 'general.$key'));
    }

    final scrubbed = stripEmbeddedUrlCredentials(payload);
    envelope['payload'] = scrubbed.value;
    paths.addAll(scrubbed.paths);

    return paths;
  }

  /// Which of [document]'s sections this build can actually apply.
  ///
  /// A file may name kinds this version does not know; they are listed in the
  /// file but cannot be selected.
  Set<SettingsTransferSection> availableSections(
    SettingsExportDocument document,
  ) {
    return {
      for (final key in document.documents.keys)
        if (SettingsTransferSection.forKindValue(key) case final section?)
          section,
    };
  }

  /// Applies [sections] of [document] to this profile.
  ///
  /// Each section replaces its settings wholesale, exactly as restoring a sync
  /// snapshot does — this is not a merge. Sections absent from the file, or not
  /// selected, are left alone.
  ///
  /// Every selected section is decoded and validated *before* any of them is
  /// applied. Two sections land in two subsystems and no transaction spans
  /// them, so the one thing that can be guaranteed is that a file which was
  /// never going to work is refused while the profile is still untouched —
  /// rather than the app settings being replaced and then the preferences
  /// turning out to be unreadable. If an apply still fails after an earlier one
  /// succeeded, that is reported as [SettingsImportPartialFailure] instead of a
  /// plain error, because "the import failed" would be untrue.
  Future<void> import({
    required SettingsExportDocument document,
    required Set<SettingsTransferSection> sections,
  }) async {
    final prepared = <(SettingsTransferSection, List<int>)>[];

    for (final section in SettingsTransferSection.values) {
      if (!sections.contains(section)) continue;

      final entry = document.documents[section.kind.value];
      if (entry == null) continue;

      prepared.add((section, await _prepare(section, entry)));
    }

    final applied = <SettingsTransferSection>[];

    for (final (section, plaintext) in prepared) {
      try {
        await _documentService(section).applyRestored(plaintext);
      } catch (error) {
        // Never rethrown as a plain failure, even when this is the first
        // section: by the time a service throws it may already have written
        // part of what it was given, and "the import failed" would send the
        // user looking for settings that are in fact already replaced.
        throw SettingsImportPartialFailure(
          applied: applied,
          failed: section,
          cause: error,
        );
      }

      applied.add(section);
    }
  }

  /// Turns one section of a file into the bytes its service will apply, or
  /// throws [SettingsExportFormatException] if the file cannot supply them.
  Future<List<int>> _prepare(
    SettingsTransferSection section,
    SettingsExportEntry entry,
  ) async {
    switch (section) {
      case SettingsTransferSection.settings:
        final content = entry.content;
        if (content is! Map<String, dynamic>) {
          throw SettingsExportFormatException(
            'The "${section.title}" section is malformed.',
          );
        }

        _requireReadableSchema(section, entry);

        return utf8.encode(jsonEncode(await _withDeviceOwnedValues(content)));

      case SettingsTransferSection.geckoPrefs:
        final content = entry.content;
        if (content is! String) {
          throw SettingsExportFormatException(
            'The "${section.title}" section is malformed.',
          );
        }

        // Refused before it is applied rather than parsed leniently: an
        // unrecognised body parses as "no preferences at all", and applying
        // that resets every preference this device has set.
        final parsed = requireGeckoPrefsDocument(
          content,
          label: '"${section.title}"',
        );

        final schemaVersion = _requireReadableSchema(
          section,
          entry,
          documentVersion: parsed.schemaVersion,
        );

        final merged = mergeLocalGeckoPrefs(
          userJs: content,
          localPrefs: await _localGeckoPrefs(),
          schemaVersion: schemaVersion,
        );

        return utf8.encode(merged.content);
    }
  }

  /// Refuses a section this build is too old to read, and answers with the
  /// version it does speak.
  ///
  /// Checked here as well as inside the services, because there it happens at
  /// apply time: a too-new preferences section would otherwise be found out
  /// only after the app settings had already been replaced. Content shape is
  /// validated before this runs — a malformed section should be named as
  /// malformed, and the lookup below is what first touches the profile.
  int _requireReadableSchema(
    SettingsTransferSection section,
    SettingsExportEntry entry, {
    int? documentVersion,
  }) {
    final supported = _documentService(section).schemaVersion;

    final claimed = documentVersion == null
        ? entry.schemaVersion
        : (entry.schemaVersion > documentVersion
              ? entry.schemaVersion
              : documentVersion);

    if (claimed > supported) {
      throw SettingsExportFormatException(
        'The "${section.title}" section was written by a newer version of '
        'WebLibre (schema $claimed, this build reads up to $supported).',
      );
    }

    return supported;
  }

  Future<Map<String, Object>> _localGeckoPrefs() {
    return PrefsJsReader(
      selectedProfileDir: filesystem.selectedProfileDir,
    ).readUserPrefs();
  }

  /// Returns [envelope] with this device's credentials and local file
  /// references filled back in.
  ///
  /// The envelope is applied by replacing the whole settings object, so a null
  /// left behind by [scrubGeneralSettings] would not be ignored — it would
  /// reset the field to its default and take the user's token, or their
  /// wallpaper, with it.
  Future<Map<String, dynamic>> _withDeviceOwnedValues(
    Map<String, dynamic> envelope,
  ) async {
    final payload = envelope['payload'];
    if (payload is! Map<String, dynamic>) return envelope;

    // Two independent restorations, and the second must not be reachable only
    // through the first. Every section of the payload is nullable — an engine-
    // only file is a perfectly good one — and while such a file has no general
    // settings to take credentials from, it certainly has engine URLs whose
    // secrets need putting back.
    final general = payload['general'];
    if (general is Map<String, dynamic>) {
      final local = await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .fetchSettings();

      payload['general'] = restoreDeviceOwnedValues(
        imported: general,
        local: local.toJson(),
      );
    }

    // The named keys above are the values the export never carried. This is the
    // other half: values it carried with their secrets taken out, anywhere in
    // the payload — re-importing your own export must not hand you back a
    // resolver you can no longer authenticate against.
    envelope['payload'] = restoreScrubbedUrls(
      imported: payload,
      local: await _localSettingsPayload(),
    ).value;

    return envelope;
  }

  /// This profile's settings in the same shape an export's payload has, for
  /// comparing scrubbed values against.
  Future<Map<String, dynamic>> _localSettingsPayload() async {
    final plaintext = await ref
        .read(settingsSyncServiceProvider.notifier)
        .serializeCurrent();

    final envelope = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
    final payload = envelope['payload'];

    return payload is Map<String, dynamic> ? payload : const {};
  }
}
