import 'package:bang_navigator/features/content_block/data/database/database.dart';
import 'package:bang_navigator/features/content_block/data/models/host.dart';
import 'package:bang_navigator/features/content_block/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host.g.dart';

@Riverpod(keepAlive: true)
class HostRepository extends _$HostRepository {
  late HostDatabase _db;

  @override
  void build() {
    _db = ref.watch(hostDatabaseProvider);
  }

  Stream<List<String>> watchHosts({Iterable<HostSource>? sources}) {
    return _db.hostDao
        .getHostList(sources: sources)
        .map(
          (hostData) => hostData.hostname,
        )
        .watch();
  }

  Stream<int> watchHostCount(HostSource source) {
    return _db.hostDao.getHostCount(sources: [source]).watchSingle();
  }
}
