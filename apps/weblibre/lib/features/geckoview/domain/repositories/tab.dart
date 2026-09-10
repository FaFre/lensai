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

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/pending_tab_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/controllers/home_target_controller.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/utils/debouncer.dart';

part 'tab.g.dart';

@visibleForTesting
ContainerData? resolveAssignedContainerForTabOpen({
  required TabContainerSelection containerSelection,
  required ContainerData? requestedContainer,
  required ContainerData? siteAssignedContainer,
}) {
  return switch (containerSelection) {
    UseSelectedContainerTabSelection() =>
      siteAssignedContainer ?? requestedContainer,
    UnassignedContainerTabSelection() ||
    SpecificContainerTabSelection() => requestedContainer,
  };
}

/// The tab one step from [currentTabId] in [order], or `null` when there is no
/// step to take.
///
/// Kept as a pure function so the whole of sequential navigation's decision
/// making can be exercised without an engine: which tab is next is settled
/// here, and the repository only carries out the selection.
///
/// Returns `null` — never a fallback pick — in each case where the sequence
/// gives no answer:
///
/// - [currentTabId] is absent from [order]: it is out of this walk's reach
///   (another container, or a tab the engine has not reported yet), so nothing
///   in [order] is "adjacent" to it. Entering at an end instead is what made a
///   swipe jump across the strip in issue #603;
/// - the step falls off an end and [loop] is off;
/// - [order] holds fewer than two tabs, where even a wrap would land back on
///   the tab the user is already looking at, which is not a step.
@visibleForTesting
String? adjacentTabIdInOrder({
  required List<String> order,
  required String currentTabId,
  required bool selectPrevious,
  required bool loop,
}) {
  final index = order.indexOf(currentTabId);
  if (index < 0 || order.length < 2) {
    return null;
  }

  final targetIndex = selectPrevious ? index - 1 : index + 1;

  if (targetIndex < 0) {
    return loop ? order.last : null;
  }
  if (targetIndex >= order.length) {
    return loop ? order.first : null;
  }

  return order[targetIndex];
}

sealed class TabBackPromptBehavior {
  const TabBackPromptBehavior();
}

final class BackgroundAppTabBackPromptBehavior extends TabBackPromptBehavior {
  const BackgroundAppTabBackPromptBehavior();
}

final class ReturnToSearchTabBackPromptBehavior extends TabBackPromptBehavior {
  final TabType tabType;

  const ReturnToSearchTabBackPromptBehavior({required this.tabType});
}

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();
  final _sessionStartedAt = DateTime.now();
  bool _didPruneTombstones = false;
  bool _reclosing = false;
  bool _suppressNextReclose = false;

  final _tabBackPromptBehavior = <String, TabBackPromptBehavior>{};
  final _closeLock = Lock();
  final _pendingIsolationCleanup = <String>{};

  /// The site-assignment request currently being handled for each tab.
  ///
  /// Handling one means waiting for the tab's content state and then reading
  /// containers out of the database, and the engine can start another
  /// navigation in that tab in the meantime. The earlier request is obsolete
  /// once that happens: reopening its URL would pull the tab back to a page the
  /// engine has already left.
  final _latestAssignmentRequests = <String, String>{};

  TabBackPromptBehavior? backPromptBehaviorFor(String? tabId) {
    if (tabId == null) {
      return null;
    }

    return _tabBackPromptBehavior[tabId];
  }

  void clearBackPromptBehavior(String tabId) {
    _tabBackPromptBehavior.remove(tabId);
  }

  /// Validates the opener of a tab that is about to be created.
  ///
  /// The link is kept even when the new tab lands in a *different* container
  /// than its opener. Following a link into a container-assigned site reopens
  /// that site over there, and the opener is then the only way back once the
  /// reopened tab runs out of its own history — cutting the link stranded the
  /// user in the target container (#530).
  ///
  /// Only a parent that has no row (yet) is dropped: `tab.parent_id` carries a
  /// self-referential foreign key, so writing a dangling id would abort the
  /// insert transaction.
  Future<String?> _resolveParentId(String? parentId) async {
    if (parentId == null) {
      return null;
    }

    final parent = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabDataById(parentId)
        .getSingleOrNull();

    return parent != null ? parentId : null;
  }

  Future<String> addTab({
    required TabMode tabMode,
    Uri? url,
    required bool selectTab,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Source source = Internal.newTab,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
    TabContainerSelection containerSelection =
        const TabContainerSelection.useSelected(),
    bool launchedFromIntent = false,
    TabBackPromptBehavior? promptOnBackBehavior,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    var assignedContainer = switch (containerSelection) {
      UseSelectedContainerTabSelection() =>
        await ref.read(selectedContainerProvider.notifier).fetchData(),
      UnassignedContainerTabSelection() => null,
      SpecificContainerTabSelection(:final container) => container,
    };

    if (tabMode is RegularTabMode &&
        url != null &&
        url.hasAuthority &&
        url.isHttpOrHttps) {
      final siteAssignedContainerId = await ref
          .read(containerRepositoryProvider.notifier)
          .siteAssignedContainerId(url);
      final siteAssignedContainer = await siteAssignedContainerId.mapNotNull(
        (id) =>
            ref.read(containerRepositoryProvider.notifier).getContainerData(id),
      );

      assignedContainer = resolveAssignedContainerForTabOpen(
        containerSelection: containerSelection,
        requestedContainer: assignedContainer,
        siteAssignedContainer: siteAssignedContainer,
      );
    }

    final validatedParentId = await _resolveParentId(parentId);

    final effectiveIsolationContextId = tabMode.isolationContextId;

    final effectiveContextId = tabMode is IsolatedTabMode
        ? effectiveIsolationContextId
        : assignedContainer?.metadata.contextualIdentity;

    final newTabId = await tabDao.upsertTabTransactional(
      () {
        return _tabsService.addTab(
          url: url,
          selectTab: selectTab,
          startLoading: startLoading,
          parentId: validatedParentId,
          flags: flags,
          contextId: effectiveContextId,
          source: source,
          private: tabMode is PrivateTabMode,
          historyMetadata: historyMetadata,
          additionalHeaders: additionalHeaders,
          // Carried into the engine so the exclusion is in place before the tab
          // loads; the replicated snapshot only follows once its row is written.
          excludeFromHistory:
              assignedContainer?.metadata.excludeFromHistory ?? false,
        );
      },
      parentId: Value(validatedParentId),
      containerId: Value(assignedContainer?.id),
      url: Value(url),
      tabMode: Value(tabMode),
    );

    if (launchedFromIntent) {
      _tabBackPromptBehavior[newTabId] =
          promptOnBackBehavior ?? const BackgroundAppTabBackPromptBehavior();
    } else if (promptOnBackBehavior != null) {
      _tabBackPromptBehavior[newTabId] = promptOnBackBehavior;
    }

    if (selectTab && ref.mounted) {
      _clearForceBrowserHome();

      final selectedContainerNotifier = ref.read(
        selectedContainerProvider.notifier,
      );
      if (assignedContainer != null) {
        await selectedContainerNotifier.setContainerId(assignedContainer.id);
      } else {
        selectedContainerNotifier.clearContainer();
      }
    }

    return newTabId;
  }

  Future<bool> _closeRestoredPrivateCaptureTabs(List<String> tabIds) async {
    if (tabIds.isEmpty) {
      return false;
    }

    final captureRows = await ref
        .read(tabDatabaseProvider)
        .captureTabDao
        .findAll();
    final tabStates = ref.read(tabStatesProvider);
    final restoredPrivateCaptureTabIds = captureRows
        .where((row) => row.createdAt.isBefore(_sessionStartedAt))
        .map((row) => row.tabId)
        .where((tabId) => tabIds.contains(tabId))
        .where((tabId) => tabStates[tabId]?.tabMode is PrivateTabMode)
        .toList(growable: false);

    if (restoredPrivateCaptureTabIds.isEmpty) {
      return false;
    }

    await _closeTabsInternal(
      restoredPrivateCaptureTabIds,
      recordTombstones: false,
    );
    return true;
  }

  Future<List<String>> addMultipleTabs({
    required List<AddTabParams> tabs,
    String? selectTabId,
    TabContainerSelection containerSelection =
        const TabContainerSelection.unassigned(),
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final db = ref.read(tabDatabaseProvider);
    final assignedContainer = switch (containerSelection) {
      UseSelectedContainerTabSelection() =>
        await ref.read(selectedContainerProvider.notifier).fetchData(),
      UnassignedContainerTabSelection() => null,
      SpecificContainerTabSelection(:final container) => container,
    };

    final createdTabIds = await db.transaction(() async {
      final createdTabIds = await _tabsService.addMultipleTabs(
        tabs: tabs,
        selectTabId: selectTabId,
        // Carried into the engine so the exclusion is in place before these tabs
        // load; the replicated snapshot only follows once their rows are
        // written. One value for the batch — they all land in this container.
        excludeFromHistory:
            assignedContainer?.metadata.excludeFromHistory ?? false,
      );
      // Build sets for validation
      final creatingTabIds = createdTabIds.toSet();
      final parentIdsToValidate = tabs
          .map((tab) => tab.parentId)
          .whereType<String>()
          .where((id) => !creatingTabIds.contains(id))
          .toSet();

      // Batch validate parent IDs that aren't in the current creation batch
      final existingParentIds = await tabDao
          .getExistingTabIds(parentIdsToValidate)
          .get()
          .then((ids) => ids.toSet());

      // Upsert all tabs in the database
      for (var i = 0; i < createdTabIds.length; i++) {
        final tabId = createdTabIds[i];
        final tab = tabs[i];

        // Validate parent exists in either the batch being created or database
        String? validatedParentId;
        if (tab.parentId != null) {
          if (creatingTabIds.contains(tab.parentId) ||
              existingParentIds.contains(tab.parentId)) {
            validatedParentId = tab.parentId;
          }
        }

        await tabDao.insertTab(
          tabId,
          parentId: Value(validatedParentId),
          source: TabSource.manual,
          containerId: Value(assignedContainer?.id),
          url: Value(Uri.tryParse(tab.url)),
          tabMode: Value(
            isIsolatedContextId(tab.contextId)
                ? TabMode.isolated(tab.contextId!)
                : tab.private
                ? TabMode.private
                : TabMode.regular,
          ),
        );
      }

      return createdTabIds;
    });

    if (selectTabId != null && ref.mounted) {
      _clearForceBrowserHome();
    }

    return createdTabIds;
  }

  Future<String> duplicateTab({
    required String selectTabId,
    required ContainerData? containerData,
    required bool selectTab,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    final sourceTabMode =
        await tabDao.getTabMode(selectTabId).getSingleOrNull() ??
        TabMode.regular;

    // Duplicating an isolated tab creates a new isolation group
    final duplicateIsolationContextId = sourceTabMode is IsolatedTabMode
        ? newIsolatedContextId()
        : null;

    final duplicateTabMode = sourceTabMode is IsolatedTabMode
        ? TabMode.isolated(duplicateIsolationContextId!)
        : sourceTabMode;

    // Isolated tabs always use their isolation context ID
    final effectiveContextId = sourceTabMode is IsolatedTabMode
        ? duplicateIsolationContextId
        : containerData?.metadata.contextualIdentity;

    // Place the duplicate as a sibling of the source — same parent — and
    // insert it right after the source's full subtree, so existing
    // children of the source are not split from their parent.
    final sourceData = await tabDao
        .getTabDataById(selectTabId)
        .getSingleOrNull();
    final sourceParentId = sourceData?.parentId;
    final anchorTabId =
        await tabDao
            .lastSubtreeTabIdByOrderKey(
              selectTabId,
              containerId: containerData?.id,
            )
            .getSingleOrNull() ??
        selectTabId;

    final newTabId = await tabDao.upsertTabTransactional(
      () {
        return _tabsService.duplicateTab(
          selectTabId: selectTabId,
          newContextId: effectiveContextId,
          selectNewTab: selectTab,
          excludeFromHistory:
              containerData?.metadata.excludeFromHistory ?? false,
        );
      },
      parentId: Value(sourceParentId),
      afterTabId: Value(anchorTabId),
      containerId: Value(containerData?.id),
      tabMode: Value(duplicateTabMode),
    );

    // The duplicate is a new isolation group, so it starts with no route of its
    // own — carry the source's over, or the copy silently falls back to its
    // container's routing.
    if (sourceTabMode case IsolatedTabMode(
      :final isolationContextId,
    ) when ref.mounted) {
      await ref
          .read(proxyRoutingSettingsRepositoryProvider.notifier)
          .copyIsolationContextRoute(
            isolationContextId,
            duplicateIsolationContextId!,
          );
    }

    if (selectTab && ref.mounted) {
      _clearForceBrowserHome();
    }

    return newTabId;
  }

  Future<bool> selectPreviouslyOpenedTab(String tabId) async {
    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByTimestamp(tabId: tabId)
        .getSingleOrNull();

    if (ref.mounted && previousTabId != null) {
      return selectTab(previousTabId);
    }

    return false;
  }

  Future<bool> resumeLatestTab({Set<String> excludedTabIds = const {}}) async {
    final latestTab = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabsFifo(limit: 1, excludedTabIds: excludedTabIds)
        .getSingleOrNull();

    if (!ref.mounted || latestTab == null) {
      return false;
    }

    return selectTab(latestTab.id);
  }

  Future<bool> resumeLatestContainerTab(
    String? containerId, {
    Set<String> excludedTabIds = const {},
  }) async {
    final latestTab = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getContainerTabsFifo(
          containerId,
          limit: 1,
          excludedTabIds: excludedTabIds,
        )
        .getSingleOrNull();

    if (!ref.mounted || latestTab == null) {
      return false;
    }

    return selectTab(latestTab.id);
  }

  Future<bool> selectPreviousTab(
    String tabId, {
    String? containerId,
    bool skipContainerCheck = true,
  }) => _selectAdjacentTab(
    tabId,
    containerId: containerId,
    skipContainerCheck: skipContainerCheck,
    selectPrevious: true,
  );

  Future<bool> selectNextTab(
    String tabId, {
    String? containerId,
    bool skipContainerCheck = true,
  }) => _selectAdjacentTab(
    tabId,
    containerId: containerId,
    skipContainerCheck: skipContainerCheck,
    selectPrevious: false,
  );

  /// Moves the selection one step through the tab sequence.
  ///
  /// Calls that cross containers ([skipContainerCheck] with no explicit
  /// [containerId]) — the tab bar swipe and the next/previous tab gestures —
  /// step through the *rendered* order
  /// ([sequentialTabNavigationOrderProvider]) so navigation matches the tabs the
  /// user sees: the same grouping and pinned-first handling the quick tab
  /// switcher and the tab bar draw, and deliberately none of the tray's own
  /// filters, collapsed groups or sort (see [TabListScope]). That order spans
  /// every populated container while `sequentialTabNavigationCrossContainers` is
  /// on, so this keeps walking past a container boundary exactly like the
  /// storage-order walk did; with the setting off it holds the selected
  /// container only and the walk ends there. It is authoritative once it
  /// exists, and every outcome stays inside it:
  ///
  /// - current tab in the order: step one row, stopping at either end — or
  ///   continuing at the opposite end when `sequentialTabNavigationLoop` is on;
  /// - current tab outside it: do nothing. Since the order excludes nothing,
  ///   the current tab is missing only when it is not in this walk's reach at
  ///   all — another container with cross-container navigation off, or a tab the
  ///   engine has not reported yet. Neither says anything about which tab is
  ///   "next", so there is no step to take; selecting an end of the order
  ///   instead (as this did before #603) turned a swipe into a jump across the
  ///   whole strip.
  /// - nothing visible at all: do nothing.
  ///
  /// Looping is deliberately confined to this path: the storage-order fallback
  /// below serves container-scoped stepping and the window before the tree data
  /// has loaded, where there is no rendered sequence whose ends could be joined.
  ///
  /// The storage-order path is left for calls that scope navigation to a single
  /// container (which the cross-container order cannot answer) and for the brief
  /// window before the tree data has loaded.
  Future<bool> _selectAdjacentTab(
    String tabId, {
    required String? containerId,
    required bool skipContainerCheck,
    required bool selectPrevious,
  }) async {
    if (containerId == null && skipContainerCheck) {
      final visibleOrder = ref.read(sequentialTabNavigationOrderProvider).value;

      if (visibleOrder != null) {
        final targetTabId = adjacentTabIdInOrder(
          order: visibleOrder,
          currentTabId: tabId,
          selectPrevious: selectPrevious,
          loop: ref
              .read(generalSettingsWithDefaultsProvider)
              .sequentialTabNavigationLoop,
        );

        // The rendered order is authoritative once it exists: having no step to
        // take within it is an answer, not a reason to consult storage order.
        return targetTabId != null && await selectTab(targetTabId);
      }
    }

    final adjacentTabId = await _adjacentVisibleTabByOrder(
      tabId,
      containerId: containerId,
      skipContainerCheck: skipContainerCheck,
      selectPrevious: selectPrevious,
    );

    if (ref.mounted && adjacentTabId != null) {
      return selectTab(adjacentTabId);
    }

    return false;
  }

  Future<bool> selectTab(String tabId) async {
    // The tab is still a pre-restore placeholder (known to the DB but not to
    // the engine yet): queue the selection until the native state arrives.
    if (!ref.read(browserRestoreCompleteProvider) &&
        !ref.read(tabStatesProvider).containsKey(tabId)) {
      ref.read(pendingTabSelectionProvider.notifier).queue(tabId);
      _clearForceBrowserHome();
      return true;
    }

    final containerData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabContainerData(tabId);

    if (!ref.mounted) return false;

    if (containerData != null) {
      if (containerData.metadata.proxyConnectionId != null) {
        // Routing has to be *installed*, not merely answering: an extension
        // that responds but holds no snapshot blocks this container's traffic,
        // so opening the tab would only show a broken page.
        //
        // Waited on rather than sampled, because the install window is a normal
        // part of a cold start and a tap that lands inside it should open the
        // tab a moment later instead of doing nothing at all.
        final routingReady = await ref
            .read(containerProxyRepositoryProvider.notifier)
            .waitUntilRoutingReady();

        if (!ref.mounted) return false;

        if (!routingReady) {
          logger.w(
            'Tried to open proxied tab $tabId before container routing was installed',
          );
          return false;
        }
      }
    }

    _clearForceBrowserHome();
    await _tabsService.selectTab(tabId: tabId);
    return true;
  }

  /// Cancels a pending "stay on home", because something is about to be shown.
  ///
  /// Done explicitly at each selection rather than by listening to the selected
  /// tab: the engine selects tabs on its own (restore, session recovery) and
  /// such a listener would immediately undo the flag the home target had just
  /// set. Call it only once the selection is certain — a proxy healthcheck can
  /// still refuse it, and discarding the flag then would drop the user off home
  /// without putting anything in its place.
  void _clearForceBrowserHome() {
    ref.read(forceBrowserHomeProvider.notifier).clear();
  }

  /// Selects [tabId] on behalf of the engine's own follow-up logic, i.e. not
  /// because the user asked for this particular tab.
  ///
  /// Still counts as leaving home: a neighbour is now on screen, so a
  /// "stay on home" left over from an earlier close no longer describes
  /// anything. Safe against the home target's own flag, because the branch of
  /// [_selectNextTab] that sets it is reached only when nothing was selected
  /// here.
  Future<void> _selectTabAfterClose(String tabId) async {
    _clearForceBrowserHome();
    await _tabsService.selectTab(tabId: tabId);
  }

  Future<String?> _adjacentVisibleTabByOrder(
    String tabId, {
    required String? containerId,
    required bool skipContainerCheck,
    required bool selectPrevious,
  }) {
    // Storage-order walk: neighbours by `order_key` only, so it sees neither
    // the tray's sort and filters nor its grouping. User-facing sequential
    // navigation goes through the rendered order in [_selectAdjacentTab] and
    // reaches this only as a fallback; what remains here is picking a tab
    // after a close and container-scoped stepping.
    //
    // "Previous/next" is interpreted relative to the *tab bar* direction,
    // which is the only direction this path has to go by.
    final newestFirst =
        ref.read(generalSettingsWithDefaultsProvider).tabBarDirection ==
        TabDirection.newestFirst;
    final TabDatabase tabDatabase = ref.read(tabDatabaseProvider);
    final definitions = tabDatabase.definitionsDrift;

    if (newestFirst == selectPrevious) {
      return definitions
          .nextTabByOrderKey(
            tabId: tabId,
            containerId: containerId,
            skipContainerCheck: skipContainerCheck,
          )
          .getSingleOrNull();
    }

    return definitions
        .previousTabByOrderKey(
          tabId: tabId,
          containerId: containerId,
          skipContainerCheck: skipContainerCheck,
        )
        .getSingleOrNull();
  }

  Future<String?> _nearestAvailableVisibleTabByOrder(
    String tabId, {
    required String? containerId,
    required Set<String> excludedTabIds,
  }) async {
    Future<String?> walkDirection({required bool selectPrevious}) async {
      var candidate = await _adjacentVisibleTabByOrder(
        tabId,
        containerId: containerId,
        skipContainerCheck: false,
        selectPrevious: selectPrevious,
      );

      while (candidate != null) {
        if (!excludedTabIds.contains(candidate)) {
          return candidate;
        }

        candidate = await _adjacentVisibleTabByOrder(
          candidate,
          containerId: containerId,
          skipContainerCheck: false,
          selectPrevious: selectPrevious,
        );
      }

      return null;
    }

    return await walkDirection(selectPrevious: true) ??
        await walkDirection(selectPrevious: false);
  }

  /// Nearest still-open ancestor of [tabId], or `null` when the chain runs out.
  ///
  /// The stored chain is the authority: `tab_maintain_parent_chain_on_delete`
  /// repoints a child at its grandparent as soon as the parent row goes away,
  /// whereas the engine's `parentId` only reaches Dart with that tab's *next*
  /// content-state event and can still name a tab that is already closed. The
  /// engine value is therefore only consulted while the row itself is missing,
  /// i.e. before the insert for a freshly opened tab has landed.
  ///
  /// An ancestor in another container is a valid target: selecting it moves the
  /// tray along with it (see `SelectedContainer`), which is the way back out of
  /// a container a link pulled the user into (#530).
  Future<String?> _nearestAvailableAncestor(
    String tabId, {
    required Set<String> excludedTabIds,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final row = await tabDao.getTabDataById(tabId).getSingleOrNull();

    if (!ref.mounted) return null;

    var candidate = row != null
        ? row.parentId
        : ref.read(tabStatesProvider)[tabId]?.parentId;

    final liveTabIds = ref.read(tabListProvider).value.toSet();
    final visited = <String>{tabId};

    while (candidate != null && visited.add(candidate)) {
      if (!excludedTabIds.contains(candidate) &&
          liveTabIds.contains(candidate)) {
        return candidate;
      }

      // Closing an ancestor together with this tab (or an engine tab that never
      // materialised) is not the end of the chain — keep climbing.
      final ancestor = await tabDao.getTabDataById(candidate).getSingleOrNull();

      if (!ref.mounted) return null;

      candidate = ancestor?.parentId;
    }

    return null;
  }

  Future<void> _selectNextTab(
    String tabId, {
    Set<String> excludedTabIds = const {},
  }) async {
    final tabState = ref.read(tabStatesProvider)[tabId];

    final currentContainerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabContainerId(tabId);

    if (!ref.mounted) return;

    final sameContainerTabs = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerTabIds(currentContainerId)
        .then(
          (tabs) => tabs
              .where((tab) => tab != tabId && !excludedTabIds.contains(tab))
              .toList(),
        );

    if (!ref.mounted) return;

    // Priority 1: hand the user back to whoever opened this tab, across
    // containers if that is where the opener lives.
    final ancestorTabId = await _nearestAvailableAncestor(
      tabId,
      excludedTabIds: excludedTabIds,
    );

    if (!ref.mounted) return;

    if (ancestorTabId != null) {
      return _selectTabAfterClose(ancestorTabId);
    }

    // Priority 2: Check for previous tab by timestamp
    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByTimestamp(tabId: tabId)
        .getSingleOrNull();

    if (previousTabId != null) {
      if (sameContainerTabs.any((tab) => tab == previousTabId)) {
        return _selectTabAfterClose(previousTabId);
      }
    }

    if (!ref.mounted) return;

    final orderedNeighborTabId = await _nearestAvailableVisibleTabByOrder(
      tabId,
      containerId: currentContainerId,
      excludedTabIds: excludedTabIds,
    );

    if (orderedNeighborTabId != null) {
      return _selectTabAfterClose(orderedNeighborTabId);
    }

    if (!ref.mounted) return;

    // Out of candidates in this container. By default the search widens to
    // unassigned tabs and then to other containers, which drags the user out
    // of the container they were working in; the home target keeps them here.
    if (ref
        .read(generalSettingsWithDefaultsProvider)
        .homeTargetOnLastTabClosed) {
      await ref
          .read(homeTargetControllerProvider.notifier)
          .applyTarget(
            // currentContainerId is null for the unassigned container, which is
            // still a scope to stay inside — hence the explicit flag.
            scopeToContainer: true,
            containerId: currentContainerId,
            closingTabUrl: tabState?.url,
            // Tab rows outlive this call — they are deleted only after the next
            // selection is made — so without this the resume would pick the
            // very tab being closed, which sorts first as the active one.
            excludedTabIds: {...excludedTabIds, tabId},
          );
      return;
    }

    final unassignedTabs = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerTabIds(null)
        .then(
          (tabs) => tabs
              .where((tab) => tab != tabId && !excludedTabIds.contains(tab))
              .toList(),
        );

    if (unassignedTabs.isNotEmpty) {
      return _selectTabAfterClose(unassignedTabs.first);
    }

    if (!ref.mounted) return;

    final availableContainers = await ref
        .read(containerRepositoryProvider.notifier)
        .getAllContainersWithCount();

    final nextAvailableContainer = availableContainers.firstOrNull;

    if (!ref.mounted) return;

    final nextContainerTabs = await nextAvailableContainer.mapNotNull(
      (container) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerTabIds(container.id)
          .then(
            (tabs) => tabs
                .where((tab) => tab != tabId && !excludedTabIds.contains(tab))
                .toList(),
          ),
    );

    if (nextContainerTabs.isNotEmpty) {
      return _selectTabAfterClose(nextContainerTabs!.first);
    }
  }

  Future<void> _closeTabsInternal(
    List<String> tabIds, {
    required bool recordTombstones,
  }) {
    return _closeLock.synchronized(() async {
      if (tabIds.isEmpty) {
        return;
      }

      if (recordTombstones) {
        await ref
            .read(tabDatabaseProvider)
            .tabDao
            .addClosedTabTombstones(tabIds);
      }

      for (final tabId in tabIds) {
        _tabBackPromptBehavior.remove(tabId);
        final isolationContextId = ref
            .read(tabStatesProvider)[tabId]
            ?.isolationContextId;
        if (isolationContextId != null) {
          _pendingIsolationCleanup.add(isolationContextId);
        }
      }

      final selectedTab = ref.read(selectedTabProvider);
      if (selectedTab.mapNotNull(tabIds.contains) ?? false) {
        await _selectNextTab(selectedTab!, excludedTabIds: tabIds.toSet());
      }

      await _preservePromotedChildOrderOnClose(tabIds);

      if (tabIds.length == 1) {
        await _tabsService.removeTab(tabId: tabIds.single);
      } else {
        await _tabsService.removeTabs(ids: tabIds);
      }
    });
  }

  Future<void> closeTab(String tabId) {
    return _closeTabsInternal([tabId], recordTombstones: true);
  }

  Future<void> closeTabs(List<String> tabIds) {
    return _closeTabsInternal(tabIds, recordTombstones: true);
  }

  Future<void> _clearTombstonesForCurrentTabs(List<String> tabIds) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .deleteClosedTabTombstones(tabIds);
  }

  Future<void> _preservePromotedChildOrderOnClose(List<String> tabIds) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .preservePromotedChildOrderOnClose(tabIds);
  }

  /// Clears Gecko browsing data and removes proxy alias for an isolation
  /// context if no more tabs share it.
  Future<void> _cleanupIsolationContextIfEmpty(String contextId) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    // Re-verify count after close (handles concurrent close races)
    final remaining = await tabDao.tabsInIsolationGroup(contextId).getSingle();

    if (remaining > 0) return;

    // Guard against debounced DB persistence: a sibling tab can already be
    // active in-memory for this context before isolation_context_id is written.
    final activeTabs = ref.read(tabListProvider).value;
    final activeStates = ref.read(tabStatesProvider);
    final hasActiveSibling = activeTabs.any((tabId) {
      final state = activeStates[tabId];
      if (state == null) return false;

      return state.isolationContextId == contextId ||
          state.contextId == contextId;
    });

    if (hasActiveSibling) {
      logger.i(
        'Skipping isolation cleanup for active context still in memory: $contextId',
      );
      return;
    }

    logger.i('Cleaning up isolation context: $contextId');

    // Clear Gecko browsing data for this context
    try {
      await ref
          .read(browserDataServiceProvider.notifier)
          .clearDataForContext(contextId);
    } catch (e, st) {
      logger.e(
        'Failed to clear data for isolation context $contextId',
        error: e,
        stackTrace: st,
      );
    }

    // The alias derived from the group's container needs no teardown: it is
    // computed from the tabs that reference the context, so dropping those tabs
    // removes it from the next routing snapshot. A route the *user* set on the
    // group is stored, though, and would outlive every tab that could use it.
    if (!ref.mounted) return;

    try {
      await ref
          .read(proxyRoutingSettingsRepositoryProvider.notifier)
          .clearIsolationContextRoute(contextId);
    } catch (e, st) {
      logger.e(
        'Failed to drop the isolation route for $contextId',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _drainPendingIsolationCleanup() async {
    if (_pendingIsolationCleanup.isEmpty) return;

    final pending = Set<String>.of(_pendingIsolationCleanup);
    _pendingIsolationCleanup.clear();

    for (final contextId in pending) {
      if (!ref.mounted) break;
      await _cleanupIsolationContextIfEmpty(contextId);
    }
  }

  Future<void> undoClose() {
    // Suppress the next reclose pass: undo can resurrect a tab whose
    // tombstone is still on disk (from a previous session); without this
    // flag the listener would immediately re-close it.
    _suppressNextReclose = true;
    return _tabsService.undo();
  }

  Future<bool> _recloseRestoredClosedTabs(List<String> tabIds) async {
    if (_reclosing) {
      return false;
    }
    _reclosing = true;
    try {
      final tabDao = ref.read(tabDatabaseProvider).tabDao;

      if (!_didPruneTombstones) {
        await tabDao.pruneExpiredClosedTabTombstones();
        _didPruneTombstones = true;
      }

      final restoredClosedTabIds = await tabDao.getStartupRestoredClosedTabIds(
        tabIds,
        sessionStartedAt: _sessionStartedAt,
      );

      if (restoredClosedTabIds.isEmpty) {
        return false;
      }

      // recordTombstones: false — the tombstone already exists from the
      // original close; rewriting it would bump closed_at into this session
      // and disable the resurrection check on the next emission.
      await _closeTabsInternal(
        restoredClosedTabIds.toList(growable: false),
        recordTombstones: false,
      );

      return true;
    } finally {
      _reclosing = false;
    }
  }

  /// Cleans up isolation contexts from previous crashed sessions.
  /// Called once after tab list stabilizes on startup.
  // Future<void> _cleanupOrphanedIsolationContexts() async {
  //   final tabDao = ref.read(tabDatabaseProvider).tabDao;

  //   try {
  //     await _closeLock.synchronized(() async {
  //       if (!ref.mounted) return;

  //       // Reconcile DB rows against the current engine tab snapshot, including
  //       // valid empty-tab sessions (retainTabIds can be empty here).
  //       final syncTabsResult = await tabDao.syncTabs(
  //         retainTabIds: ref.read(tabListProvider).value,
  //       );
  //       _pendingIsolationCleanup.addAll(
  //         syncTabsResult.deletedIsolationContextIds,
  //       );

  //       if (_pendingIsolationCleanup.isNotEmpty) {
  //         final pending = Set<String>.of(_pendingIsolationCleanup);
  //         _pendingIsolationCleanup.clear();

  //         for (final contextId in pending) {
  //           if (!ref.mounted) return;
  //           logger.i('Cleaning orphaned isolation context: $contextId');
  //           await _cleanupIsolationContextIfEmpty(contextId);
  //         }
  //       }
  //     });
  //   } catch (e, st) {
  //     logger.e(
  //       'Error during orphan isolation context cleanup',
  //       error: e,
  //       stackTrace: st,
  //     );
  //   }
  // }

  /// Reopens a navigation the container extension cancelled, in the container
  /// the site is assigned to.
  ///
  /// The extension cancels the request natively and reports it here. Nothing
  /// else retries it, so a report this drops leaves the tab sitting on a
  /// navigation that will never happen.
  Future<void> _handleSiteAssignment(ContainerSiteAssignment event) async {
    // Strict-mode blocks have no destination container to re-open into; the
    // navigation was already cancelled natively and the user is notified via
    // a snackbar (see the strict-block listener in the app shell). Nothing
    // to reconcile here.
    if (event.strict) {
      return;
    }

    final tabId = event.tabId;
    if (tabId == null) {
      logger.w(
        'Site assignment for ${event.url} names no tab; nothing to reopen',
      );
      return;
    }

    _latestAssignmentRequests[tabId] = event.requestId;
    bool isCurrentRequest() =>
        ref.mounted && _latestAssignmentRequests[tabId] == event.requestId;

    try {
      // Not `ref.read(tabStatesProvider)[tabId]`: this event reaches Dart the
      // moment the extension answers, which for a tab opened by the very
      // navigation being cancelled is before the tab itself does.
      final tabState = await ref
          .read(tabStatesProvider.notifier)
          .awaitContentState(tabId);

      if (!isCurrentRequest()) {
        return;
      }

      if (tabState == null) {
        logger.w(
          'Gave up waiting for tab $tabId to reopen ${event.url} in its '
          'assigned container',
        );
        return;
      }

      final uri = Uri.parse(event.url);
      final originUri = event.originUrl.mapNotNull(Uri.parse);

      final targetContainerId = await ref
          .read(containerRepositoryProvider.notifier)
          .siteAssignedContainerId(Uri.parse(uri.origin));

      if (!isCurrentRequest()) {
        return;
      }

      final containerData = await targetContainerId.mapNotNull(
        (id) =>
            ref.read(containerRepositoryProvider.notifier).getContainerData(id),
      );

      if (!isCurrentRequest() || containerData == null) {
        return;
      }

      final currentTabState = ref.read(tabStatesProvider)[tabId];
      if (currentTabState == null) {
        logger.w(
          'Tab $tabId disappeared before ${event.url} could be reopened',
        );
        return;
      }

      // The tab is already in the target container, so there is nothing
      // to reconcile. This notably fires when reassigning a tab into a
      // container that shares the default Gecko context: assignContainer
      // recreates the tab in the target container, and that new tab's
      // load re-triggers this event. Without this guard the transiently
      // empty new tab would be treated as an empty tab and churn yet
      // another tab (re-prompting app-links).
      final currentTabContainerId = await ref
          .read(tabDataRepositoryProvider.notifier)
          .getTabContainerId(currentTabState.id);
      if (!isCurrentRequest() || currentTabContainerId == targetContainerId) {
        return;
      }

      final historyIsEmpty =
          ref
              .read(tabHistoryStatesProvider)[currentTabState.id]
              ?.items
              .isEmpty ??
          true;

      final tabIsEmpty =
          currentTabState.url == TabState.defaultUrl && historyIsEmpty;

      if (event.blocked || tabIsEmpty) {
        final newTabId = await addTab(
          url: uri,
          tabMode: currentTabState.tabMode,
          containerSelection: TabContainerSelection.specific(containerData),
          parentId: currentTabState.id,
          selectTab: true,
        );

        // Past the point of no return. The replacement tab exists, so the swap
        // is finished even if a newer navigation has claimed this tab since —
        // abandoning it here would leave the new tab created but unselected.
        if (historyIsEmpty && ref.mounted) {
          await closeTab(currentTabState.id);
          if (ref.mounted) {
            await selectTab(newTabId);
          }
        }
      } else {
        final latestTabState = ref.read(tabStatesProvider)[tabId];
        if (latestTabState == null) {
          logger.w(
            'Tab $tabId disappeared before ${event.url} could be reassigned',
          );
          return;
        }

        if (originUri == null) {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .assignContainer(
                latestTabState.id,
                containerData,
                replacementUrl: uri,
              );
        } else if (latestTabState.url == originUri) {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .assignContainer(
                latestTabState.id,
                containerData,
                closeOldTab: false,
                replacementUrl: uri,
              );
        } else {
          logger.w(
            'Could not match origin url for assignment ${latestTabState.url} to request ${event.originUrl}',
          );
        }
      }
    } catch (error, stackTrace) {
      // The stream's `onError` never sees what an async listener throws.
      logger.e(
        'Failed to reopen ${event.url} in its assigned container',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (_latestAssignmentRequests[tabId] == event.requestId) {
        _latestAssignmentRequests.remove(tabId);
      }
    }
  }

  @override
  void build() {
    // Hold an active listener on the rendered navigation order: swipes and
    // gestures read it synchronously, and Riverpod pauses a provider nothing is
    // listening to — a one-off read would neither keep it current nor guarantee
    // it has data when the first swipe arrives. Listened rather than watched
    // because it changes with every tab update, which must not rebuild this
    // repository; the callback is intentionally empty.
    ref.listen(
      sequentialTabNavigationOrderProvider,
      (_, _) {},
      fireImmediately: true,
    );

    final eventSerivce = ref.watch(eventServiceProvider);
    final tabContentService = ref.watch(tabContentServiceProvider);

    final db = ref.watch(tabDatabaseProvider);

    final tabAddedSub = eventSerivce.tabAddedStream.listen(
      (tabId) async {
        final containerId = ref.read(selectedContainerProvider);
        await db.tabDao.insertTab(
          tabId,
          parentId: const Value.absent(),
          source: TabSource.addedEvent,
          containerId: Value(containerId),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in tab added stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final containerSiteAssignementSub = eventSerivce.siteAssignementEvent
        .listen(
          (event) async {
            await _handleSiteAssignment(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            logger.e(
              'Error in container site assignment stream',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );

    final tabContentSub = tabContentService.tabContentStream.listen(
      (content) async {
        await db.tabDao.updateTabContent(
          content.tabId,
          isProbablyReaderable: content.isProbablyReaderable,
          extractedContentMarkdown: content.extractedContentMarkdown,
          extractedContentPlain: content.extractedContentPlain,
          fullContentMarkdown: content.fullContentMarkdown,
          fullContentPlain: content.fullContentPlain,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in tab content stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      selectedTabProvider,
      (previous, tabId) async {
        if (tabId != null) {
          await db.tabDao.touchTab(tabId, timestamp: DateTime.now());
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error listening to selectedTabProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      tabListProvider,
      (previous, next) async {
        if (_suppressNextReclose) {
          _suppressNextReclose = false;
          // Drop tombstones for the tabs that just came back via undo so
          // future emissions don't treat them as resurrections.
          await _clearTombstonesForCurrentTabs(next.value);
        } else if (await _recloseRestoredClosedTabs(next.value)) {
          return;
        } else if (await _closeRestoredPrivateCaptureTabs(next.value)) {
          return;
        }

        //Only sync tabs if there has been a previous value or is not empty.
        //Additionally require the native session restore to have completed:
        //a partial pre-restore list (e.g. a share-intent tab arriving first)
        //must not delete the cached rows of tabs that are still being
        //restored.
        final shouldSyncTabs =
            ref.read(browserRestoreCompleteProvider) &&
            (next.value.isNotEmpty || (previous?.value.isNotEmpty ?? false));

        if (shouldSyncTabs) {
          final syncTabsResult = await db.tabDao.syncTabs(
            retainTabIds: next.value,
          );
          // Capture isolation contexts from rows deleted by syncTabs
          // (orphaned tabs from crashes, or tabs the engine dropped).
          _pendingIsolationCleanup.addAll(
            syncTabsResult.deletedIsolationContextIds,
          );
        }

        // Process pending isolation context cleanups after syncTabs
        // has deleted the rows, so the count check is accurate.
        await _drainPendingIsolationCleanup();

        // One-shot orphan cleanup after tab list stabilizes (5s debounce).
        // Also runs for DB-only contexts whose rows were already deleted
        // by syncTabs above (those are handled via _pendingIsolationCleanup).
        // if (!orphanCleanupDone) {
        //   orphanCleanupTimer?.cancel();
        //   orphanCleanupTimer = Timer(const Duration(seconds: 5), () async {
        //     if (orphanCleanupDone || !ref.mounted) return;
        //     orphanCleanupDone = true;
        //     await _cleanupOrphanedIsolationContexts();
        //   });
        // }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error listening to tabListProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    // Catch up on the tab list emissions skipped while the restore-complete
    // gate above was closed: reconcile the DB once against the current list.
    ref.listen(browserRestoreCompleteProvider, (
      previous,
      restoreComplete,
    ) async {
      if (restoreComplete && !(previous ?? false)) {
        final currentTabs = ref.read(tabListProvider).value;
        if (currentTabs.isNotEmpty) {
          final syncTabsResult = await db.tabDao.syncTabs(
            retainTabIds: currentTabs,
          );
          _pendingIsolationCleanup.addAll(
            syncTabsResult.deletedIsolationContextIds,
          );
          await _drainPendingIsolationCleanup();
        }
      }
    });

    final tabStateDebouncer = Debouncer(const Duration(seconds: 1));
    Map<String, TabState>? debounceStartValue;

    ref.listen(
      tabStatesProvider,
      (previous, next) {
        //Since state changes occure pretty often and our map always contains
        //the latest state, we cache the value before starting debouncing and
        //later diff to that, to avoid frequent database writes
        if (!tabStateDebouncer.isDebouncing) {
          debounceStartValue = previous;
        }

        tabStateDebouncer.eventOccured(() async {
          await db.tabDao.updateTabs(debounceStartValue, next);
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error listening to tabStatesProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      tabStateDebouncer.dispose();
      await tabAddedSub.cancel();
      await tabContentSub.cancel();
      await containerSiteAssignementSub.cancel();
    });
  }
}
