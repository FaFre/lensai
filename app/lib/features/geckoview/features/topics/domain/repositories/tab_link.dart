import 'package:drift/drift.dart';
import 'package:lensai/features/geckoview/domain/repositories/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/topics/data/database/database.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_link.g.dart';

@Riverpod(keepAlive: true)
class TabLinkRepository extends _$TabLinkRepository {
  late TabDatabase _db;

  @override
  void build() {
    _db = ref.watch(tabDatabaseProvider);

    //Sync existing tabs
    ref.listen(
      tabRepositoryProvider.select((tabs) => tabs.keys.toList()),
      (previous, next) async {
        //No empty list to avoid data loss
        if (next.isNotEmpty) {
          await _db.tabLinkDao.syncTabLinks(retainTabIds: next);
        }
      },
    );

    ref.listen(
      selectedTabControllerProvider,
      (previous, next) async {
        if (next != null) {
          await _db.tabLinkDao.touchTabLink(next, timestamp: DateTime.now());
        }
      },
    );
  }

  Future<void> assignTab(String tabId, String? topicId) {
    return _db.tabLinkDao.upsertTabLink(
      tabId,
      timestamp: DateTime.now(),
      topicId: Value(topicId),
    );
  }

  Future<void> closeAllTabs(String? topicId) async {
    final tabIds = await _db.tabLinkDao.topicTabIds(topicId).get();
    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }
  }
}
