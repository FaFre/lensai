import 'package:drift/drift.dart';
import 'package:lensai/features/topics/data/database/database.dart';
import 'package:lensai/features/topics/data/providers.dart';
import 'package:lensai/features/web_view/domain/entities/abstract/tab.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  late TabDatabase _db;

  @override
  Stream<List<TabData>> build() {
    _db = ref.watch(tabDatabaseProvider);
    return _db.tabDao.watchTabs();
  }

  Future<void> updateTab(
    String id, {
    Value<Uri> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> topicId = const Value.absent(),
    Value<Uint8List?> screenshot = const Value.absent(),
  }) {
    return _db.tabDao.updateTab(
      id,
      timestamp: DateTime.now(),
      url: url,
      title: title,
      topicId: topicId,
      screenshot: screenshot,
    );
  }

  Future<void> deleteTab(String id) {
    return _db.tabDao.deleteTab(id);
  }
}

@Riverpod()
class TopicTabRepository extends _$TopicTabRepository {
  late TabDatabase _db;

  @override
  Stream<List<String>> build(String? topicId) {
    _db = ref.watch(tabDatabaseProvider);
    return _db.tabDao.watchTopicTabs(topicId);
  }

  Future<void> addTab(ITab tab) {
    assert(tab.topicId == topicId);
    return _db.tabDao.upsertTab(tab, DateTime.now());
  }

  Future<void> closeAllTabs() {
    return _db.tabDao.deleteTopicTabs(topicId);
  }
}
