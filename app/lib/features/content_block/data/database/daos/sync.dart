import 'package:bang_navigator/features/content_block/data/database/database.dart';
import 'package:bang_navigator/features/content_block/data/models/host.dart';
import 'package:drift/drift.dart';

part 'sync.g.dart';

@DriftAccessor()
class SyncDao extends DatabaseAccessor<HostDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  SingleOrNullSelectable<DateTime?> lastSyncOfSource(HostSource source) {
    final query = selectOnly(db.hostSync)
      ..addColumns([db.hostSync.lastSync])
      ..where(db.hostSync.source.equalsValue(source));

    return query.map((row) => row.read(db.hostSync.lastSync));
  }

  Future<void> upsertLastSyncOfSource(HostSource source, DateTime lastSync) {
    return db.hostSync.insertOne(
      HostSyncCompanion.insert(
        source: Value(source),
        lastSync: lastSync,
      ),
      onConflict: DoUpdate(
        (old) => HostSyncCompanion.custom(lastSync: Variable(lastSync)),
      ),
    );
  }

  Future<void> insertHosts(HostSource source, Iterable<String> hosts) {
    return db.host.insertAll(
      hosts.map((host) => HostCompanion.insert(hostname: host, source: source)),
      // It is possible that we get conflicts, in case the host is added in
      // multiple lists. In this case we just gonna igore it, and make sure,
      // the unified list is inserted first.
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<int> deleteHosts(Iterable<String> hosts) {
    return db.host.deleteWhere((t) => t.hostname.isIn(hosts));
  }

  Future<void> syncHosts({
    required HostSource source,
    required Set<String> remoteHosts,
    required DateTime syncTime,
  }) async {
    final localHosts = await db.hostDao
        .getHostList(sources: [source])
        .get()
        .then((hosts) => hosts.map((host) => host.hostname).toSet());

    final removedHosts = localHosts.difference(remoteHosts);
    final addedHosts = remoteHosts.difference(localHosts);

    await db.transaction(
      () async {
        await deleteHosts(removedHosts);
        await insertHosts(source, addedHosts);
        await upsertLastSyncOfSource(source, syncTime);
      },
    );
  }
}
