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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_summary.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/tab_parent_change.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabDataRepository extends _$TabDataRepository {
  Future<void> assignContainer(
    String tabId,
    ContainerData targetContainer, {
    bool closeOldTab = true,
    // When the reassignment is driven by a navigation to a site assigned to
    // [targetContainer] (see the site-assignment listener), the recreated tab
    // must load that requested URL rather than the tab's current URL. The
    // current URL can be a stale origin page (e.g. the search result the link
    // was opened from) when the assignment fires before the navigation
    // commits. Left null for manual moves (drag/drop, menu), which keep the
    // tab on its current page.
    Uri? replacementUrl,
  }) async {
    final selectedTabId = ref.read(selectedTabProvider);
    final tabState = ref.read(tabStatesProvider)[tabId];

    // Isolated tabs: always do DB-only assignment (never recreate/recontext)
    if (tabState != null && tabState.tabMode is IsolatedTabMode) {
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: targetContainer.id);
      return;
    }

    final currentContainerData = await getTabContainerData(tabId);

    // The tab is already in the target container, so there is nothing to
    // reconcile. This guards against churn when an async assignment races a
    // move that already landed the tab in [targetContainer] (recreating it
    // here would spawn a redundant tab and re-trigger its load).
    if (currentContainerData?.id == targetContainer.id) {
      return;
    }

    final sameContext =
        targetContainer.metadata.contextualIdentity ==
        currentContainerData?.metadata.contextualIdentity;

    // A pure regrouping (no navigation) can stay in place when the Gecko
    // context is unchanged — this is the manual-move case (drag/drop, menu),
    // which passes no [replacementUrl] and keeps the tab on its current page.
    //
    // An assignment-driven move ([replacementUrl] set) must send the tab to the
    // requested site. Reloading in place on the origin tab is unreliable after
    // an app-link "open in app" cancel (the engine session is left in a state
    // where the load never commits), so we recreate the tab in that case even
    // when the context is unchanged. The fresh session loads the URL reliably.
    if (sameContext && replacementUrl == null) {
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: targetContainer.id);
    } else {
      if (tabState != null) {
        // Resolved before the close, while the row is still around.
        //
        // A tab that survives the move is itself the opener of the replacement:
        // the user navigated from it into a site that belongs elsewhere, so
        // closing the replacement has to lead back to it — across the container
        // boundary (#530). When the old tab goes away instead, the replacement
        // takes over its place in the hierarchy.
        final parentId = closeOldTab
            ? (await getTabDataById(tabId))?.parentId
            : tabId;

        if (closeOldTab) {
          await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);
        }

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: replacementUrl ?? tabState.url,
              tabMode: tabState.tabMode,
              containerSelection: TabContainerSelection.specific(
                targetContainer,
              ),
              parentId: parentId,
              selectTab: selectedTabId == tabState.id,
              // Assignment-driven navigation is classified in its assigned context
              // like any other load; the app-links fallback re-entry map (§2.7)
              // covers the redirect loop the old delegate bypass used to guard.
              flags: LoadUrlFlags.NONE,
            );
      }
    }
  }

  Future<void> unassignContainer(String tabId) async {
    final selectedTabId = ref.read(selectedTabProvider);
    final tabState = ref.read(tabStatesProvider)[tabId];

    // Isolated tabs: always do DB-only unassignment (never recreate/recontext)
    if (tabState != null && tabState.tabMode is IsolatedTabMode) {
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: null);
      return;
    }

    final currentContainerData = await getTabContainerData(tabId);

    if (currentContainerData?.metadata.contextualIdentity == null) {
      return ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: null);
    } else {
      if (tabState != null) {
        // The replacement stands in for the tab being retired, so it inherits
        // its place in the hierarchy — read before the row disappears.
        final parentId = (await getTabDataById(tabId))?.parentId;

        await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: tabState.url,
              tabMode: tabState.tabMode,
              containerSelection: const TabContainerSelection.unassigned(),
              parentId: parentId,
              selectTab: selectedTabId == tabState.id,
            );
      }
    }
  }

  Future<void> setPinned(String tabId, {required bool pinned}) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .setPinned(tabId, pinned: pinned);
  }

  Future<void> reorderTabs({
    required List<String> movingTabIds,
    required String? previousTabId,
    required String? nextTabId,
    TabParentChange parentChange = const TabParentChange.unchanged(),
  }) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .reorderTabs(
          movingTabIds: movingTabIds,
          previousTabId: previousTabId,
          nextTabId: nextTabId,
          parentChange: parentChange,
        );
  }

  Future<bool> setTabParent({
    required String tabId,
    required String? newParentId,
  }) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .setTabParent(tabId: tabId, newParentId: newParentId);
  }

  Future<bool> seedParentFromEngineState({
    required String childId,
    required String? parentId,
    required String? contextId,
  }) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .seedParentFromEngineState(
          childId: childId,
          parentId: parentId,
          contextId: contextId,
        );
  }

  Future<bool> promoteChildToParent(String childId) {
    return ref.read(tabDatabaseProvider).tabDao.promoteChildToParent(childId);
  }

  Future<bool> moveTabAmongSiblings(String tabId, {required bool down}) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .moveTabAmongSiblings(tabId, down: down);
  }

  /// How many private tabs are open across every container.
  ///
  /// The same set `exitApp` closes on the way out, asked ahead of time so a
  /// confirmation can say what leaving costs instead of finding out afterwards.
  Future<int> countPrivateTabs() async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getAllTabIds(includeRegular: false, includeIsolated: false)
        .get();

    return tabIds.length;
  }

  Future<int> closeAllTabs({
    bool includeRegular = true,
    bool includePrivate = true,
    bool includeIsolated = true,
  }) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getAllTabIds(
          includeRegular: includeRegular,
          includePrivate: includePrivate,
          includeIsolated: includeIsolated,
        )
        .get();

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }

    return tabIds.length;
  }

  Future<List<String>> closeContainerTabs(
    String? containerId, {
    bool includeRegular = true,
    bool includePrivate = true,
    bool includeIsolated = true,
  }) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabIds(
          containerId,
          includeRegular: includeRegular,
          includePrivate: includePrivate,
          includeIsolated: includeIsolated,
        )
        .get();

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }

    return tabIds;
  }

  Future<int> closeAllTabsByHost(String? containerId, String host) async {
    final tabs = await getContainerTabsData(containerId);

    final filtered = tabs
        .where((tab) => tab.url?.host == host)
        .map((tab) => tab.id)
        .toList();

    if (filtered.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(filtered);
    }

    return filtered.length;
  }

  Future<TabData?> getTabDataById(String tabId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabDataById(tabId)
        .getSingleOrNull();
  }

  Future<List<TabSummary>> getContainerTabsData(String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabsData(containerId)
        .get();
  }

  Future<String?> getTabContainerId(String tabId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerId(tabId)
        .getSingleOrNull();
  }

  Future<ContainerData?> getTabContainerData(String tabId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerData(tabId)
        .getSingleOrNull();
  }

  Future<Map<String, String?>> getTabsContainerId(Iterable<String> tabIds) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabsContainerId(tabIds)
        .get()
        .then(Map.fromEntries);
  }

  Future<Map<String, String?>> getTabDescendants(String tabId) async {
    final results = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .unorderedTabDescendants(tabId: tabId)
        .get();

    return Map.fromEntries(
      results.map((pair) => MapEntry(pair.id, pair.parentId)),
    );
  }

  /// [getTabDescendants] stopped at the seed tab's container boundary.
  ///
  /// What the bulk-close actions operate on: they are offered from a
  /// container-scoped view whose counts exclude a child that was reopened in
  /// another container, so closing must exclude it too.
  Future<Map<String, String?>> getContainerTabDescendants(String tabId) async {
    final results = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .unorderedContainerTabDescendants(tabId: tabId)
        .get();

    return Map.fromEntries(
      results.map((pair) => MapEntry(pair.id, pair.parentId)),
    );
  }

  Future<List<String>> getFilteredTabIds(String? containerId) async {
    final db = ref.read(tabDatabaseProvider);
    final filterOptions = ref.read(tabViewFilterControllerProvider);
    final tabStates = ref.read(tabStatesProvider);

    // Get all tab IDs in this container from DB
    final containerTabIds = await db.containerDao
        .getContainerTabIds(containerId)
        .get();

    // Only keep tabs that exist in the engine
    final candidateIds = containerTabIds
        .where((id) => tabStates.containsKey(id))
        .toList();

    if (candidateIds.isEmpty) return const [];

    if (!filterOptions.hasActiveFilter) return candidateIds;

    // Only fetch timestamps when date filtering is active
    final timestamps = filterOptions.effectiveDateRange != null
        ? Map.fromEntries(await db.tabDao.getTabTimestamps().get())
        : null;

    return candidateIds.where((id) {
      final state = tabStates[id];
      return filterOptions.matchesTab(state?.tabMode, timestamps?[id]);
    }).toList();
  }

  Future<int> deleteUnassignedTabsOlderThan(DateTime threshold) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getUnassignedRegularTabsOlderThan(threshold);

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }

    return tabIds.length;
  }

  @override
  void build() {}
}
