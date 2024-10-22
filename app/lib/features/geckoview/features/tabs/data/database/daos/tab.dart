import 'dart:async';

import 'package:drift/drift.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lexo_rank/lexo_rank.dart';

part 'tab.g.dart';

@DriftAccessor()
class TabDao extends DatabaseAccessor<TabDatabase> with _$TabDaoMixin {
  TabDao(super.db);

  Selectable<String> containerTabIds(String? containerId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(
        (containerId != null)
            ? db.tab.containerId.equals(containerId)
            : db.tab.containerId.isNull(),
      )
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => row.read(db.tab.id)!);
  }

  Selectable<String> allTabIds() {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => row.read(db.tab.id)!);
  }

  SingleSelectable<String?> tabContainerId(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.containerId])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.read(db.tab.containerId));
  }

  Future<String> upsertTab(
    String tabId, {
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
  }) {
    return db.transaction(() async {
      final currentOrderKey = orderKey.value ??
          await db.containerDao
              .generateLeadingOrderKey(containerId.value)
              .getSingle();

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          timestamp: DateTime.now(),
          containerId: containerId,
          orderKey: currentOrderKey,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion.custom(
            containerId:
                (containerId.present) ? Variable(containerId.value) : null,
            orderKey: (orderKey.present) ? Variable(orderKey.value) : null,
          ),
        ),
      );

      return tabId;
    });
  }

  Future<void> assignContainer(
    String id, {
    required String? containerId,
  }) {
    final statement = db.tab.update()..where((t) => t.id.equals(id));
    return statement.write(
      TabCompanion(containerId: Value(containerId)),
    );
  }

  Future<void> assignOrderKey(
    String id, {
    required String orderKey,
  }) {
    final statement = db.tab.update()..where((t) => t.id.equals(id));
    return statement.write(
      TabCompanion(orderKey: Value(orderKey)),
    );
  }

  Future<void> touchTab(
    String id, {
    required DateTime timestamp,
  }) {
    final statement = db.tab.update()..where((t) => t.id.equals(id));
    return statement.write(
      TabCompanion(timestamp: Value(timestamp)),
    );
  }

  Future<void> syncTabs({required List<String> retainTabIds}) async {
    return db.transaction(() async {
      await (db.tab.delete()..where((t) => t.id.isNotIn(retainTabIds))).go();

      var currentOrderKey =
          await db.containerDao.generateLeadingOrderKey(null).getSingle();

      await db.tab.insertAll(
        retainTabIds.map(
          (id) {
            final insertable = TabCompanion.insert(
              id: id,
              orderKey: currentOrderKey,
              timestamp: DateTime.now(),
            );

            currentOrderKey = LexoRank.parse(currentOrderKey).genPrev().value;

            return insertable;
          },
        ),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
