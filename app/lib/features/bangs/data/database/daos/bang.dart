import 'package:bang_navigator/features/bangs/data/database/database.dart';
import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:drift/drift.dart';

part 'bang.g.dart';

@DriftAccessor()
class BangDao extends DatabaseAccessor<BangDatabase> with _$BangDaoMixin {
  BangDao(super.db);

  Selectable<Bang> getBangs({Iterable<BangGroup?>? groups}) {
    final selectable = select(db.bang);
    if (groups != null) {
      selectable.where((t) => t.group.isInValues(groups));
    }

    return selectable;
  }

  SingleOrNullSelectable<BangData> getBangData(String trigger) {
    return select(db.bangDataView)..where((t) => t.trigger.equals(trigger));
  }

  Selectable<BangData> getBangDataList({Iterable<BangGroup?>? groups}) {
    final selectable = select(db.bangDataView);
    if (groups != null) {
      selectable.where((t) => t.group.isInValues(groups));
    }

    selectable.orderBy([(t) => OrderingTerm.asc(t.websiteName)]);

    return selectable;
  }

  Selectable<BangData> getFrequentBangDataList({Iterable<BangGroup?>? groups}) {
    final selectable = select(db.bangDataView)
      ..where((t) => t.frequency.isBiggerThanValue(0));
    if (groups != null) {
      selectable.where((t) => t.group.isInValues(groups));
    }

    selectable.orderBy([
      (t) => OrderingTerm.desc(t.frequency),
      (t) => OrderingTerm.desc(t.lastUsed),
    ]);

    return selectable;
  }

  Future<int> increaseFrequency(String trigger) {
    return db.bangFrequency.insertOne(
      BangFrequencyCompanion.insert(
        trigger: trigger,
        frequency: 1,
        lastUsed: DateTime.now(),
      ),
      onConflict: DoUpdate(
        (old) => BangFrequencyCompanion.custom(
          frequency: old.frequency + const Constant(1),
          lastUsed: Variable(DateTime.now()),
        ),
      ),
    );
  }

  Selectable<BangData> queryBangs(String searchString) {
    return db.bangQuery(query: db.buildQuery(searchString));
  }

  Future<void> insertBangs(Iterable<Bang> bangs) {
    return db.bang.insertAll(bangs);
  }

  Future<int> upsertIcon(String trigger, Uint8List iconData) {
    return db.bangIcon.insertOne(
      BangIconCompanion.insert(
        trigger: trigger,
        iconData: iconData,
        fetchDate: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
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
}
