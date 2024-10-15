import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:lensai/features/geckoview/features/topics/data/database/daos/tab.dart';
import 'package:lensai/features/geckoview/features/topics/data/database/daos/topic.dart';
import 'package:lensai/features/geckoview/features/topics/data/database/drift/converters/color.dart';
import 'package:lensai/features/geckoview/features/topics/data/models/topic_data.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [TopicDao, TabLinkDao],
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
              await m.renameTable(tabLink, 'tab');

              await m.dropColumn(tabLink, 'url');
              await m.dropColumn(tabLink, 'title');
              await m.dropColumn(tabLink, 'screenshot');

              await m.alterTable(TableMigration(tabLink));
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
