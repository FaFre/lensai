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

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/settings/domain/services/settings_transfer_service.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

void main() {
  // The settings document reaches three repositories, and one of them talks to
  // a platform channel on the way — without a binding the whole export fails
  // before any of it is written.
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );

    container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWith((ref) => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  SettingsTransferService service() =>
      container.read(settingsTransferServiceProvider.notifier);

  GeneralSettingsRepository generalSettings() =>
      container.read(generalSettingsRepositoryProvider.notifier);

  EngineSettingsRepository engineSettings() =>
      container.read(engineSettingsRepositoryProvider.notifier);

  const settingsOnly = {SettingsTransferSection.settings};

  group('export', () {
    test('carries settings and leaves credentials behind', () async {
      await generalSettings().updateSettings(
        (current) => current.copyWith
            .disableAnimations(true)
            .copyWith
            .unshortenerToken('super-secret'),
      );

      final text = await service().export(sections: settingsOnly);

      expect(text, isNot(contains('super-secret')));
      expect(text, contains('"disableAnimations": true'));

      final document = decodeSettingsExport(text);
      expect(document.redacted, ['general.unshortenerToken']);
      expect(service().availableSections(document), {
        SettingsTransferSection.settings,
      });
    });
  });

  group('import', () {
    test('replaces settings with the ones in the file', () async {
      await generalSettings().updateSettings(
        (current) => current.copyWith.disableAnimations(true),
      );
      final exported = await service().export(sections: settingsOnly);

      await generalSettings().updateSettings(
        (current) => current.copyWith.disableAnimations(false),
      );

      await service().import(
        document: decodeSettingsExport(exported),
        sections: settingsOnly,
      );

      expect((await generalSettings().fetchSettings()).disableAnimations, true);
    });

    // The failure this guards is silent: the export writes the token as null,
    // and settings are applied by replacing the whole object, so an import
    // would hand the user back a default-empty token they never cleared.
    test('keeps the credentials already on this device', () async {
      final exported = await service().export(sections: settingsOnly);

      await generalSettings().updateSettings(
        (current) => current.copyWith.unshortenerToken('local-token'),
      );

      await service().import(
        document: decodeSettingsExport(exported),
        sections: settingsOnly,
      );

      expect(
        (await generalSettings().fetchSettings()).unshortenerToken,
        'local-token',
      );
    });

    test('leaves sections the caller did not pick alone', () async {
      await generalSettings().updateSettings(
        (current) => current.copyWith.disableAnimations(true),
      );
      final exported = await service().export(sections: settingsOnly);

      await generalSettings().updateSettings(
        (current) => current.copyWith.disableAnimations(false),
      );

      await service().import(
        document: decodeSettingsExport(exported),
        sections: const {},
      );

      expect(
        (await generalSettings().fetchSettings()).disableAnimations,
        false,
      );
    });

    test('refuses a section from a newer build before applying anything', () {
      final document = decodeSettingsExport(
        encodeSettingsExport(
          documents: {
            'weblibre_settings': const SettingsExportEntry(
              schemaVersion: 99,
              content: {'payload': <String, dynamic>{}},
            ),
          },
          exportedAt: DateTime.utc(2026, 9, 7),
        ),
      );

      expect(
        () => service().import(document: document, sections: settingsOnly),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });

    test('refuses a section whose content is the wrong shape', () {
      final document = decodeSettingsExport(
        encodeSettingsExport(
          documents: {
            'weblibre_settings': const SettingsExportEntry(
              schemaVersion: 1,
              content: 'not an envelope',
            ),
          },
          exportedAt: DateTime.utc(2026, 9, 4),
        ),
      );

      expect(
        () => service().import(document: document, sections: settingsOnly),
        throwsA(isA<SettingsExportFormatException>()),
      );
    });
  });

  group('export scrubbing', () {
    test('strips a password out of a DoH resolver URL', () async {
      await engineSettings().updateSettings(
        (current) => current.copyWith.customDohProviders([
          CustomDohProvider(url: 'https://user:pw@doh.example/dns-query'),
        ]),
      );

      final text = await service().export(sections: settingsOnly);

      expect(text, isNot(contains('user:pw')));
      // The resolver itself still travels — only the half that must not.
      expect(text, contains('https://doh.example/dns-query'));
      expect(
        decodeSettingsExport(text).redacted,
        contains('engine.customDohProviders[0].url'),
      );
    });

    test('empties the wallpaper reference', () async {
      await generalSettings().updateSettings(
        (current) => current.copyWith.homeWallpaperFile('mine.jpg'),
      );

      final text = await service().export(sections: settingsOnly);

      expect(text, isNot(contains('mine.jpg')));
      expect(
        decodeSettingsExport(text).redacted,
        contains('general.homeWallpaperFile'),
      );
    });
  });

  group('import protection', () {
    // The damage here is a deleted file, not a wrong setting: WallpaperSweeper
    // reclaims any image that nothing references, so adopting a foreign file
    // name costs the destination its own wallpaper on the next start.
    test('keeps the wallpaper the destination already has', () async {
      final exported = await service().export(sections: settingsOnly);

      await generalSettings().updateSettings(
        (current) => current.copyWith.homeWallpaperFile('local.jpg'),
      );

      await service().import(
        document: decodeSettingsExport(exported),
        sections: settingsOnly,
      );

      expect(
        (await generalSettings().fetchSettings()).homeWallpaperFile,
        'local.jpg',
      );
    });

    // Export strips the password; without the matching restore on the way in,
    // re-importing your own file hands back a resolver you can no longer
    // authenticate against — while the UI claims this device keeps its own.
    test('gives back the resolver password on a round trip', () async {
      const url = 'https://user:pw@doh.example/dns-query';

      await engineSettings().updateSettings(
        (current) =>
            current.copyWith.customDohProviders([CustomDohProvider(url: url)]),
      );

      final exported = await service().export(sections: settingsOnly);
      expect(exported, isNot(contains('user:pw')));

      await service().import(
        document: decodeSettingsExport(exported),
        sections: settingsOnly,
      );

      final settings = await engineSettings().fetchSettings();
      expect(settings.customDohProviders.single.url, url);
    });

    test('takes a resolver that really did change', () async {
      await engineSettings().updateSettings(
        (current) => current.copyWith.customDohProviders([
          CustomDohProvider(url: 'https://user:pw@doh.example/dns-query'),
        ]),
      );

      final exported = await service().export(sections: settingsOnly);

      await engineSettings().updateSettings(
        (current) => current.copyWith.customDohProviders([
          CustomDohProvider(url: 'https://elsewhere.example/dns-query'),
        ]),
      );

      await service().import(
        document: decodeSettingsExport(exported),
        sections: settingsOnly,
      );

      final settings = await engineSettings().fetchSettings();
      expect(
        settings.customDohProviders.single.url,
        'https://doh.example/dns-query',
      );
    });

    // Every section of the payload is nullable, so a file with only engine
    // settings is a valid one — and it still has URLs whose secrets need
    // putting back on the way in.
    test(
      'restores engine URLs in a payload that has no general half',
      () async {
        const url = 'https://user:pw@doh.example/dns-query';

        await engineSettings().updateSettings(
          (current) => current.copyWith.customDohProviders([
            CustomDohProvider(url: url),
          ]),
        );

        final exported = decodeSettingsExport(
          await service().export(sections: settingsOnly),
        );
        final envelope = Map<String, dynamic>.of(
          exported.documents['weblibre_settings']!.content
              as Map<String, dynamic>,
        );
        final payload = Map<String, dynamic>.of(
          envelope['payload'] as Map<String, dynamic>,
        )..remove('general');
        envelope['payload'] = payload;

        final document = decodeSettingsExport(
          encodeSettingsExport(
            documents: {
              'weblibre_settings': SettingsExportEntry(
                schemaVersion: 1,
                content: envelope,
              ),
            },
            exportedAt: DateTime.utc(2026, 9, 7),
          ),
        );

        await service().import(document: document, sections: settingsOnly);

        final settings = await engineSettings().fetchSettings();
        expect(settings.customDohProviders.single.url, url);
      },
    );

    test('applies nothing when a later section cannot be read', () async {
      await generalSettings().updateSettings(
        (current) => current.copyWith.disableAnimations(true),
      );
      final exported = decodeSettingsExport(
        await service().export(sections: settingsOnly),
      );

      // Same file, with an unreadable prefs section bolted on: the settings
      // section is fine and would have been applied first.
      final document = decodeSettingsExport(
        encodeSettingsExport(
          documents: {
            'weblibre_settings': SettingsExportEntry(
              schemaVersion: 1,
              content: exported.documents['weblibre_settings']!.content,
            ),
            'gecko_user_js': const SettingsExportEntry(
              schemaVersion: 1,
              content: 'garbage',
            ),
          },
          exportedAt: DateTime.utc(2026, 9, 7),
        ),
      );

      await generalSettings().updateSettings(
        (current) => current.copyWith.disableAnimations(false),
      );

      await expectLater(
        service().import(
          document: document,
          sections: SettingsTransferSection.values.toSet(),
        ),
        throwsA(isA<SettingsExportFormatException>()),
      );

      expect(
        (await generalSettings().fetchSettings()).disableAnimations,
        false,
      );
    });
  });
}
