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
import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor, Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

/// Columns no query that merely *lists* tabs may read.
///
/// `content_hash` earns its place next to the four text columns: it is a
/// `VIRTUAL` generated column, so SQLite evaluates it — a Dart UDF that
/// UTF-8-encodes and hashes up to 512 KB of stored page text — once per row it
/// materialises. Selecting it in a list query costs a re-hash of every stored
/// page on every emission.
const _forbiddenColumns = {
  'extracted_content_markdown',
  'extracted_content_plain',
  'full_content_markdown',
  'full_content_plain',
  'content_hash',
};

/// Records the SQL drift actually sends.
///
/// The alternative would be asking a `Selectable` for its query, which drift
/// does not expose once `.map()` has wrapped it — and reading the real statement
/// is the stronger assertion anyway.
typedef _RecordedSelect = ({String sql, List<Object?> args});

class _RecordingInterceptor extends QueryInterceptor {
  final selects = <_RecordedSelect>[];

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    selects.add((sql: statement, args: args));
    return super.runSelect(executor, statement, args);
  }
}

void _expectNoContentColumns(String sql) {
  final lowered = sql.toLowerCase();
  for (final column in _forbiddenColumns) {
    expect(
      lowered,
      isNot(contains(column)),
      reason:
          'This query is watched as a stream and re-runs on every write to '
          '`tab`; selecting `$column` re-reads (and for content_hash, '
          're-hashes) every stored page. Project the columns explicitly — see '
          'TabSummary.\nSQL: $sql',
    );
  }
}

void main() {
  late TabDatabase db;
  late _RecordingInterceptor recorded;

  setUp(() {
    recorded = _RecordingInterceptor();
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ).interceptWith(recorded),
    );
  });

  /// The statement [run] issued against `tab`, with its bound arguments.
  Future<_RecordedSelect> selectOf(Future<void> Function() run) async {
    recorded.selects.clear();
    await run();

    return recorded.selects.singleWhere(
      (select) => select.sql.contains('FROM "tab"'),
    );
  }

  Future<String> sqlOf(Future<void> Function() run) async =>
      (await selectOf(run)).sql;

  tearDown(() async {
    await db.close();
  });

  group('the tab queries that render lists', () {
    test('getTabsFifo selects no content columns', () async {
      _expectNoContentColumns(await sqlOf(db.tabDao.getTabsFifo().get));
    });

    test('getContainerTabsFifo selects no content columns', () async {
      _expectNoContentColumns(
        await sqlOf(db.tabDao.getContainerTabsFifo('work').get),
      );
    });

    test('getContainerTabsData selects no content columns', () async {
      _expectNoContentColumns(
        await sqlOf(db.containerDao.getContainerTabsData('work').get),
      );
    });

    test('getTabSummaryById selects no content columns', () async {
      _expectNoContentColumns(
        await sqlOf(db.tabDao.getTabSummaryById('tab-1').getSingleOrNull),
      );
    });

    test('getTabContainerData selects no content columns', () async {
      _expectNoContentColumns(
        await sqlOf(db.tabDao.getTabContainerData('tab-1').getSingleOrNull),
      );
    });

    test('watchTabDbData selects no content columns', () async {
      // Watched for as long as the tab menu or parent picker is open, so it
      // re-runs on every write to `tab`.
      _expectNoContentColumns(
        await sqlOf(
          () => db.tabDao.getTabSummaryById('tab-1').watchSingleOrNull().first,
        ),
      );
    });

    test(
      'getTabDataById is still the wide row — one row, and its caller wants it',
      () async {
        final sql = await sqlOf(
          db.tabDao.getTabDataById('tab-1').getSingleOrNull,
        );

        // `SELECT *`, which is precisely why it may not be used for a list:
        // the star covers the content columns and the generated hash.
        expect(sql, contains('SELECT * FROM "tab"'));
      },
    );
  });

  group('the indexes those queries need', () {
    /// `EXPLAIN QUERY PLAN` is the only thing that proves an index is reachable;
    /// the schema merely declaring one says nothing about whether the planner
    /// can use it for the query as written.
    Future<String> plan(_RecordedSelect select) async {
      final rows = await db
          .customSelect(
            'EXPLAIN QUERY PLAN ${select.sql}',
            // `Variable<Object>` accepts a null value fine; only the type
            // argument has a non-nullable bound.
            variables: [
              for (final arg in select.args) Variable<Object>(arg as Object),
            ],
          )
          .get();

      return rows.map((row) => row.data['detail'] as String).join('\n');
    }

    Future<void> addTab(String id, {String? containerId}) async {
      await db.tabDao.insertTab(
        id,
        source: TabSource.manual,
        parentId: const Value(null),
        containerId: Value(containerId),
      );
      await db.tabDao.touchTab(id, timestamp: DateTime(2026, 8, 1, 12));
    }

    test('getTabsFifo walks idx_tab_timestamp instead of sorting', () async {
      await addTab('a');

      final detail = await plan(await selectOf(db.tabDao.getTabsFifo().get));

      expect(detail, contains('idx_tab_timestamp'));
      // A B-tree walk in the right direction needs no sorter at all. This is
      // the half that matters: without the index SQLite pushed every row of
      // `tab` through a temp sorter to find the newest few.
      expect(detail, isNot(contains('USE TEMP B-TREE FOR ORDER BY')));
    });

    test('getTabsFifo breaks timestamp ties deterministically', () async {
      // Drift stores DATETIME as unix seconds, so tabs touched in the same
      // second tie — and `resumeLatestContainerTab` takes LIMIT 1 off this.
      final sameSecond = DateTime(2026, 8, 1, 12);
      for (final id in ['a', 'b', 'c']) {
        await addTab(id);
        await db.tabDao.touchTab(id, timestamp: sameSecond);
      }

      final order = (await db.tabDao.getTabsFifo().get())
          .map((tab) => tab.id)
          .toList();

      expect(order, ['c', 'b', 'a']);

      // And the index still serves the whole ordering, ties included.
      final detail = await plan(await selectOf(db.tabDao.getTabsFifo().get));
      expect(detail, contains('idx_tab_timestamp'));
      expect(detail, isNot(contains('USE TEMP B-TREE FOR ORDER BY')));
    });

    test(
      'getContainerTabsData walks idx_tab_container_order instead of sorting',
      () async {
        await db.containerDao.addContainer(
          ContainerData(
            id: 'work',
            name: 'work',
            color: Colors.blue,
            orderKey: 'work',
            metadata: ContainerMetadata.withDefaults(
              contextualIdentity: 'work',
            ),
          ),
        );
        await addTab('a', containerId: 'work');

        final detail = await plan(
          await selectOf(db.containerDao.getContainerTabsData('work').get),
        );

        expect(detail, contains('idx_tab_container_order'));
        expect(detail, isNot(contains('USE TEMP B-TREE FOR ORDER BY')));
      },
    );
  });
}
