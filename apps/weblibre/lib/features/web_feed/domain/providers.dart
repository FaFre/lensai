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

import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/data/models/feed_parse_result.dart';
import 'package:weblibre/features/web_feed/data/providers.dart';
import 'package:weblibre/features/web_feed/domain/providers/article_filter.dart';
import 'package:weblibre/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:weblibre/features/web_feed/domain/services/feed_reader.dart';

part 'providers.g.dart';

@Riverpod()
class ArticleSearch extends _$ArticleSearch {
  late StreamController<List<FeedArticleSummary>> _streamController;

  Future<void> search(
    String input, {
    int snippetLength = 120,
    int maxResults = 25,
    String matchPrefix = '***',
    String matchSuffix = '***',
    String ellipsis = '…',
  }) async {
    if (input.isNotEmpty) {
      await ref
          .read(feedDatabaseProvider)
          .articleDao
          .queryArticles(
            matchPrefix: matchPrefix,
            matchSuffix: matchSuffix,
            ellipsis: ellipsis,
            snippetLength: snippetLength,
            searchString: input,
            feedId: feedId,
            limit: maxResults,
          )
          .get()
          .then((value) {
            if (!_streamController.isClosed) {
              _streamController.add(value);
            }
          });
    }
  }

  @override
  Stream<List<FeedArticleSummary>> build(Uri? feedId) {
    _streamController = StreamController();

    ref.onDispose(() async {
      await _streamController.close();
    });

    return ConcatStream([Stream.value([]), _streamController.stream]);
  }
}

@Riverpod()
Stream<List<FeedData>> feedList(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchFeeds();
}

@Riverpod()
Stream<FeedData?> feedData(Ref ref, Uri? feedId) {
  final repository = ref.watch(feedRepositoryProvider.notifier);

  if (feedId == null) {
    return Stream.value(null);
  }

  return repository.watchFeed(feedId);
}

@Riverpod()
Stream<List<FeedArticleListEntry>> feedArticleList(Ref ref, Uri? feedId) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchFeedArticles(feedId);
}

@Riverpod()
class FilteredArticleList extends _$FilteredArticleList {
  bool _hasSearch = false;

  void search(String input) {
    if (input.isNotEmpty) {
      if (!_hasSearch) {
        _hasSearch = true;
        ref.invalidateSelf();
      }

      //Don't block
      unawaited(ref.read(articleSearchProvider(feedId).notifier).search(input));
    } else if (_hasSearch) {
      _hasSearch = false;
      ref.invalidateSelf();
    }
  }

  @override
  AsyncValue<List<FeedArticleSummary>> build(Uri? feedId) {
    final filterTags = ref.watch(articleFilterProvider);

    final articlesAsync = _hasSearch
        ? ref.watch(articleSearchProvider(feedId))
        : ref.watch(feedArticleListProvider(feedId));

    return articlesAsync.whenData((articles) {
      if (filterTags.isNotEmpty) {
        return articles.where((article) {
          final tags = article.tags?.map((tag) => tag.id).toSet();

          final authors = article.authors
              ?.map((author) => author.name.whenNotEmpty)
              .nonNulls
              .toSet();

          return filterTags.every(
            (filter) =>
                (tags?.contains(filter) ?? false) ||
                (authors?.contains(filter) ?? false),
          );
        }).toList();
      }

      return articles;
    });
  }
}

@Riverpod()
Stream<FeedArticle?> feedArticle(
  Ref ref,
  String articleId, {
  required bool updateReadDate,
}) async* {
  final repository = ref.watch(feedRepositoryProvider.notifier);

  if (updateReadDate) {
    await repository.touchArticleRead(articleId);
  }

  yield* repository.watchArticle(articleId);
}

@Riverpod()
Raw<Stream<Map<String, int>>> unreadArticleCount(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchUnreadFeedArticleCount();
}

@Riverpod()
Stream<int?> unreadFeedArticleCount(Ref ref, Uri feedId) {
  final stream = ref.watch(unreadArticleCountProvider);
  return stream.map((counts) => counts[feedId.toString()]);
}

@Riverpod()
Future<FeedParseResult> fetchWebFeed(Ref ref, Uri url) {
  return ref.read(feedReaderProvider.notifier).parseFeed(url);
}
