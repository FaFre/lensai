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
import 'package:weblibre/features/web_feed/data/database/daos/article.drift.dart';
import 'package:weblibre/features/web_feed/data/database/database.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_query_result.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';

@DriftAccessor()
class ArticleDao extends DatabaseAccessor<FeedDatabase> with $ArticleDaoMixin {
  ArticleDao(super.attachedDatabase);

  /// The feed's articles, newest first — without their bodies. See
  /// `article_list_view`.
  Selectable<FeedArticleListEntry> getFeedArticles(Uri? url) {
    final select = db.articleListView.select();

    if (url != null) {
      select.where((article) => article.feedId.equalsValue(url));
    }

    return select..orderBy([
      (row) => OrderingTerm(
        expression: coalesce([row.updated, row.created]),
        mode: OrderingMode.desc,
      ),
    ]);
  }

  Selectable<FeedArticle> getUnprocessedArticles() {
    return db.articleView.select()..where(
      (article) =>
          (article.contentHtml.isNotNull() &
              (article.contentMarkdown.isNull() |
                  article.contentPlain.isNull())) |
          (article.summaryHtml.isNotNull() &
              (article.summaryMarkdown.isNull() |
                  article.summaryPlain.isNull())),
    );
  }

  SingleOrNullSelectable<FeedArticle> getArticleById(String articleId) {
    return db.articleView.select()..where((row) => row.id.equals(articleId));
  }

  Future<void> updateArticleContent(List<FeedArticle> articles) {
    return db.transaction(() async {
      await Future.wait(
        articles.map((newArticle) {
          final statement = db.article.update()
            ..where((article) => article.id.equals(newArticle.id));

          return statement.write(
            ArticleCompanion(
              summaryHtml: Value(newArticle.summaryHtml),
              summaryMarkdown: Value(newArticle.summaryMarkdown),
              summaryPlain: Value(newArticle.summaryPlain),
              contentHtml: Value(newArticle.contentHtml),
              contentMarkdown: Value(newArticle.contentMarkdown),
              contentPlain: Value(newArticle.contentPlain),
            ),
          );
        }),
      );
    });
  }

  Future<void> upsertArticles(List<FeedArticle> articles) {
    return db.transaction(() async {
      await Future.wait(
        articles
            .map(
              (article) => db.article.insertOne(
                article,
                onConflict: DoUpdate(
                  (old) {
                    return ArticleCompanion(
                      authors: Value(article.authors),
                      contentHtml: Value(article.contentHtml),
                      contentMarkdown: Value(article.contentMarkdown),
                      contentPlain: Value(article.contentPlain),
                      links: Value(article.links),
                      summaryHtml: Value(article.summaryHtml),
                      summaryMarkdown: Value(article.summaryMarkdown),
                      summaryPlain: Value(article.summaryPlain),
                      tags: Value(article.tags),
                      title: Value(article.title),
                      updated: Value(article.updated),
                    );
                  },
                  where: (old) =>
                      old.updated.isNotNull() &
                      old.updated.isSmallerThanValue(
                        article.updated ?? DateTime(0),
                      ),
                ),
              ),
            )
            .toList(),
      );
    });
  }

  Future<int> updateArticleRead(String articleId, DateTime? read) {
    final statement = db.article.update()
      ..where((article) => article.id.equals(articleId));

    return statement.write(ArticleCompanion(lastRead: Value(read)));
  }

  Selectable<(String, int)> getUnreadArticleCount() {
    final count = countAll();

    final countByFeed = db.article.selectOnly()
      ..addColumns([db.article.feedId, count])
      ..where(
        db.article.lastRead.isNull() |
            (db.article.updated.isNotNull() &
                db.article.lastRead.isSmallerThan(db.article.lastRead)),
      )
      ..groupBy([db.article.feedId]);

    return countByFeed.map(
      (result) => (result.read(db.article.feedId)!, result.read(count)!),
    );
  }

  Selectable<FeedArticleQueryResult> queryArticles({
    required String matchPrefix,
    required String matchSuffix,
    required String ellipsis,
    required int snippetLength,
    required String searchString,
    required Uri? feedId,
    int limit = 25,
  }) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.definitionsDrift.queryArticlesFullContent(
        feedId: feedId?.toString(),
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
        limit: limit,
      );
    } else {
      return db.definitionsDrift.queryArticlesBasic(
        feedId: feedId?.toString(),
        query: db.buildLikeQuery(searchString),
        limit: limit,
      );
    }
  }
}
