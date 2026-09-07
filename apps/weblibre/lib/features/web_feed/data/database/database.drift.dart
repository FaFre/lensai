// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/web_feed/data/database/daos/article.dart'
    as i2;
import 'package:weblibre/features/web_feed/data/database/database.dart' as i3;
import 'package:weblibre/features/web_feed/data/database/daos/feed.dart' as i4;
import 'package:drift/internal/modular.dart' as i5;
import 'package:sqlite3/common.dart' as i6;

abstract class $FeedDatabase extends i0.GeneratedDatabase {
  $FeedDatabase(i0.QueryExecutor e) : super(e);
  $FeedDatabaseManager get managers => $FeedDatabaseManager(this);
  late final i1.Feed feed = i1.Feed(this);
  late final i1.Article article = i1.Article(this);
  late final i1.ArticleView articleView = i1.ArticleView(this);
  late final i1.ArticleListView articleListView = i1.ArticleListView(this);
  late final i1.ArticleFts articleFts = i1.ArticleFts(this);
  late final i2.ArticleDao articleDao = i2.ArticleDao(this as i3.FeedDatabase);
  late final i4.FeedDao feedDao = i4.FeedDao(this as i3.FeedDatabase);
  i1.DefinitionsDrift get definitionsDrift => i5.ReadDatabaseContainer(
    this,
  ).accessor<i1.DefinitionsDrift>(i1.DefinitionsDrift.new);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    feed,
    article,
    articleView,
    articleListView,
    i1.articleFeedId,
    articleFts,
    i1.articleAfterInsert,
    i1.articleAfterDelete,
    i1.articleAfterUpdate,
  ];
  @override
  i0.StreamQueryUpdateRules get streamUpdateRules =>
      const i0.StreamQueryUpdateRules([
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'feed',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [i0.TableUpdate('article', kind: i0.UpdateKind.delete)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'article',
            limitUpdateKind: i0.UpdateKind.insert,
          ),
          result: [i0.TableUpdate('article_fts', kind: i0.UpdateKind.insert)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'article',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [i0.TableUpdate('article_fts', kind: i0.UpdateKind.insert)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'article',
            limitUpdateKind: i0.UpdateKind.update,
          ),
          result: [i0.TableUpdate('article_fts', kind: i0.UpdateKind.insert)],
        ),
      ]);
}

class $FeedDatabaseManager {
  final $FeedDatabase _db;
  $FeedDatabaseManager(this._db);
  i1.$FeedTableManager get feed => i1.$FeedTableManager(_db, _db.feed);
  i1.$ArticleTableManager get article =>
      i1.$ArticleTableManager(_db, _db.article);
  i1.$ArticleFtsTableManager get articleFts =>
      i1.$ArticleFtsTableManager(_db, _db.articleFts);
}

extension DefineFunctions on i6.CommonDatabase {
  void defineFunctions({
    required String Function(int, String?) lexoRankNext,
    required String Function(int, String?) lexoRankPrevious,
    required String Function(String?, String?) lexoRankReorderAfter,
    required String Function(String?, String?) lexoRankReorderBefore,
    required int Function() generateContentHash,
    required bool Function(String?) urlIndexable,
    required String Function(String?) urlCanonical,
    required String Function(String?) urlHost,
    required String Function(String?) urlPath,
  }) {
    createFunction(
      functionName: 'lexo_rank_next',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankNext(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_previous',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankPrevious(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_after',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderAfter(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_before',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderBefore(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'generate_content_hash',
      argumentCount: const i6.AllowedArgumentCount(0),
      function: (args) {
        return generateContentHash();
      },
    );
    createFunction(
      functionName: 'url_indexable',
      argumentCount: const i6.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlIndexable(arg0);
      },
    );
    createFunction(
      functionName: 'url_canonical',
      argumentCount: const i6.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlCanonical(arg0);
      },
    );
    createFunction(
      functionName: 'url_host',
      argumentCount: const i6.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlHost(arg0);
      },
    );
    createFunction(
      functionName: 'url_path',
      argumentCount: const i6.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlPath(arg0);
      },
    );
  }
}
