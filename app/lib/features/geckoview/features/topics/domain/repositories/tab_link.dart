import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
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
  }

  Future<void> assignTab(String tabId, String topicId) {
    return _db.tabLinkDao.upsertTabLink(
      tabId,
      timestamp: DateTime.now(),
      topicId: topicId,
    );
  }

  Future<void> closeAllTabs(String? topicId) async {
    final List<String> tabIds;
    if (topicId != null) {
      tabIds = await _db.tabLinkDao.topicTabIds(topicId).get();
    } else {
      final openTabs = ref.read(tabStatesProvider).keys.toSet();
      final assignedTabIds = await _db.tabLinkDao.allTabIds().get();

      tabIds =
          openTabs.where((tabId) => !assignedTabIds.contains(tabId)).toList();
    }

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }
  }
}
