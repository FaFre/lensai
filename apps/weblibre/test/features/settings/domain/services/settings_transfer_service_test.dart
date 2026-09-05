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
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
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
}
