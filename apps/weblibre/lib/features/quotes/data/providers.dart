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
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/asset_database.dart';
import 'package:weblibre/core/database_registry.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/features/quotes/data/database/database.dart';

part 'providers.g.dart';

const _quotesAssetPath = 'assets/quotes/quotes.db';
const _quotesDbFileName = 'quotes.db';

@Riverpod(keepAlive: true)
QuotesDatabase quotesDatabase(Ref ref) {
  final db = QuotesDatabase(
    LazyDatabase(() async {
      final file = await installAssetDatabase(
        assetPath: _quotesAssetPath,
        target: File(
          p.join(filesystem.profileDatabasesDir.path, _quotesDbFileName),
        ),
      );

      return NativeDatabase.createInBackground(file);
    }),
  );

  DatabaseRegistry.instance.register('quotes', db);

  ref.onDispose(() async {
    await db.close();
  });

  return db;
}
