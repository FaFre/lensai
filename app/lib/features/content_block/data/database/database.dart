import 'package:bang_navigator/features/content_block/data/database/daos/host.dart';
import 'package:bang_navigator/features/content_block/data/database/daos/sync.dart';
import 'package:bang_navigator/features/content_block/data/models/host.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [HostDao, SyncDao],
)
class HostDatabase extends _$HostDatabase {
  @override
  final int schemaVersion = 1;

  HostDatabase(super.e);
}
