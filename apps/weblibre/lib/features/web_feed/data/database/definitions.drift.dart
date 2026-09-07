// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/web_feed/data/models/feed_author.dart' as i2;
import 'package:weblibre/features/web_feed/data/models/feed_category.dart'
    as i3;
import 'package:weblibre/data/database/converters/uri.dart' as i4;
import 'package:weblibre/features/web_feed/data/database/converters/feed_authors.dart'
    as i5;
import 'package:weblibre/features/web_feed/data/database/converters/feed_categories.dart'
    as i6;
import 'package:weblibre/features/web_feed/data/models/feed_article.dart' as i7;
import 'package:weblibre/features/web_feed/data/models/feed_link.dart' as i8;
import 'package:weblibre/features/web_feed/data/database/converters/feed_links.dart'
    as i9;
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart'
    as i10;
import 'package:drift/internal/modular.dart' as i11;
import 'package:weblibre/features/web_feed/data/models/feed_article_query_result.dart'
    as i12;

typedef $FeedCreateCompanionBuilder =
    i1.FeedCompanion Function({
      required Uri url,
      i0.Value<String?> title,
      i0.Value<String?> description,
      i0.Value<Uri?> icon,
      i0.Value<Uri?> siteLink,
      i0.Value<List<i2.FeedAuthor>?> authors,
      i0.Value<List<i3.FeedCategory>?> tags,
      i0.Value<DateTime?> lastFetched,
      i0.Value<int> rowid,
    });
typedef $FeedUpdateCompanionBuilder =
    i1.FeedCompanion Function({
      i0.Value<Uri> url,
      i0.Value<String?> title,
      i0.Value<String?> description,
      i0.Value<Uri?> icon,
      i0.Value<Uri?> siteLink,
      i0.Value<List<i2.FeedAuthor>?> authors,
      i0.Value<List<i3.FeedCategory>?> tags,
      i0.Value<DateTime?> lastFetched,
      i0.Value<int> rowid,
    });

final class $FeedReferences
    extends i0.BaseReferences<i0.GeneratedDatabase, i1.Feed, i1.FeedData> {
  $FeedReferences(super.$_db, super.$_table, super.$_typedResult);

  static i0.MultiTypedResultKey<i1.Article, List<i7.FeedArticle>>
  _articleRefsTable(i0.GeneratedDatabase db) =>
      i0.MultiTypedResultKey.fromTable(
        i11.ReadDatabaseContainer(db).resultSet<i1.Article>('article'),
        aliasName: 'feed__url__article__feed_id',
      );

  i1.$ArticleProcessedTableManager get articleRefs {
    final manager = i1
        .$ArticleTableManager(
          $_db,
          i11.ReadDatabaseContainer($_db).resultSet<i1.Article>('article'),
        )
        .filter((f) => f.feedId.url.sqlEquals($_itemColumn<String>('url')!));

    final cache = $_typedResult.readTableOrNull(_articleRefsTable($_db));
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $FeedFilterComposer extends i0.Composer<i0.GeneratedDatabase, i1.Feed> {
  $FeedFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnWithTypeConverterFilters<Uri, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<Uri?, Uri, String> get icon =>
      $composableBuilder(
        column: $table.icon,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<Uri?, Uri, String> get siteLink =>
      $composableBuilder(
        column: $table.siteLink,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<
    List<i2.FeedAuthor>?,
    List<i2.FeedAuthor>,
    String
  >
  get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    List<i3.FeedCategory>?,
    List<i3.FeedCategory>,
    String
  >
  get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.Expression<bool> articleRefs(
    i0.Expression<bool> Function(i1.$ArticleFilterComposer f) f,
  ) {
    final i1.$ArticleFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: i11.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.Article>('article'),
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$ArticleFilterComposer(
            $db: $db,
            $table: i11.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.Article>('article'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FeedOrderingComposer extends i0.Composer<i0.GeneratedDatabase, i1.Feed> {
  $FeedOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get siteLink => $composableBuilder(
    column: $table.siteLink,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $FeedAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Feed> {
  $FeedAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumnWithTypeConverter<Uri, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  i0.GeneratedColumnWithTypeConverter<Uri?, String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri?, String> get siteLink =>
      $composableBuilder(column: $table.siteLink, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<List<i2.FeedAuthor>?, String>
  get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<List<i3.FeedCategory>?, String>
  get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  i0.Expression<T> articleRefs<T extends Object>(
    i0.Expression<T> Function(i1.$ArticleAnnotationComposer a) f,
  ) {
    final i1.$ArticleAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: i11.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.Article>('article'),
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$ArticleAnnotationComposer(
            $db: $db,
            $table: i11.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.Article>('article'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FeedTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.Feed,
          i1.FeedData,
          i1.$FeedFilterComposer,
          i1.$FeedOrderingComposer,
          i1.$FeedAnnotationComposer,
          $FeedCreateCompanionBuilder,
          $FeedUpdateCompanionBuilder,
          (i1.FeedData, i1.$FeedReferences),
          i1.FeedData,
          i0.PrefetchHooks Function({bool articleRefs})
        > {
  $FeedTableManager(i0.GeneratedDatabase db, i1.Feed table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$FeedFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$FeedOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$FeedAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<Uri> url = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<String?> description = const i0.Value.absent(),
                i0.Value<Uri?> icon = const i0.Value.absent(),
                i0.Value<Uri?> siteLink = const i0.Value.absent(),
                i0.Value<List<i2.FeedAuthor>?> authors =
                    const i0.Value.absent(),
                i0.Value<List<i3.FeedCategory>?> tags = const i0.Value.absent(),
                i0.Value<DateTime?> lastFetched = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.FeedCompanion(
                url: url,
                title: title,
                description: description,
                icon: icon,
                siteLink: siteLink,
                authors: authors,
                tags: tags,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Uri url,
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<String?> description = const i0.Value.absent(),
                i0.Value<Uri?> icon = const i0.Value.absent(),
                i0.Value<Uri?> siteLink = const i0.Value.absent(),
                i0.Value<List<i2.FeedAuthor>?> authors =
                    const i0.Value.absent(),
                i0.Value<List<i3.FeedCategory>?> tags = const i0.Value.absent(),
                i0.Value<DateTime?> lastFetched = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.FeedCompanion.insert(
                url: url,
                title: title,
                description: description,
                icon: icon,
                siteLink: siteLink,
                authors: authors,
                tags: tags,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), i1.$FeedReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({articleRefs = false}) {
            return i0.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (articleRefs)
                  i11.ReadDatabaseContainer(
                    db,
                  ).resultSet<i1.Article>('article'),
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (articleRefs)
                    await i0.$_getPrefetchedData<
                      i1.FeedData,
                      i1.Feed,
                      i7.FeedArticle
                    >(
                      currentTable: table,
                      referencedTable: i1.$FeedReferences._articleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          i1.$FeedReferences(db, table, p0).articleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.feedId == item.url),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $FeedProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.Feed,
      i1.FeedData,
      i1.$FeedFilterComposer,
      i1.$FeedOrderingComposer,
      i1.$FeedAnnotationComposer,
      $FeedCreateCompanionBuilder,
      $FeedUpdateCompanionBuilder,
      (i1.FeedData, i1.$FeedReferences),
      i1.FeedData,
      i0.PrefetchHooks Function({bool articleRefs})
    >;
typedef $ArticleCreateCompanionBuilder =
    i1.ArticleCompanion Function({
      required String id,
      required Uri feedId,
      required DateTime fetched,
      i0.Value<DateTime?> created,
      i0.Value<DateTime?> updated,
      i0.Value<DateTime?> lastRead,
      i0.Value<String?> title,
      i0.Value<List<i2.FeedAuthor>?> authors,
      i0.Value<List<i3.FeedCategory>?> tags,
      i0.Value<List<i8.FeedLink>?> links,
      i0.Value<String?> summaryHtml,
      i0.Value<String?> summaryMarkdown,
      i0.Value<String?> summaryPlain,
      i0.Value<String?> contentHtml,
      i0.Value<String?> contentMarkdown,
      i0.Value<String?> contentPlain,
      i0.Value<int> rowid,
    });
typedef $ArticleUpdateCompanionBuilder =
    i1.ArticleCompanion Function({
      i0.Value<String> id,
      i0.Value<Uri> feedId,
      i0.Value<DateTime> fetched,
      i0.Value<DateTime?> created,
      i0.Value<DateTime?> updated,
      i0.Value<DateTime?> lastRead,
      i0.Value<String?> title,
      i0.Value<List<i2.FeedAuthor>?> authors,
      i0.Value<List<i3.FeedCategory>?> tags,
      i0.Value<List<i8.FeedLink>?> links,
      i0.Value<String?> summaryHtml,
      i0.Value<String?> summaryMarkdown,
      i0.Value<String?> summaryPlain,
      i0.Value<String?> contentHtml,
      i0.Value<String?> contentMarkdown,
      i0.Value<String?> contentPlain,
      i0.Value<int> rowid,
    });

final class $ArticleReferences
    extends
        i0.BaseReferences<i0.GeneratedDatabase, i1.Article, i7.FeedArticle> {
  $ArticleReferences(super.$_db, super.$_table, super.$_typedResult);

  static i1.Feed _feedIdTable(i0.GeneratedDatabase db) =>
      i11.ReadDatabaseContainer(
        db,
      ).resultSet<i1.Feed>('feed').createAlias('article__feed_id__feed__url');

  i1.$FeedProcessedTableManager get feedId {
    final $_column = $_itemColumn<String>('feed_id')!;

    final manager = i1
        .$FeedTableManager(
          $_db,
          i11.ReadDatabaseContainer($_db).resultSet<i1.Feed>('feed'),
        )
        .filter((f) => f.url.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feedIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ArticleFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Article> {
  $ArticleFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get fetched => $composableBuilder(
    column: $table.fetched,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    List<i2.FeedAuthor>?,
    List<i2.FeedAuthor>,
    String
  >
  get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    List<i3.FeedCategory>?,
    List<i3.FeedCategory>,
    String
  >
  get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    List<i8.FeedLink>?,
    List<i8.FeedLink>,
    String
  >
  get links => $composableBuilder(
    column: $table.links,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get summaryHtml => $composableBuilder(
    column: $table.summaryHtml,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get summaryMarkdown => $composableBuilder(
    column: $table.summaryMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i1.$FeedFilterComposer get feedId {
    final i1.$FeedFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: i11.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.Feed>('feed'),
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$FeedFilterComposer(
            $db: $db,
            $table: i11.ReadDatabaseContainer($db).resultSet<i1.Feed>('feed'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ArticleOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Article> {
  $ArticleOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get fetched => $composableBuilder(
    column: $table.fetched,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get links => $composableBuilder(
    column: $table.links,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get summaryHtml => $composableBuilder(
    column: $table.summaryHtml,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get summaryMarkdown => $composableBuilder(
    column: $table.summaryMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i1.$FeedOrderingComposer get feedId {
    final i1.$FeedOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: i11.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.Feed>('feed'),
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$FeedOrderingComposer(
            $db: $db,
            $table: i11.ReadDatabaseContainer($db).resultSet<i1.Feed>('feed'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ArticleAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Article> {
  $ArticleAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get fetched =>
      $composableBuilder(column: $table.fetched, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get lastRead =>
      $composableBuilder(column: $table.lastRead, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<List<i2.FeedAuthor>?, String>
  get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<List<i3.FeedCategory>?, String>
  get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<List<i8.FeedLink>?, String> get links =>
      $composableBuilder(column: $table.links, builder: (column) => column);

  i0.GeneratedColumn<String> get summaryHtml => $composableBuilder(
    column: $table.summaryHtml,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get summaryMarkdown => $composableBuilder(
    column: $table.summaryMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => column,
  );

  i1.$FeedAnnotationComposer get feedId {
    final i1.$FeedAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: i11.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.Feed>('feed'),
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$FeedAnnotationComposer(
            $db: $db,
            $table: i11.ReadDatabaseContainer($db).resultSet<i1.Feed>('feed'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ArticleTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.Article,
          i7.FeedArticle,
          i1.$ArticleFilterComposer,
          i1.$ArticleOrderingComposer,
          i1.$ArticleAnnotationComposer,
          $ArticleCreateCompanionBuilder,
          $ArticleUpdateCompanionBuilder,
          (i7.FeedArticle, i1.$ArticleReferences),
          i7.FeedArticle,
          i0.PrefetchHooks Function({bool feedId})
        > {
  $ArticleTableManager(i0.GeneratedDatabase db, i1.Article table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$ArticleFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$ArticleOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$ArticleAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<Uri> feedId = const i0.Value.absent(),
                i0.Value<DateTime> fetched = const i0.Value.absent(),
                i0.Value<DateTime?> created = const i0.Value.absent(),
                i0.Value<DateTime?> updated = const i0.Value.absent(),
                i0.Value<DateTime?> lastRead = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<List<i2.FeedAuthor>?> authors =
                    const i0.Value.absent(),
                i0.Value<List<i3.FeedCategory>?> tags = const i0.Value.absent(),
                i0.Value<List<i8.FeedLink>?> links = const i0.Value.absent(),
                i0.Value<String?> summaryHtml = const i0.Value.absent(),
                i0.Value<String?> summaryMarkdown = const i0.Value.absent(),
                i0.Value<String?> summaryPlain = const i0.Value.absent(),
                i0.Value<String?> contentHtml = const i0.Value.absent(),
                i0.Value<String?> contentMarkdown = const i0.Value.absent(),
                i0.Value<String?> contentPlain = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ArticleCompanion(
                id: id,
                feedId: feedId,
                fetched: fetched,
                created: created,
                updated: updated,
                lastRead: lastRead,
                title: title,
                authors: authors,
                tags: tags,
                links: links,
                summaryHtml: summaryHtml,
                summaryMarkdown: summaryMarkdown,
                summaryPlain: summaryPlain,
                contentHtml: contentHtml,
                contentMarkdown: contentMarkdown,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uri feedId,
                required DateTime fetched,
                i0.Value<DateTime?> created = const i0.Value.absent(),
                i0.Value<DateTime?> updated = const i0.Value.absent(),
                i0.Value<DateTime?> lastRead = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<List<i2.FeedAuthor>?> authors =
                    const i0.Value.absent(),
                i0.Value<List<i3.FeedCategory>?> tags = const i0.Value.absent(),
                i0.Value<List<i8.FeedLink>?> links = const i0.Value.absent(),
                i0.Value<String?> summaryHtml = const i0.Value.absent(),
                i0.Value<String?> summaryMarkdown = const i0.Value.absent(),
                i0.Value<String?> summaryPlain = const i0.Value.absent(),
                i0.Value<String?> contentHtml = const i0.Value.absent(),
                i0.Value<String?> contentMarkdown = const i0.Value.absent(),
                i0.Value<String?> contentPlain = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ArticleCompanion.insert(
                id: id,
                feedId: feedId,
                fetched: fetched,
                created: created,
                updated: updated,
                lastRead: lastRead,
                title: title,
                authors: authors,
                tags: tags,
                links: links,
                summaryHtml: summaryHtml,
                summaryMarkdown: summaryMarkdown,
                summaryPlain: summaryPlain,
                contentHtml: contentHtml,
                contentMarkdown: contentMarkdown,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), i1.$ArticleReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({feedId = false}) {
            return i0.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends i0.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (feedId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.feedId,
                                referencedTable: i1.$ArticleReferences
                                    ._feedIdTable(db),
                                referencedColumn: i1.$ArticleReferences
                                    ._feedIdTable(db)
                                    .url,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ArticleProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.Article,
      i7.FeedArticle,
      i1.$ArticleFilterComposer,
      i1.$ArticleOrderingComposer,
      i1.$ArticleAnnotationComposer,
      $ArticleCreateCompanionBuilder,
      $ArticleUpdateCompanionBuilder,
      (i7.FeedArticle, i1.$ArticleReferences),
      i7.FeedArticle,
      i0.PrefetchHooks Function({bool feedId})
    >;
typedef $ArticleFtsCreateCompanionBuilder =
    i1.ArticleFtsCompanion Function({
      required String title,
      required String summaryPlain,
      required String contentPlain,
      i0.Value<int> rowid,
    });
typedef $ArticleFtsUpdateCompanionBuilder =
    i1.ArticleFtsCompanion Function({
      i0.Value<String> title,
      i0.Value<String> summaryPlain,
      i0.Value<String> contentPlain,
      i0.Value<int> rowid,
    });

class $ArticleFtsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ArticleFts> {
  $ArticleFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $ArticleFtsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ArticleFts> {
  $ArticleFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $ArticleFtsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ArticleFts> {
  $ArticleFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => column,
  );
}

class $ArticleFtsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.ArticleFts,
          i1.ArticleFt,
          i1.$ArticleFtsFilterComposer,
          i1.$ArticleFtsOrderingComposer,
          i1.$ArticleFtsAnnotationComposer,
          $ArticleFtsCreateCompanionBuilder,
          $ArticleFtsUpdateCompanionBuilder,
          (
            i1.ArticleFt,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.ArticleFts,
              i1.ArticleFt
            >,
          ),
          i1.ArticleFt,
          i0.PrefetchHooks Function()
        > {
  $ArticleFtsTableManager(i0.GeneratedDatabase db, i1.ArticleFts table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$ArticleFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$ArticleFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$ArticleFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> title = const i0.Value.absent(),
                i0.Value<String> summaryPlain = const i0.Value.absent(),
                i0.Value<String> contentPlain = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ArticleFtsCompanion(
                title: title,
                summaryPlain: summaryPlain,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String summaryPlain,
                required String contentPlain,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ArticleFtsCompanion.insert(
                title: title,
                summaryPlain: summaryPlain,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ArticleFtsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.ArticleFts,
      i1.ArticleFt,
      i1.$ArticleFtsFilterComposer,
      i1.$ArticleFtsOrderingComposer,
      i1.$ArticleFtsAnnotationComposer,
      $ArticleFtsCreateCompanionBuilder,
      $ArticleFtsUpdateCompanionBuilder,
      (
        i1.ArticleFt,
        i0.BaseReferences<i0.GeneratedDatabase, i1.ArticleFts, i1.ArticleFt>,
      ),
      i1.ArticleFt,
      i0.PrefetchHooks Function()
    >;

class Feed extends i0.Table with i0.TableInfo<Feed, i1.FeedData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Feed(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> url =
      i0.GeneratedColumn<String>(
        'url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'PRIMARY KEY NOT NULL',
      ).withConverter<Uri>(i1.Feed.$converterurl);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> description =
      i0.GeneratedColumn<String>(
        'description',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> icon =
      i0.GeneratedColumn<String>(
        'icon',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(i1.Feed.$convertericon);
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> siteLink =
      i0.GeneratedColumn<String>(
        'site_link',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(i1.Feed.$convertersiteLink);
  late final i0.GeneratedColumnWithTypeConverter<List<i2.FeedAuthor>?, String>
  authors = i0.GeneratedColumn<String>(
    'authors',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<i2.FeedAuthor>?>(i1.Feed.$converterauthorsn);
  late final i0.GeneratedColumnWithTypeConverter<List<i3.FeedCategory>?, String>
  tags = i0.GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<i3.FeedCategory>?>(i1.Feed.$convertertagsn);
  late final i0.GeneratedColumn<DateTime> lastFetched =
      i0.GeneratedColumn<DateTime>(
        'last_fetched',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    url,
    title,
    description,
    icon,
    siteLink,
    authors,
    tags,
    lastFetched,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {url};
  @override
  i1.FeedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.FeedData(
      url: i1.Feed.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}url'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: i1.Feed.$convertericon.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}icon'],
        ),
      ),
      siteLink: i1.Feed.$convertersiteLink.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}site_link'],
        ),
      ),
      authors: i1.Feed.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      tags: i1.Feed.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      lastFetched: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched'],
      ),
    );
  }

  @override
  Feed createAlias(String alias) {
    return Feed(attachedDatabase, alias);
  }

  static i0.TypeConverter<Uri, String> $converterurl = const i4.UriConverter();
  static i0.TypeConverter<Uri?, String?> $convertericon =
      const i4.UriConverterNullable();
  static i0.TypeConverter<Uri?, String?> $convertersiteLink =
      const i4.UriConverterNullable();
  static i0.TypeConverter<List<i2.FeedAuthor>, String> $converterauthors =
      const i5.FeedAuthorsConverter();
  static i0.TypeConverter<List<i2.FeedAuthor>?, String?> $converterauthorsn =
      i0.NullAwareTypeConverter.wrap($converterauthors);
  static i0.TypeConverter<List<i3.FeedCategory>, String> $convertertags =
      const i6.FeedCategoriesConverter();
  static i0.TypeConverter<List<i3.FeedCategory>?, String?> $convertertagsn =
      i0.NullAwareTypeConverter.wrap($convertertags);
  @override
  bool get dontWriteConstraints => true;
}

class FeedData extends i0.DataClass implements i0.Insertable<i1.FeedData> {
  final Uri url;
  final String? title;
  final String? description;
  final Uri? icon;
  final Uri? siteLink;
  final List<i2.FeedAuthor>? authors;
  final List<i3.FeedCategory>? tags;
  final DateTime? lastFetched;
  const FeedData({
    required this.url,
    this.title,
    this.description,
    this.icon,
    this.siteLink,
    this.authors,
    this.tags,
    this.lastFetched,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    {
      map['url'] = i0.Variable<String>(i1.Feed.$converterurl.toSql(url));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = i0.Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = i0.Variable<String>(description);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = i0.Variable<String>(i1.Feed.$convertericon.toSql(icon));
    }
    if (!nullToAbsent || siteLink != null) {
      map['site_link'] = i0.Variable<String>(
        i1.Feed.$convertersiteLink.toSql(siteLink),
      );
    }
    if (!nullToAbsent || authors != null) {
      map['authors'] = i0.Variable<String>(
        i1.Feed.$converterauthorsn.toSql(authors),
      );
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = i0.Variable<String>(i1.Feed.$convertertagsn.toSql(tags));
    }
    if (!nullToAbsent || lastFetched != null) {
      map['last_fetched'] = i0.Variable<DateTime>(lastFetched);
    }
    return map;
  }

  factory FeedData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return FeedData(
      url: serializer.fromJson<Uri>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<Uri?>(json['icon']),
      siteLink: serializer.fromJson<Uri?>(json['site_link']),
      authors: serializer.fromJson<List<i2.FeedAuthor>?>(json['authors']),
      tags: serializer.fromJson<List<i3.FeedCategory>?>(json['tags']),
      lastFetched: serializer.fromJson<DateTime?>(json['last_fetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<Uri>(url),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<Uri?>(icon),
      'site_link': serializer.toJson<Uri?>(siteLink),
      'authors': serializer.toJson<List<i2.FeedAuthor>?>(authors),
      'tags': serializer.toJson<List<i3.FeedCategory>?>(tags),
      'last_fetched': serializer.toJson<DateTime?>(lastFetched),
    };
  }

  i1.FeedData copyWith({
    Uri? url,
    i0.Value<String?> title = const i0.Value.absent(),
    i0.Value<String?> description = const i0.Value.absent(),
    i0.Value<Uri?> icon = const i0.Value.absent(),
    i0.Value<Uri?> siteLink = const i0.Value.absent(),
    i0.Value<List<i2.FeedAuthor>?> authors = const i0.Value.absent(),
    i0.Value<List<i3.FeedCategory>?> tags = const i0.Value.absent(),
    i0.Value<DateTime?> lastFetched = const i0.Value.absent(),
  }) => i1.FeedData(
    url: url ?? this.url,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    siteLink: siteLink.present ? siteLink.value : this.siteLink,
    authors: authors.present ? authors.value : this.authors,
    tags: tags.present ? tags.value : this.tags,
    lastFetched: lastFetched.present ? lastFetched.value : this.lastFetched,
  );
  FeedData copyWithCompanion(i1.FeedCompanion data) {
    return FeedData(
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      siteLink: data.siteLink.present ? data.siteLink.value : this.siteLink,
      authors: data.authors.present ? data.authors.value : this.authors,
      tags: data.tags.present ? data.tags.value : this.tags,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedData(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('siteLink: $siteLink, ')
          ..write('authors: $authors, ')
          ..write('tags: $tags, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    url,
    title,
    description,
    icon,
    siteLink,
    authors,
    tags,
    lastFetched,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.FeedData &&
          other.url == this.url &&
          other.title == this.title &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.siteLink == this.siteLink &&
          other.authors == this.authors &&
          other.tags == this.tags &&
          other.lastFetched == this.lastFetched);
}

class FeedCompanion extends i0.UpdateCompanion<i1.FeedData> {
  final i0.Value<Uri> url;
  final i0.Value<String?> title;
  final i0.Value<String?> description;
  final i0.Value<Uri?> icon;
  final i0.Value<Uri?> siteLink;
  final i0.Value<List<i2.FeedAuthor>?> authors;
  final i0.Value<List<i3.FeedCategory>?> tags;
  final i0.Value<DateTime?> lastFetched;
  final i0.Value<int> rowid;
  const FeedCompanion({
    this.url = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.description = const i0.Value.absent(),
    this.icon = const i0.Value.absent(),
    this.siteLink = const i0.Value.absent(),
    this.authors = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.lastFetched = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  FeedCompanion.insert({
    required Uri url,
    this.title = const i0.Value.absent(),
    this.description = const i0.Value.absent(),
    this.icon = const i0.Value.absent(),
    this.siteLink = const i0.Value.absent(),
    this.authors = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.lastFetched = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : url = i0.Value(url);
  static i0.Insertable<i1.FeedData> custom({
    i0.Expression<String>? url,
    i0.Expression<String>? title,
    i0.Expression<String>? description,
    i0.Expression<String>? icon,
    i0.Expression<String>? siteLink,
    i0.Expression<String>? authors,
    i0.Expression<String>? tags,
    i0.Expression<DateTime>? lastFetched,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (siteLink != null) 'site_link': siteLink,
      if (authors != null) 'authors': authors,
      if (tags != null) 'tags': tags,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.FeedCompanion copyWith({
    i0.Value<Uri>? url,
    i0.Value<String?>? title,
    i0.Value<String?>? description,
    i0.Value<Uri?>? icon,
    i0.Value<Uri?>? siteLink,
    i0.Value<List<i2.FeedAuthor>?>? authors,
    i0.Value<List<i3.FeedCategory>?>? tags,
    i0.Value<DateTime?>? lastFetched,
    i0.Value<int>? rowid,
  }) {
    return i1.FeedCompanion(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      siteLink: siteLink ?? this.siteLink,
      authors: authors ?? this.authors,
      tags: tags ?? this.tags,
      lastFetched: lastFetched ?? this.lastFetched,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (url.present) {
      map['url'] = i0.Variable<String>(i1.Feed.$converterurl.toSql(url.value));
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = i0.Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = i0.Variable<String>(
        i1.Feed.$convertericon.toSql(icon.value),
      );
    }
    if (siteLink.present) {
      map['site_link'] = i0.Variable<String>(
        i1.Feed.$convertersiteLink.toSql(siteLink.value),
      );
    }
    if (authors.present) {
      map['authors'] = i0.Variable<String>(
        i1.Feed.$converterauthorsn.toSql(authors.value),
      );
    }
    if (tags.present) {
      map['tags'] = i0.Variable<String>(
        i1.Feed.$convertertagsn.toSql(tags.value),
      );
    }
    if (lastFetched.present) {
      map['last_fetched'] = i0.Variable<DateTime>(lastFetched.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedCompanion(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('siteLink: $siteLink, ')
          ..write('authors: $authors, ')
          ..write('tags: $tags, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Article extends i0.Table with i0.TableInfo<Article, i7.FeedArticle> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Article(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> feedId =
      i0.GeneratedColumn<String>(
        'feed_id',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL REFERENCES feed(url)ON DELETE CASCADE',
      ).withConverter<Uri>(i1.Article.$converterfeedId);
  late final i0.GeneratedColumn<DateTime> fetched =
      i0.GeneratedColumn<DateTime>(
        'fetched',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<DateTime> created =
      i0.GeneratedColumn<DateTime>(
        'created',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<DateTime> updated =
      i0.GeneratedColumn<DateTime>(
        'updated',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<DateTime> lastRead =
      i0.GeneratedColumn<DateTime>(
        'last_read',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumnWithTypeConverter<List<i2.FeedAuthor>?, String>
  authors = i0.GeneratedColumn<String>(
    'authors',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<i2.FeedAuthor>?>(i1.Article.$converterauthorsn);
  late final i0.GeneratedColumnWithTypeConverter<List<i3.FeedCategory>?, String>
  tags = i0.GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<i3.FeedCategory>?>(i1.Article.$convertertagsn);
  late final i0.GeneratedColumnWithTypeConverter<List<i8.FeedLink>?, String>
  links = i0.GeneratedColumn<String>(
    'links',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<i8.FeedLink>?>(i1.Article.$converterlinksn);
  late final i0.GeneratedColumn<String> summaryHtml =
      i0.GeneratedColumn<String>(
        'summaryHtml',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> summaryMarkdown =
      i0.GeneratedColumn<String>(
        'summaryMarkdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> summaryPlain =
      i0.GeneratedColumn<String>(
        'summaryPlain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> contentHtml =
      i0.GeneratedColumn<String>(
        'contentHtml',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> contentMarkdown =
      i0.GeneratedColumn<String>(
        'contentMarkdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> contentPlain =
      i0.GeneratedColumn<String>(
        'contentPlain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    feedId,
    fetched,
    created,
    updated,
    lastRead,
    title,
    authors,
    tags,
    links,
    summaryHtml,
    summaryMarkdown,
    summaryPlain,
    contentHtml,
    contentMarkdown,
    contentPlain,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i7.FeedArticle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i7.FeedArticle(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedId: i1.Article.$converterfeedId.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}feed_id'],
        )!,
      ),
      fetched: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}fetched'],
      )!,
      created: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      ),
      updated: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      lastRead: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      authors: i1.Article.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      tags: i1.Article.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      links: i1.Article.$converterlinksn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}links'],
        ),
      ),
      summaryHtml: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryHtml'],
      ),
      summaryMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryMarkdown'],
      ),
      summaryPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryPlain'],
      ),
      contentHtml: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}contentHtml'],
      ),
      contentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}contentMarkdown'],
      ),
      contentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}contentPlain'],
      ),
    );
  }

  @override
  Article createAlias(String alias) {
    return Article(attachedDatabase, alias);
  }

  static i0.TypeConverter<Uri, String> $converterfeedId =
      const i4.UriConverter();
  static i0.TypeConverter<List<i2.FeedAuthor>, String> $converterauthors =
      const i5.FeedAuthorsConverter();
  static i0.TypeConverter<List<i2.FeedAuthor>?, String?> $converterauthorsn =
      i0.NullAwareTypeConverter.wrap($converterauthors);
  static i0.TypeConverter<List<i3.FeedCategory>, String> $convertertags =
      const i6.FeedCategoriesConverter();
  static i0.TypeConverter<List<i3.FeedCategory>?, String?> $convertertagsn =
      i0.NullAwareTypeConverter.wrap($convertertags);
  static i0.TypeConverter<List<i8.FeedLink>, String> $converterlinks =
      const i9.FeedLinksConverter();
  static i0.TypeConverter<List<i8.FeedLink>?, String?> $converterlinksn =
      i0.NullAwareTypeConverter.wrap($converterlinks);
  @override
  bool get dontWriteConstraints => true;
}

class ArticleCompanion extends i0.UpdateCompanion<i7.FeedArticle> {
  final i0.Value<String> id;
  final i0.Value<Uri> feedId;
  final i0.Value<DateTime> fetched;
  final i0.Value<DateTime?> created;
  final i0.Value<DateTime?> updated;
  final i0.Value<DateTime?> lastRead;
  final i0.Value<String?> title;
  final i0.Value<List<i2.FeedAuthor>?> authors;
  final i0.Value<List<i3.FeedCategory>?> tags;
  final i0.Value<List<i8.FeedLink>?> links;
  final i0.Value<String?> summaryHtml;
  final i0.Value<String?> summaryMarkdown;
  final i0.Value<String?> summaryPlain;
  final i0.Value<String?> contentHtml;
  final i0.Value<String?> contentMarkdown;
  final i0.Value<String?> contentPlain;
  final i0.Value<int> rowid;
  const ArticleCompanion({
    this.id = const i0.Value.absent(),
    this.feedId = const i0.Value.absent(),
    this.fetched = const i0.Value.absent(),
    this.created = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
    this.lastRead = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.authors = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.links = const i0.Value.absent(),
    this.summaryHtml = const i0.Value.absent(),
    this.summaryMarkdown = const i0.Value.absent(),
    this.summaryPlain = const i0.Value.absent(),
    this.contentHtml = const i0.Value.absent(),
    this.contentMarkdown = const i0.Value.absent(),
    this.contentPlain = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  ArticleCompanion.insert({
    required String id,
    required Uri feedId,
    required DateTime fetched,
    this.created = const i0.Value.absent(),
    this.updated = const i0.Value.absent(),
    this.lastRead = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.authors = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.links = const i0.Value.absent(),
    this.summaryHtml = const i0.Value.absent(),
    this.summaryMarkdown = const i0.Value.absent(),
    this.summaryPlain = const i0.Value.absent(),
    this.contentHtml = const i0.Value.absent(),
    this.contentMarkdown = const i0.Value.absent(),
    this.contentPlain = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       feedId = i0.Value(feedId),
       fetched = i0.Value(fetched);
  static i0.Insertable<i7.FeedArticle> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? feedId,
    i0.Expression<DateTime>? fetched,
    i0.Expression<DateTime>? created,
    i0.Expression<DateTime>? updated,
    i0.Expression<DateTime>? lastRead,
    i0.Expression<String>? title,
    i0.Expression<String>? authors,
    i0.Expression<String>? tags,
    i0.Expression<String>? links,
    i0.Expression<String>? summaryHtml,
    i0.Expression<String>? summaryMarkdown,
    i0.Expression<String>? summaryPlain,
    i0.Expression<String>? contentHtml,
    i0.Expression<String>? contentMarkdown,
    i0.Expression<String>? contentPlain,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (fetched != null) 'fetched': fetched,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (lastRead != null) 'last_read': lastRead,
      if (title != null) 'title': title,
      if (authors != null) 'authors': authors,
      if (tags != null) 'tags': tags,
      if (links != null) 'links': links,
      if (summaryHtml != null) 'summaryHtml': summaryHtml,
      if (summaryMarkdown != null) 'summaryMarkdown': summaryMarkdown,
      if (summaryPlain != null) 'summaryPlain': summaryPlain,
      if (contentHtml != null) 'contentHtml': contentHtml,
      if (contentMarkdown != null) 'contentMarkdown': contentMarkdown,
      if (contentPlain != null) 'contentPlain': contentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.ArticleCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<Uri>? feedId,
    i0.Value<DateTime>? fetched,
    i0.Value<DateTime?>? created,
    i0.Value<DateTime?>? updated,
    i0.Value<DateTime?>? lastRead,
    i0.Value<String?>? title,
    i0.Value<List<i2.FeedAuthor>?>? authors,
    i0.Value<List<i3.FeedCategory>?>? tags,
    i0.Value<List<i8.FeedLink>?>? links,
    i0.Value<String?>? summaryHtml,
    i0.Value<String?>? summaryMarkdown,
    i0.Value<String?>? summaryPlain,
    i0.Value<String?>? contentHtml,
    i0.Value<String?>? contentMarkdown,
    i0.Value<String?>? contentPlain,
    i0.Value<int>? rowid,
  }) {
    return i1.ArticleCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      fetched: fetched ?? this.fetched,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      lastRead: lastRead ?? this.lastRead,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      tags: tags ?? this.tags,
      links: links ?? this.links,
      summaryHtml: summaryHtml ?? this.summaryHtml,
      summaryMarkdown: summaryMarkdown ?? this.summaryMarkdown,
      summaryPlain: summaryPlain ?? this.summaryPlain,
      contentHtml: contentHtml ?? this.contentHtml,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
      contentPlain: contentPlain ?? this.contentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = i0.Variable<String>(
        i1.Article.$converterfeedId.toSql(feedId.value),
      );
    }
    if (fetched.present) {
      map['fetched'] = i0.Variable<DateTime>(fetched.value);
    }
    if (created.present) {
      map['created'] = i0.Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = i0.Variable<DateTime>(updated.value);
    }
    if (lastRead.present) {
      map['last_read'] = i0.Variable<DateTime>(lastRead.value);
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (authors.present) {
      map['authors'] = i0.Variable<String>(
        i1.Article.$converterauthorsn.toSql(authors.value),
      );
    }
    if (tags.present) {
      map['tags'] = i0.Variable<String>(
        i1.Article.$convertertagsn.toSql(tags.value),
      );
    }
    if (links.present) {
      map['links'] = i0.Variable<String>(
        i1.Article.$converterlinksn.toSql(links.value),
      );
    }
    if (summaryHtml.present) {
      map['summaryHtml'] = i0.Variable<String>(summaryHtml.value);
    }
    if (summaryMarkdown.present) {
      map['summaryMarkdown'] = i0.Variable<String>(summaryMarkdown.value);
    }
    if (summaryPlain.present) {
      map['summaryPlain'] = i0.Variable<String>(summaryPlain.value);
    }
    if (contentHtml.present) {
      map['contentHtml'] = i0.Variable<String>(contentHtml.value);
    }
    if (contentMarkdown.present) {
      map['contentMarkdown'] = i0.Variable<String>(contentMarkdown.value);
    }
    if (contentPlain.present) {
      map['contentPlain'] = i0.Variable<String>(contentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('fetched: $fetched, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('lastRead: $lastRead, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('tags: $tags, ')
          ..write('links: $links, ')
          ..write('summaryHtml: $summaryHtml, ')
          ..write('summaryMarkdown: $summaryMarkdown, ')
          ..write('summaryPlain: $summaryPlain, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('contentMarkdown: $contentMarkdown, ')
          ..write('contentPlain: $contentPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ArticleView extends i0.ViewInfo<i1.ArticleView, i7.FeedArticle>
    implements i0.HasResultSet {
  final String? _alias;
  @override
  final i0.GeneratedDatabase attachedDatabase;
  ArticleView(this.attachedDatabase, [this._alias]);
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    feedId,
    fetched,
    created,
    updated,
    lastRead,
    title,
    authors,
    tags,
    links,
    summaryHtml,
    summaryMarkdown,
    summaryPlain,
    contentHtml,
    contentMarkdown,
    contentPlain,
    icon,
    siteLink,
  ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'article_view';
  @override
  Map<i0.SqlDialect, String> get createViewStatements => {
    i0.SqlDialect.sqlite:
        'CREATE VIEW article_view AS SELECT a.*, f.icon, f.site_link FROM article AS a INNER JOIN feed AS f ON f.url = a.feed_id',
  };
  @override
  ArticleView get asDslTable => this;
  @override
  i7.FeedArticle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i7.FeedArticle(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedId: i1.Article.$converterfeedId.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}feed_id'],
        )!,
      ),
      fetched: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}fetched'],
      )!,
      created: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      ),
      updated: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      lastRead: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      authors: i1.Article.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      tags: i1.Article.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      links: i1.Article.$converterlinksn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}links'],
        ),
      ),
      summaryHtml: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryHtml'],
      ),
      summaryMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryMarkdown'],
      ),
      summaryPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryPlain'],
      ),
      contentHtml: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}contentHtml'],
      ),
      contentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}contentMarkdown'],
      ),
      contentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}contentPlain'],
      ),
      icon: i1.Feed.$convertericon.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}icon'],
        ),
      ),
      siteLink: i1.Feed.$convertersiteLink.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}site_link'],
        ),
      ),
    );
  }

  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> feedId =
      i0.GeneratedColumn<String>(
        'feed_id',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
      ).withConverter<Uri>(i1.Article.$converterfeedId);
  late final i0.GeneratedColumn<DateTime> fetched =
      i0.GeneratedColumn<DateTime>(
        'fetched',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<DateTime> created =
      i0.GeneratedColumn<DateTime>(
        'created',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<DateTime> updated =
      i0.GeneratedColumn<DateTime>(
        'updated',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<DateTime> lastRead =
      i0.GeneratedColumn<DateTime>(
        'last_read',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  );
  late final i0.GeneratedColumnWithTypeConverter<List<i2.FeedAuthor>?, String>
  authors = i0.GeneratedColumn<String>(
    'authors',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  ).withConverter<List<i2.FeedAuthor>?>(i1.Article.$converterauthorsn);
  late final i0.GeneratedColumnWithTypeConverter<List<i3.FeedCategory>?, String>
  tags = i0.GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  ).withConverter<List<i3.FeedCategory>?>(i1.Article.$convertertagsn);
  late final i0.GeneratedColumnWithTypeConverter<List<i8.FeedLink>?, String>
  links = i0.GeneratedColumn<String>(
    'links',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  ).withConverter<List<i8.FeedLink>?>(i1.Article.$converterlinksn);
  late final i0.GeneratedColumn<String> summaryHtml =
      i0.GeneratedColumn<String>(
        'summaryHtml',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumn<String> summaryMarkdown =
      i0.GeneratedColumn<String>(
        'summaryMarkdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumn<String> summaryPlain =
      i0.GeneratedColumn<String>(
        'summaryPlain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumn<String> contentHtml =
      i0.GeneratedColumn<String>(
        'contentHtml',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumn<String> contentMarkdown =
      i0.GeneratedColumn<String>(
        'contentMarkdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumn<String> contentPlain =
      i0.GeneratedColumn<String>(
        'contentPlain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> icon =
      i0.GeneratedColumn<String>(
        'icon',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      ).withConverter<Uri?>(i1.Feed.$convertericon);
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> siteLink =
      i0.GeneratedColumn<String>(
        'site_link',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      ).withConverter<Uri?>(i1.Feed.$convertersiteLink);
  @override
  ArticleView createAlias(String alias) {
    return ArticleView(attachedDatabase, alias);
  }

  @override
  i0.Query? get query => null;
  @override
  Set<String> get readTables => const {'article', 'feed'};
}

class ArticleListView
    extends i0.ViewInfo<i1.ArticleListView, i10.FeedArticleListEntry>
    implements i0.HasResultSet {
  final String? _alias;
  @override
  final i0.GeneratedDatabase attachedDatabase;
  ArticleListView(this.attachedDatabase, [this._alias]);
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    feedId,
    fetched,
    created,
    updated,
    lastRead,
    title,
    authors,
    tags,
    links,
    summaryPlain,
    icon,
    siteLink,
  ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'article_list_view';
  @override
  Map<i0.SqlDialect, String> get createViewStatements => {
    i0.SqlDialect.sqlite:
        'CREATE VIEW article_list_view AS SELECT a.id, a.feed_id, a.fetched, a.created, a.updated, a.last_read, a.title, a.authors, a.tags, a.links, a.summaryPlain, f.icon, f.site_link FROM article AS a INNER JOIN feed AS f ON f.url = a.feed_id',
  };
  @override
  ArticleListView get asDslTable => this;
  @override
  i10.FeedArticleListEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i10.FeedArticleListEntry(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedId: i1.Article.$converterfeedId.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}feed_id'],
        )!,
      ),
      fetched: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}fetched'],
      )!,
      created: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      ),
      updated: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      lastRead: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      authors: i1.Article.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      tags: i1.Article.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      links: i1.Article.$converterlinksn.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}links'],
        ),
      ),
      summaryPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryPlain'],
      ),
      icon: i1.Feed.$convertericon.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}icon'],
        ),
      ),
      siteLink: i1.Feed.$convertersiteLink.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}site_link'],
        ),
      ),
    );
  }

  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> feedId =
      i0.GeneratedColumn<String>(
        'feed_id',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
      ).withConverter<Uri>(i1.Article.$converterfeedId);
  late final i0.GeneratedColumn<DateTime> fetched =
      i0.GeneratedColumn<DateTime>(
        'fetched',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<DateTime> created =
      i0.GeneratedColumn<DateTime>(
        'created',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<DateTime> updated =
      i0.GeneratedColumn<DateTime>(
        'updated',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<DateTime> lastRead =
      i0.GeneratedColumn<DateTime>(
        'last_read',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
      );
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  );
  late final i0.GeneratedColumnWithTypeConverter<List<i2.FeedAuthor>?, String>
  authors = i0.GeneratedColumn<String>(
    'authors',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  ).withConverter<List<i2.FeedAuthor>?>(i1.Article.$converterauthorsn);
  late final i0.GeneratedColumnWithTypeConverter<List<i3.FeedCategory>?, String>
  tags = i0.GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  ).withConverter<List<i3.FeedCategory>?>(i1.Article.$convertertagsn);
  late final i0.GeneratedColumnWithTypeConverter<List<i8.FeedLink>?, String>
  links = i0.GeneratedColumn<String>(
    'links',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  ).withConverter<List<i8.FeedLink>?>(i1.Article.$converterlinksn);
  late final i0.GeneratedColumn<String> summaryPlain =
      i0.GeneratedColumn<String>(
        'summaryPlain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> icon =
      i0.GeneratedColumn<String>(
        'icon',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      ).withConverter<Uri?>(i1.Feed.$convertericon);
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> siteLink =
      i0.GeneratedColumn<String>(
        'site_link',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      ).withConverter<Uri?>(i1.Feed.$convertersiteLink);
  @override
  ArticleListView createAlias(String alias) {
    return ArticleListView(attachedDatabase, alias);
  }

  @override
  i0.Query? get query => null;
  @override
  Set<String> get readTables => const {'article', 'feed'};
}

i0.Index get articleFeedId => i0.Index(
  'article_feed_id',
  'CREATE INDEX article_feed_id ON article (feed_id)',
);

class ArticleFts extends i0.Table
    with
        i0.TableInfo<ArticleFts, i1.ArticleFt>,
        i0.VirtualTableInfo<ArticleFts, i1.ArticleFt> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  ArticleFts(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> summaryPlain =
      i0.GeneratedColumn<String>(
        'summaryPlain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> contentPlain =
      i0.GeneratedColumn<String>(
        'contentPlain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [title, summaryPlain, contentPlain];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_fts';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i1.ArticleFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.ArticleFt(
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summaryPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summaryPlain'],
      )!,
      contentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}contentPlain'],
      )!,
    );
  }

  @override
  ArticleFts createAlias(String alias) {
    return ArticleFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, summaryPlain, contentPlain, content=article, tokenize="trigram")';
}

class ArticleFt extends i0.DataClass implements i0.Insertable<i1.ArticleFt> {
  final String title;
  final String summaryPlain;
  final String contentPlain;
  const ArticleFt({
    required this.title,
    required this.summaryPlain,
    required this.contentPlain,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['title'] = i0.Variable<String>(title);
    map['summaryPlain'] = i0.Variable<String>(summaryPlain);
    map['contentPlain'] = i0.Variable<String>(contentPlain);
    return map;
  }

  factory ArticleFt.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return ArticleFt(
      title: serializer.fromJson<String>(json['title']),
      summaryPlain: serializer.fromJson<String>(json['summaryPlain']),
      contentPlain: serializer.fromJson<String>(json['contentPlain']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'summaryPlain': serializer.toJson<String>(summaryPlain),
      'contentPlain': serializer.toJson<String>(contentPlain),
    };
  }

  i1.ArticleFt copyWith({
    String? title,
    String? summaryPlain,
    String? contentPlain,
  }) => i1.ArticleFt(
    title: title ?? this.title,
    summaryPlain: summaryPlain ?? this.summaryPlain,
    contentPlain: contentPlain ?? this.contentPlain,
  );
  ArticleFt copyWithCompanion(i1.ArticleFtsCompanion data) {
    return ArticleFt(
      title: data.title.present ? data.title.value : this.title,
      summaryPlain: data.summaryPlain.present
          ? data.summaryPlain.value
          : this.summaryPlain,
      contentPlain: data.contentPlain.present
          ? data.contentPlain.value
          : this.contentPlain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleFt(')
          ..write('title: $title, ')
          ..write('summaryPlain: $summaryPlain, ')
          ..write('contentPlain: $contentPlain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, summaryPlain, contentPlain);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.ArticleFt &&
          other.title == this.title &&
          other.summaryPlain == this.summaryPlain &&
          other.contentPlain == this.contentPlain);
}

class ArticleFtsCompanion extends i0.UpdateCompanion<i1.ArticleFt> {
  final i0.Value<String> title;
  final i0.Value<String> summaryPlain;
  final i0.Value<String> contentPlain;
  final i0.Value<int> rowid;
  const ArticleFtsCompanion({
    this.title = const i0.Value.absent(),
    this.summaryPlain = const i0.Value.absent(),
    this.contentPlain = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  ArticleFtsCompanion.insert({
    required String title,
    required String summaryPlain,
    required String contentPlain,
    this.rowid = const i0.Value.absent(),
  }) : title = i0.Value(title),
       summaryPlain = i0.Value(summaryPlain),
       contentPlain = i0.Value(contentPlain);
  static i0.Insertable<i1.ArticleFt> custom({
    i0.Expression<String>? title,
    i0.Expression<String>? summaryPlain,
    i0.Expression<String>? contentPlain,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (title != null) 'title': title,
      if (summaryPlain != null) 'summaryPlain': summaryPlain,
      if (contentPlain != null) 'contentPlain': contentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.ArticleFtsCompanion copyWith({
    i0.Value<String>? title,
    i0.Value<String>? summaryPlain,
    i0.Value<String>? contentPlain,
    i0.Value<int>? rowid,
  }) {
    return i1.ArticleFtsCompanion(
      title: title ?? this.title,
      summaryPlain: summaryPlain ?? this.summaryPlain,
      contentPlain: contentPlain ?? this.contentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (summaryPlain.present) {
      map['summaryPlain'] = i0.Variable<String>(summaryPlain.value);
    }
    if (contentPlain.present) {
      map['contentPlain'] = i0.Variable<String>(contentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleFtsCompanion(')
          ..write('title: $title, ')
          ..write('summaryPlain: $summaryPlain, ')
          ..write('contentPlain: $contentPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Trigger get articleAfterInsert => i0.Trigger(
  'CREATE TRIGGER article_after_insert AFTER INSERT ON article BEGIN INSERT INTO article_fts ("rowid", title, summaryPlain, contentPlain) VALUES (new."rowid", new.title, new.summaryPlain, new.contentPlain);END',
  'article_after_insert',
);
i0.Trigger get articleAfterDelete => i0.Trigger(
  'CREATE TRIGGER article_after_delete AFTER DELETE ON article BEGIN INSERT INTO article_fts (article_fts, "rowid", title, summaryPlain, contentPlain) VALUES (\'delete\', old."rowid", old.title, old.summaryPlain, old.contentPlain);END',
  'article_after_delete',
);
i0.Trigger get articleAfterUpdate => i0.Trigger(
  'CREATE TRIGGER article_after_update AFTER UPDATE OF title, summaryPlain, contentPlain ON article WHEN OLD.title IS NOT NEW.title OR OLD.summaryPlain IS NOT NEW.summaryPlain OR OLD.contentPlain IS NOT NEW.contentPlain BEGIN INSERT INTO article_fts (article_fts, "rowid", title, summaryPlain, contentPlain) VALUES (\'delete\', old."rowid", old.title, old.summaryPlain, old.contentPlain);INSERT INTO article_fts ("rowid", title, summaryPlain, contentPlain) VALUES (new."rowid", new.title, new.summaryPlain, new.contentPlain);END',
  'article_after_update',
);

class DefinitionsDrift extends i11.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO article_fts (article_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {articleFts},
    );
  }

  i0.Selectable<i12.FeedArticleQueryResult> queryArticlesBasic({
    required String query,
    String? feedId,
    required int limit,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 1.0 AS title_weight) SELECT a.*, f.icon,(bm25(article_fts, weights.title_weight))AS weighted_rank FROM article_fts AS fts INNER JOIN article AS a ON a."rowid" = fts."rowid" INNER JOIN feed AS f ON f.url = a.feed_id CROSS JOIN weights WHERE fts.title LIKE ?1 AND(?2 IS NULL OR a.feed_id = ?2)ORDER BY weighted_rank ASC, a.created DESC NULLS LAST LIMIT ?3',
      variables: [
        i0.Variable<String>(query),
        i0.Variable<String>(feedId),
        i0.Variable<int>(limit),
      ],
      readsFrom: {feed, articleFts, article},
    ).map(
      (i0.QueryRow row) => i12.FeedArticleQueryResult(
        id: row.read<String>('id'),
        feedId: i1.Article.$converterfeedId.fromSql(
          row.read<String>('feed_id'),
        ),
        fetched: row.read<DateTime>('fetched'),
        weightedRank: row.read<double>('weighted_rank'),
        created: row.readNullable<DateTime>('created'),
        updated: row.readNullable<DateTime>('updated'),
        lastRead: row.readNullable<DateTime>('last_read'),
        title: row.readNullable<String>('title'),
        authors: i0.NullAwareTypeConverter.wrapFromSql(
          i1.Article.$converterauthors,
          row.readNullable<String>('authors'),
        ),
        tags: i0.NullAwareTypeConverter.wrapFromSql(
          i1.Article.$convertertags,
          row.readNullable<String>('tags'),
        ),
        links: i0.NullAwareTypeConverter.wrapFromSql(
          i1.Article.$converterlinks,
          row.readNullable<String>('links'),
        ),
        summaryHtml: row.readNullable<String>('summaryHtml'),
        summaryMarkdown: row.readNullable<String>('summaryMarkdown'),
        summaryPlain: row.readNullable<String>('summaryPlain'),
        contentHtml: row.readNullable<String>('contentHtml'),
        contentMarkdown: row.readNullable<String>('contentMarkdown'),
        contentPlain: row.readNullable<String>('contentPlain'),
        icon: i1.Feed.$convertericon.fromSql(row.readNullable<String>('icon')),
      ),
    );
  }

  i0.Selectable<i12.FeedArticleQueryResult> queryArticlesFullContent({
    required String beforeMatch,
    required String afterMatch,
    required String ellipsis,
    required int snippetLength,
    required String query,
    String? feedId,
    required int limit,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 3.0 AS summary_weight, 1.0 AS content_weight) SELECT a.*, f.icon, highlight(article_fts, 0, ?1, ?2) AS title_highlight, snippet(article_fts, 1, ?1, ?2, ?3, ?4) AS summary_snippet, snippet(article_fts, 2, ?1, ?2, ?3, ?4) AS content_snippet,(bm25(article_fts, weights.title_weight, weights.summary_weight, weights.content_weight))AS weighted_rank FROM article_fts(?5)AS fts INNER JOIN article AS a ON a."rowid" = fts."rowid" INNER JOIN feed AS f ON f.url = a.feed_id CROSS JOIN weights WHERE ?6 IS NULL OR a.feed_id = ?6 ORDER BY weighted_rank ASC, a.created DESC NULLS LAST LIMIT ?7',
      variables: [
        i0.Variable<String>(beforeMatch),
        i0.Variable<String>(afterMatch),
        i0.Variable<String>(ellipsis),
        i0.Variable<int>(snippetLength),
        i0.Variable<String>(query),
        i0.Variable<String>(feedId),
        i0.Variable<int>(limit),
      ],
      readsFrom: {feed, articleFts, article},
    ).map(
      (i0.QueryRow row) => i12.FeedArticleQueryResult(
        id: row.read<String>('id'),
        feedId: i1.Article.$converterfeedId.fromSql(
          row.read<String>('feed_id'),
        ),
        fetched: row.read<DateTime>('fetched'),
        weightedRank: row.read<double>('weighted_rank'),
        created: row.readNullable<DateTime>('created'),
        updated: row.readNullable<DateTime>('updated'),
        lastRead: row.readNullable<DateTime>('last_read'),
        title: row.readNullable<String>('title'),
        authors: i0.NullAwareTypeConverter.wrapFromSql(
          i1.Article.$converterauthors,
          row.readNullable<String>('authors'),
        ),
        tags: i0.NullAwareTypeConverter.wrapFromSql(
          i1.Article.$convertertags,
          row.readNullable<String>('tags'),
        ),
        links: i0.NullAwareTypeConverter.wrapFromSql(
          i1.Article.$converterlinks,
          row.readNullable<String>('links'),
        ),
        summaryHtml: row.readNullable<String>('summaryHtml'),
        summaryMarkdown: row.readNullable<String>('summaryMarkdown'),
        summaryPlain: row.readNullable<String>('summaryPlain'),
        contentHtml: row.readNullable<String>('contentHtml'),
        contentMarkdown: row.readNullable<String>('contentMarkdown'),
        contentPlain: row.readNullable<String>('contentPlain'),
        icon: i1.Feed.$convertericon.fromSql(row.readNullable<String>('icon')),
        titleHighlight: row.readNullable<String>('title_highlight'),
        summarySnippet: row.readNullable<String>('summary_snippet'),
        contentSnippet: row.readNullable<String>('content_snippet'),
      ),
    );
  }

  i1.ArticleFts get articleFts => i11.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.ArticleFts>('article_fts');
  i1.Article get article => i11.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.Article>('article');
  i1.Feed get feed =>
      i11.ReadDatabaseContainer(attachedDatabase).resultSet<i1.Feed>('feed');
}
