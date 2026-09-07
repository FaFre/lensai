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
import 'package:lexo_rank/lexo_rank.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/projections/tab_summary.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_summary.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/tab_parent_change.dart';

class SyncTabsResult {
  final Set<String> deletedIsolationContextIds;
  final int deletedCount;

  const SyncTabsResult({
    required this.deletedIsolationContextIds,
    required this.deletedCount,
  });
}

@DriftAccessor()
class TabDao extends DatabaseAccessor<TabDatabase> with $TabDaoMixin {
  final _undoHistory = <String, TabData>{};
  final _pendingParentIds = <String, String>{};
  Timer? _clearHistoryTimer;

  static const closedTabTombstoneTtl = Duration(hours: 24);

  /// Soft cap for stored extracted/full content bytes (UTF-16 code units).
  /// The trigram FTS index expansion is roughly 5–10x the source size, so an
  /// uncapped multi-MB page DOM blows up the shadow tables disproportionately.
  /// Anything above the cap is truncated at write time; the tail is rarely
  /// useful for in-page text search anyway.
  static const _contentSizeCap = 256 * 1024;

  static String? _capContent(String? value) {
    if (value == null) return null;
    if (value.length <= _contentSizeCap) return value;
    return value.substring(0, _contentSizeCap);
  }

  TabDao(super.db);

  UpdateStatement<Tab, TabData> _updateByIdStatement(String id) =>
      db.tab.update()..where((t) => t.id.equals(id));

  /// The full row, page text included. Only for the one caller that renders
  /// stored content ([showContentSelectionDialog]); everything that lists or
  /// watches tabs wants [TabSummary] instead — see that class for why.
  SingleOrNullSelectable<TabData> getTabDataById(String id) =>
      db.tab.select()..where((t) => t.id.equals(id));

  /// A `selectOnly` over [tabSummaryColumns], mapped to [TabSummary].
  ///
  /// [refine] adds the `where`/`orderBy`/`limit` — a callback rather than a
  /// cascade on the return value, because mapping has to come last.
  JoinedSelectStatement<Tab, TabData> _tabSummaryQuery(
    void Function(JoinedSelectStatement<Tab, TabData> query) refine,
  ) {
    final query = selectTabSummaries(this, db.tab);
    refine(query);
    return query;
  }

  Selectable<TabSummary> _tabSummaries(
    void Function(JoinedSelectStatement<Tab, TabData> query) refine,
  ) => _tabSummaryQuery(refine).map((row) => readTabSummary(row, db.tab));

  /// [getTabDataById] without the content columns.
  SingleOrNullSelectable<TabSummary> getTabSummaryById(String id) =>
      _tabSummaryQuery(
        (q) => q..where(db.tab.id.equals(id)),
      ).map((row) => readTabSummary(row, db.tab));

  SingleOrNullSelectable<TabMode> getTabMode(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.tabMode, db.tab.isolationContextId])
      ..where(db.tab.id.equals(tabId));

    return query.map(
      (row) => TabMode.fromDbValue(
        row.readWithConverter(db.tab.tabMode)!,
        isolationContextId: row.read(db.tab.isolationContextId),
      ),
    );
  }

  SingleOrNullSelectable<String?> getTabIsolationContextId(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.isolationContextId])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.read(db.tab.isolationContextId));
  }

  Selectable<String> getAllTabIds() {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => row.read(db.tab.id)!);
  }

  /// Validates multiple tab IDs and returns only those that exist in the database.
  Selectable<String> getExistingTabIds(Iterable<String> tabIds) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(db.tab.id.isIn(tabIds));

    return query.map((row) => row.read(db.tab.id)!);
  }

  /// Most recently used tabs first.
  ///
  /// [excludedTabIds] skips tabs that are on their way out: tab rows are only
  /// deleted after the next selection has been made, so a tab being closed is
  /// still present here — and, having just been active, sorts first.
  Selectable<TabSummary> getTabsFifo({
    int limit = 25,
    Set<String> excludedTabIds = const {},
  }) {
    return _tabSummaries((query) {
      query
        ..limit(limit)
        ..orderBy([
          OrderingTerm.desc(db.tab.timestamp),
          // Total order, and the reason is in `idx_tab_timestamp`: timestamps
          // have one-second resolution, so ties are ordinary.
          OrderingTerm.desc(db.tab.id),
        ]);

      if (excludedTabIds.isNotEmpty) {
        query.where(db.tab.id.isNotIn(excludedTabIds));
      }
    });
  }

  /// As [getTabsFifo], restricted to one container. A null [containerId] is the
  /// unassigned container, not "any container".
  Selectable<TabSummary> getContainerTabsFifo(
    String? containerId, {
    int limit = 25,
    Set<String> excludedTabIds = const {},
  }) {
    return _tabSummaries((query) {
      query
        ..where(
          containerId != null
              ? db.tab.containerId.equals(containerId)
              : db.tab.containerId.isNull(),
        )
        ..limit(limit)
        ..orderBy([
          OrderingTerm.desc(db.tab.timestamp),
          OrderingTerm.desc(db.tab.id),
        ]);

      if (excludedTabIds.isNotEmpty) {
        query.where(db.tab.id.isNotIn(excludedTabIds));
      }
    });
  }

  SingleOrNullSelectable<String?> getTabContainerId(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.containerId])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.read(db.tab.containerId));
  }

  /// Only the container is read, so only the container's columns are selected —
  /// driving this off `select(db.tab)` would pull the tab's page text along with
  /// it for nothing.
  SingleOrNullSelectable<ContainerData?> getTabContainerData(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns(db.container.$columns)
      ..join([
        innerJoin(db.container, db.container.id.equalsExp(db.tab.containerId)),
      ])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.readTableOrNull(db.container));
  }

  Selectable<MapEntry<String, String?>> getTabsContainerId(
    Iterable<String> tabIds,
  ) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id, db.tab.containerId])
      ..where(db.tab.id.isIn(tabIds));

    return query.map(
      (row) => MapEntry(row.read(db.tab.id)!, row.read(db.tab.containerId)),
    );
  }

  Selectable<MapEntry<String, String>> getTabOrderKeys() {
    final query = selectOnly(db.tab)..addColumns([db.tab.id, db.tab.orderKey]);

    return query.map(
      (row) => MapEntry(row.read(db.tab.id)!, row.read(db.tab.orderKey)!),
    );
  }

  Future<void> _resolvePendingParents() async {
    if (_pendingParentIds.isEmpty) return;

    final pendingChildren = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(
        db.tab.id.isIn(_pendingParentIds.keys) &
            db.tab.parentId.isNull() &
            db.tab.source.isNotValue(TabSource.manual.index),
      );
    final pendingChildIds = {
      for (final row in await pendingChildren.get()) row.read(db.tab.id)!,
    };

    if (pendingChildIds.isEmpty) {
      _pendingParentIds.clear();
      return;
    }

    final parentIds = pendingChildIds
        .map((childId) => _pendingParentIds[childId]!)
        .toSet();
    // Existence is the only requirement: a parent_id pointing at a row that is
    // not there yet would abort the batch on the self-referential FK. The
    // parent's container is deliberately *not* compared — a tab opened from a
    // tab in another container keeps pointing at its opener (see the
    // cross-container note on [seedParentFromEngineState]).
    final resolvableParentIds = await getExistingTabIds(
      parentIds,
    ).get().then((ids) => ids.toSet());

    await batch((batch) {
      for (final childId in pendingChildIds) {
        final parentId = _pendingParentIds[childId];
        if (parentId == null || !resolvableParentIds.contains(parentId)) {
          continue;
        }

        batch.update(
          db.tab,
          TabCompanion(
            parentId: Value(parentId),
            source: const Value(TabSource.manual),
          ),
          where: (t) => t.id.equals(childId),
        );
      }
    });

    _pendingParentIds.removeWhere(
      (childId, parentId) =>
          !pendingChildIds.contains(childId) ||
          resolvableParentIds.contains(parentId),
    );
  }

  Future<bool> seedParentFromEngineState({
    required String childId,
    required String? parentId,
    required String? contextId,
  }) {
    return db.transaction(() async {
      if (parentId == null || parentId == childId) {
        // A null or self-referential engine parent can never seed a hierarchy
        // link (the latter would create a cycle), so drop any pending retry.
        _pendingParentIds.remove(childId);
        return false;
      }

      final child = await getTabDataById(childId).getSingleOrNull();
      if (child == null) {
        _pendingParentIds[childId] = parentId;
        return false;
      }
      if (child.parentId != null || child.source == TabSource.manual) {
        _pendingParentIds.remove(childId);
        return false;
      }

      final parent = await getTabDataById(parentId).getSingleOrNull();
      if (parent == null) {
        _pendingParentIds[childId] = parentId;
        return false;
      }

      final repairedContainerId = child.containerId == null && contextId != null
          ? (await _containerIdsByContextualIdentity({contextId}))[contextId]
          : null;

      // The parent's container is deliberately not compared against the
      // child's. A link followed into a container-assigned site is reopened in
      // that container (see the site-assignment listener), and the opener is
      // the only thing that can bring the user back once the reopened tab runs
      // out of history — so provenance has to survive the container boundary.
      // Hierarchical views stay container-scoped regardless: a child whose
      // parent lives elsewhere renders as a local root (`tabsWithRootAndDepth`)
      // and appends at the end of its own container (`_generateOrderKey`).
      await _updateByIdStatement(childId).write(
        TabCompanion(
          parentId: Value(parentId),
          source: const Value(TabSource.manual),
          containerId:
              repairedContainerId.mapNotNull(Value.new) ?? const Value.absent(),
        ),
      );
      _pendingParentIds.remove(childId);
      return true;
    });
  }

  Future<String> _generateOrderKey({
    required Value<String?> parentId,
    required Value<String?> containerId,
    Value<String?> afterTabId = const Value.absent(),
  }) async {
    // Explicit "place after this tab" wins regardless of parent.
    if (afterTabId.present && afterTabId.value != null) {
      final key = await db.containerDao
          .generateOrderKeyAfterTabId(containerId.value, afterTabId.value!)
          .getSingleOrNull();
      if (key != null) {
        return key;
      }
    }

    if (parentId.value.isNotEmpty) {
      // Place new child after the last existing sibling, falling back to
      // immediately after the parent if there are none yet.
      final lastChildId = await db.containerDao
          .getLastChildTabId(containerId.value, parentId.value!)
          .getSingleOrNull();

      final lastChildSubtreeId = lastChildId == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
              lastChildId,
              containerId: containerId.value,
            ).getSingleOrNull();

      final anchorTabId = lastChildSubtreeId ?? lastChildId ?? parentId.value!;

      final key = await db.containerDao
          .generateOrderKeyAfterTabId(containerId.value, anchorTabId)
          .getSingleOrNull();
      if (key != null) {
        return key;
      }
      // Defensive fallback: covers both "parent row not present" *and* the
      // cross-container case where the parent lives in a different container
      // than `containerId.value` (then `getLastChildTabId` and
      // `generateOrderKeyAfterTabId` both yield null because they filter on
      // the new container). In either case append to the end.
    }

    // Root tabs (or unresolved parent) always append to the end of the list.
    // Display direction is applied at render time via TabListDirection /
    // TabBarDirection settings, so we never need to insert at the front.
    return db.containerDao
        .generateTrailingOrderKey(containerId.value)
        .getSingle();
  }

  Future<String> upsertTabTransactional(
    Future<String> Function() createTab, {
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
    Value<String?> afterTabId = const Value.absent(),
    Value<Uri?> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<TabMode> tabMode = const Value.absent(),
  }) {
    return db.transaction(() async {
      final tabId = await createTab();
      final currentOrderKey =
          orderKey.value ??
          await _generateOrderKey(
            parentId: parentId,
            containerId: containerId,
            afterTabId: afterTabId,
          );
      final Value<TabModeDbValue> persistedTabMode = tabMode.present
          ? Value(tabMode.value.toDbValue())
          : const Value.absent();
      final Value<String?> isolationContextId = tabMode.present
          ? Value(tabMode.value.isolationContextId)
          : const Value.absent();

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          parentId: parentId,
          source: TabSource.manual,
          timestamp: DateTime.now(),
          containerId: containerId,
          url: url,
          title: title,
          orderKey: currentOrderKey,
          tabMode: persistedTabMode,
          isolationContextId: isolationContextId,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            source: const Value(TabSource.manual),
            parentId: parentId,
            containerId: containerId,
            url: url,
            title: title,
            orderKey: Value.absentIfNull(orderKey.value),
            tabMode: persistedTabMode,
            isolationContextId: isolationContextId,
          ),
        ),
      );

      return tabId;
    });
  }

  //Upsert an tab only if there is no container assigned yet
  Future<String> insertTab(
    String tabId, {
    required TabSource source,
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
    Value<String?> afterTabId = const Value.absent(),
    Value<Uri?> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<TabMode> tabMode = const Value.absent(),
  }) {
    return db.transaction(() async {
      final currentOrderKey =
          orderKey.value ??
          await _generateOrderKey(
            parentId: parentId,
            containerId: containerId,
            afterTabId: afterTabId,
          );
      final Value<TabModeDbValue> persistedTabMode = tabMode.present
          ? Value(tabMode.value.toDbValue())
          : const Value.absent();
      final Value<String?> isolationContextId = tabMode.present
          ? Value(tabMode.value.isolationContextId)
          : const Value.absent();

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          parentId: parentId,
          source: source,
          timestamp: DateTime.now(),
          containerId: containerId,
          orderKey: currentOrderKey,
          url: url,
          title: title,
          tabMode: persistedTabMode,
          isolationContextId: isolationContextId,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            source: Value(source),
            parentId: parentId,
            containerId: containerId,
            url: url,
            title: title,
            orderKey: Value.absentIfNull(orderKey.value),
            tabMode: persistedTabMode,
            isolationContextId: isolationContextId,
          ),
          where: (old) => old.source.isSmallerThanValue(source.index),
        ),
      );

      return tabId;
    });
  }

  Future<void> assignContainer(String id, {required String? containerId}) {
    final statement = _updateByIdStatement(id);
    return statement.write(TabCompanion(containerId: Value(containerId)));
  }

  Future<void> addClosedTabTombstones(
    Iterable<String> tabIds, {
    DateTime? closedAt,
  }) async {
    final uniqueIds = tabIds.toSet();
    if (uniqueIds.isEmpty) {
      return;
    }

    final effectiveClosedAt = closedAt ?? DateTime.now();

    await batch((batch) {
      for (final tabId in uniqueIds) {
        batch.insert(
          db.closedTabTombstone,
          ClosedTabTombstoneCompanion.insert(
            tabId: tabId,
            closedAt: effectiveClosedAt,
          ),
          onConflict: DoUpdate(
            (_) =>
                ClosedTabTombstoneCompanion(closedAt: Value(effectiveClosedAt)),
          ),
        );
      }
    });
  }

  Future<void> deleteClosedTabTombstones(Iterable<String> tabIds) {
    final uniqueIds = tabIds.toSet();
    if (uniqueIds.isEmpty) {
      return Future.value();
    }

    return (db.closedTabTombstone.delete()
          ..where((t) => t.tabId.isIn(uniqueIds)))
        .go();
  }

  Future<void> pruneExpiredClosedTabTombstones({
    Duration ttl = closedTabTombstoneTtl,
    DateTime? now,
  }) {
    final cutoff = (now ?? DateTime.now()).subtract(ttl);

    return (db.closedTabTombstone.delete()
          ..where((t) => t.closedAt.isSmallerOrEqualValue(cutoff)))
        .go();
  }

  Future<Set<String>> getStartupRestoredClosedTabIds(
    Iterable<String> tabIds, {
    required DateTime sessionStartedAt,
    Duration ttl = closedTabTombstoneTtl,
    DateTime? now,
  }) async {
    final uniqueIds = tabIds.toSet();
    if (uniqueIds.isEmpty) {
      return const <String>{};
    }

    final freshnessCutoff = (now ?? DateTime.now()).subtract(ttl);
    final query = selectOnly(db.closedTabTombstone)
      ..addColumns([db.closedTabTombstone.tabId])
      ..where(
        db.closedTabTombstone.tabId.isIn(uniqueIds) &
            db.closedTabTombstone.closedAt.isSmallerThanValue(
              sessionStartedAt,
            ) &
            db.closedTabTombstone.closedAt.isBiggerOrEqualValue(
              freshnessCutoff,
            ),
      );

    return query
        .map((row) => row.read(db.closedTabTombstone.tabId)!)
        .get()
        .then((rows) => rows.toSet());
  }

  Future<Map<String, String>> _containerIdsByContextualIdentity(
    Iterable<String> contextIds,
  ) async {
    final uniqueContextIds = contextIds.toSet();
    if (uniqueContextIds.isEmpty) {
      return const <String, String>{};
    }

    final rows = await db.definitionsDrift
        .containerIdsByContextualIdentities(
          contextIds: uniqueContextIds.toList(growable: false),
        )
        .get();

    return {for (final row in rows) row.contextualIdentity: row.id};
  }

  Future<void> reorderTabs({
    required List<String> movingTabIds,
    required String? previousTabId,
    required String? nextTabId,
    TabParentChange parentChange = const TabParentChange.unchanged(),
  }) {
    if (movingTabIds.isEmpty) {
      return Future.value();
    }

    return db.transaction(() async {
      final anchorIds = [
        if (previousTabId != null) previousTabId,
        if (nextTabId != null) nextTabId,
      ];

      final anchors = anchorIds.isEmpty
          ? const <String, TabSummary>{}
          : {
              for (final tab in await _tabSummaries(
                (q) => q..where(db.tab.id.isIn(anchorIds)),
              ).get())
                tab.id: tab,
            };

      final previousTab = previousTabId == null ? null : anchors[previousTabId];
      final nextTab = nextTabId == null ? null : anchors[nextTabId];
      final previousRank = previousTab == null
          ? null
          : LexoRank.parse(previousTab.orderKey);
      final nextRank = nextTab == null
          ? null
          : LexoRank.parse(nextTab.orderKey);

      final orderKeys = _generateOrderKeysBetween(
        count: movingTabIds.length,
        previousRank: previousRank,
        nextRank: nextRank,
      );

      // Resolve the parent_id / container_id companion values once.
      //
      // For a `TabParentToSpecific` whose target row is missing, fall back
      // to "unchanged" so we don't issue a parent_id FK violation — the
      // caller passed a stale id, but the order_key change is still
      // useful. The container cascade fires whenever the parent_id is
      // being assigned to a concrete tab (including unassigned parents,
      // container_id = null), since `tabsWithRootAndDepth` is
      // container-scoped and a divergent child would vanish from
      // hierarchical views.
      Value<String?> parentValue = const Value.absent();
      Value<String?> containerValue = const Value.absent();
      Value<TabSource> rootSource = const Value.absent();
      switch (parentChange) {
        case TabParentUnchanged():
          break;
        case TabParentDetach():
          parentValue = const Value(null);
          rootSource = const Value(TabSource.manual);
        case TabParentToSpecific(:final parentTabId):
          final parent =
              anchors[parentTabId] ??
              await getTabSummaryById(parentTabId).getSingleOrNull();
          if (parent != null) {
            parentValue = Value(parentTabId);
            containerValue = Value(parent.containerId);
            rootSource = const Value(TabSource.manual);
          }
      }

      await batch((batch) {
        for (var i = 0; i < movingTabIds.length; i++) {
          final isRoot = i == 0;
          batch.update(
            db.tab,
            TabCompanion(
              source: isRoot ? rootSource : const Value.absent(),
              orderKey: Value(orderKeys[i]),
              // parent_id change applies only to the moving root;
              // descendants keep their existing parent_id pointers.
              parentId: isRoot ? parentValue : const Value.absent(),
              // Container cascade applies to the whole subtree.
              containerId: containerValue,
            ),
            where: (t) => t.id.equals(movingTabIds[i]),
          );
        }
      });
    });
  }

  /// Returns the recursive set of [tabId] and its descendants across every
  /// container. Use this for hierarchy validation, not container-local moves.
  Future<Set<String>> _collectSubtreeIds(String tabId) async {
    final rows = await db.definitionsDrift
        .unorderedTabDescendants(tabId: tabId)
        .get();
    return {for (final r in rows) r.id};
  }

  /// Returns [tabId] and the descendants connected to it within its container.
  Future<Set<String>> _collectContainerSubtreeIds(String tabId) async {
    final rows = await db.definitionsDrift
        .unorderedContainerTabDescendants(tabId: tabId)
        .get();
    return {for (final r in rows) r.id};
  }

  /// Re-parents [tabId] to [newParentId] (or detaches when null).
  ///
  /// Returns `true` on success, `false` when the move was rejected
  /// (cycle, unknown tab, or no-op).
  ///
  /// - Cycle-safe: rejects when [newParentId] is the moving tab itself or
  ///   any of its descendants.
  /// - When attaching to a non-null parent, the container-local moving subtree
  ///   adopts the new parent's `container_id`. Descendants already rendered in
  ///   another container remain local roots there.
  /// - Slots the container-local moving subtree immediately after the new
  ///   parent's last existing child (or after the parent itself if it has
  ///   none), as an atomic order_key block. When detaching, order_keys are left
  ///   untouched — the tab simply becomes a root in its current slot.
  Future<bool> setTabParent({
    required String tabId,
    required String? newParentId,
  }) {
    if (tabId == newParentId) {
      return Future.value(false);
    }

    return db.transaction(() async {
      final movingTab = await getTabDataById(tabId).getSingleOrNull();
      if (movingTab == null) {
        return false;
      }
      if (movingTab.parentId == newParentId) {
        return false;
      }

      // Parent links may cross containers, so cycle detection must see the
      // global hierarchy even though the moving order block is local.
      final descendantIds = await _collectSubtreeIds(tabId);

      String? targetContainerId;
      if (newParentId != null) {
        if (descendantIds.contains(newParentId)) {
          return false;
        }
        final newParent = await getTabDataById(newParentId).getSingleOrNull();
        if (newParent == null) {
          return false;
        }
        targetContainerId = newParent.containerId;
      } else {
        targetContainerId = movingTab.containerId;
      }

      // Resolve this before changing any container IDs. Crossing a boundary
      // must not pull descendants that currently render as roots elsewhere.
      final movingSubtreeIds = await _collectContainerSubtreeIds(tabId);

      // Cascade container updates only through the rendered local subtree.
      if (targetContainerId != movingTab.containerId) {
        await (update(db.tab)..where((t) => t.id.isIn(movingSubtreeIds))).write(
          TabCompanion(containerId: Value(targetContainerId)),
        );
      }

      if (newParentId == null) {
        // Detach: keep existing order_keys. The row becomes a root in its
        // current slot and the subtree under it stays intact.
        await _updateByIdStatement(tabId).write(
          const TabCompanion(
            source: Value(TabSource.manual),
            parentId: Value(null),
          ),
        );
        return true;
      }

      // Pull the (now container-adjusted) subtree rows so we can re-rank
      // them as an atomic block. We must compute anchors BEFORE writing
      // the new parent_id, otherwise `getLastChildTabId(newParentId)`
      // would pick up the moving root itself as a sibling.
      final subtreeRows = await _tabSummaries(
        (q) => q
          ..where(db.tab.id.isIn(movingSubtreeIds))
          ..orderBy([OrderingTerm.asc(db.tab.orderKey)]),
      ).get();
      final orderedIds = subtreeRows.map((r) => r.id).toList();
      if (orderedIds.isEmpty) {
        return true;
      }

      final lastSiblingId = await db.containerDao
          .getLastChildTabId(targetContainerId, newParentId)
          .getSingleOrNull();
      final lastSiblingSubtreeId = lastSiblingId == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
              lastSiblingId,
              containerId: targetContainerId,
            ).getSingleOrNull();
      final anchorId = lastSiblingSubtreeId ?? lastSiblingId ?? newParentId;

      final anchorRow = await getTabSummaryById(anchorId).getSingleOrNull();
      if (anchorRow == null) {
        return false;
      }
      final previousRank = LexoRank.parse(anchorRow.orderKey);

      // Next-rank = first non-subtree tab in the destination container with
      // order_key strictly greater than the anchor. Skipping subtree members
      // keeps the moved block compact even when the subtree's old keys
      // sat near the anchor in storage.
      final nextRow = await _tabSummaries((q) {
        final containerEq = targetContainerId != null
            ? db.tab.containerId.equals(targetContainerId)
            : db.tab.containerId.isNull();

        q
          ..where(
            containerEq &
                db.tab.orderKey.isBiggerThanValue(anchorRow.orderKey) &
                db.tab.id.isNotIn(movingSubtreeIds),
          )
          ..orderBy([OrderingTerm.asc(db.tab.orderKey)])
          ..limit(1);
      }).getSingleOrNull();
      final nextRank = nextRow == null
          ? null
          : LexoRank.parse(nextRow.orderKey);

      final orderKeys = _generateOrderKeysBetween(
        count: orderedIds.length,
        previousRank: previousRank,
        nextRank: nextRank,
      );

      await batch((batch) {
        // parent_id change is applied on the moving root only; subtree
        // descendants keep their existing parent_id pointers.
        batch.update(
          db.tab,
          TabCompanion(
            source: const Value(TabSource.manual),
            parentId: Value(newParentId),
            orderKey: Value(orderKeys[0]),
          ),
          where: (t) => t.id.equals(orderedIds[0]),
        );
        for (var i = 1; i < orderedIds.length; i++) {
          batch.update(
            db.tab,
            TabCompanion(orderKey: Value(orderKeys[i])),
            where: (t) => t.id.equals(orderedIds[i]),
          );
        }
      });

      return true;
    });
  }

  /// Swaps a direct child with its parent: the child takes the parent's
  /// slot in the tree (parent_id + order_key), and the parent becomes a
  /// child of the (formerly) child, placed after its existing siblings.
  ///
  /// Returns `false` when [childId] has no parent or the tabs cross a
  /// container boundary (which would imply data corruption).
  Future<bool> promoteChildToParent(String childId) {
    return db.transaction(() async {
      final child = await getTabDataById(childId).getSingleOrNull();
      if (child == null || child.parentId == null) {
        return false;
      }
      final parentId = child.parentId!;
      final parent = await getTabDataById(parentId).getSingleOrNull();
      if (parent == null) {
        return false;
      }
      if (parent.containerId != child.containerId) {
        return false;
      }

      final containerId = child.containerId;

      // The (about-to-be-demoted) parent gets placed after the new
      // parent's (= former child's) existing other children. We read the
      // anchor's order_key BEFORE any writes — `generateOrderKeyAfterTabId`
      // reads from storage, so the captured key reflects pre-swap state.
      final lastChildOfChild = await db.containerDao
          .getLastChildTabId(containerId, childId)
          .getSingleOrNull();
      final lastChildSubtreeId = lastChildOfChild == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
              lastChildOfChild,
              containerId: containerId,
            ).getSingleOrNull();
      final anchorId = lastChildSubtreeId ?? lastChildOfChild ?? childId;
      final newParentOrderKey = await db.containerDao
          .generateOrderKeyAfterTabId(containerId, anchorId)
          .getSingleOrNull();
      if (newParentOrderKey == null) {
        return false;
      }

      await batch((batch) {
        batch.update(
          db.tab,
          TabCompanion(
            source: const Value(TabSource.manual),
            parentId: Value(parent.parentId),
            orderKey: Value(parent.orderKey),
          ),
          where: (t) => t.id.equals(childId),
        );
        batch.update(
          db.tab,
          TabCompanion(
            source: const Value(TabSource.manual),
            parentId: Value(childId),
            orderKey: Value(newParentOrderKey),
          ),
          where: (t) => t.id.equals(parentId),
        );
      });

      return true;
    });
  }

  /// Moves [tabId] one sibling slot up (or down) within its parent scope,
  /// carrying its whole subtree as an atomic block.
  ///
  /// Returns `false` when the tab is unknown or already at the relevant
  /// end of its sibling list.
  Future<bool> moveTabAmongSiblings(String tabId, {required bool down}) {
    // Transactional so the sibling-list read, subtree resolution, and the
    // anchor lookup all observe the same DB snapshot. `reorderTabs` opens
    // a nested savepoint internally, which is fine.
    return db.transaction(() async {
      final tab = await getTabDataById(tabId).getSingleOrNull();
      if (tab == null) {
        return false;
      }

      final parentContainerId = tab.parentId == null
          ? null
          : await getTabContainerId(tab.parentId!).getSingleOrNull();
      final renderedParentId =
          tab.parentId != null && parentContainerId == tab.containerId
          ? tab.parentId
          : null;
      final siblingIds = await db.definitionsDrift
          .containerScopeSiblings(
            containerId: tab.containerId,
            parentId: renderedParentId,
          )
          .get()
          .then((siblings) => siblings.map((sibling) => sibling.id).toList());

      final idx = siblingIds.indexOf(tabId);
      if (idx < 0) {
        return false;
      }
      final newIdx = down ? idx + 1 : idx - 1;
      if (newIdx < 0 || newIdx >= siblingIds.length) {
        return false;
      }

      final reorderedIds = siblingIds..removeAt(idx);
      reorderedIds.insert(newIdx, tabId);

      final previousIdx = newIdx - 1;
      final nextIdx = newIdx + 1;
      final previousSiblingId = previousIdx >= 0
          ? reorderedIds[previousIdx]
          : null;
      final previousTabId = previousSiblingId == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
                  previousSiblingId,
                  containerId: tab.containerId,
                ).getSingleOrNull() ??
                previousSiblingId;
      final nextTabId = nextIdx < reorderedIds.length
          ? reorderedIds[nextIdx]
          : null;

      final subtreeIds = await _collectContainerSubtreeIds(tabId);
      final subtreeRows = await _tabSummaries(
        (q) => q
          ..where(db.tab.id.isIn(subtreeIds))
          ..orderBy([OrderingTerm.asc(db.tab.orderKey)]),
      ).get();
      final movingTabIds = subtreeRows.map((r) => r.id).toList();

      await reorderTabs(
        movingTabIds: movingTabIds,
        previousTabId: previousTabId,
        nextTabId: nextTabId,
      );
      return true;
    });
  }

  List<String> _generateOrderKeysBetween({
    required int count,
    required LexoRank? previousRank,
    required LexoRank? nextRank,
  }) {
    if (count <= 0) {
      return const [];
    }

    if (previousRank == null && nextRank == null) {
      var rank = LexoRank.middle();
      return [
        for (var i = 0; i < count; i++)
          () {
            final value = rank.value;
            rank = rank.genNext();
            return value;
          }(),
      ];
    }

    if (nextRank == null) {
      var rank = previousRank!.genNext();
      return [
        for (var i = 0; i < count; i++)
          () {
            final value = rank.value;
            rank = rank.genNext();
            return value;
          }(),
      ];
    }

    if (previousRank == null) {
      var rank = nextRank;
      final reversed = <String>[];
      for (var i = 0; i < count; i++) {
        rank = rank.genPrev();
        reversed.add(rank.value);
      }
      return reversed.reversed.toList();
    }

    var upperBound = nextRank;
    final reversed = <String>[];
    for (var i = 0; i < count; i++) {
      upperBound = previousRank.genBetween(upperBound);
      reversed.add(upperBound.value);
    }
    return reversed.reversed.toList();
  }

  /// Reassigns `order_key` for grandchildren whose parent is being closed so
  /// they slot into the closing scope at the position previously occupied by
  /// their (closing) parent. Run *before* the close itself.
  ///
  /// Edge cases worth knowing about:
  ///
  /// - When the first batch of pending grandchildren has no surviving sibling
  ///   strictly before them, [previousRank] is `null` (rather than a tab in
  ///   the parent of the scope's parent). The assigned keys are correct
  ///   relative to siblings in this scope, but in a flat-by-order_key view
  ///   (e.g. the tab bar) the promoted children may now sort before unrelated
  ///   tabs from other scopes that originally sat before the closing tab in
  ///   storage. Hierarchical views mask this via `tabsWithRootAndDepth`.
  ///
  /// - Within a scope, grandchildren are emitted in DFS order through the
  ///   closing chain (`childrenByParent[closingId]` recursively), not by raw
  ///   storage order. If a user manually reordered a grandchild to sit after
  ///   one of its uncles in storage and the uncle is also closing, the DFS
  ///   walk will re-emit them in tree order — silently overriding the manual
  ///   key. This is treated as "rebuild the scope on close".
  ///
  /// - Only `order_key` is rewritten. `parent_id` is left untouched and is
  ///   normalised lazily by the `tab_maintain_parent_chain_on_delete` trigger
  ///   when the close itself runs.
  ///
  /// - Children in a *different* container than the closing tab are skipped
  ///   entirely. `order_key` is only meaningful within one container, so
  ///   slotting such a child into the closing scope would drop a foreign rank
  ///   into its list; it is already a local root over there and keeps its
  ///   place.
  ///
  /// - A scope is the set of tabs *rendered* as siblings, which is not the same
  ///   as sharing a `parent_id` now that a parent may live in another container
  ///   (see `containerScopeSiblings`). A closing tab with such a parent holds a
  ///   slot among its own container's roots, and is grouped and anchored there.
  ///   Matching `parent_id` raw would give it a scope with no other members, so
  ///   its promoted children would rank against nothing and land at
  ///   `LexoRank.middle()` instead of in the slot it vacated.
  Future<void> preservePromotedChildOrderOnClose(Iterable<String> tabIds) {
    final closingIds = tabIds.toSet();
    if (closingIds.isEmpty) {
      return Future.value();
    }

    return db.transaction(() async {
      final closingTabs = await _tabSummaries(
        (q) => q..where(db.tab.id.isIn(closingIds)),
      ).get();

      if (closingTabs.isEmpty) {
        return;
      }

      final directChildren = await _tabSummaries(
        (q) => q
          ..where(db.tab.parentId.isIn(closingIds))
          ..orderBy([OrderingTerm.asc(db.tab.orderKey)]),
      ).get();

      final closingTabById = {for (final tab in closingTabs) tab.id: tab};
      final childrenByParent = <String, List<TabSummary>>{};
      for (final child in directChildren) {
        final parentId = child.parentId;
        if (parentId == null) continue;
        childrenByParent.putIfAbsent(parentId, () => []).add(child);
      }

      final promotedBoundaryCache = <String, List<TabSummary>>{};
      List<TabSummary> promotedBoundaryChildren(String closingTabId) {
        return promotedBoundaryCache.putIfAbsent(closingTabId, () {
          final result = <TabSummary>[];
          for (final child
              in childrenByParent[closingTabId] ?? const <TabSummary>[]) {
            if (closingIds.contains(child.id)) {
              result.addAll(promotedBoundaryChildren(child.id));
            } else {
              result.add(child);
            }
          }
          return result;
        });
      }

      // A stored parent only groups its child when both live in the same
      // container. Otherwise `tabsWithRootAndDepth` draws the child as a local
      // root, and that root scope — not a scope of its own under an
      // out-of-container parent — is the one it holds a slot in.
      final closingParentIds = {
        for (final tab in closingTabs)
          if (tab.parentId case final parentId?) parentId,
      };
      final closingParentContainerIds = closingParentIds.isEmpty
          ? const <String, String?>{}
          : await getTabsContainerId(
              closingParentIds,
            ).get().then(Map.fromEntries);

      String? renderedParentId(TabSummary tab) {
        final parentId = tab.parentId;
        if (parentId == null) {
          return null;
        }

        return closingParentContainerIds[parentId] == tab.containerId
            ? parentId
            : null;
      }

      // Absorbed into the parent's pass only when that parent re-ranks this
      // tab's container at all — a closing parent elsewhere has its promoted
      // children filtered down to its own container, so this tab has to stand
      // in for its own scope instead of silently losing its pass.
      final representativeClosingTabs = closingTabs.where((tab) {
        final closingParent = closingTabById[tab.parentId];
        return closingParent == null ||
            closingParent.containerId != tab.containerId;
      });

      final closingTabsByScope = groupBy(
        representativeClosingTabs,
        (TabSummary tab) =>
            (containerId: tab.containerId, parentId: renderedParentId(tab)),
      );

      for (final entry in closingTabsByScope.entries) {
        final scope = entry.key;
        final scopedClosingTabs = entry.value.sorted(
          (a, b) => a.orderKey.compareTo(b.orderKey),
        );

        // Survivors are matched on the scope they *render* in, so a sibling
        // whose parent sits in another container still anchors the root scope
        // it is drawn in rather than dropping out of the pass.
        final sameScopeTabs = await db.definitionsDrift
            .containerScopeSiblings(
              containerId: scope.containerId,
              parentId: scope.parentId,
            )
            .get()
            .then(
              (tabs) =>
                  tabs.where((tab) => !closingIds.contains(tab.id)).toList(),
            );

        var closingIndex = 0;
        var survivorIndex = 0;
        LexoRank? previousRank;
        final pendingChildren = <TabSummary>[];

        Future<void> assignPendingChildren(LexoRank? nextRank) async {
          if (pendingChildren.isEmpty) {
            return;
          }

          final orderKeys = _generateOrderKeysBetween(
            count: pendingChildren.length,
            previousRank: previousRank,
            nextRank: nextRank,
          );

          for (var i = 0; i < pendingChildren.length; i++) {
            await _updateByIdStatement(
              pendingChildren[i].id,
            ).write(TabCompanion(orderKey: Value(orderKeys[i])));
          }

          pendingChildren.clear();
        }

        while (closingIndex < scopedClosingTabs.length ||
            survivorIndex < sameScopeTabs.length) {
          final nextClosing = closingIndex < scopedClosingTabs.length
              ? scopedClosingTabs[closingIndex]
              : null;
          final nextSurvivor = survivorIndex < sameScopeTabs.length
              ? sameScopeTabs[survivorIndex]
              : null;

          final takeClosing =
              nextClosing != null &&
              (nextSurvivor == null ||
                  nextClosing.orderKey.compareTo(nextSurvivor.orderKey) < 0);

          if (takeClosing) {
            pendingChildren.addAll(
              promotedBoundaryChildren(
                nextClosing.id,
              ).where((child) => child.containerId == scope.containerId),
            );
            closingIndex++;
            continue;
          }

          final survivor = nextSurvivor!;
          final survivorRank = LexoRank.parse(survivor.orderKey);
          await assignPendingChildren(survivorRank);
          previousRank = survivorRank;
          survivorIndex++;
        }

        await assignPendingChildren(null);
      }
    });
  }

  Future<void> touchTab(String id, {required DateTime timestamp}) {
    final statement = _updateByIdStatement(id);
    return statement.write(TabCompanion(timestamp: Value(timestamp)));
  }

  Future<void> updateTabContent(
    String id, {
    required bool isProbablyReaderable,
    required String? extractedContentMarkdown,
    required String? extractedContentPlain,
    required String? fullContentMarkdown,
    required String? fullContentPlain,
  }) async {
    final statement = _updateByIdStatement(id);

    await statement.write(
      TabCompanion(
        isProbablyReaderable: Value(isProbablyReaderable),
        extractedContentMarkdown: Value(_capContent(extractedContentMarkdown)),
        extractedContentPlain: Value(_capContent(extractedContentPlain)),
        fullContentMarkdown: Value(_capContent(fullContentMarkdown)),
        fullContentPlain: Value(_capContent(fullContentPlain)),
      ),
    );
  }

  Future<void> updateTabs(
    Map<String, TabState>? previous,
    Map<String, TabState> next,
  ) {
    return db.transaction(() async {
      // Gecko exposes a parentId in content-state events, but local DB tab
      // hierarchy becomes authoritative once a row has a DB parent or has
      // been manually created/reparented. Only use Gecko parent data to seed
      // engine-event rows that have not been claimed by local hierarchy yet.
      // Keep retrying while the row remains unclaimed so out-of-order tab-list
      // inserts can seed the parent later without needing another parentId
      // change from Gecko.
      final parentSyncEligibleIds = next.isEmpty
          ? const <String>{}
          : await (() async {
              final query = selectOnly(db.tab)
                ..addColumns([db.tab.id, db.tab.source])
                ..where(db.tab.id.isIn(next.keys) & db.tab.parentId.isNull());
              return {
                for (final row in await query.get())
                  if (row.readWithConverter(db.tab.source) != TabSource.manual)
                    row.read(db.tab.id)!,
              };
            })();

      // Validate every candidate parent against the database — a parentId
      // present in `next` is not proof the row has been persisted yet (e.g.
      // engine state snapshot arriving before the matching tab-list insert).
      // Without the DB check we could write a parent_id pointing at a row
      // that does not exist, triggering the self-referential FK violation
      // and aborting the whole batch.
      final parentIdsToValidate = <String>{
        for (final state in next.values)
          if (parentSyncEligibleIds.contains(state.id) &&
              state.parentId != null)
            state.parentId!,
      };
      final existingParentIds = await getExistingTabIds(
        parentIdsToValidate,
      ).get().then((ids) => ids.toSet());
      final validatedParentIds = <String, String?>{};

      final containerRepairCandidates = {
        for (final state in next.values)
          if (state.contextId != null &&
              (previous?[state.id]?.contextId != state.contextId ||
                  previous?[state.id] == null))
            state.id: state.contextId!,
      };
      final currentContainerIds = containerRepairCandidates.isEmpty
          ? const <String, String?>{}
          : await getTabsContainerId(
              containerRepairCandidates.keys,
            ).get().then(Map.fromEntries);
      final repairableContexts = containerRepairCandidates.entries
          .where((entry) => currentContainerIds[entry.key] == null)
          .map((entry) => entry.value)
          .toSet();
      final containerIdsByContext = await _containerIdsByContextualIdentity(
        repairableContexts,
      );
      final repairedContainerIds = <String, String>{
        for (final entry in containerRepairCandidates.entries)
          if (currentContainerIds[entry.key] == null)
            if (containerIdsByContext[entry.value] case final containerId?)
              entry.key: containerId,
      };

      for (final state in next.values) {
        if (!parentSyncEligibleIds.contains(state.id)) {
          _pendingParentIds.remove(state.id);
          continue;
        }

        if (state.parentId == null) {
          _pendingParentIds.remove(state.id);
          continue;
        }

        final parentId = state.parentId!;
        if (parentId == state.id) {
          // A self-referential engine parent would create a hierarchy cycle.
          _pendingParentIds.remove(state.id);
          continue;
        }
        // Existence is the only gate — the parent's container is not compared
        // against the child's, see [seedParentFromEngineState].
        if (existingParentIds.contains(parentId)) {
          validatedParentIds[state.id] = parentId;
          _pendingParentIds.remove(state.id);
        } else {
          _pendingParentIds[state.id] = parentId;
        }
      }

      await batch((batch) {
        for (final state in next.values) {
          final previousState = previous?[state.id];
          final hasParentUpdate = validatedParentIds.containsKey(state.id);
          final hasContainerRepair = repairedContainerIds.containsKey(state.id);
          final hasUrlChange = previousState?.url != state.url;
          final hasTitleChange = previousState?.title != state.title;
          final hasTabModeChange = previousState?.tabMode != state.tabMode;

          if (hasUrlChange ||
              hasTitleChange ||
              hasTabModeChange ||
              hasParentUpdate ||
              hasContainerRepair) {
            batch.update(
              db.tab,
              TabCompanion(
                parentId: hasParentUpdate
                    ? Value(validatedParentIds[state.id])
                    : const Value.absent(),
                source: hasParentUpdate
                    ? const Value(TabSource.manual)
                    : const Value.absent(),
                containerId:
                    repairedContainerIds[state.id].mapNotNull(Value.new) ??
                    const Value.absent(),
                url: hasUrlChange ? Value(state.url) : const Value.absent(),
                title: hasTitleChange
                    ? Value(state.title)
                    : const Value.absent(),
                tabMode: hasTabModeChange
                    ? Value(state.tabMode.toDbValue())
                    : const Value.absent(),
                isolationContextId: hasTabModeChange
                    ? Value(state.isolationContextId)
                    : const Value.absent(),
              ),
              where: (t) => t.id.equals(state.id),
            );
          }
        }
      });
    });
  }

  /// Syncs DB tab rows with the engine's active tab list.
  /// Returns metadata about deleted rows for follow-up cleanup.
  Future<SyncTabsResult> syncTabs({required List<String> retainTabIds}) {
    return db.transaction(() async {
      final deleted =
          await (db.tab.delete()..where((t) => t.id.isNotIn(retainTabIds)))
              .goAndReturn();

      final deletedIsolationContextIds = <String>{
        for (final tab in deleted)
          if (tab.isolationContextId != null) tab.isolationContextId!,
      };

      if (deleted.isNotEmpty) {
        _clearHistoryTimer?.cancel();

        _undoHistory.addAll({for (final tab in deleted) tab.id: tab});

        _clearHistoryTimer = Timer(const Duration(seconds: 5), () {
          //Dont keep things in memory
          _undoHistory.clear();
        });
      }

      final retainedTabIds = retainTabIds.toSet();
      _pendingParentIds.removeWhere(
        (childId, parentId) =>
            !retainedTabIds.contains(childId) ||
            !retainedTabIds.contains(parentId),
      );

      var currentOrderKey = await db.containerDao
          .generateLeadingOrderKey(null)
          .getSingle();

      await db.tab.insertAll(
        retainTabIds.map((id) {
          final insertable =
              _undoHistory[id] ??
              TabCompanion.insert(
                id: id,
                source: TabSource.syncEvent,
                orderKey: currentOrderKey,
                timestamp: DateTime.now(),
              );

          currentOrderKey = LexoRank.parse(currentOrderKey).genPrev().value;

          return insertable;
        }),
        onConflict: DoNothing(),
      );

      await _resolvePendingParents();

      return SyncTabsResult(
        deletedIsolationContextIds: deletedIsolationContextIds,
        deletedCount: deleted.length,
      );
    });
  }

  Selectable<TabQueryResult> queryTabs({
    required String matchPrefix,
    required String matchSuffix,
    required String ellipsis,
    required int snippetLength,
    required String searchString,
    int limit = 25,
  }) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.definitionsDrift.queryTabsFullContent(
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
        limit: limit,
      );
    } else {
      return db.definitionsDrift.queryTabsBasic(
        query: db.buildLikeQuery(searchString),
        limit: limit,
      );
    }
  }

  SingleSelectable<int> tabsInIsolationGroup(String contextId) {
    return db.definitionsDrift.tabsInIsolationGroup(contextId: contextId);
  }

  Selectable<String?> allIsolationContextIds() {
    return db.definitionsDrift.allIsolationContextIds();
  }

  Selectable<IsolatedContextContainerPairsResult>
  isolatedContextContainerPairs() {
    return db.definitionsDrift.isolatedContextContainerPairs();
  }

  Selectable<HistoryExclusionTabsResult> historyExclusionTabs() {
    return db.definitionsDrift.historyExclusionTabs();
  }

  Future<void> setPinned(String id, {required bool pinned}) {
    final statement = _updateByIdStatement(id);
    return statement.write(TabCompanion(isPinned: Value(pinned)));
  }

  Selectable<String> getPinnedTabIds() {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(db.tab.isPinned.equals(true));

    return query.map((row) => row.read(db.tab.id)!);
  }

  Selectable<MapEntry<String, DateTime>> getTabTimestamps() {
    final query = selectOnly(db.tab)..addColumns([db.tab.id, db.tab.timestamp]);

    return query.map(
      (row) => MapEntry(row.read(db.tab.id)!, row.read(db.tab.timestamp)!),
    );
  }

  SingleOrNullSelectable<String> lastSubtreeTabIdByOrderKey(
    String tabId, {
    required String? containerId,
  }) {
    return db.definitionsDrift.lastSubtreeTabIdByOrderKey(
      tabId: tabId,
      containerId: containerId,
    );
  }

  Future<List<String>> getUnassignedRegularTabsOlderThan(DateTime threshold) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(
        db.tab.containerId.isNull() &
            db.tab.timestamp.isSmallerThanValue(threshold) &
            db.tab.tabMode.equalsValue(TabModeDbValue.regular),
      );

    return query.map((row) => row.read(db.tab.id)!).get();
  }
}
