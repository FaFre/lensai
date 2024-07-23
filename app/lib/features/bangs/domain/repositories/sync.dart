import 'package:drift/isolate.dart';
import 'package:exceptions/exceptions.dart';
import 'package:lensai/features/bangs/data/database/database.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/data/providers.dart';
import 'package:lensai/features/bangs/data/services/source.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync.g.dart';

@Riverpod(keepAlive: true)
class BangSyncRepository extends _$BangSyncRepository {
  late BangDatabase _db;

  BangSyncRepository();

  static Future<Result<void>> _fetchAndSync({
    required BangSourceService sourceService,
    required BangDatabase db,
    required Uri url,
    required BangGroup group,
    required Duration? syncInterval,
  }) async {
    if (syncInterval != null) {
      final lastSync =
          await db.syncDao.lastSyncOfGroup(group).getSingleOrNull();

      if (lastSync != null &&
          lastSync.difference(DateTime.now()) < syncInterval) {
        return Result.success(null);
      }
    }

    final result = await sourceService.getBangs(url, group);
    return result.flatMapAsync(
      (remoteBangs) async {
        await db.syncDao.syncBangs(
          group: group,
          remoteBangs: remoteBangs,
          syncTime: DateTime.now(),
        );
        await db.optimizeFtsIndex();
      },
    );
  }

  Future<Result<void>> syncBangGroup(
    BangGroup group,
    Duration? syncInterval,
  ) async {
    try {
      return Result.success(
        await _db.computeWithDatabase(
          connect: BangDatabase.new,
          computation: (db) async {
            final ref = ProviderContainer();
            final result = await _fetchAndSync(
              sourceService: ref.read(bangSourceServiceProvider.notifier),
              db: db,
              url: Uri.parse(group.url),
              group: group,
              syncInterval: syncInterval,
            );

            //Throw if necessary
            return result.value;
          },
        ),
      );
    } catch (e) {
      return Result.failure(
        ErrorMessage(
          message: "Failed to sync Bangs (${group.name})",
          source: 'BangSync',
          details: e,
        ),
      );
    }
  }

  Stream<DateTime?> watchLastSyncOfGroup(BangGroup group) {
    return _db.syncDao.lastSyncOfGroup(group).watchSingleOrNull();
  }

  Future<Map<BangGroup, Result<void>>> syncBangGroups({
    Set<BangGroup>? groups,
    Duration? syncInterval,
  }) async {
    //Default to all sources
    groups ??= BangGroup.values.toSet();

    //Run isolated operations
    final futures = groups.map(
      (source) => syncBangGroup(source, syncInterval)
          .then((result) => MapEntry(source, result)),
    );

    return Map.fromEntries(await Future.wait(futures));
  }

  @override
  void build() {
    _db = ref.watch(bangDatabaseProvider);
  }
}
