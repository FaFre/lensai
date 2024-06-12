import 'package:bang_navigator/domain/services/generic_website.dart';
import 'package:bang_navigator/features/bangs/data/database/database.dart';
import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/data/providers.dart';
import 'package:bang_navigator/utils/image_helper.dart';
import 'package:drift/drift.dart';
import 'package:exceptions/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bang_data.g.dart';

@Riverpod(keepAlive: true)
class BangDataRepository extends _$BangDataRepository {
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

  Stream<int> watchBangCount(BangGroup group) {
    return _db.bangDao.getBangCount(groups: [group]).watchSingle();
  }

  Stream<List<BangData>> watchBangs({Iterable<BangGroup>? groups}) {
    return _db.bangDao.getBangDataList(groups: groups).watch();
  }

  Stream<List<BangData>> watchFrequentBangs({Iterable<BangGroup>? groups}) {
    return _db.bangDao.getFrequentBangDataList(groups: groups).watch();
  }

  Future<void> increaseFrequency(String trigger) {
    return _db.bangDao.increaseBangFrequency(trigger);
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
          await _db.bangDao.upsertBangIcon(bang.trigger, faviconBytes);
          return bang.copyWith.iconData(faviconBytes);
        }

        return bang;
      },
    );
  }

  Future<int> clearIconData() {
    return _db.bangIcon.deleteAll();
  }

  Future<int> clearFrequency() {
    return _db.bangFrequency.deleteAll();
  }
}