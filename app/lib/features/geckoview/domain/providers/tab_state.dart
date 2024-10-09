import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/extensions/image.dart';
import 'package:lensai/features/geckoview/domain/entities/find_result_state.dart';
import 'package:lensai/features/geckoview/domain/entities/history_state.dart';
import 'package:lensai/features/geckoview/domain/entities/readerable_state.dart';
import 'package:lensai/features/geckoview/domain/entities/security_state.dart';
import 'package:lensai/features/geckoview/domain/entities/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/utils/image_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_state.g.dart';

@Riverpod(keepAlive: true)
class TabStates extends _$TabStates {
  final _tabsService = GeckoTabService();

  void _onTabListChange(List<String> tabs) {
    state = {
      for (final tabId in tabs) tabId: state[tabId] ?? TabState.$default(tabId),
    };
  }

  void _onTabContentStateChange(TabContentState contentState) {
    final current =
        state[contentState.id] ?? TabState.$default(contentState.id);

    state = {...state}..[contentState.id] = current.copyWith(
        contextId: contentState.contextId,
        url: Uri.parse(contentState.url),
        title: contentState.title,
        progress: contentState.progress,
        isPrivate: contentState.isPrivate,
        isFullScreen: contentState.isFullScreen,
        isLoading: contentState.isLoading,
      );
  }

  Future<void> _onIconChange(IconEvent event) async {
    final IconEvent(:tabId, :bytes) = event;

    final current = state[tabId] ?? TabState.$default(tabId);

    final image = (bytes != null)
        ? (await tryDecodeImage(bytes)
            .then((image) async => image?.toEquatable()))
        : null;

    state = {...state}..[tabId] = current.copyWith.icon(image);
  }

  Future<void> _onThumbnailChange(ThumbnailEvent event) async {
    final ThumbnailEvent(:tabId, :bytes) = event;

    final current = state[tabId] ?? TabState.$default(tabId);

    final image = (bytes != null)
        ? (await tryDecodeImage(bytes)
            .then((image) async => image?.toEquatable()))
        : null;

    state = {...state}..[tabId] = current.copyWith.thumbnail(image);
  }

  void _onSecurityInfoStateChange(SecurityInfoEvent event) {
    final SecurityInfoEvent(:tabId, :securityInfo) = event;

    final current = state[tabId] ?? TabState.$default(tabId);

    state = {...state}..[tabId] = current.copyWith.securityInfoState(
        SecurityState(
          secure: securityInfo.secure,
          host: securityInfo.host,
          issuer: securityInfo.issuer,
        ),
      );
  }

  void _onHistoryStateChange(HistoryEvent event) {
    final HistoryEvent(:tabId, :history) = event;

    final current = state[tabId] ?? TabState.$default(tabId);

    state = {...state}..[tabId] = current.copyWith.historyState(
        HistoryState(
          items: history.items.nonNulls
              .map(
                (item) =>
                    HistoryItem(url: Uri.parse(item.url), title: item.title),
              )
              .toList(),
          currentIndex: history.currentIndex,
          canGoBack: history.canGoBack,
          canGoForward: history.canGoForward,
        ),
      );
  }

  void _onReaderableStateChange(ReaderableEvent event) {
    final ReaderableEvent(:tabId, :readerable) = event;

    final current = state[tabId] ?? TabState.$default(tabId);

    state = {...state}..[tabId] = current.copyWith.readerableState(
        ReaderableState(
          readerable: readerable.readerable,
          active: readerable.active,
        ),
      );
  }

  void _onFindResults(FindResultsEvent event) {
    final FindResultsEvent(:tabId, :results) = event;

    if (results.isNotEmpty) {
      final current = state[tabId] ?? TabState.$default(tabId);
      final result = results.last;

      state = {...state}..[tabId] = current.copyWith.findResultState(
          FindResultState(
            activeMatchOrdinal: result.activeMatchOrdinal,
            numberOfMatches: result.numberOfMatches,
            isDoneCounting: result.isDoneCounting,
          ),
        );
    }
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

  Future<void> closeTabs(List<String> tabIds) {
    return _tabsService.removeTabs(ids: tabIds);
  }

  Future<void> closeTab(String tabIds) {
    return _tabsService.removeTab(tabId: tabIds);
  }

  @override
  Map<String, TabState> build() {
    final eventService = ref.watch(eventServiceProvider);

    final subscriptions = [
      eventService.tabListEvents.listen(_onTabListChange),
      eventService.tabContentEvents.listen(_onTabContentStateChange),
      eventService.iconEvents.listen(_onIconChange),
      eventService.thumbnailEvents.listen(_onThumbnailChange),
      eventService.securityInfoEvents.listen(_onSecurityInfoStateChange),
      eventService.historyEvents.listen(_onHistoryStateChange),
      eventService.readerableEvents.listen(_onReaderableStateChange),
      eventService.findResultsEvent.listen(_onFindResults),
    ];

    ref.onDispose(() {
      for (final sub in subscriptions) {
        unawaited(sub.cancel());
      }
    });

    return {};
  }
}

@Riverpod()
TabState? tabState(TabStateRef ref, String? tabId) {
  if (tabId == null) {
    return null;
  }

  return ref.watch(
    tabStatesProvider.select((tabs) => tabs[tabId]),
  );
}

@Riverpod()
TabState? selectedTabState(SelectedTabStateRef ref) {
  final tabId = ref.watch(selectedTabProvider);
  return ref.watch(tabStateProvider(tabId));
}
