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
import 'package:weblibre/features/account/domain/utils/user_js_parser.dart';
import 'package:weblibre/features/account/domain/utils/user_js_serializer.dart';
import 'package:weblibre/utils/uri_input_parser.dart';

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
/// never travel in one, in either direction: [scrubGeneralSettings] empties
/// them on the way out and [restoreDeviceOwnedValues] puts the device's own
/// value back on the way in. The consequence is deliberate — an export can
/// never *set* a credential on another device, and can never clear the one
/// already there.
///
/// Keys are the JSON names of `GeneralSettings` fields (camelCase, as written
/// by `toJson`). Add to this set whenever a settings field starts holding a
/// secret; nothing detects one automatically. Credentials that arrive inside a
/// URL are caught separately by [stripEmbeddedUrlCredentials].
const redactedGeneralSettingsKeys = <String>{'unshortenerToken'};

/// `GeneralSettings` keys naming a file that exists only in this profile.
///
/// These are not secrets — they are references that mean nothing anywhere else.
/// A wallpaper is stored as a file name inside the profile's wallpaper
/// directory and the export carries no image, so importing one elsewhere would
/// point the destination at a file it does not have *and* leave its own image
/// unreferenced, which the startup sweep in `WallpaperSweeper` then deletes.
/// Handled exactly like a credential — emptied on the way out, the device's own
/// value restored on the way in — for a different reason.
const profileLocalGeneralSettingsKeys = <String>{'homeWallpaperFile'};

/// Every `GeneralSettings` key whose value belongs to the device rather than to
/// the export.
const deviceOwnedGeneralSettingsKeys = <String>{
  ...redactedGeneralSettingsKeys,
  ...profileLocalGeneralSettingsKeys,
};

/// Gecko preferences that are credentials outright, whatever they hold.
const sensitiveGeckoPrefNames = <String>{'network.trr.credentials'};

/// Name fragments that make a *string-valued* Gecko preference a secret.
///
/// Only string values are matched: a boolean or an integer named `…auth…` is a
/// policy switch, and dropping those would quietly reset behaviour the user
/// chose. A false positive here costs one preference that has to be set again
/// on the destination; a false negative puts a secret in a bug report.
const sensitiveGeckoPrefNameFragments = <String>[
  'credential',
  'password',
  'passwd',
  'secret',
  'token',
  'apikey',
  'api_key',
  'private_key',
];

bool isSensitiveGeckoPref(String name, Object value) {
  if (sensitiveGeckoPrefNames.contains(name)) return true;
  if (value is! String) return false;

  final lower = name.toLowerCase();
  return sensitiveGeckoPrefNameFragments.any(lower.contains);
}

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
  /// does not rely on it — [restoreDeviceOwnedValues] protects the whole
  /// device-owned set regardless of what the file claims about itself.
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
    // The optional metadata is checked rather than cast. It is only ever shown
    // on the confirmation dialog, so a file carrying `"app_version": 7` has
    // nothing wrong with its settings — but an unchecked cast would abort the
    // import with a raw `TypeError` instead of anything a reader can act on.
    appVersion: _optionalString(decoded, 'app_version'),
    exportedAt: DateTime.tryParse(
      _optionalString(decoded, 'exported_at') ?? '',
    ),
    redacted: _optionalStringList(decoded, 'redacted'),
  );
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw SettingsExportFormatException('The export\'s "$key" is malformed.');
  }
  return value;
}

List<String> _optionalStringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return const [];
  if (value is! List) {
    throw SettingsExportFormatException('The export\'s "$key" is malformed.');
  }
  return value.whereType<String>().toList();
}

/// Empties the values a `GeneralSettings` map must not carry out of a profile —
/// credentials and profile-local file references alike.
///
/// Emptied whether or not they hold anything: an export taken on a device with
/// no token would otherwise carry a perfectly honest `""` that clears the token
/// on the device importing it — the same damage as leaking one, arrived at from
/// the other side.
///
/// Only values that were actually set are *reported*, though. A file that
/// announced a secret it never carried would be a lie a reader has to go and
/// check.
({Map<String, dynamic> values, List<String> keys}) scrubGeneralSettings(
  Map<String, dynamic> general,
) {
  final values = Map<String, dynamic>.of(general);
  final keys = <String>[];

  for (final key in deviceOwnedGeneralSettingsKeys) {
    if (!values.containsKey(key)) continue;

    final value = values[key];
    values[key] = null;

    if (value == null || value == '') continue;
    keys.add(key);
  }

  return (values: values, keys: keys);
}

/// Puts the device's own credentials and local references back into imported
/// settings.
///
/// Credentials come from the device whenever the file leaves them empty — null,
/// absent, or blank — and not only when the file lists them as redacted: its
/// own account of itself may be missing or hand edited, and the failure this
/// prevents (an import silently wiping the token the user typed in) stays
/// invisible until the feature it belongs to stops working. A file that does
/// carry one still wins, so a hand-written import can set it.
///
/// Profile-local references come from the device *always*, with no way for a
/// file to override them. See the loop below for why.
Map<String, dynamic> restoreDeviceOwnedValues({
  required Map<String, dynamic> imported,
  required Map<String, dynamic> local,
}) {
  final values = Map<String, dynamic>.of(imported);

  // A profile-local reference is never negotiable. Exports written before these
  // keys were scrubbed still carry a real file name, and a file name from
  // another profile is not a setting worth honouring — it points at an image
  // this device does not have, and leaves the one it does have unreferenced for
  // the sweep to delete.
  for (final key in profileLocalGeneralSettingsKeys) {
    values[key] = local[key];
  }

  // A credential the file carries deliberately still wins, so a hand-written
  // import can set one.
  for (final key in redactedGeneralSettingsKeys) {
    final value = values[key];
    if (value != null && value != '') continue;
    values[key] = local[key];
  }

  return values;
}

/// Query parameter names whose values are secrets.
///
/// The same fragments that make a preference name suspicious, matched against
/// a URL's query keys: `?token=…`, `?api_key=…`. A secret buried in a URL's
/// *path* is indistinguishable from a path and is not caught — say so rather
/// than pretend otherwise.
const sensitiveQueryParameterFragments = sensitiveGeckoPrefNameFragments;

/// Removes the parts of [node] that a URL must not carry out of the device,
/// returning the cleaned structure and the dotted paths that were changed.
///
/// Three things get taken out of anything URL-shaped: the `user:password@` in
/// the authority, and the value of any query parameter whose name reads like a
/// secret. The third is reach — some settings are stored as a JSON *string*
/// (uBlock's filter lists, the add-on collection), so a plain walk stops at an
/// opaque blob with filter-list URLs inside it. Those are decoded, walked, and
/// re-encoded, and left byte-identical when there was nothing to change.
///
/// The named credential keys cover the fields that are *only* a secret. This
/// covers the ones that merely can be: a DoH resolver, a sync server override
/// or a filter-list URL is an ordinary setting worth carrying, right up until
/// someone puts a password in it. The rest of the URL survives, so the setting
/// still arrives — without the half that must not.
({Object? value, List<String> paths}) stripEmbeddedUrlCredentials(
  Object? node, {
  String path = '',
}) {
  if (node is Map) {
    final result = <String, dynamic>{};
    final paths = <String>[];

    for (final entry in node.entries) {
      final key = entry.key.toString();
      final scrubbed = stripEmbeddedUrlCredentials(
        entry.value,
        path: path.isEmpty ? key : '$path.$key',
      );
      result[key] = scrubbed.value;
      paths.addAll(scrubbed.paths);
    }

    return (value: result, paths: paths);
  }

  if (node is List) {
    final result = <dynamic>[];
    final paths = <String>[];

    for (var index = 0; index < node.length; index++) {
      final scrubbed = stripEmbeddedUrlCredentials(
        node[index],
        path: '$path[$index]',
      );
      result.add(scrubbed.value);
      paths.addAll(scrubbed.paths);
    }

    return (value: result, paths: paths);
  }

  if (node is String) {
    final nested = _scrubJsonString(node, path);
    if (nested != null) return nested;

    final cleaned = _urlWithoutSecrets(node);
    if (cleaned == null) return (value: node, paths: const []);

    return (value: cleaned, paths: [path]);
  }

  return (value: node, paths: const []);
}

/// Walks a setting that is stored as encoded JSON, or null if [value] is not
/// one.
({Object? value, List<String> paths})? _scrubJsonString(
  String value,
  String path,
) {
  final trimmed = value.trimLeft();
  if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return null;

  final Object? decoded;
  try {
    decoded = jsonDecode(value);
  } on FormatException {
    return null;
  }
  if (decoded is! Map && decoded is! List) return null;

  final scrubbed = stripEmbeddedUrlCredentials(decoded, path: path);
  // Re-encoding an untouched blob would rewrite its formatting for nothing.
  if (scrubbed.paths.isEmpty) return (value: value, paths: const []);

  return (value: jsonEncode(scrubbed.value), paths: scrubbed.paths);
}

/// The query string with secret-looking values blanked, or null if there were
/// none.
///
/// Edited pair by pair over the raw text rather than through a parsed map. A
/// map keyed by name collapses repeats — `?token=SECRET&token=` reads as an
/// empty value, and the secret survives — and writing one back reorders
/// interleaved duplicates and turns `flag=` into `flag`. Endpoints exist that
/// tell those apart, and none of that is this function's business to change.
String? _queryWithoutSecrets(String query) {
  final pairs = query.split('&');
  var changed = false;

  for (var index = 0; index < pairs.length; index++) {
    final pair = pairs[index];

    final separator = pair.indexOf('=');
    if (separator < 0) continue;

    final rawName = pair.substring(0, separator);
    if (pair.length == separator + 1) continue;

    final name = Uri.decodeQueryComponent(rawName).toLowerCase();
    if (!sensitiveQueryParameterFragments.any(name.contains)) continue;

    pairs[index] = '$rawName=';
    changed = true;
  }

  return changed ? pairs.join('&') : null;
}

/// The URL without its `user:password@` and without any secret-looking query
/// values, or null if there was nothing to take out.
String? _urlWithoutSecrets(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasAuthority) return null;

  // The userInfo half is what `redactUriCredentials` already does for bookmarks
  // and log lines; the query half below is this feature's own.
  var cleaned = redactUriCredentials(uri);

  if (uri.hasQuery) {
    final query = _queryWithoutSecrets(uri.query);
    if (query != null) {
      cleaned = cleaned.replace(query: query);
    }
  }

  if (cleaned == uri) return null;

  return cleaned.toString();
}

/// Puts back the URL secrets this device already had.
///
/// Export takes them out; without this, exporting and re-importing on the same
/// device would hand back the stripped URL and quietly break the resolver it
/// belongs to. The test is equality after scrubbing: if the value in the file
/// is exactly what this device's value looks like with its secrets removed,
/// they are the same setting and the device's copy is the complete one. A file
/// carrying a *different* URL is a real change and wins.
({Object? value, List<String> paths}) restoreScrubbedUrls({
  required Object? imported,
  required Object? local,
}) {
  if (imported is Map) {
    final result = <String, dynamic>{};
    final paths = <String>[];

    for (final entry in imported.entries) {
      final key = entry.key.toString();
      final restored = restoreScrubbedUrls(
        imported: entry.value,
        local: local is Map ? local[key] : null,
      );
      result[key] = restored.value;
      paths.addAll(restored.paths.map((p) => p.isEmpty ? key : '$key.$p'));
    }

    return (value: result, paths: paths);
  }

  if (imported is List) {
    final result = <dynamic>[];
    final paths = <String>[];

    // Candidates are consumed as they are used, so one local entry can never
    // hand its credentials to two imported ones.
    final unclaimed = local is List ? List<Object?>.of(local) : <Object?>[];

    for (var index = 0; index < imported.length; index++) {
      final counterpart = _claimLocalCounterpart(imported[index], unclaimed);

      final restored = restoreScrubbedUrls(
        imported: imported[index],
        local: counterpart,
      );
      result.add(restored.value);
      paths.addAll(restored.paths.map((p) => '[$index]$p'));
    }

    return (value: result, paths: paths);
  }

  if (imported is String) {
    // A setting stored as encoded JSON is restored field by field, not as one
    // string: comparing the blobs whole means any unrelated edit anywhere in
    // them — one filter list added — blocks the restoration of every credential
    // inside.
    final nested = _restoreJsonString(imported, local);
    if (nested != null) return nested;

    if (local is String && imported != local && _scrubsTo(local, imported)) {
      return (value: local, paths: ['']);
    }
  }

  return (value: imported, paths: const []);
}

/// Takes the element of [unclaimed] that [imported] came from, or null if that
/// cannot be said for certain.
///
/// Matched on the URLs a record carries, not on the record whole: a resolver
/// the user renamed is still the same resolver, and comparing every field would
/// refuse to give it its password back over an edited label. Custom resolvers
/// are also a list the user can reorder, so position says nothing either.
///
/// Ambiguity is answered with null — no restoration is a setting the user has
/// to retype, the wrong restoration is a credential sent somewhere it was never
/// meant to go — and a claimed candidate is removed from [unclaimed] so it
/// cannot be spent twice.
Object? _claimLocalCounterpart(Object? imported, List<Object?> unclaimed) {
  final wanted = _urlIdentity(imported);
  if (wanted.isEmpty) return null;

  var matchIndex = -1;

  for (var index = 0; index < unclaimed.length; index++) {
    if (!_sameIdentity(_urlIdentity(unclaimed[index]), wanted)) continue;

    if (matchIndex >= 0) return null;
    matchIndex = index;
  }

  if (matchIndex < 0) return null;

  return unclaimed.removeAt(matchIndex);
}

/// The scrubbed URLs inside [node], in the order they are reached.
///
/// This is a record's identity for restoration purposes: the part of it that
/// can carry a credential, with the credential taken off. An imported record is
/// already scrubbed, and scrubbing is idempotent, so both sides can be measured
/// the same way.
List<String> _urlIdentity(Object? node) {
  final scrubbed = stripEmbeddedUrlCredentials(node).value;
  final urls = <String>[];

  void walk(Object? value) {
    if (value is Map) {
      for (final entry in value.entries) {
        walk(entry.value);
      }
      return;
    }

    if (value is List) {
      for (final element in value) {
        walk(element);
      }
      return;
    }

    if (value is String) {
      final decoded = _decodeJsonStructure(value);
      if (decoded != null) {
        walk(decoded);
        return;
      }

      final uri = Uri.tryParse(value);
      if (uri != null && uri.hasAuthority) urls.add(value);
    }
  }

  walk(scrubbed);

  return urls;
}

bool _sameIdentity(List<String> a, List<String> b) {
  if (a.length != b.length) return false;

  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) return false;
  }

  return true;
}

/// Restores inside two settings that are both encoded JSON, or null if they
/// are not.
({Object? value, List<String> paths})? _restoreJsonString(
  String imported,
  Object? local,
) {
  if (local is! String) return null;

  final decodedImported = _decodeJsonStructure(imported);
  if (decodedImported == null) return null;

  final decodedLocal = _decodeJsonStructure(local);
  if (decodedLocal == null) return null;

  final restored = restoreScrubbedUrls(
    imported: decodedImported,
    local: decodedLocal,
  );
  if (restored.paths.isEmpty) return (value: imported, paths: const []);

  return (value: jsonEncode(restored.value), paths: restored.paths);
}

Object? _decodeJsonStructure(String value) {
  final trimmed = value.trimLeft();
  if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return null;

  try {
    final decoded = jsonDecode(value);
    return decoded is Map || decoded is List ? decoded : null;
  } on FormatException {
    return null;
  }
}

/// Whether [local] is [imported] with its secrets taken out.
bool _scrubsTo(String local, String imported) {
  final scrubbed = stripEmbeddedUrlCredentials(local);
  return scrubbed.paths.isNotEmpty && scrubbed.value == imported;
}

/// The first line of every snapshot WebLibre writes, and the thing that makes
/// one recognisable as such.
const geckoPrefsSnapshotMarker = '// WebLibre Gecko prefs snapshot';

/// Reads a Gecko preferences document, refusing anything that is not one.
///
/// Strict on purpose, because `parseUserJs` is not: it skips whatever it does
/// not understand and answers with the preferences it did manage to read.
/// Applying that answer *resets* everything missing from it, since
/// `PrefsSyncService` reads absence as "the exporting device had this at its
/// default" — so a file with three mangled lines does not import three fewer
/// preferences, it clears them, and a body of prose imports as "reset
/// everything". Neither is a thing a person asked for.
///
/// So every line has to be one WebLibre itself would have written: the marker,
/// a comment, or a well-formed statement. An empty snapshot still passes —
/// exported from a profile with nothing set, replacing with it is a legitimate
/// thing to ask for — but an empty *parse* of a non-empty file does not.
UserJsParseResult requireGeckoPrefsDocument(String content, {String? label}) {
  final name = label ?? 'Gecko preferences';

  var sawMarker = false;
  final statements = <String>[];

  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trim();

    if (line.isEmpty) continue;
    if (line == geckoPrefsSnapshotMarker) {
      sawMarker = true;
      continue;
    }
    if (line.startsWith('//') || line.startsWith('#')) continue;

    // Asked of the writer, not of a pattern that approximates it. A regex
    // describing "a well-formed statement" is a second opinion, and where the
    // two disagree — `"bad\q"`, an integer past 2^31 — the line validates, the
    // parser drops it, and the preference it named is reset on the
    // destination.
    //
    // Nor is "parses to one preference" enough, because the parser skips what
    // it cannot read and keeps going:
    //
    //     user_pref("safe.pref", true); user_pref("victim.pref", );
    //
    // is one preference by that measure, with a second one quietly on its way
    // to being reset. So the line has to be *exactly* what `serializeUserJs`
    // would have written for the preference it parses to — nothing before it,
    // nothing after it, escaped the same way.
    final statement = parseUserJs(line).prefs;
    if (statement.length == 1) {
      final entry = statement.entries.single;
      if (line == _canonicalStatement(entry.key, entry.value)) {
        statements.add(entry.key);
        continue;
      }
    }

    final shown = line.length > 60 ? '${line.substring(0, 60)}…' : line;
    throw SettingsExportFormatException(
      'The $name section has a line WebLibre cannot read: "$shown". '
      'Importing it would reset preferences rather than restore them.',
    );
  }

  if (!sawMarker) {
    throw SettingsExportFormatException(
      'The $name section is not a WebLibre preferences snapshot.',
    );
  }

  final parsed = parseUserJs(content);

  if (parsed.schemaVersion == null) {
    throw SettingsExportFormatException(
      'The $name section does not say which schema version it is.',
    );
  }

  // The lines validate one at a time; this is the whole document agreeing with
  // the sum of them. A statement that parses alone but is swallowed in context
  // would otherwise still reach the reset path.
  for (final prefName in statements) {
    if (parsed.prefs.containsKey(prefName)) continue;

    throw SettingsExportFormatException(
      'The $name section holds a preference WebLibre could not read back: '
      '"$prefName".',
    );
  }

  return parsed;
}

/// The one line `serializeUserJs` writes for [name] = [value], or null if it
/// would not write one at all.
///
/// Borrowed from the writer rather than reimplemented, so the escaping cannot
/// drift away from it.
String? _canonicalStatement(String name, Object value) {
  final written = serializeUserJs(
    userPrefs: {name: value},
    schemaVersion: 1,
    exportedAt: '',
  );

  final statements = const LineSplitter()
      .convert(written)
      .where((line) => line.startsWith('user_pref('))
      .toList();

  return statements.length == 1 ? statements.single : null;
}

/// Takes the secrets out of a `user.js` snapshot on its way out.
///
/// Two kinds. A preference that *is* a credential is dropped outright. A
/// preference that merely *holds* a URL keeps its place with the secret parts
/// of that URL removed — checking names alone would miss it, since the name of
/// a proxy or update URL says nothing about what somebody put in it.
///
/// Dropped names are restored from the device on import rather than left
/// absent, which is what [mergeLocalGeckoPrefs] is for.
({String content, List<String> names}) scrubGeckoPrefs(
  String userJs, {
  required int schemaVersion,
}) {
  final parsed = parseUserJs(userJs);

  final kept = <String, Object>{};
  final scrubbed = <String>[];

  for (final entry in parsed.prefs.entries) {
    if (isSensitiveGeckoPref(entry.key, entry.value)) {
      scrubbed.add(entry.key);
      continue;
    }

    final value = entry.value;
    if (value is String) {
      final cleaned = stripEmbeddedUrlCredentials(value);
      if (cleaned.paths.isNotEmpty) {
        kept[entry.key] = cleaned.value! as String;
        scrubbed.add(entry.key);
        continue;
      }
    }

    kept[entry.key] = value;
  }

  // Untouched text when there was nothing to remove, so an export is byte-for-
  // byte what the prefs service produced.
  if (scrubbed.isEmpty) return (content: userJs, names: const []);

  return (
    content: serializeUserJs(
      userPrefs: kept,
      schemaVersion: parsed.schemaVersion ?? schemaVersion,
      exportedAt: parsed.exportedAt,
    ),
    names: scrubbed,
  );
}

/// Puts this device's preference secrets back into an imported snapshot.
///
/// Both halves of what [scrubGeckoPrefs] took out. A credential preference the
/// file does not carry is re-injected, because leaving it absent would not
/// merely fail to carry it — it would *reset* it, absence meaning "was at
/// default". A URL that arrives as this device's own value with its secrets
/// stripped is replaced by the complete local one, so a round trip through an
/// export does not quietly de-authenticate a resolver.
({String content, List<String> names}) mergeLocalGeckoPrefs({
  required String userJs,
  required Map<String, Object> localPrefs,
  required int schemaVersion,
}) {
  final parsed = parseUserJs(userJs);

  final merged = Map<String, Object>.of(parsed.prefs);
  final restored = <String>[];

  for (final entry in localPrefs.entries) {
    final imported = merged[entry.key];

    if (isSensitiveGeckoPref(entry.key, entry.value)) {
      // A file that carries one wins, the same way a hand-written credential in
      // the settings section does.
      if (imported != null) continue;

      merged[entry.key] = entry.value;
      restored.add(entry.key);
      continue;
    }

    if (imported is! String || entry.value is! String) continue;
    if (imported == entry.value) continue;

    final scrubbedLocal = stripEmbeddedUrlCredentials(entry.value);
    if (scrubbedLocal.paths.isEmpty) continue;
    if (scrubbedLocal.value != imported) continue;

    merged[entry.key] = entry.value;
    restored.add(entry.key);
  }

  if (restored.isEmpty) return (content: userJs, names: const []);

  return (
    content: serializeUserJs(
      userPrefs: merged,
      schemaVersion: parsed.schemaVersion ?? schemaVersion,
      exportedAt: parsed.exportedAt,
    ),
    names: restored,
  );
}
