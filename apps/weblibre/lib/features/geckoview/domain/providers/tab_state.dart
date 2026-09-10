/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/find_result.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/history.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/security.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/translation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/repositories/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

part 'tab_state.g.dart';

/// Decode width for tab thumbnails. The screenshots arrive at full device
/// resolution but are only ever shown in tab-tray previews a few hundred
/// logical pixels wide, so decoding them at native size burns main-isolate
/// time and GPU memory for detail nobody sees. Only the width is constrained
/// so the decoder keeps the aspect ratio; upscaling is disabled so smaller
/// sources are left alone.
const thumbnailDecodeWidth = 720;

@Riverpod(keepAlive: true)
class TabStates extends _$TabStates {
  /// Callers parked in [awaitContentState], per tab.
  final _contentStateWaiters = <String, List<Completer<TabState?>>>{};

  /// Replaces the entry for [tabId] — but only when [next] actually differs.
  ///
  /// Every write here allocates a new map, and `Map` compares by identity, so
  /// an unconditional assignment notifies *all* whole-map watchers (the quick
  /// tab switcher, the grouped tab list, the FIFO list) even when nothing
  /// changed. Gecko re-emits the full content state on every progress tick, so
  /// without this guard a single page load pushed dozens of no-op rebuilds
  /// through the entire browser chrome. [TabState] is `FastEquatable`, so the
  /// comparison is a cached-hash check.
  void _put(String tabId, TabState next) {
    if (state[tabId] == next) {
      return;
    }

    state = {...state}..[tabId] = next;

    if (next.hasContentState) {
      final waiters = _contentStateWaiters.remove(tabId);
      if (waiters != null) {
        for (final waiter in waiters) {
          waiter.complete(next);
        }
      }
    }
  }

  Future<void> _onTabContentStateChange(TabContentState contentState) async {
    final current = await patchedState(contentState.id);

    final url = Uri.parse(contentState.url);

    // Determine title based on priority: new non-empty title > existing title if URL authority unchanged > new title
    final String resolvedTitle;
    if (contentState.title.isNotEmpty) {
      resolvedTitle = contentState.title;
    } else if (current.url.authority == url.authority) {
      resolvedTitle = current.title;
    } else {
      resolvedTitle = contentState.title;
    }

    // Infer tabMode from context ID if not already set and context is isolated
    final inferredTabMode = switch (current.tabMode) {
      IsolatedTabMode() => current.tabMode,
      _ when isIsolatedContextId(contentState.contextId) => TabMode.isolated(
        contentState.contextId!,
      ),
      _ when contentState.isPrivate => TabMode.private,
      _ => TabMode.regular,
    };

    // `current.parentId` still holds the last engine parent we applied, so
    // capture whether the engine link changed before overwriting it below.
    final engineParentChanged = contentState.parentId != current.parentId;

    final newState = current.copyWith(
      hasContentState: true,
      parentId: contentState.parentId,
      contextId: contentState.contextId,
      url: url,
      title: resolvedTitle,
      tabMode: inferredTabMode,
      isFullScreen: contentState.isFullScreen,
      isLoading: contentState.isLoading,
      showToolbarAsExpanded: contentState.showToolbarAsExpanded,
    );

    _put(contentState.id, newState);

    // Progress lives outside [TabState] so a load tick doesn't invalidate the
    // whole map (and with it every chip in the quick tab switcher).
    ref
        .read(tabProgressStatesProvider.notifier)
        .update(contentState.id, contentState.progress);

    // Only reconcile DB hierarchy when the engine parent link actually changes.
    // Content-state events also fire on every progress/title tick, and seeding
    // opens a transaction, so re-running it on each tick would add needless DB
    // I/O to this hot path. The debounced updateTabs pass is the backstop for
    // anything not seeded here (e.g. a container assigned after the parent).
    if (ref.mounted && engineParentChanged) {
      await ref
          .read(tabDataRepositoryProvider.notifier)
          .seedParentFromEngineState(
            childId: contentState.id,
            parentId: contentState.parentId,
            contextId: contentState.contextId,
          );
    }

    if (!contentState.isLoading && contentState.progress == 100) {
      ref
          .read(geckoInferenceRepositoryProvider.notifier)
          .markInitialLoadComplete();
    }
  }

  /// Waits until [tabId] carries the engine's content state, and returns it.
  ///
  /// A tab reaches this map only once native has reported its content, and that
  /// report is not immediate: it crosses a per-tab diff natively and the
  /// database read in [patchedState] here. Anything acting on a *different*
  /// native event — a container site assignment, say — can therefore arrive
  /// first and find nothing, or find the partial entry an icon left behind.
  /// Both look like a tab that does not exist, and treating them that way is
  /// how a cancelled navigation ends up in a tab that never loads anything.
  ///
  /// Returns `null` if [timeout] passes first — long enough that only a tab
  /// native never reports at all runs it out — or if this provider is disposed
  /// while waiting.
  Future<TabState?> awaitContentState(
    String tabId, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final current = state[tabId];
    if (current != null && current.hasContentState) {
      return current;
    }

    final completer = Completer<TabState?>();
    _contentStateWaiters.putIfAbsent(tabId, () => []).add(completer);

    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      return null;
    } finally {
      // Read the map again rather than holding on to the list: [_put] detaches
      // it wholesale, and any waiter that arrived since is in a new one.
      final waiters = _contentStateWaiters[tabId];
      if (waiters != null) {
        waiters.remove(completer);
        if (waiters.isEmpty) {
          _contentStateWaiters.remove(tabId);
        }
      }
    }
  }

  Future<TabState> patchedState(String id) async {
    var current = stateOrNull?[id];

    if (current == null || current.url == TabState.defaultUrl) {
      current ??= TabState.$default(id);

      final tabData = await ref
          .read(tabDataRepositoryProvider.notifier)
          .getTabDataById(id);

      if (tabData?.url != null) {
        current = current.copyWith(
          title: tabData!.title ?? current.title,
          url: tabData.url ?? current.url,
        );
      }
    }

    return current;
  }

  Future<void> _onIconChange(IconChangeEvent event) async {
    final IconChangeEvent(:tabId, :bytes) = event;

    final image = await bytes.mapNotNull((bytes) => tryDecodeImage(bytes));

    if (!ref.mounted) {
      return;
    }

    final current = state[tabId] ?? TabState.$default(tabId);
    _put(tabId, current.copyWith.icon(image));
  }

  Future<void> _onThumbnailChange(ThumbnailEvent event) async {
    final ThumbnailEvent(:tabId, :bytes) = event;

    final image = await bytes.mapNotNull(
      (bytes) => tryDecodeImage(
        bytes,
        targetWidth: thumbnailDecodeWidth,
        allowUpscaling: false,
      ),
    );

    if (!ref.mounted) {
      return;
    }

    ref.read(tabThumbnailsProvider.notifier).update(tabId, image);
  }

  void _onSecurityInfoStateChange(SecurityInfoEvent event) {
    final SecurityInfoEvent(:tabId, :securityInfo) = event;

    final current = state[tabId] ?? TabState.$default(tabId);
    _put(
      tabId,
      current.copyWith.securityInfoState(
        SecurityState(
          secure: securityInfo.secure,
          host: securityInfo.host,
          issuer: securityInfo.issuer,
        ),
      ),
    );
  }

  void _onHistoryStateChange(HistoryEvent event) {
    final HistoryEvent(:tabId, :history) = event;

    ref
        .read(tabHistoryStatesProvider.notifier)
        .update(
          tabId,
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
    _put(
      tabId,
      current.copyWith.readerableState(
        ReaderableState(
          readerable: readerable.readerable,
          active: readerable.active,
        ),
      ),
    );
  }

  void _onTabTranslationStateChange(TabTranslationEvent event) {
    final TabTranslationEvent(:tabId, :state) = event;

    ref
        .read(tabTranslationStatesProvider.notifier)
        .update(tabId, TranslationState.fromData(state));
  }

  void _onFindResultsChange(FindResultsEvent event) {
    final FindResultsEvent(:tabId, :results) = event;
    final findResults = ref.read(tabFindResultStatesProvider.notifier);

    if (results.isNotEmpty) {
      final result = results.last;

      findResults.update(
        tabId,
        FindResultState(
          lastSearchText: ref.read(findInPageRepositoryProvider(tabId)),
          activeMatchOrdinal: result.activeMatchOrdinal,
          numberOfMatches: result.numberOfMatches,
          isDoneCounting: result.isDoneCounting,
        ),
      );
    } else if (findResults.resultFor(tabId).hasMatches) {
      findResults.update(tabId, FindResultState.$default());
    }
  }

  @override
  Map<String, TabState> build() {
    final eventService = ref.watch(eventServiceProvider);

    final subscriptions = [
      eventService.tabContentEvents.listen(
        (event) async {
          await _onTabContentStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in tab content events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.iconChangeEvents.listen(
        (event) async {
          await _onIconChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in icon change events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.thumbnailEvents.listen(
        (event) async {
          await _onThumbnailChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in thumbnail events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.securityInfoEvents.listen(
        (event) {
          _onSecurityInfoStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in security info events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.historyEvents.listen(
        (event) {
          _onHistoryStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in history events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.readerableEvents.listen(
        (event) {
          _onReaderableStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in readerable events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      // Gecko emits match counters at ~40/s while a find is running. 25ms let
      // essentially every one of those through; 100ms is still well under the
      // threshold where the counter feels laggy. Debounced *per tab* so a
      // background tab still counting can't starve the foreground one.
      eventService.findResultsEvent
          .groupBy((event) => event.tabId)
          .flatMap(
            (group) => group.debounceTime(const Duration(milliseconds: 100)),
          )
          .listen(
            (event) {
              _onFindResultsChange(event);
            },
            onError: (Object error, StackTrace stackTrace) {
              logger.e(
                'Error in find results events',
                error: error,
                stackTrace: stackTrace,
              );
            },
          ),
      eventService.tabTranslationEvents.listen(
        (event) {
          _onTabTranslationStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in tab translation events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
    ];

    ref.listen(
      fireImmediately: true,
      engineReadyStateProvider,
      (previous, next) async {
        if (next) {
          await GeckoTabService().syncEvents(
            onTabContentStateChange: true,
            onIconChange: true,
            onThumbnailChange: true,
            onSecurityInfoStateChange: true,
            onHistoryStateChange: true,
            onFindResults: true,
            onTranslationStateChange: true,
          );
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineReadyStateProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      for (final waiters in _contentStateWaiters.values.toList()) {
        for (final waiter in waiters) {
          waiter.complete(null);
        }
      }
      _contentStateWaiters.clear();

      for (final sub in subscriptions) {
        await sub.cancel();
      }
    });

    return {};
  }
}

@Riverpod()
TabState? tabState(Ref ref, String? tabId) {
  if (tabId == null) {
    return null;
  }

  return ref.watch(tabStatesProvider.select((tabs) => tabs[tabId]));
}

/// The only fields of [TabState] that tab filtering/sorting depends on.
class TabSortKeys with FastEquatable {
  final TabMode tabMode;
  final String titleOrAuthority;
  final String url;

  TabSortKeys({
    required this.tabMode,
    required this.titleOrAuthority,
    required this.url,
  });

  @override
  List<Object?> get hashParameters => [tabMode, titleOrAuthority, url];
}

/// Projection of [tabStatesProvider] for consumers that order or filter tabs
/// but render nothing from the state itself. Watching this instead of the full
/// map keeps the (expensive) grouping/sorting passes off the path of every
/// icon, security-info and readerable event.
@Riverpod(keepAlive: true)
EquatableValue<Map<String, TabSortKeys>> tabSortKeys(Ref ref) {
  return ref.watch(
    tabStatesProvider.select(
      (states) => EquatableValue({
        for (final MapEntry(:key, :value) in states.entries)
          key: TabSortKeys(
            tabMode: value.tabMode,
            titleOrAuthority: value.titleOrAuthority,
            url: value.url.toString(),
          ),
      }),
    ),
  );
}

@Riverpod()
Future<TabState> tabStateWithFallback(Ref ref, String tabId) async {
  final state = ref.watch(tabStateProvider(tabId));

  if (state != null) {
    return state;
  }

  return await ref.read(tabStatesProvider.notifier).patchedState(tabId);
}

@Riverpod()
Future<bool> isTabTunneled(Ref ref, String? tabId) async {
  final tabState = ref.watch(tabStateProvider(tabId));
  final proxyRoutingSettings = ref.watch(
    proxyRoutingSettingsWithDefaultsProvider,
  );

  if (tabState != null) {
    // Isolated tabs follow the same proxy rules as regular tabs
    // (container-based routing via proxy aliasing)
    if (tabState.tabMode is PrivateTabMode) {
      return proxyRoutingSettings.privateTabsProxyConnectionId != null;
    } else {
      switch (proxyRoutingSettings.regularTabsMode) {
        case ProxyRegularTabRoutingMode.container:
          final containerData = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getTabContainerData(tabState.id);

          if (!ref.mounted) return false;

          return containerData?.metadata.proxyConnectionId != null;
        case ProxyRegularTabRoutingMode.all:
          final containerData = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getTabContainerData(tabState.id);

          if (!ref.mounted) return false;

          if (containerData?.metadata.proxyConnectionId != null) {
            return true;
          }
          if (containerData?.metadata.bypassGlobalProxy == true) {
            return false;
          }

          return proxyRoutingSettings.regularTabsProxyConnectionId != null;
      }
    }
  }

  return false;
}

@Riverpod()
TabState? selectedTabState(Ref ref) {
  final tabId = ref.watch(selectedTabProvider);
  return ref.watch(tabStateProvider(tabId));
}

@Riverpod()
TabType? selectedTabType(Ref ref) {
  final selectedState = ref.watch(selectedTabStateProvider);

  return selectedState?.tabMode.toTabType();
}

@Riverpod()
AsyncValue<String?> selectedTabContainerId(Ref ref) {
  final tabId = ref.watch(selectedTabProvider);
  if (tabId != null) {
    return ref.watch(watchContainerTabIdProvider(tabId));
  }

  return const AsyncData(null);
}

// @Riverpod()
// Stream<int> tabScrollY(Ref ref, String? tabId, Duration sampleTime) {
//   final eventService = ref.watch(eventServiceProvider);

//   return eventService.scrollEvent
//       .where((event) => event.tabId == tabId)
//       .sampleTime(sampleTime)
//       .map((event) => event.scrollY)
//       .asBroadcastStream();
// }
