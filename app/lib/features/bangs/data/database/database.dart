import 'package:drift/drift.dart';
import 'package:lensai/features/bangs/data/database/daos/bang.dart';
import 'package:lensai/features/bangs/data/database/daos/sync.dart';
import 'package:lensai/features/bangs/data/database/drift/converters/bang_format.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/query/domain/tokenizer.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [BangDao, SyncDao],
)
class BangDatabase extends _$BangDatabase with PrefixQueryBuilderMixin {
  @override
  final int schemaVersion = 1;

  @override
  final int ftsTokenLimit = 6;
  @override
  final int ftsMinTokenLength = 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  BangDatabase(super.e);
}
