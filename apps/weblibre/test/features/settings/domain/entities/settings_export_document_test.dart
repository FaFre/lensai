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

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/account/domain/utils/user_js_serializer.dart';
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  group('encodeSettingsExport', () {
    test('round-trips JSON and text documents', () {
      final text = encodeSettingsExport(
        documents: {
          'weblibre_settings': const SettingsExportEntry(
            schemaVersion: 1,
            content: {
              'payload': {
                'general': {'themeMode': 'dark'},
              },
            },
          ),
          'gecko_user_js': const SettingsExportEntry(
            schemaVersion: 1,
            content: 'user_pref("alpha.pref", true);\n',
          ),
        },
        exportedAt: DateTime.utc(2026, 9, 4, 12, 30),
        redacted: const ['general.unshortenerToken'],
        appVersion: '1.2.3+45',
      );

      final document = decodeSettingsExport(text);

      expect(document.formatVersion, settingsExportFormatVersion);
      expect(document.appVersion, '1.2.3+45');
      expect(document.exportedAt, DateTime.utc(2026, 9, 4, 12, 30));
      expect(document.redacted, ['general.unshortenerToken']);
      expect(document.documents.keys, ['weblibre_settings', 'gecko_user_js']);
      expect(
        document.documents['gecko_user_js']!.content,
        'user_pref("alpha.pref", true);\n',
      );
      expect(
        (document.documents['weblibre_settings']!.content
            as Map<String, dynamic>)['payload'],
        {
          'general': {'themeMode': 'dark'},
        },
      );
    });

    test('stays readable rather than nesting encoded JSON', () {
      final text = encodeSettingsExport(
        documents: {
          'weblibre_settings': const SettingsExportEntry(
            schemaVersion: 1,
            content: {'schema_version': 1},
          ),
        },
        exportedAt: DateTime.utc(2026, 9, 4),
      );

      expect(text, contains('\n  "documents": {'));
      expect(text, isNot(contains(r'\"')));
    });

    test('omits the redaction list when nothing was left out', () {
      final text = encodeSettingsExport(
        documents: {
          'gecko_user_js': const SettingsExportEntry(
            schemaVersion: 1,
            content: '',
          ),
        },
        exportedAt: DateTime.utc(2026, 9, 4),
      );

      expect(jsonDecode(text), isNot(contains('redacted')));
    });
  });

  group('decodeSettingsExport', () {
    test('rejects text that is not JSON', () {
      expect(
        () => decodeSettingsExport('not json at all'),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('rejects JSON that is not an export', () {
      expect(
        () => decodeSettingsExport('{"hello": "world"}'),
        throwsA(
          isA<SettingsExportFormatException>().having(
            (error) => error.message,
            'message',
            contains('not a WebLibre settings export'),
          ),
        ),
      );
    });

    test('rejects a newer envelope instead of guessing at it', () {
      final text = jsonEncode({
        'format': settingsExportFormat,
        'format_version': settingsExportFormatVersion + 1,
        'documents': {
          'weblibre_settings': {'schema_version': 1, 'content': {}},
        },
      });

      expect(
        () => decodeSettingsExport(text),
        throwsA(
          isA<SettingsExportFormatException>().having(
            (error) => error.message,
            'message',
            contains('newer version'),
          ),
        ),
      );
    });

    test('rejects an export with no documents', () {
      final text = jsonEncode({
        'format': settingsExportFormat,
        'format_version': settingsExportFormatVersion,
        'documents': <String, dynamic>{},
      });

      expect(
        () => decodeSettingsExport(text),
        throwsA(
          isA<SettingsExportFormatException>().having(
            (error) => error.message,
            'message',
            contains('no settings'),
          ),
        ),
      );
    });

    test('names the malformed section', () {
      final text = jsonEncode({
        'format': settingsExportFormat,
        'format_version': settingsExportFormatVersion,
        'documents': {
          'weblibre_settings': {'content': <String, dynamic>{}},
        },
      });

      expect(
        () => decodeSettingsExport(text),
        throwsA(
          isA<SettingsExportFormatException>().having(
            (error) => error.message,
            'message',
            contains('"weblibre_settings"'),
          ),
        ),
      );
    });

    test('keeps document kinds it does not know', () {
      final text = jsonEncode({
        'format': settingsExportFormat,
        'format_version': settingsExportFormatVersion,
        'documents': {
          'some_future_kind': {'schema_version': 7, 'content': 'opaque'},
        },
      });

      expect(decodeSettingsExport(text).documents.keys, ['some_future_kind']);
    });
  });

  group('scrubGeneralSettings', () {
    test('nulls a credential that is set and reports it', () {
      final result = scrubGeneralSettings({
        'themeMode': 'dark',
        'unshortenerToken': 'super-secret',
      });

      expect(result.values['unshortenerToken'], isNull);
      expect(result.values['themeMode'], 'dark');
      expect(result.keys, ['unshortenerToken']);
    });

    test('does not claim a redaction for a credential that was never set', () {
      final result = scrubGeneralSettings({'unshortenerToken': ''});

      expect(result.keys, isEmpty);
    });

    test('empties a credential that was never set anyway', () {
      // An honest empty string still clears whatever the importing device had.
      final result = scrubGeneralSettings({'unshortenerToken': ''});

      expect(result.values['unshortenerToken'], isNull);
    });

    test("leaves the caller's map alone", () {
      final general = {'unshortenerToken': 'super-secret'};
      scrubGeneralSettings(general);

      expect(general['unshortenerToken'], 'super-secret');
    });

    test('redacts every key it declares', () {
      final result = scrubGeneralSettings({
        for (final key in deviceOwnedGeneralSettingsKeys) key: 'set',
      });

      expect(result.keys.toSet(), deviceOwnedGeneralSettingsKeys);
    });

    test('empties the wallpaper reference, which means nothing elsewhere', () {
      final result = scrubGeneralSettings({
        'homeWallpaperFile': 'a1b2c3.jpg',
        'homeWallpaperBlur': 4.0,
      });

      expect(result.values['homeWallpaperFile'], isNull);
      // The treatment travels; only the file it points at does not.
      expect(result.values['homeWallpaperBlur'], 4.0);
      expect(result.keys, ['homeWallpaperFile']);
    });
  });

  group('restoreDeviceOwnedValues', () {
    test('puts the local credential back where the file has none', () {
      final restored = restoreDeviceOwnedValues(
        imported: {'themeMode': 'dark', 'unshortenerToken': null},
        local: {'themeMode': 'light', 'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'local-token');
      expect(restored['themeMode'], 'dark');
    });

    test('protects the wallpaper the destination already has', () {
      // Losing this is not a wrong setting but a deleted file: the sweep in
      // WallpaperSweeper reclaims any image nothing references.
      final restored = restoreDeviceOwnedValues(
        imported: {'homeWallpaperFile': null},
        local: {'homeWallpaperFile': 'local.jpg'},
      );

      expect(restored['homeWallpaperFile'], 'local.jpg');
    });

    test('protects a credential the file omits entirely', () {
      final restored = restoreDeviceOwnedValues(
        imported: {'themeMode': 'dark'},
        local: {'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'local-token');
    });

    test('treats an empty credential in the file as no credential', () {
      final restored = restoreDeviceOwnedValues(
        imported: {'unshortenerToken': ''},
        local: {'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'local-token');
    });

    test('keeps a credential the file actually carries', () {
      final restored = restoreDeviceOwnedValues(
        imported: {'unshortenerToken': 'from-file'},
        local: {'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'from-file');
    });
  });

  group('deviceOwnedGeneralSettingsKeys', () {
    test('every key names a real setting', () {
      // A typo here redacts nothing and reports nothing — the export would just
      // quietly carry the secret it promises to strip.
      final general = GeneralSettings.withDefaults().toJson();

      for (final key in deviceOwnedGeneralSettingsKeys) {
        expect(
          general,
          contains(key),
          reason: '$key is not a GeneralSettings field',
        );
      }
    });
  });

  group('settingsExportFileName', () {
    test('names the file after the moment it was taken', () {
      expect(
        settingsExportFileName(DateTime(2026, 9, 4, 14, 30, 5)),
        'weblibre-settings_2026-09-04_143005.json',
      );
    });
  });

  group('decodeSettingsExport optional metadata', () {
    String exportWith(Map<String, dynamic> extra) => jsonEncode({
      'format': settingsExportFormat,
      'format_version': settingsExportFormatVersion,
      ...extra,
      'documents': {
        'gecko_user_js': {'schema_version': 1, 'content': ''},
      },
    });

    test('rejects a non-string app_version instead of crashing', () {
      // The metadata is only ever shown on the confirmation dialog, but an
      // unchecked cast aborts the whole import with a raw TypeError — which on
      // the clipboard path used to escape the button callback entirely.
      expect(
        () => decodeSettingsExport(exportWith({'app_version': 7})),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('rejects a non-string exported_at', () {
      expect(
        () => decodeSettingsExport(exportWith({'exported_at': 7})),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('rejects a redaction list that is not a list', () {
      expect(
        () => decodeSettingsExport(exportWith({'redacted': <String, int>{}})),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('survives an unparsable exported_at', () {
      final document = decodeSettingsExport(
        exportWith({'exported_at': 'sometime last tuesday'}),
      );

      expect(document.exportedAt, isNull);
    });
  });

  group('stripEmbeddedUrlCredentials', () {
    test('removes the authority half a URL must not carry', () {
      final result = stripEmbeddedUrlCredentials({
        'engine': {'dohProviderUrl': 'https://user:pw@doh.example/dns-query'},
      });

      final engine = (result.value! as Map)['engine'] as Map;
      expect(engine['dohProviderUrl'], 'https://doh.example/dns-query');
      expect(result.paths, ['engine.dohProviderUrl']);
    });

    test('reaches into lists, which is where custom resolvers live', () {
      final result = stripEmbeddedUrlCredentials({
        'engine': {
          'customDohProviders': [
            {'url': 'https://a:b@one.example/dns-query'},
            {'url': 'https://two.example/dns-query'},
          ],
        },
      });

      expect(result.paths, ['engine.customDohProviders[0].url']);
    });

    test('leaves ordinary values alone', () {
      final result = stripEmbeddedUrlCredentials({
        'general': {
          'urlCleanerCatalogUrl': 'https://example.org/rules.json',
          'maxSearchHistoryEntries': 50,
          'themeMode': 'dark',
        },
      });

      expect(result.paths, isEmpty);
      final general = (result.value! as Map)['general'] as Map;
      expect(general['urlCleanerCatalogUrl'], 'https://example.org/rules.json');
    });
  });

  group('scrubGeckoPrefs', () {
    test('drops a credential preference', () {
      final result = scrubGeckoPrefs(
        '$_snapshotHeader'
        'user_pref("network.trr.credentials", "user:pw");\n'
        'user_pref("network.trr.mode", 3);\n',
        schemaVersion: 1,
      );

      expect(result.names, ['network.trr.credentials']);
      expect(result.content, isNot(contains('user:pw')));
      expect(result.content, contains('network.trr.mode'));
    });

    test('keeps non-string preferences whose names merely sound alarming', () {
      // A boolean named "...token..." is a policy switch. Dropping it would
      // quietly reset behaviour the user chose, and it cannot be a secret.
      final result = scrubGeckoPrefs(
        '$_snapshotHeader'
        'user_pref("privacy.antitracking.tokens.enabled", true);\n',
        schemaVersion: 1,
      );

      expect(result.names, isEmpty);
    });

    test('returns the text untouched when there is nothing to remove', () {
      const text =
          '$_snapshotHeader'
          'user_pref("network.trr.mode", 3);\n';

      expect(scrubGeckoPrefs(text, schemaVersion: 1).content, same(text));
    });
  });

  group('requireGeckoPrefsDocument', () {
    test('refuses text that is not a snapshot', () {
      // parseUserJs answers "no preferences" for this, and applying that answer
      // resets every preference the device has set.
      expect(
        () => requireGeckoPrefsDocument('garbage'),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('refuses an empty body', () {
      expect(
        () => requireGeckoPrefsDocument(''),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('accepts a snapshot that genuinely holds no preferences', () {
      // Distinct from the above: this really was exported from a profile with
      // nothing set, and replacing with it is a legitimate thing to ask for.
      final parsed = requireGeckoPrefsDocument(_snapshotHeader);

      expect(parsed.prefs, isEmpty);
      expect(parsed.schemaVersion, 1);
    });
  });

  group('mergeLocalGeckoPrefs', () {
    test('puts this device credential back so the import cannot reset it', () {
      final result = mergeLocalGeckoPrefs(
        userJs:
            '$_snapshotHeader'
            'user_pref("network.trr.mode", 3);\n',
        localPrefs: {'network.trr.credentials': 'local:secret'},
        schemaVersion: 1,
      );

      expect(result.names, ['network.trr.credentials']);
      expect(result.content, contains('local:secret'));
    });

    test('leaves a credential the file carries deliberately', () {
      final result = mergeLocalGeckoPrefs(
        userJs:
            '$_snapshotHeader'
            'user_pref("network.trr.credentials", "from:file");\n',
        localPrefs: {'network.trr.credentials': 'local:secret'},
        schemaVersion: 1,
      );

      expect(result.names, isEmpty);
      expect(result.content, contains('from:file'));
    });
  });

  group('profile-local references', () {
    test('always come from the device, even against an older export', () {
      // Exports written before these keys were scrubbed carry a real file name.
      // A non-empty value must not win here the way a credential does.
      final restored = restoreDeviceOwnedValues(
        imported: {'homeWallpaperFile': 'from-another-profile.jpg'},
        local: {'homeWallpaperFile': 'mine.jpg'},
      );

      expect(restored['homeWallpaperFile'], 'mine.jpg');
    });

    test('stay empty when the device has none', () {
      final restored = restoreDeviceOwnedValues(
        imported: {'homeWallpaperFile': 'from-another-profile.jpg'},
        local: <String, dynamic>{},
      );

      expect(restored['homeWallpaperFile'], isNull);
    });
  });

  group('stripEmbeddedUrlCredentials reach', () {
    test('walks into a setting stored as encoded JSON', () {
      // uBlock's filter lists and the add-on collection are JSON strings inside
      // the settings map, so a plain walk stops at an opaque blob.
      final encoded = jsonEncode({
        'externalFilterLists': [
          {'url': 'https://user:pw@lists.example/list.txt'},
        ],
      });

      final result = stripEmbeddedUrlCredentials({
        'engine': {'ublockFilterListSettings': encoded},
      });

      final engine = (result.value! as Map)['engine'] as Map;
      expect(engine['ublockFilterListSettings'], isNot(contains('user:pw')));
      expect(engine['ublockFilterListSettings'], contains('lists.example'));
      expect(result.paths, [
        'engine.ublockFilterListSettings.externalFilterLists[0].url',
      ]);
    });

    test('leaves an untouched JSON blob byte-identical', () {
      const encoded = '{"externalFilterLists":[{"url":"https://ok.example"}]}';

      final result = stripEmbeddedUrlCredentials({'engine': encoded});

      expect((result.value! as Map)['engine'], same(encoded));
    });

    test('blanks a secret carried as a query parameter', () {
      final result = stripEmbeddedUrlCredentials(
        'https://doh.example/dns-query?api_key=SECRET&ttl=60',
      );

      expect(result.value, isNot(contains('SECRET')));
      expect(result.value, contains('ttl=60'));
      expect(result.paths, ['']);
    });

    test('is not fooled by a string that merely looks JSON-ish', () {
      const value = '{not json at all';

      expect(stripEmbeddedUrlCredentials(value).value, same(value));
    });
  });

  group('restoreScrubbedUrls', () {
    test('gives back the credentials the export took out', () {
      const local = 'https://user:pw@doh.example/dns-query';

      final restored = restoreScrubbedUrls(
        imported: {
          'engine': {'dohProviderUrl': 'https://doh.example/dns-query'},
        },
        local: {
          'engine': {'dohProviderUrl': local},
        },
      );

      final engine = (restored.value! as Map)['engine'] as Map;
      expect(engine['dohProviderUrl'], local);
      expect(restored.paths, ['engine.dohProviderUrl']);
    });

    test('lets a genuinely different URL through', () {
      final restored = restoreScrubbedUrls(
        imported: {
          'engine': {'dohProviderUrl': 'https://other.example/dns-query'},
        },
        local: {
          'engine': {'dohProviderUrl': 'https://user:pw@doh.example/dns-query'},
        },
      );

      final engine = (restored.value! as Map)['engine'] as Map;
      expect(engine['dohProviderUrl'], 'https://other.example/dns-query');
      expect(restored.paths, isEmpty);
    });

    test('does not invent a local value where there is none', () {
      final restored = restoreScrubbedUrls(
        imported: {'engine': <String, dynamic>{}},
        local: null,
      );

      expect((restored.value! as Map)['engine'], isEmpty);
    });
  });

  group('requireGeckoPrefsDocument strictness', () {
    test('refuses a snapshot header followed by prose', () {
      // parseUserJs would answer "no preferences", and applying that answer
      // resets every preference this device has set.
      expect(
        () => requireGeckoPrefsDocument('${_snapshotHeader}garbage\n'),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('refuses a statement the parser would silently skip', () {
      expect(
        () => requireGeckoPrefsDocument(
          '$_snapshotHeader'
          'user_pref("network.trr.mode", );\n',
        ),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('refuses a body with statements but no marker', () {
      expect(
        () => requireGeckoPrefsDocument(
          '// schema_version=1\n'
          'user_pref("network.trr.mode", 3);\n',
        ),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('accepts what the serializer actually writes', () {
      final text = serializeUserJs(
        userPrefs: <String, Object>{
          'network.trr.mode': 3,
          'text.pref': 'quote " and \\ backslash',
        },
        schemaVersion: 1,
      );

      expect(requireGeckoPrefsDocument(text).prefs, hasLength(2));
    });
  });

  group('gecko preference URLs', () {
    test('strips a password out of a URL-valued preference', () {
      final result = scrubGeckoPrefs(
        '$_snapshotHeader'
        'user_pref("network.proxy.autoconfig_url", '
        '"https://user:pw@proxy.example/wpad.dat");\n',
        schemaVersion: 1,
      );

      expect(result.names, ['network.proxy.autoconfig_url']);
      expect(result.content, isNot(contains('user:pw')));
      // Kept rather than dropped: a missing preference would be reset.
      expect(result.content, contains('proxy.example/wpad.dat'));
    });

    test('gives the password back on the way in', () {
      const local = 'https://user:pw@proxy.example/wpad.dat';

      final result = mergeLocalGeckoPrefs(
        userJs:
            '$_snapshotHeader'
            'user_pref("network.proxy.autoconfig_url", '
            '"https://proxy.example/wpad.dat");\n',
        localPrefs: const {'network.proxy.autoconfig_url': local},
        schemaVersion: 1,
      );

      expect(result.names, ['network.proxy.autoconfig_url']);
      expect(result.content, contains('user:pw'));
    });
  });

  group('duplicate query parameters', () {
    test('blanks every occurrence, not the one the map kept', () {
      // `?token=SECRET&token=` collapses to an empty value in `queryParameters`,
      // which reads as "nothing to redact" while the secret is still in there.
      final result = stripEmbeddedUrlCredentials(
        'https://doh.example/q?token=SECRET&token=',
      );

      expect(result.value, isNot(contains('SECRET')));
      expect(result.paths, ['']);
    });

    test('keeps unrelated duplicates that a collapsed map would drop', () {
      final result = stripEmbeddedUrlCredentials(
        'https://doh.example/q?token=SECRET&tag=a&tag=b',
      );

      final cleaned = Uri.parse(result.value! as String);
      expect(cleaned.queryParametersAll['tag'], ['a', 'b']);
    });
  });

  group('gecko validation matches the parser', () {
    test('refuses an escape the parser will not accept', () {
      // Validates against a pattern, drops on parse, and the preference it
      // named is reset on the destination.
      expect(
        () => requireGeckoPrefsDocument(
          '$_snapshotHeader'
          r'user_pref("text.pref", "bad\q");'
          '\n',
        ),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('refuses an integer the parser will not accept', () {
      expect(
        () => requireGeckoPrefsDocument(
          '$_snapshotHeader'
          'user_pref("int.pref", 2147483648);\n',
        ),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });
  });

  group('secrets in a URL path', () {
    test('are not detected, and the code says so', () {
      // Pins a known limitation rather than a guarantee: a token in a path is
      // indistinguishable from a path. The UI tells the user to read the file,
      // and this test exists so nobody later mistakes silence for coverage.
      final result = stripEmbeddedUrlCredentials(
        'https://lists.example/SECRETTOKEN/list.txt',
      );

      expect(result.paths, isEmpty);
    });
  });

  group('restoreScrubbedUrls identity matching', () {
    List<Map<String, String>> providers(List<String> urls) => [
      for (final url in urls) {'url': url},
    ];

    test('follows a reordered list instead of its positions', () {
      final local = providers([
        'https://a:1@one.example/dns-query',
        'https://b:2@two.example/dns-query',
      ]);

      final restored = restoreScrubbedUrls(
        imported: providers([
          'https://two.example/dns-query',
          'https://one.example/dns-query',
        ]),
        local: local,
      );

      final result = restored.value! as List;
      expect((result[0] as Map)['url'], 'https://b:2@two.example/dns-query');
      expect((result[1] as Map)['url'], 'https://a:1@one.example/dns-query');
    });

    test('refuses to guess when two entries scrub to the same URL', () {
      // Restoring the wrong one would hand one entry's password to another.
      final restored = restoreScrubbedUrls(
        imported: providers(['https://one.example/dns-query']),
        local: providers([
          'https://a:1@one.example/dns-query',
          'https://b:2@one.example/dns-query',
        ]),
      );

      final result = restored.value! as List;
      expect((result[0] as Map)['url'], 'https://one.example/dns-query');
      expect(restored.paths, isEmpty);
    });

    test('restores inside encoded JSON despite an unrelated change', () {
      final local = jsonEncode({
        'externalFilterLists': [
          {'url': 'https://user:pw@lists.example/list.txt'},
        ],
      });
      final imported = jsonEncode({
        'externalFilterLists': [
          {'url': 'https://lists.example/list.txt'},
        ],
        'enabled': true,
      });

      final restored = restoreScrubbedUrls(imported: imported, local: local);

      expect(restored.value, contains('user:pw'));
      expect(restored.value, contains('"enabled":true'));
    });
  });

  group('gecko statements must stand alone', () {
    test('refuses a good statement sharing a line with a broken one', () {
      // Parses to exactly one preference, which is what makes it dangerous:
      // victim.pref is silently dropped and then reset on the destination.
      expect(
        () => requireGeckoPrefsDocument(
          '$_snapshotHeader'
          'user_pref("safe.pref", true); user_pref("victim.pref", );\n',
        ),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('refuses trailing junk after a good statement', () {
      expect(
        () => requireGeckoPrefsDocument(
          '$_snapshotHeader'
          'user_pref("safe.pref", true); rm -rf /\n',
        ),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('still accepts two statements on their own lines', () {
      final parsed = requireGeckoPrefsDocument(
        '$_snapshotHeader'
        'user_pref("one.pref", true);\n'
        'user_pref("two.pref", 2);\n',
      );

      expect(parsed.prefs, hasLength(2));
    });
  });

  group('query representation survives scrubbing', () {
    test('keeps an empty flag empty rather than bare', () {
      final result = stripEmbeddedUrlCredentials(
        'https://doh.example/q?token=SECRET&flag=',
      );

      expect(result.value, endsWith('flag='));
    });

    test('keeps interleaved duplicates in their original order', () {
      final result = stripEmbeddedUrlCredentials(
        'https://doh.example/q?a=1&token=SECRET&b=2&a=3',
      );

      expect(result.value, 'https://doh.example/q?a=1&token=&b=2&a=3');
    });

    test('leaves a bare flag alone', () {
      const url = 'https://doh.example/q?token';

      expect(stripEmbeddedUrlCredentials(url).paths, isEmpty);
    });
  });

  group('restoreScrubbedUrls one-to-one', () {
    test('never hands one local credential to two imported entries', () {
      // Two imported records that scrub to the same URL are indistinguishable,
      // so neither is restored — the alternative is spending one entry's
      // password on both, or guessing which of them it belonged to.
      final restored = restoreScrubbedUrls(
        imported: [
          {'url': 'https://one.example/dns-query'},
          {'url': 'https://one.example/dns-query'},
        ],
        local: [
          {'url': 'https://a:1@one.example/dns-query'},
          {'url': 'https://one.example/dns-query'},
        ],
      );

      final urls = [
        for (final entry in restored.value! as List) (entry as Map)['url'],
      ];

      expect(urls, everyElement('https://one.example/dns-query'));
      expect(restored.paths, isEmpty);
    });

    test('restores each of two distinct resolvers from its own entry', () {
      final restored = restoreScrubbedUrls(
        imported: [
          {'url': 'https://one.example/dns-query'},
          {'url': 'https://two.example/dns-query'},
        ],
        local: [
          {'url': 'https://a:1@one.example/dns-query'},
          {'url': 'https://b:2@two.example/dns-query'},
        ],
      );

      final urls = [
        for (final entry in restored.value! as List) (entry as Map)['url'],
      ];

      expect(urls, [
        'https://a:1@one.example/dns-query',
        'https://b:2@two.example/dns-query',
      ]);
    });

    test('restores a resolver the user renamed', () {
      // Identity is the URL, not the whole record: an edited label is still the
      // same resolver and must not cost the password.
      final restored = restoreScrubbedUrls(
        imported: [
          {'url': 'https://one.example/dns-query', 'name': 'Renamed'},
        ],
        local: [
          {'url': 'https://a:1@one.example/dns-query', 'name': 'Old name'},
        ],
      );

      final result = (restored.value! as List).single as Map;
      expect(result['url'], 'https://a:1@one.example/dns-query');
      expect(result['name'], 'Renamed');
    });
  });
}

/// The two comment lines every WebLibre prefs snapshot opens with, and the only
/// thing separating one from a file that is not a snapshot at all.
const _snapshotHeader =
    '// WebLibre Gecko prefs snapshot\n'
    '// schema_version=1\n';
