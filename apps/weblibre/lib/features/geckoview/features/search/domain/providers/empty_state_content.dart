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
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';

part 'empty_state_content.g.dart';

@Riverpod()
Future<List<HistoryHighlight>> searchEmptyHistoryHighlights(
  Ref ref, {
  int count = 25,
}) async {
  final highlights = await ref
      .read(historyRepositoryProvider.notifier)
      .getHistoryHighlights(limit: count);

  if (!ref.mounted) return [];

  return highlights.where((h) => Uri.tryParse(h.url) != null).toList();
}

@Riverpod()
Future<List<VisitInfo>> searchEmptyRecentHistory(
  Ref ref, {
  int count = 25,
}) async {
  final visits = await ref
      .read(historyRepositoryProvider.notifier)
      .getVisitsPaginated(count: count);

  if (!ref.mounted) return [];

  return visits.where((v) => Uri.tryParse(v.url) != null).toList();
}

@Riverpod()
AsyncValue<List<FeedArticleSummary>> searchEmptyRecentFeedArticles(
  Ref ref, {
  int count = 25,
}) {
  final feeds = ref.watch(feedListProvider);

  final hasFeeds = feeds.whenOrNull(data: (list) => list.isNotEmpty) ?? false;
  if (!hasFeeds) {
    return const AsyncValue.data([]);
  }

  return ref
      .watch(feedArticleListProvider(null))
      .whenData((articles) => articles.take(count).toList());
}

@Riverpod()
List<TabStateWithContainer> searchEmptyRecentTabs(Ref ref, {int count = 25}) {
  final tabs = ref.watch(fifoTabStatesProvider).value;

  return tabs.take(count).toList();
}
