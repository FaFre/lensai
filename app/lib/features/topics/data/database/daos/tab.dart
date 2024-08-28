import 'package:drift/drift.dart';
import 'package:lensai/features/topics/data/database/database.dart';
import 'package:lensai/features/web_view/domain/entities/abstract/tab.dart';

part 'tab.g.dart';

@DriftAccessor()
class TabDao extends DatabaseAccessor<TabDatabase> with _$TabDaoMixin {
  TabDao(super.db);

  Stream<List<TabData>> watchTabs() {
    return (db.tab.select()..orderBy([(u) => OrderingTerm.asc(u.id)])).watch();
  }

  Stream<TabData?> watchTab(String tabId) {
    return (db.tab.select()..where((t) => t.id.equals(tabId)))
        .watchSingleOrNull();
  }

  Stream<bool> watchTabExisiting(String tabId) {
    final existsStatement =
        existsQuery(db.tab.select()..where((t) => t.id.equals(tabId)));

    return selectExpressions([existsStatement])
        .map((row) => row.read(existsStatement)!)
        .watchSingle();
  }

  Stream<List<String>> watchTopicTabs(String? topicId) {
    final query = (selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(
        (topicId == null)
            ? db.tab.topicId.isNull()
            : db.tab.topicId.equals(topicId),
      )
      ..orderBy([OrderingTerm.asc(db.tab.id)]));

    return query.map((row) => row.read(db.tab.id)!).watch();
  }

  Future<void> upsertTab(ITab tab, DateTime timestamp) {
    return db.tab.insertOne(
      TabCompanion.insert(
        id: tab.id,
        timestamp: timestamp,
        url: tab.url,
        topicId: Value(tab.topicId),
        title: Value(tab.title),
        screenshot: Value(tab.screenshot),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> updateTab(
    String id, {
    required DateTime timestamp,
    Value<Uri> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> topicId = const Value.absent(),
    Value<Uint8List?> screenshot = const Value.absent(),
  }) {
    final statement = db.tab.update()..where((t) => t.id.equals(id));

    return statement.write(
      TabCompanion(
        timestamp: Value(timestamp),
        url: url,
        title: title,
        topicId: topicId,
        screenshot: screenshot,
      ),
    );
  }

  Future<void> deleteTab(String id) {
    return db.tab.deleteOne(TabCompanion.custom(id: Variable(id)));
  }

  Future<void> deleteTopicTabs(String? topicId) {
    return (db.tab.delete()
          ..where(
            (t) => (topicId == null)
                ? t.topicId.isNull()
                : t.topicId.equals(topicId),
          ))
        .go();
  }
}
