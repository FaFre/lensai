import 'package:drift/drift.dart';
import 'package:lensai/features/bangs/data/database/database.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';

part 'sync.g.dart';

@DriftAccessor()
class SyncDao extends DatabaseAccessor<BangDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  SingleOrNullSelectable<DateTime?> lastSyncOfGroup(BangGroup group) {
    final query = selectOnly(db.bangSync)
      ..addColumns([db.bangSync.lastSync])
      ..where(db.bangSync.group.equalsValue(group));

    return query.map((row) => row.read(db.bangSync.lastSync));
  }

  Future<void> upsertLastSyncOfGroup(BangGroup group, DateTime lastSync) {
    return db.bangSync.insertOne(
      BangSyncCompanion.insert(
        group: Value(group),
        lastSync: lastSync,
      ),
      onConflict: DoUpdate(
        (old) => BangSyncCompanion.custom(lastSync: Variable(lastSync)),
      ),
    );
  }

  Future<void> insertBangs(Iterable<Bang> bangs) {
    return db.bang.insertAll(bangs);
  }

  Future<void> replaceBangs(Iterable<Bang> bangs) {
    return batch(
      (batch) {
        batch.replaceAll(db.bang, bangs);
      },
    );
  }

  Future<int> deleteBangs(Iterable<String> triggers) {
    final statement = delete(db.bang)..where((t) => t.trigger.isIn(triggers));
    return statement.go();
  }

  Future<void> syncBangs({
    required BangGroup group,
    required Iterable<Bang> remoteBangs,
    required DateTime syncTime,
  }) async {
    final remoteBangMap =
        Map.fromEntries(remoteBangs.map((e) => MapEntry(e.trigger, e)));
    final localBangMap =
        await db.bangDao.getBangList(groups: [group]).get().then(
              (bangs) =>
                  Map.fromEntries(bangs.map((e) => MapEntry(e.trigger, e))),
            );

    final remoteBangTriggers = remoteBangMap.keys.toSet();
    final localBangTriggers = localBangMap.keys.toSet();

    final removedBangs = localBangTriggers.difference(remoteBangTriggers);
    final addedBangs = remoteBangTriggers.difference(localBangTriggers).map(
          (e) => remoteBangMap[e]!,
        );

    final changedBangs = remoteBangTriggers
        .intersection(localBangTriggers)
        .where((e) => remoteBangMap[e] != localBangMap[e])
        .map(
          (e) => remoteBangMap[e]!,
        );

    await db.transaction(
      () async {
        await deleteBangs(removedBangs);
        await insertBangs(addedBangs);
        await replaceBangs(changedBangs);
        await upsertLastSyncOfGroup(group, syncTime);
      },
    );
  }
}
