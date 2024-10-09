import 'package:drift/drift.dart';
import 'package:lensai/features/geckoview/features/topics/data/database/database.dart';

part 'tab.g.dart';

@DriftAccessor()
class TabLinkDao extends DatabaseAccessor<TabDatabase> with _$TabLinkDaoMixin {
  TabLinkDao(super.db);

  Selectable<String> topicTabIds(String? topicId) {
    final query = selectOnly(db.tabLink)
      ..addColumns([db.tabLink.id])
      ..where(
        (topicId == null)
            ? db.tabLink.topicId.isNull()
            : db.tabLink.topicId.equals(topicId),
      )
      ..orderBy([OrderingTerm.asc(db.tabLink.id)]);

    return query.map((row) => row.read(db.tabLink.id)!);
  }

  SingleOrNullSelectable<String> tabTopicId(String tabId) {
    final query = selectOnly(db.tabLink)
      ..addColumns([db.tabLink.topicId])
      ..where(db.tabLink.id.equals(tabId));

    return query.map((row) => row.read(db.tabLink.id)!);
  }

  Future<void> upsertTabLink(
    String tabId, {
    required DateTime timestamp,
    Value<String?> topicId = const Value.absent(),
  }) {
    return db.tabLink.insertOne(
      TabLinkCompanion.insert(
        id: tabId,
        timestamp: timestamp,
        topicId: topicId,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> touchTabLink(
    String id, {
    required DateTime timestamp,
  }) {
    final statement = db.tabLink.update()..where((t) => t.id.equals(id));
    return statement.write(
      TabLinkCompanion(timestamp: Value(timestamp)),
    );
  }

  Future<void> syncTabLinks({required List<String> retainTabIds}) {
    return (db.tabLink.delete()..where((t) => t.id.isNotIn(retainTabIds))).go();
  }
}
