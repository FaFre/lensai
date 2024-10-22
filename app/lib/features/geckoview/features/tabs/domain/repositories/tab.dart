import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabDataRepository extends _$TabDataRepository {
  late TabDatabase _db;

  @override
  void build() {
    _db = ref.watch(tabDatabaseProvider);
  }

  Future<void> assignContainer(String tabId, String? containerId) {
    return _db.tabDao.assignContainer(
      tabId,
      containerId: containerId,
    );
  }

  Future<void> assignOrderKey(String tabId, String orderKey) {
    return _db.tabDao.assignOrderKey(
      tabId,
      orderKey: orderKey,
    );
  }

  Future<void> closeAllTabs(String? containerId) async {
    final tabIds = await _db.tabDao.containerTabIds(containerId).get();
    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }
  }

  Future<String?> containerTabId(String tabId) {
    return _db.tabDao.tabContainerId(tabId).getSingle();
  }
}
