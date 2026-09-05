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
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
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
    'Appearance, browsing, tabs, search, privacy, Tor and web engine settings',
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

/// Reads and writes settings as a plain file, next to — and independent of —
/// account sync.
///
/// Everything that knows how to turn settings into bytes and back already
/// exists as [SyncDocumentService] implementations; sync just happens to send
/// those bytes to a server. This does the same two calls with a file or the
/// clipboard on the other end, so the two paths cannot drift apart in what
/// they consider a setting.
///
/// The one thing it adds is redaction, which sync does not need: sync's
/// documents are encrypted with a key only the user's devices hold, while
/// these are written to be read.
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
          redacted.addAll(_redactEnvelope(envelope));
          content = envelope;
        case SettingsTransferSection.geckoPrefs:
          content = utf8.decode(plaintext);
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

  /// Strips credentials out of a settings envelope in place, returning the
  /// dotted paths of what was removed.
  List<String> _redactEnvelope(Map<String, dynamic> envelope) {
    final payload = envelope['payload'];
    if (payload is! Map<String, dynamic>) return const [];

    final general = payload['general'];
    if (general is! Map<String, dynamic>) return const [];

    final result = redactCredentials(general);
    payload['general'] = result.values;

    return result.keys.map((key) => 'general.$key').toList();
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
  Future<void> import({
    required SettingsExportDocument document,
    required Set<SettingsTransferSection> sections,
  }) async {
    for (final section in SettingsTransferSection.values) {
      if (!sections.contains(section)) continue;

      final entry = document.documents[section.kind.value];
      if (entry == null) continue;

      final List<int> plaintext;
      switch (section) {
        case SettingsTransferSection.settings:
          final content = entry.content;
          if (content is! Map<String, dynamic>) {
            throw SettingsExportFormatException(
              'The "${section.title}" section is malformed.',
            );
          }
          plaintext = utf8.encode(
            jsonEncode(await _withLocalCredentials(content)),
          );
        case SettingsTransferSection.geckoPrefs:
          final content = entry.content;
          if (content is! String) {
            throw SettingsExportFormatException(
              'The "${section.title}" section is malformed.',
            );
          }
          plaintext = utf8.encode(content);
      }

      await _documentService(section).applyRestored(plaintext);
    }
  }

  /// Returns [envelope] with this device's credentials filled back in.
  ///
  /// The envelope is applied by replacing the whole settings object, so a null
  /// left behind by [redactCredentials] would not be ignored — it would reset
  /// the field to its default and take the user's token with it.
  Future<Map<String, dynamic>> _withLocalCredentials(
    Map<String, dynamic> envelope,
  ) async {
    final payload = envelope['payload'];
    if (payload is! Map<String, dynamic>) return envelope;

    final general = payload['general'];
    if (general is! Map<String, dynamic>) return envelope;

    final local = await ref
        .read(generalSettingsRepositoryProvider.notifier)
        .fetchSettings();

    payload['general'] = restoreRedactedValues(
      imported: general,
      local: local.toJson(),
    );

    return envelope;
  }
}
