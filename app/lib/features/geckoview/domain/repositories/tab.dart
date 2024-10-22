import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();

  late TabDatabase _db;

  Future<String> addTab({
    Uri? url,
    bool selectTab = true,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    String? contextId,
    Source source = Internal.newTab,
    bool private = false,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
  }) {
    return _tabsService.addTab(
      url: url,
      selectTab: selectTab,
      startLoading: startLoading,
      parentId: parentId,
      flags: flags,
      contextId: contextId,
      source: source,
      private: private,
      historyMetadata: historyMetadata,
      additionalHeaders: additionalHeaders,
    );
  }

  Future<void> selectTab(String tabId) {
    return _tabsService.selectTab(tabId: tabId);
  }

  Future<void> closeTab(String tabId) {
    return _tabsService.removeTab(tabId: tabId);
  }

  Future<void> closeTabs(List<String> tabIds) {
    return _tabsService.removeTabs(ids: tabIds);
  }

  @override
  void build() {
    final eventSerivce = ref.watch(eventServiceProvider);

    _db = ref.watch(tabDatabaseProvider);

    final tabAddedSub = eventSerivce.tabAddedStream.listen(
      (tabId) async {
        final containerId = ref.read(selectedContainerProvider);
        await _db.tabDao.upsertTab(tabId, containerId: Value(containerId));
      },
    );

    ref.onDispose(() {
      unawaited(tabAddedSub.cancel());
    });
  }
}
