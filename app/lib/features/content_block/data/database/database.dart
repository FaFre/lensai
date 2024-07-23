import 'package:drift/drift.dart';
import 'package:lensai/features/content_block/data/database/daos/host.dart';
import 'package:lensai/features/content_block/data/database/daos/sync.dart';
import 'package:lensai/features/content_block/data/models/host.dart';

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
