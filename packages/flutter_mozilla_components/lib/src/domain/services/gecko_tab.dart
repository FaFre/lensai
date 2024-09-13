import 'package:flutter_mozilla_components/src/data/models/load_url_flags.dart';
import 'package:flutter_mozilla_components/src/data/models/source.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart'
    hide IconSource;

final _apiInstance = GeckoTabsApi();

class GeckoTabService {
  final GeckoTabsApi _api;

  GeckoTabService({GeckoTabsApi? api}) : _api = api ?? _apiInstance;

  Future<void> selectTab({required String tabId}) {
    return _api.selectTab(tabId: tabId);
  }

  Future<void> removeTab({required String tabId}) {
    return _api.removeTab(tabId: tabId);
  }

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
    return _api.addTab(
      url: (url ?? Uri.parse('about:blank')).toString(),
      selectTab: selectTab,
      startLoading: startLoading,
      parentId: parentId,
      flags: flags.toValue(),
      contextId: contextId,
      source: source.toValue(),
      private: private,
      historyMetadata: historyMetadata,
      additionalHeaders: additionalHeaders,
    );
  }

  Future<void> removeAllTabs({required bool recoverable}) {
    return _api.removeAllTabs(recoverable: recoverable);
  }

  Future<void> removeTabs({required List<String> ids}) {
    return _api.removeTabs(ids: ids);
  }

  Future<void> removeNormalTabs() {
    return _api.removeNormalTabs();
  }

  Future<void> removePrivateTabs() {
    return _api.removePrivateTabs();
  }

  Future<void> undo() {
    return _api.undo();
  }

  //restoreTabs invokes splitted
  Future<void> restoreTabsByList({
    required List<RecoverableTab> tabs,
    String? selectTabId,
    RestoreLocation restoreLocation = RestoreLocation.end,
  }) {
    return _api.restoreTabsByList(
        tabs: tabs, selectTabId: selectTabId, restoreLocation: restoreLocation);
  }

  Future<void> restoreTabsByBrowserState({
    required RecoverableBrowserState state,
    RestoreLocation restoreLocation = RestoreLocation.end,
  }) {
    return _api.restoreTabsByBrowserState(
        state: state, restoreLocation: restoreLocation);
  }
  //The calls with engin storage for restore are not supported at the moment

  //selectOrAddTab invokes splitted
  /// Selects an already existing tab with the matching [HistoryMetadataKey] or otherwise
  /// creates a new tab with the given [url].
  Future<String> selectOrAddTabByHistory({
    required Uri url,
    required HistoryMetadataKey historyMetadata,
  }) {
    return _api.selectOrAddTabByHistory(
        url: url.toString(), historyMetadata: historyMetadata);
  }

  /// Selects an already existing tab displaying [url] or otherwise creates a new tab.
  Future<String> selectOrAddTabByUrl({
    required Uri url,
    bool private = false,
    Source source = Internal.newTab,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    bool ignoreFragment = false,
  }) {
    return _api.selectOrAddTabByUrl(
      url: url.toString(),
      private: private,
      source: source.toValue(),
      flags: flags.toValue(),
      ignoreFragment: ignoreFragment,
    );
  }

  Future<String> duplicateTab({
    String? selectTabId,
    bool selectNewTab = true,
  }) {
    return _api.duplicateTab(
        selectTabId: selectTabId, selectNewTab: selectNewTab);
  }

  Future<void> moveTabs({
    required List<String> tabIds,
    required String targetTabId,
    required bool placeAfter,
  }) {
    return _api.moveTabs(
        tabIds: tabIds, targetTabId: targetTabId, placeAfter: placeAfter);
  }

  Future<String> migratePrivateTabUseCase({
    required String tabId,
    Uri? alternativeUrl,
  }) {
    return _api.migratePrivateTabUseCase(
        tabId: tabId, alternativeUrl: alternativeUrl?.toString());
  }
}
