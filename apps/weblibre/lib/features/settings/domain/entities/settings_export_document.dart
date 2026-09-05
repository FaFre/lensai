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

import 'package:convert/convert.dart';

/// Marks a file as a WebLibre settings export.
///
/// Checked before anything else on import: the alternative is decoding a
/// stranger's JSON far enough to notice it has no settings in it, and then
/// having to explain that in an error message.
const settingsExportFormat = 'weblibre.settings.export';

/// Version of the *envelope* — the wrapper below, not the documents inside it.
///
/// Each document carries its own `schema_version`, checked by the sync service
/// that owns it. This one moves only if the wrapper's own shape changes.
const settingsExportFormatVersion = 1;

/// `GeneralSettings` keys that hold a credential rather than a preference.
///
/// An export is written to be readable and pasted into bug reports, so these
/// never travel in one, in either direction: [redactCredentials] empties them
/// on the way out and [restoreRedactedValues] puts the device's own value back
/// on the way in. The consequence is deliberate — an export can never *set* a
/// credential on another device, and can never clear the one already there.
///
/// Keys are the JSON names of `GeneralSettings` fields (camelCase, as written
/// by `toJson`). Add to this set whenever a settings field starts holding a
/// secret; nothing detects one automatically.
const redactedGeneralSettingsKeys = <String>{'unshortenerToken'};

/// Timestamp in an export's file name. Local time, and non-UTC decoding, for
/// the reasons spelled out on `backupArchiveDateFormatter`.
final settingsExportDateFormatter = FixedDateTimeFormatter(
  'YYYY-MM-DD_hhmmss',
  isUtc: false,
);

const settingsExportExtension = '.json';

String settingsExportFileName(DateTime at) =>
    'weblibre-settings_${settingsExportDateFormatter.encode(at)}'
    '$settingsExportExtension';

/// The file is not a settings export this build can read.
class SettingsExportFormatException implements Exception {
  const SettingsExportFormatException(this.message);

  /// Shown to the user as-is, so it says what is wrong with *their* file.
  final String message;

  @override
  String toString() => message;
}

/// One document inside an export, in the form its owning service speaks.
class SettingsExportEntry {
  const SettingsExportEntry({
    required this.schemaVersion,
    required this.content,
  });

  final int schemaVersion;

  /// A JSON object for document kinds that serialize to JSON, a string for
  /// kinds that serialize to text (the Gecko prefs are a `user.js`). Kept as
  /// the decoded form so the export file stays readable instead of nesting an
  /// escaped JSON string inside JSON.
  final Object content;

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'content': content,
  };
}

/// A decoded export file.
class SettingsExportDocument {
  const SettingsExportDocument({
    required this.formatVersion,
    required this.documents,
    this.appVersion,
    this.exportedAt,
    this.redacted = const [],
  });

  final int formatVersion;

  /// Documents by their `SyncDocumentKind.value`, which is what ties a file
  /// written here to the services that know how to apply it. Kinds this build
  /// does not know are kept rather than dropped, so a round trip through an
  /// older version is at least visible in the file.
  final Map<String, SettingsExportEntry> documents;

  final String? appVersion;
  final DateTime? exportedAt;

  /// Dotted paths of the values left out of this file, for display. Import
  /// does not rely on it — [restoreRedactedValues] protects the whole credential
  /// set regardless of what the file claims about itself.
  final List<String> redacted;
}

/// Encodes an export, pretty-printed.
///
/// The indentation is the point: the first thing anyone does with one of these
/// is open it in a text editor to see what a bug reporter actually had set.
String encodeSettingsExport({
  required Map<String, SettingsExportEntry> documents,
  required DateTime exportedAt,
  List<String> redacted = const [],
  String? appVersion,
}) {
  return const JsonEncoder.withIndent('  ').convert({
    'format': settingsExportFormat,
    'format_version': settingsExportFormatVersion,
    if (appVersion != null) 'app_version': appVersion,
    'exported_at': exportedAt.toUtc().toIso8601String(),
    if (redacted.isNotEmpty) 'redacted': redacted,
    'documents': {
      for (final MapEntry(:key, :value) in documents.entries)
        key: value.toJson(),
    },
  });
}

SettingsExportDocument decodeSettingsExport(String text) {
  final Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException {
    throw const SettingsExportFormatException('This is not a JSON file.');
  }

  if (decoded is! Map<String, dynamic>) {
    throw const SettingsExportFormatException(
      'This is not a WebLibre settings export.',
    );
  }

  if (decoded['format'] != settingsExportFormat) {
    throw const SettingsExportFormatException(
      'This is not a WebLibre settings export.',
    );
  }

  final formatVersion = decoded['format_version'];
  if (formatVersion is! int) {
    throw const SettingsExportFormatException(
      'The export does not say which format version it is.',
    );
  }
  if (formatVersion > settingsExportFormatVersion) {
    throw SettingsExportFormatException(
      'This export was written by a newer version of WebLibre '
      '(format $formatVersion, this build reads up to '
      '$settingsExportFormatVersion). Update the app and try again.',
    );
  }

  final rawDocuments = decoded['documents'];
  if (rawDocuments is! Map<String, dynamic>) {
    throw const SettingsExportFormatException(
      'The export contains no settings.',
    );
  }

  final documents = <String, SettingsExportEntry>{};
  for (final MapEntry(:key, :value) in rawDocuments.entries) {
    if (value is! Map<String, dynamic>) {
      throw SettingsExportFormatException('The "$key" section is malformed.');
    }

    final schemaVersion = value['schema_version'];
    final Object? content = value['content'];
    if (schemaVersion is! int || content == null) {
      throw SettingsExportFormatException('The "$key" section is malformed.');
    }

    documents[key] = SettingsExportEntry(
      schemaVersion: schemaVersion,
      content: content,
    );
  }

  if (documents.isEmpty) {
    throw const SettingsExportFormatException(
      'The export contains no settings.',
    );
  }

  return SettingsExportDocument(
    formatVersion: formatVersion,
    documents: documents,
    appVersion: decoded['app_version'] as String?,
    exportedAt: DateTime.tryParse(decoded['exported_at'] as String? ?? ''),
    redacted:
        (decoded['redacted'] as List<dynamic>?)?.whereType<String>().toList() ??
        const [],
  );
}

/// Strips credentials out of a serialized `GeneralSettings` map.
///
/// Emptied whether or not they hold anything: an export taken on a device with
/// no token would otherwise carry a perfectly honest `""` that clears the token
/// on the device importing it — the same damage as leaking one, arrived at from
/// the other side.
///
/// Only values that were actually set are *reported* as redacted, though. A
/// file that announced a secret it never carried would be a lie a reader has to
/// go and check.
({Map<String, dynamic> values, List<String> keys}) redactCredentials(
  Map<String, dynamic> general,
) {
  final values = Map<String, dynamic>.of(general);
  final keys = <String>[];

  for (final key in redactedGeneralSettingsKeys) {
    if (!values.containsKey(key)) continue;

    final value = values[key];
    values[key] = null;

    if (value == null || value == '') continue;
    keys.add(key);
  }

  return (values: values, keys: keys);
}

/// Puts the device's own credentials back into imported settings.
///
/// Applied to every key in [redactedGeneralSettingsKeys] the file leaves
/// empty — null, absent, or a blank string — and not only to the ones the file
/// lists as redacted: the file's own account of itself may be missing or hand
/// edited, and the failure this prevents (an import silently wiping the token
/// the user typed in) stays invisible until the feature it belongs to stops
/// working.
///
/// A file that does carry a credential still wins, so a hand-written import can
/// set one deliberately.
Map<String, dynamic> restoreRedactedValues({
  required Map<String, dynamic> imported,
  required Map<String, dynamic> local,
}) {
  final values = Map<String, dynamic>.of(imported);

  for (final key in redactedGeneralSettingsKeys) {
    final value = values[key];
    if (value != null && value != '') continue;
    values[key] = local[key];
  }

  return values;
}
