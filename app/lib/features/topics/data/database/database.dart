import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:lensai/features/topics/data/database/daos/tab.dart';
import 'package:lensai/features/topics/data/database/daos/topic.dart';
import 'package:lensai/features/topics/data/database/drift/converters/color.dart';
import 'package:lensai/features/topics/data/database/drift/converters/uri.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [TopicDao, TabDao],
)
class TabDatabase extends _$TabDatabase {
  @override
  final int schemaVersion = 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  TabDatabase(super.e);
}
