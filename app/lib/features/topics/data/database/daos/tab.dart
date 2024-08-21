import 'package:drift/drift.dart';
import 'package:lensai/features/topics/data/database/database.dart';
import 'package:lensai/features/web_view/domain/entities/abstract/tab.dart';

part 'tab.g.dart';

@DriftAccessor()
class TabDao extends DatabaseAccessor<TabDatabase> with _$TabDaoMixin {
  TabDao(super.db);

  Future<void> upsertTab(ITab tab) {
    return db.tab.insertOne(
      TabCompanion.insert(
        id: tab.id,
        timestamp: DateTime.now(),
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
    Value<Uri> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> topicId = const Value.absent(),
    Value<Uint8List?> screenshot = const Value.absent(),
  }) {
    final statement = db.tab.update()..where((t) => t.id.equals(id));

    return statement.write(
      TabCompanion(
        timestamp: Value(DateTime.now()),
        url: url,
        title: title,
        topicId: topicId,
        screenshot: screenshot,
      ),
    );
  }
}
