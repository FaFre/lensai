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
import 'package:drift/drift.dart';
import 'package:drift/internal/versioned_schema.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter/foundation.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/capture_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/visit_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.steps.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';

@DriftDatabase(
  include: {'definitions.drift'},
  daos: [ContainerDao, TabDao, CaptureTabDao, HistoryDao, VisitContainerDao],
)
class TabDatabase extends $TabDatabase with TrigramQueryBuilderMixin {
  @override
  final int schemaVersion = 17;

  @override
  final int ftsTokenLimit = 10;
  @override
  final int ftsMinTokenLength = 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (kDebugMode) {
        // This check pulls in a fair amount of code that's not needed
        // anywhere else, so we recommend only doing it in debug builds.
        await validateDatabaseSchema(
          setup: (database) {
            registerLexorankFunctions(database);
            registerUrlFunctions(database);
          },
        );
      }

      await customStatement('PRAGMA foreign_keys = ON');
      await definitionsDrift.optimizeFtsIndex();
      if (details.versionNow >= 12) {
        await definitionsDrift.optimizeHistoryFtsIndex();
      }
    },
    onUpgrade: (m, from, to) async {
      // Following the advice from https://drift.simonbinder.eu/Migrations/api/#general-tips
      await customStatement('PRAGMA foreign_keys = OFF');

      await transaction(
        () => VersionedSchema.runMigrationSteps(
          migrator: m,
          from: from,
          to: to,
          steps: _upgrade,
        ),
      );

      if (kDebugMode) {
        final wrongForeignKeys = await customSelect(
          'PRAGMA foreign_key_check',
        ).get();
        assert(
          wrongForeignKeys.isEmpty,
          '${wrongForeignKeys.map((e) => e.data)}',
        );
      }

      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  TabDatabase(super.e);

  static final _upgrade = migrationSteps(
    from2To3: (m, schema) async {
      final tabAtV3 = schema.tab;
      await m.addColumn(tabAtV3, tabAtV3.isPrivate);
    },
    from3To4: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.tab,
          columnTransformer: {
            schema.tab.source: Constant(TabSource.manual.index),
          },
          newColumns: [schema.tab.source],
        ),
      );
    },
    from4To5: (m, schema) async {
      await m.drop(schema.tabMaintainParentChainOnDelete);
      await m.create(schema.tabMaintainParentChainOnDelete);
    },
    from5To6: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.tab,
          columnTransformer: {
            // Backfill tab_mode from is_private: private=true -> 1 (private), else -> 0 (regular)
            schema.tab.tabMode: const CustomExpression(
              'CASE WHEN is_private = 1 THEN 1 ELSE 0 END',
            ),
          },
          newColumns: [schema.tab.tabMode, schema.tab.isolationContextId],
        ),
      );

      await m.alterTable(TableMigration(schema.tab));
    },
    from6To7: (m, schema) async {
      await m.addColumn(schema.tab, schema.tab.isPinned);
    },
    from7To8: (m, schema) async {
      // Composite index supporting `tabsWithRootAndDepth` (parent existence
      // checks scoped per container) and `lastChildTabId` (last child of a
      // parent within a container). On large containers SQLite was falling
      // back to per-row scans on the recursive seed.
      //
      // Also drop any rows whose `parent_id` references a tab that no
      // longer exists (e.g. left over from a close that ran without the
      // delete trigger). `tab_maintain_parent_chain_on_delete` keeps this
      // clean going forward; the one-shot UPDATE here removes legacy
      // dangling pointers so the new index is built on consistent data.
      await m.database.customStatement(
        'UPDATE tab SET parent_id = NULL '
        'WHERE parent_id IS NOT NULL '
        'AND NOT EXISTS (SELECT 1 FROM tab p WHERE p.id = tab.parent_id)',
      );

      await m.createIndex(schema.idxTabParentContainer);
    },
    from8To9: (m, schema) async {
      await m.create(schema.closedTabTombstone);
    },
    from9To10: (m, schema) async {
      await m.create(schema.captureTab);
      await m.create(schema.idxCaptureTabCaptureId);
    },
    from10To11: (m, schema) async {
      // Re-scope `tab_after_update` to fire only when FTS-relevant columns
      // change. Previously every tab UPDATE (order_key reshuffle, container
      // reassignment, pin toggle, timestamp touch, ...) rewrote the trigram
      // shadow rows for free.
      await m.drop(schema.tabAfterUpdate);
      await m.create(schema.tabAfterUpdate);
    },
    from11To12: (m, schema) async {
      // Local search index — content companion to Mozilla Places (which
      // remains SoT for visit metadata). See definitions.drift for layout.
      //
      // Order matters: the generated `tab.content_hash` column references
      // the `content_hash()` SQL function, which is registered in the
      // tab.db `setup` callback. The migration runs after `setup`, so the
      // function is available here.
      //
      // `tab.content_hash` requires recreating the tab table because
      // SQLite's ALTER TABLE only supports adding VIRTUAL generated
      // columns when the column is not part of any existing index/trigger
      // dependency chain — drift's TableMigration handles the rebuild.
      await m.alterTable(TableMigration(schema.tab));

      // Settings table seeded with defaults: index enabled, private tabs
      // not indexed.
      await m.create(schema.localIndexSetting);
      await m.database.customStatement(
        "INSERT INTO local_index_setting (key, value) VALUES ('enabled', 1)",
      );
      await m.database.customStatement(
        "INSERT INTO local_index_setting (key, value) VALUES ('index_private', 0)",
      );

      // History content table + FTS5 + maintenance triggers.
      await m.create(schema.history);
      await m.create(schema.idxHistoryHost);
      await m.create(schema.idxHistoryObserved);
      await m.create(schema.historyFts);
      await m.create(schema.historyAfterInsert);
      await m.create(schema.historyAfterDelete);
      await m.create(schema.historyAfterUpdate);

      // tab_after_update gains a content_hash WHEN guard. Recreate.
      await m.drop(schema.tabAfterUpdate);
      await m.create(schema.tabAfterUpdate);

      // Tab → history fan-out triggers.
      await m.create(schema.tabToHistoryOnInsert);
      await m.create(schema.tabToHistoryOnUpdate);
    },
    from12To13: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.container,
          newColumns: [schema.container.orderKey, schema.container.isPinned],
          columnTransformer: {
            schema.container.orderKey: Constant(LexoRank.middle().value),
            schema.container.isPinned: const Constant(false),
          },
        ),
      );

      final database = m.database as TabDatabase;
      final containerIds = await database.definitionsDrift
          .containerIdsByLastUpdated()
          .get();

      var rank = LexoRank.middle();
      for (final containerId in containerIds) {
        await (database.update(database.container)
              ..where((container) => container.id.equals(containerId)))
            .write(ContainerCompanion(orderKey: Value(rank.value)));
        rank = rank.genNext();
      }
    },
    from13To14: (m, schema) async {
      // Add per-container exclude-from-index gate to the tab→history
      // triggers, plus re-evaluation triggers for container assignment and
      // exclude-flag changes.
      await m.drop(schema.tabToHistoryOnInsert);
      await m.create(schema.tabToHistoryOnInsert);
      await m.drop(schema.tabToHistoryOnUpdate);
      await m.create(schema.tabToHistoryOnUpdate);
      await m.create(schema.tabToHistoryOnContainerUpdate);
      await m.create(schema.containerToHistoryOnMetadataUpdate);
    },
    from14To15: (m, schema) async {
      // Visit → container relation. Mozilla Places stays the source of truth
      // for history; this table only records which container each contained
      // visit belonged to. See definitions.drift.
      await m.create(schema.visitContainer);
      await m.create(schema.idxVcCanonical);
      await m.create(schema.idxVcContainer);
    },
    from15To16: (m, schema) async {
      // Exclude-from-history now also keeps a container out of the local
      // search index: recording nothing in Places is pointless while the same
      // pages stay searchable locally (and reachable from any other tab that
      // opens the same URL). Every fan-out trigger gained the second flag.
      await m.drop(schema.tabToHistoryOnInsert);
      await m.create(schema.tabToHistoryOnInsert);
      await m.drop(schema.tabToHistoryOnUpdate);
      await m.create(schema.tabToHistoryOnUpdate);
      await m.drop(schema.tabToHistoryOnContainerUpdate);
      await m.create(schema.tabToHistoryOnContainerUpdate);
      await m.drop(schema.containerToHistoryOnMetadataUpdate);
      await m.create(schema.containerToHistoryOnMetadataUpdate);

      // Re-evaluate what the old predicate already let in, exactly as
      // container_to_history_on_metadata_update does — DELETE, then re-INSERT
      // the best remaining candidate — applied to every excluded container at
      // once. Both halves are needed: the DELETE spares a URL that some other
      // eligible tab still holds, and that spared row would otherwise keep the
      // *excluded* tab's title and content (in `history` and in `history_fts`)
      // until something touched that tab again.
      //
      // The SQL lives in definitions.drift so the analyzer checks it against
      // the schema; see the note there about pinning it if these tables change.
      final database = m.database as TabDatabase;
      await database.definitionsDrift.evictExcludedHistoryPages();
      await database.definitionsDrift.reindexAfterExcludedHistoryEviction();
    },
    from16To17: (m, schema) async {
      // Two indexes only. `getTabsFifo` ordered by `timestamp DESC LIMIT n`
      // with nothing to walk, so SQLite scanned every row of `tab` and pushed
      // it through a sorter — and that query is a live stream re-run on every
      // write to the table. `getContainerTabsData` had the same problem for
      // `container_id` + `order_key`, which `idx_tab_parent_container` cannot
      // serve because `container_id` is not its leftmost column.
      await m.create(schema.idxTabTimestamp);
      await m.create(schema.idxTabContainerOrder);
    },
  );
}
