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
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/web_feed/data/database/database.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';

/// Long enough that a trigram index over it is unmistakably expensive to
/// rebuild, which is what makes rebuilding it for a `last_read` stamp worth a
/// test.
final _body = 'the quick brown fox jumps over the lazy dog. ' * 400;

final _feedUrl = Uri.parse('https://example.invalid/feed.xml');

void main() {
  late FeedDatabase db;

  setUp(() async {
    db = FeedDatabase(NativeDatabase.memory());

    await db.feedDao.upsertFeed(
      FeedData(url: _feedUrl, title: 'Example', lastFetched: DateTime(2026)),
    );
    await db.articleDao.upsertArticles([
      FeedArticle(
        id: 'article-1',
        feedId: _feedUrl,
        fetched: DateTime(2026),
        created: DateTime(2026),
        title: 'Fox news',
        summaryHtml: '<p>summary</p>',
        summaryPlain: 'summary',
        contentHtml: '<p>$_body</p>',
        contentMarkdown: _body,
        contentPlain: _body,
      ),
    ]);
  });

  tearDown(() async {
    await db.close();
  });

  /// The bytes FTS5 keeps for `article_fts`. A delete + re-insert of a row
  /// appends new segment data, so this changing is the index having been
  /// rewritten.
  Future<int> ftsBytes() async {
    final rows = await db
        .customSelect(
          'SELECT coalesce(sum(length(block)), 0) AS total FROM article_fts_data',
        )
        .getSingle();

    return rows.read<int>('total');
  }

  group('article_after_update', () {
    test('does not rebuild the index when only last_read changes', () async {
      final before = await ftsBytes();

      await db.articleDao.updateArticleRead('article-1', DateTime(2026, 2));

      expect(
        await ftsBytes(),
        before,
        reason:
            'Stamping last_read rewrote the trigram index of the whole article '
            'body. That is what scoping article_after_update to the FTS '
            'columns is for.',
      );
    });

    test(
      'does not rebuild the index when content is rewritten as-is',
      () async {
        // What a feed re-serving an unchanged entry does.
        final before = await ftsBytes();

        await db.articleDao.updateArticleContent([
          FeedArticle(
            id: 'article-1',
            feedId: _feedUrl,
            fetched: DateTime(2026),
            title: 'Fox news',
            summaryHtml: '<p>summary</p>',
            summaryPlain: 'summary',
            contentHtml: '<p>$_body</p>',
            contentMarkdown: _body,
            contentPlain: _body,
          ),
        ]);

        expect(await ftsBytes(), before);
      },
    );

    test('still rebuilds the index when the indexed text changes', () async {
      final before = await ftsBytes();

      await db.articleDao.updateArticleContent([
        FeedArticle(
          id: 'article-1',
          feedId: _feedUrl,
          fetched: DateTime(2026),
          title: 'Fox news',
          summaryHtml: '<p>summary</p>',
          summaryPlain: 'summary',
          contentHtml: '<p>hedgehog</p>',
          contentMarkdown: 'hedgehog',
          contentPlain: 'hedgehog',
        ),
      ]);

      expect(await ftsBytes(), isNot(before));

      // And the new text is findable, i.e. the rebuild was correct and not just
      // noisy.
      final hits = await db.articleDao
          .queryArticles(
            matchPrefix: '',
            matchSuffix: '',
            ellipsis: '…',
            snippetLength: 20,
            searchString: 'hedgehog',
            feedId: null,
          )
          .get();

      expect(hits.map((hit) => hit.id), ['article-1']);
    });
  });

  group('getFeedArticles', () {
    test('reads a view that carries no article body', () async {
      // The view *is* the guarantee, so assert on its definition rather than on
      // one query's SQL.
      final view = await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE name = 'article_list_view'",
          )
          .getSingle();
      final sql = view.read<String>('sql');

      for (final column in [
        'summaryHtml',
        'summaryMarkdown',
        'contentHtml',
        'contentMarkdown',
        'contentPlain',
      ]) {
        expect(
          sql,
          isNot(contains(column)),
          reason: 'article_list_view must not carry the article body.',
        );
      }
    });

    test('still returns everything a card renders', () async {
      final articles = await db.articleDao.getFeedArticles(_feedUrl).get();

      expect(articles.single.id, 'article-1');
      expect(articles.single.title, 'Fox news');
      expect(articles.single.summaryPlain, 'summary');
      expect(articles.single.feedId, _feedUrl);
      expect(articles.single.created, DateTime(2026));
    });
  });
}
