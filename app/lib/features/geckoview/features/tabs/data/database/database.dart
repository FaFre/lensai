import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Color, IconData;
import 'package:lensai/data/database/converters/color.dart';
import 'package:lensai/data/database/converters/icon_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/daos/container.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/daos/tab.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [ContainerDao, TabDao],
)
class TabDatabase extends _$TabDatabase {
  @override
  final int schemaVersion = 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // disable foreign_keys before migrations
          await customStatement('PRAGMA foreign_keys = OFF');

          if (from < 2) {
            await transaction(() async {
              // await m.dropColumn(tabLink, 'url');
              // await m.dropColumn(tabLink, 'title');
              // await m.dropColumn(tabLink, 'screenshot');

              // await m.alterTable(TableMigration(tab));
            });
          }

          // Assert that the schema is valid after migrations
          if (kDebugMode) {
            final wrongForeignKeys =
                await customSelect('PRAGMA foreign_key_check').get();
            assert(
              wrongForeignKeys.isEmpty,
              '${wrongForeignKeys.map((e) => e.data)}',
            );
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  TabDatabase(super.e);
}
