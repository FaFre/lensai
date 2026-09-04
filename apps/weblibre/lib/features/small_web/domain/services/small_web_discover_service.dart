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
import 'dart:math';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/small_web/data/database/database.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/data/models/wander_console_source.dart';
import 'package:weblibre/features/small_web/domain/services/kagi_source_service.dart';
import 'package:weblibre/features/small_web/domain/services/wander_source_service.dart';

final _random = Random.secure();

class WanderDiscoverResult with FastEquatable {
  final SmallWebItem item;
  final Uri consoleUrl;

  WanderDiscoverResult({required this.item, required this.consoleUrl});

  @override
  List<Object?> get hashParameters => [item, consoleUrl];
}

class SmallWebDiscoverService {
  final SmallWebDatabase _db;
  final KagiSourceService _kagiService;
  final WanderSourceService _wanderService;

  SmallWebDiscoverService(this._db, this._kagiService, this._wanderService);

  Future<void> recordVisit({
    required String itemId,
    required SmallWebSourceKind sourceKind,
    required KagiSmallWebMode? mode,
    Uri? consoleUrl,
  }) async {
    await _db.smallWebVisitDao.insertVisit(
      SmallWebVisit(
        id: uuid.v4(),
        itemId: itemId,
        sourceKind: sourceKind,
        mode: mode?.name,
        consoleUrl: consoleUrl,
        visitedAt: DateTime.now(),
      ),
    );
  }

  Future<SmallWebItem?> discoverKagi({
    required KagiSmallWebMode mode,
    String? category,
  }) async {
    if (await _kagiService.needsRefresh(mode)) {
      await _kagiService.fetchAndIngest(mode);
    }

    final items = await _db.smallWebItemDao
        .getDiscoverableKagiItems(mode, category)
        .get();

    if (items.isEmpty) return null;

    final picked = items[_random.nextInt(items.length)];

    await recordVisit(
      itemId: picked.id,
      sourceKind: SmallWebSourceKind.kagi,
      mode: mode,
    );

    return picked;
  }

  Future<WanderDiscoverResult?> discoverWander({
    Uri? currentConsoleUrl,
    bool forceNewConsole = false,
  }) async {
    await _wanderService.syncSeeds();

    final recentItemIds =
        (await _db.smallWebVisitDao
                .getRecentItemIds(
                  sourceKind: SmallWebSourceKind.wander,
                  mode: null,
                )
                .get())
            .toSet();

    // Pick a console to explore
    Uri consoleUrl;
    if (currentConsoleUrl != null && !forceNewConsole) {
      consoleUrl = currentConsoleUrl;
    } else {
      final consoleUrls = await _wanderService.getDiscoveredConsoleUrls();

      if (forceNewConsole && currentConsoleUrl != null) {
        consoleUrls.remove(currentConsoleUrl);
      }

      if (consoleUrls.isEmpty) return null;

      consoleUrl = consoleUrls[_random.nextInt(consoleUrls.length)];
    }

    final pages = await _refreshAndGetPages(consoleUrl, forceRetry: true);
    final unvisitedPages = pages
        .where((page) => !recentItemIds.contains(page.id))
        .toList();

    if (unvisitedPages.isNotEmpty) {
      return _pickAndRecord(unvisitedPages, consoleUrl);
    }

    // No unvisited pages on this console — try alternatives
    final result = await _tryAlternativeConsoles(consoleUrl, recentItemIds);
    if (result != null) return result;

    // Last resort: revisit a page from the original console
    if (pages.isEmpty) return null;
    return _pickAndRecord(pages, consoleUrl);
  }

  Future<void> updateItemTitle(String itemId, String title) {
    return _db.smallWebItemDao.updateTitle(itemId, title);
  }

  Future<List<SmallWebItem>> _refreshAndGetPages(
    Uri consoleUrl, {
    bool forceRetry = false,
  }) async {
    if (await _wanderService.shouldRefreshConsole(
      consoleUrl,
      forceRetry: forceRetry,
    )) {
      await _wanderService.fetchAndIngestConsole(
        consoleUrl,
        source: WanderConsoleSource.discovered,
      );
    }
    return _wanderService.getPagesForConsole(consoleUrl);
  }

  Future<WanderDiscoverResult?> _tryAlternativeConsoles(
    Uri excludeConsole,
    Set<String> recentItemIds,
  ) async {
    final allConsoles = await _wanderService.getDiscoveredConsoleUrls()
      ..remove(excludeConsole)
      ..shuffle(_random);

    for (final altConsole in allConsoles.take(10)) {
      final List<SmallWebItem> candidates;

      try {
        final altPages = await _refreshAndGetPages(altConsole);
        final unvisited = altPages
            .where((p) => !recentItemIds.contains(p.id))
            .toList();
        candidates = unvisited.isNotEmpty ? unvisited : altPages;
      } catch (_) {
        // Skip consoles that fail to fetch; continue trying others.
        continue;
      }

      // Deliberately outside the try: the catch above is for consoles that fail
      // to fetch, and recording the pick failing is not that.
      if (candidates.isNotEmpty) {
        return _pickAndRecord(candidates, altConsole);
      }
    }

    return null;
  }

  Future<WanderDiscoverResult> _pickAndRecord(
    List<SmallWebItem> candidates,
    Uri consoleUrl,
  ) async {
    final picked = candidates[_random.nextInt(candidates.length)];

    await recordVisit(
      itemId: picked.id,
      sourceKind: SmallWebSourceKind.wander,
      mode: null,
      consoleUrl: consoleUrl,
    );

    return WanderDiscoverResult(item: picked, consoleUrl: consoleUrl);
  }
}
