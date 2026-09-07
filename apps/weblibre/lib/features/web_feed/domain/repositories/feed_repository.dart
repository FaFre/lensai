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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/data/providers.dart';

part 'feed_repository.g.dart';

@Riverpod(keepAlive: true)
class FeedRepository extends _$FeedRepository {
  Future<List<FeedData>> getAllFeeds() {
    return ref.read(feedDatabaseProvider).feedDao.getFeeds().get();
  }

  Future<void> touchFeedFetched(Uri feedId) {
    return ref
        .read(feedDatabaseProvider)
        .feedDao
        .updateFeedFetched(feedId, DateTime.now());
  }

  Future<void> upsertFeed(FeedData feedData) {
    return ref.read(feedDatabaseProvider).feedDao.upsertFeed(feedData);
  }

  Future<void> upsertArticles(List<FeedArticle> articles) {
    return ref.read(feedDatabaseProvider).articleDao.upsertArticles(articles);
  }

  Future<int> deleteFeed(Uri feedId) {
    return ref.read(feedDatabaseProvider).feedDao.deleteFeed(feedId);
  }

  Future<void> touchArticleRead(String articleId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .updateArticleRead(articleId, DateTime.now());
  }

  Future<void> unsetArticleRead(String articleId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .updateArticleRead(articleId, null);
  }

  Stream<List<FeedData>> watchFeeds() {
    return ref.read(feedDatabaseProvider).feedDao.getFeeds().watch();
  }

  Stream<FeedData?> watchFeed(Uri feedId) {
    return ref
        .read(feedDatabaseProvider)
        .feedDao
        .getFeed(feedId)
        .watchSingleOrNull();
  }

  Stream<List<FeedArticleListEntry>> watchFeedArticles(Uri? feedId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .getFeedArticles(feedId)
        .watch();
  }

  Stream<FeedArticle?> watchArticle(String articleId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .getArticleById(articleId)
        .watchSingleOrNull();
  }

  Stream<Map<String, int>> watchUnreadFeedArticleCount() {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .getUnreadArticleCount()
        .watch()
        .map(
          (results) =>
              Map.fromEntries(results.map((e) => MapEntry(e.$1, e.$2))),
        );
  }

  @override
  void build() {}
}
