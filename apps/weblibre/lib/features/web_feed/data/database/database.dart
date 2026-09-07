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
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';
import 'package:weblibre/features/web_feed/data/database/daos/article.dart';
import 'package:weblibre/features/web_feed/data/database/daos/feed.dart';
import 'package:weblibre/features/web_feed/data/database/database.drift.dart';
import 'package:weblibre/features/web_feed/data/database/database.steps.dart';

@DriftDatabase(include: {'definitions.drift'}, daos: [ArticleDao, FeedDao])
class FeedDatabase extends $FeedDatabase with TrigramQueryBuilderMixin {
  @override
  final int schemaVersion = 2;

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
        await validateDatabaseSchema();
      }

      await customStatement('PRAGMA foreign_keys = ON;');
      await definitionsDrift.optimizeFtsIndex();
    },
    onUpgrade: (m, from, to) async {
      // https://drift.simonbinder.eu/Migrations/api/#general-tips
      await customStatement('PRAGMA foreign_keys = OFF');

      await transaction(
        () => VersionedSchema.runMigrationSteps(
          migrator: m,
          from: from,
          to: to,
          steps: _upgrade,
        ),
      );

      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  FeedDatabase(super.e);

  static final _upgrade = migrationSteps(
    from1To2: (m, schema) async {
      // The body-free list projection.
      await m.create(schema.articleListView);

      // `article_after_update` is now scoped to the FTS columns and guarded on
      // them changing. Recreate; see definitions.drift.
      await m.drop(schema.articleAfterUpdate);
      await m.create(schema.articleAfterUpdate);
    },
  );
}
