import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();

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
  void build() {}
}
