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

  group('redactCredentials', () {
    test('nulls a credential that is set and reports it', () {
      final result = redactCredentials({
        'themeMode': 'dark',
        'unshortenerToken': 'super-secret',
      });

      expect(result.values['unshortenerToken'], isNull);
      expect(result.values['themeMode'], 'dark');
      expect(result.keys, ['unshortenerToken']);
    });

    test('does not claim a redaction for a credential that was never set', () {
      final result = redactCredentials({'unshortenerToken': ''});

      expect(result.keys, isEmpty);
    });

    test('empties a credential that was never set anyway', () {
      // An honest empty string still clears whatever the importing device had.
      final result = redactCredentials({'unshortenerToken': ''});

      expect(result.values['unshortenerToken'], isNull);
    });

    test("leaves the caller's map alone", () {
      final general = {'unshortenerToken': 'super-secret'};
      redactCredentials(general);

      expect(general['unshortenerToken'], 'super-secret');
    });

    test('redacts every key it declares', () {
      final result = redactCredentials({
        for (final key in redactedGeneralSettingsKeys) key: 'set',
      });

      expect(result.keys.toSet(), redactedGeneralSettingsKeys);
    });
  });

  group('restoreRedactedValues', () {
    test('puts the local credential back where the file has none', () {
      final restored = restoreRedactedValues(
        imported: {'themeMode': 'dark', 'unshortenerToken': null},
        local: {'themeMode': 'light', 'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'local-token');
      expect(restored['themeMode'], 'dark');
    });

    test('protects a credential the file omits entirely', () {
      final restored = restoreRedactedValues(
        imported: {'themeMode': 'dark'},
        local: {'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'local-token');
    });

    test('treats an empty credential in the file as no credential', () {
      final restored = restoreRedactedValues(
        imported: {'unshortenerToken': ''},
        local: {'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'local-token');
    });

    test('keeps a credential the file actually carries', () {
      final restored = restoreRedactedValues(
        imported: {'unshortenerToken': 'from-file'},
        local: {'unshortenerToken': 'local-token'},
      );

      expect(restored['unshortenerToken'], 'from-file');
    });
  });

  group('redactedGeneralSettingsKeys', () {
    test('every key names a real setting', () {
      // A typo here redacts nothing and reports nothing — the export would just
      // quietly carry the secret it promises to strip.
      final general = GeneralSettings.withDefaults().toJson();

      for (final key in redactedGeneralSettingsKeys) {
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
}
