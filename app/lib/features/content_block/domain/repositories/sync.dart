import 'package:drift/isolate.dart';
import 'package:exceptions/exceptions.dart';
import 'package:lensai/features/content_block/data/database/database.dart';
import 'package:lensai/features/content_block/data/models/host.dart';
import 'package:lensai/features/content_block/data/providers.dart';
import 'package:lensai/features/content_block/data/services/source.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync.g.dart';

@Riverpod(keepAlive: true)
class HostSyncRepository extends _$HostSyncRepository {
  late HostDatabase _db;

  HostSyncRepository();

  static Future<Result<void>> _fetchAndSync({
    required HostSourceService sourceService,
    required HostDatabase db,
    required Uri url,
    required HostSource source,
    required Duration? syncInterval,
  }) async {
    if (syncInterval != null) {
      final lastSync =
          await db.syncDao.lastSyncOfSource(source).getSingleOrNull();

      if (lastSync != null &&
          DateTime.now().difference(lastSync) < syncInterval) {
        return Result.success(null);
      }
    }

    final result = await sourceService.getHosts(url);
    return result.flatMapAsync(
      (remoteHosts) async {
        await db.syncDao.syncHosts(
          source: source,
          remoteHosts: remoteHosts,
          syncTime: DateTime.now(),
        );
      },
    );
  }

  Future<Result<void>> syncHostSource(
    HostSource source,
    Duration? syncInterval,
  ) async {
    try {
      return Result.success(
        await _db.computeWithDatabase(
          connect: HostDatabase.new,
          computation: (db) async {
            final ref = ProviderContainer();
            final result = await _fetchAndSync(
              sourceService: ref.read(hostSourceServiceProvider.notifier),
              db: db,
              url: Uri.parse(source.url),
              source: source,
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
          message: "Failed to sync Hosts (${source.name})",
          source: 'HostSync',
          details: e,
        ),
      );
    }
  }

  Stream<DateTime?> watchLastSyncOfSource(HostSource source) {
    return _db.syncDao.lastSyncOfSource(source).watchSingleOrNull();
  }

  Future<Map<HostSource, Result<void>>> syncHostSources({
    Set<HostSource>? sources,
    Duration? syncInterval,
  }) async {
    //Default to all sources
    sources ??= HostSource.values.toSet();

    //Run isolated operations
    final futures = sources.map(
      (source) => syncHostSource(source, syncInterval)
          .then((result) => MapEntry(source, result)),
    );

    return Map.fromEntries(await Future.wait(futures));
  }

  @override
  void build() {
    _db = ref.watch(hostDatabaseProvider);
  }
}
