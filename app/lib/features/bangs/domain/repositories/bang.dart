import 'package:bang_navigator/domain/services/generic_website.dart';
import 'package:bang_navigator/features/bangs/data/database/database.dart';
import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/data/providers.dart';
import 'package:bang_navigator/features/bangs/data/services/bang_source.dart';
import 'package:bang_navigator/utils/image_helper.dart';
import 'package:drift/isolate.dart';
import 'package:exceptions/exceptions.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bang.g.dart';

Future<Result<void>> _syncBangGroupStatic(
  BangSource source,
  BangDatabase db,
  Uri url,
  BangGroup? group,
) async {
  final result = await source.getBangs(url, group);

  return result.flatMapAsync(
    (value) async {
      final sourcedBangMap =
          Map.fromEntries(value.map((e) => MapEntry(e.trigger, e)));
      final localBangMap =
          await db.bangDao.getBangs(groups: [group]).get().then(
                (bangs) =>
                    Map.fromEntries(bangs.map((e) => MapEntry(e.trigger, e))),
              );

      final sourcedBangTriggers = sourcedBangMap.keys.toSet();
      final localBangTriggers = localBangMap.keys.toSet();

      final removedBangs = localBangTriggers.difference(sourcedBangTriggers);
      final addedBangs = sourcedBangTriggers.difference(localBangTriggers).map(
            (e) => sourcedBangMap[e]!,
          );

      final changedBangs = sourcedBangTriggers
          .intersection(localBangTriggers)
          .where((e) => sourcedBangMap[e] != localBangMap[e])
          .map(
            (e) => sourcedBangMap[e]!,
          );

      await db.bangDao.deleteBangs(removedBangs);
      await db.bangDao.insertBangs(addedBangs);
      await db.bangDao.replaceBangs(changedBangs);

      await db.optimizeFtsIndex();
    },
  );
}

@Riverpod(keepAlive: true)
class BangRepository extends _$BangRepository {
  late BangDatabase _db;

  @override
  void build() {
    _db = ref.watch(bangDatabaseProvider);
  }

  Stream<BangData?> watchBang(String? trigger) {
    if (trigger != null) {
      return _db.bangDao.getBangData(trigger).watchSingleOrNull();
    } else {
      return Stream.value(null);
    }
  }

  Stream<List<BangData>> watchBangs({Iterable<BangGroup?>? groups}) {
    return _db.bangDao.getBangDataList(groups: groups).watch();
  }

  Stream<List<BangData>> watchFrequentBangs({Iterable<BangGroup?>? groups}) {
    return _db.bangDao.getFrequentBangDataList(groups: groups).watch();
  }

  Future<void> increaseFrequency(String trigger) {
    return _db.bangDao.increaseFrequency(trigger);
  }

  Future<Result<BangData>> ensureIconAvailable(BangData bang) async {
    if (bang.iconData != null) {
      return Result.success(bang);
    }

    final result = await ref
        .read(genericWebsiteServiceProvider.notifier)
        .getFaviconBytes(Uri.parse(bang.getUrl('').origin));

    return result.flatMapAsync(
      (faviconBytes) async {
        if (faviconBytes != null && await isImageValid(faviconBytes)) {
          await _db.bangDao.upsertIcon(bang.trigger, faviconBytes);
          return bang.copyWith.iconData(faviconBytes);
        }

        return bang;
      },
    );
  }

  Future<Result<void>> syncBangGroup(
    Uri url,
    BangGroup? group,
  ) =>
      _syncBangGroupStatic(
        ref.read(bangSourceProvider.notifier),
        _db,
        url,
        group,
      );

  Future<void> syncAllBangGroups() async {
    await _db.computeWithDatabase(
      connect: BangDatabase.new,
      computation: (db) async {
        final ref = ProviderContainer();
        final source = ref.read(bangSourceProvider.notifier);

        await _syncBangGroupStatic(
          source,
          db,
          Uri.parse(
            'https://raw.githubusercontent.com/kagisearch/bangs/main/data/bangs.json',
          ),
          null,
        );

        await _syncBangGroupStatic(
          source,
          db,
          Uri.parse(
            'https://raw.githubusercontent.com/kagisearch/bangs/main/data/kagi_bangs.json',
          ),
          BangGroup.kagi,
        );

        await _syncBangGroupStatic(
          source,
          db,
          Uri.parse(
            'https://raw.githubusercontent.com/kagisearch/bangs/main/data/assistant_bangs.json',
          ),
          BangGroup.assistant,
        );
      },
    );
  }
}
