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
import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/container.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/projections/tab_summary.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_summary.dart';

@DriftAccessor()
class ContainerDao extends DatabaseAccessor<TabDatabase>
    with $ContainerDaoMixin {
  ContainerDao(super.db);

  Future<void> addContainer(ContainerData container) {
    return db.container.insertOne(
      ContainerCompanion.insert(
        id: container.id,
        name: Value(container.name),
        color: container.color,
        orderKey: container.orderKey,
        isPinned: Value(container.isPinned),
        metadata: Value(container.metadata),
      ),
    );
  }

  Future<void> replaceContainer(ContainerData container) {
    return db.container.replaceOne(
      ContainerCompanion(
        id: Value(container.id),
        name: Value(container.name),
        color: Value(container.color),
        orderKey: Value(container.orderKey),
        isPinned: Value(container.isPinned),
        metadata: Value(container.metadata),
      ),
    );
  }

  Future<void> assignOrderKey(String id, {required String orderKey}) {
    return (update(db.container)..where((c) => c.id.equals(id))).write(
      ContainerCompanion(orderKey: Value(orderKey)),
    );
  }

  Future<void> assignPinned(
    String id, {
    required bool isPinned,
    required String orderKey,
  }) {
    return (update(db.container)..where((c) => c.id.equals(id))).write(
      ContainerCompanion(isPinned: Value(isPinned), orderKey: Value(orderKey)),
    );
  }

  Future<void> deleteContainer(String id) {
    return db.container.deleteOne(ContainerCompanion(id: Value(id)));
  }

  SingleOrNullSelectable<ContainerData> getContainerData(String id) {
    return select(db.container)..where((t) => t.id.equals(id));
  }

  Selectable<Color> getDistinctColors() {
    final query = db.selectOnly(db.container, distinct: true)
      ..addColumns([db.container.color])
      ..where(db.container.color.isNotNull());

    return query.map(
      (row) => row.readWithConverter<Color?, int>(db.container.color)!,
    );
  }

  Selectable<String> getAllTabIds({
    bool includeRegular = true,
    bool includePrivate = true,
    bool includeIsolated = true,
  }) {
    final query = selectOnly(db.tab)..addColumns([db.tab.id]);

    final excludedModes = <TabModeDbValue>[];
    if (!includeRegular) excludedModes.add(TabModeDbValue.regular);
    if (!includePrivate) excludedModes.add(TabModeDbValue.private);
    if (!includeIsolated) excludedModes.add(TabModeDbValue.isolated);

    if (excludedModes.isNotEmpty) {
      query.where(db.tab.tabMode.isNotInValues(excludedModes));
    }

    return query.map((row) => row.read(db.tab.id)!);
  }

  Selectable<String> getContainerTabIds(
    String? containerId, {
    bool includeRegular = true,
    bool includePrivate = true,
    bool includeIsolated = true,
  }) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(
        (containerId != null)
            ? db.tab.containerId.equals(containerId)
            : db.tab.containerId.isNull(),
      )
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    final excludedModes = <TabModeDbValue>[];
    if (!includeRegular) excludedModes.add(TabModeDbValue.regular);
    if (!includePrivate) excludedModes.add(TabModeDbValue.private);
    if (!includeIsolated) excludedModes.add(TabModeDbValue.isolated);

    if (excludedModes.isNotEmpty) {
      query.where(db.tab.tabMode.isNotInValues(excludedModes));
    }

    return query.map((row) => row.read(db.tab.id)!);
  }

  /// Every tab of one container, in render order.
  ///
  /// A [TabSummary] rather than a `TabData`: this is watched as a stream, so it
  /// re-runs on every write to `tab`, and no consumer reads a content column.
  Selectable<TabSummary> getContainerTabsData(String? containerId) {
    final query = selectTabSummaries(this, db.tab)
      ..where(
        (containerId != null)
            ? db.tab.containerId.equals(containerId)
            : db.tab.containerId.isNull(),
      )
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => readTabSummary(row, db.tab));
  }

  SingleSelectable<String> generateLeadingOrderKey(
    String? containerId, {
    int bucket = 0,
  }) {
    return db.definitionsDrift.leadingOrderKey(
      bucket: bucket,
      containerId: containerId,
    );
  }

  SingleSelectable<String> generateTrailingOrderKey(
    String? containerId, {
    int bucket = 0,
  }) {
    return db.definitionsDrift.trailingOrderKey(
      bucket: bucket,
      containerId: containerId,
    );
  }

  SingleSelectable<String> generateLeadingContainerOrderKey({
    required bool isPinned,
    int bucket = 0,
  }) {
    return db.definitionsDrift.leadingContainerOrderKey(
      isPinned: isPinned,
      bucket: bucket,
    );
  }

  SingleSelectable<String> generateTrailingContainerOrderKey({
    required bool isPinned,
    int bucket = 0,
  }) {
    return db.definitionsDrift.trailingContainerOrderKey(
      isPinned: isPinned,
      bucket: bucket,
    );
  }

  SingleOrNullSelectable<String> generateOrderKeyAfterContainerId(
    String containerId, {
    required bool isPinned,
  }) {
    return db.definitionsDrift.containerOrderKeyAfter(
      containerId: containerId,
      isPinned: isPinned,
    );
  }

  SingleSelectable<String> generateOrderKeyBeforeContainerId(
    String containerId, {
    required bool isPinned,
  }) {
    return db.definitionsDrift.containerOrderKeyBefore(
      containerId: containerId,
      isPinned: isPinned,
    );
  }

  SingleOrNullSelectable<String> getLastChildTabId(
    String? containerId,
    String parentId,
  ) {
    return db.definitionsDrift.lastChildTabId(
      containerId: containerId,
      parentId: parentId,
    );
  }

  SingleOrNullSelectable<String> generateOrderKeyAfterTabId(
    String? containerId,
    String tabId,
  ) {
    return db.definitionsDrift.orderKeyAfterTab(
      containerId: containerId,
      tabId: tabId,
    );
  }

  SingleSelectable<String> generateOrderKeyBeforeTabId(
    String? containerId,
    String tabId,
  ) {
    return db.definitionsDrift.orderKeyBeforeTab(
      containerId: containerId,
      tabId: tabId,
    );
  }

  SingleSelectable<bool> areSitesAvailable(
    Iterable<Uri> origins,
    String ignoredContainerId,
  ) {
    return db.definitionsDrift.areSitesAvailable(
      ignoreContainerId: ignoredContainerId,
      uriList: jsonEncode(origins.map((value) => value.origin).toList()),
    );
  }

  Selectable<SiteAssignment> allAssignedSites() {
    return db.definitionsDrift.allAssignedSites();
  }

  Selectable<String?> containersToClearOnExit() {
    return db.definitionsDrift.containersToClearOnExit();
  }

  Selectable<StrictContextAssignmentsResult> strictContextAssignments() {
    return db.definitionsDrift.strictContextAssignments();
  }

  Selectable<String?> excludedHistoryContextIds() {
    return db.definitionsDrift.excludedHistoryContextIds();
  }

  SingleOrNullSelectable<ContainerData> getContainerByContextualIdentity(
    String contextId,
  ) {
    return db.definitionsDrift.containerByContextualIdentity(
      contextId: contextId,
    );
  }
}
