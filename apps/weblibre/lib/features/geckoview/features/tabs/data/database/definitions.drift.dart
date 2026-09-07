// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart'
    as i1;
import 'dart:ui' as i2;
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart'
    as i3;
import 'package:weblibre/data/database/converters/color.dart' as i4;
import 'package:weblibre/features/geckoview/features/tabs/data/database/converters/container_metadata_converter.dart'
    as i5;
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart'
    as i6;
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart'
    as i7;
import 'package:weblibre/data/database/converters/uri.dart' as i8;
import 'package:drift/internal/modular.dart' as i9;
import 'package:weblibre/features/geckoview/features/tabs/data/models/history_query_result.dart'
    as i10;
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart'
    as i11;
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart'
    as i12;

typedef $ContainerCreateCompanionBuilder =
    i3.ContainerCompanion Function({
      required String id,
      i0.Value<String?> name,
      required i2.Color color,
      required String orderKey,
      i0.Value<bool> isPinned,
      i0.Value<i1.ContainerMetadata?> metadata,
      i0.Value<int> rowid,
    });
typedef $ContainerUpdateCompanionBuilder =
    i3.ContainerCompanion Function({
      i0.Value<String> id,
      i0.Value<String?> name,
      i0.Value<i2.Color> color,
      i0.Value<String> orderKey,
      i0.Value<bool> isPinned,
      i0.Value<i1.ContainerMetadata?> metadata,
      i0.Value<int> rowid,
    });

final class $ContainerReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.Container,
          i1.ContainerData
        > {
  $ContainerReferences(super.$_db, super.$_table, super.$_typedResult);

  static i0.MultiTypedResultKey<i3.Tab, List<i3.TabData>> _tabRefsTable(
    i0.GeneratedDatabase db,
  ) => i0.MultiTypedResultKey.fromTable(
    i9.ReadDatabaseContainer(db).resultSet<i3.Tab>('tab'),
    aliasName: 'container__id__tab__container_id',
  );

  i3.$TabProcessedTableManager get tabRefs {
    final manager = i3
        .$TabTableManager(
          $_db,
          i9.ReadDatabaseContainer($_db).resultSet<i3.Tab>('tab'),
        )
        .filter((f) => f.containerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabRefsTable($_db));
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static i0.MultiTypedResultKey<i3.VisitContainer, List<i3.VisitContainerData>>
  _visitContainerRefsTable(i0.GeneratedDatabase db) =>
      i0.MultiTypedResultKey.fromTable(
        i9.ReadDatabaseContainer(
          db,
        ).resultSet<i3.VisitContainer>('visit_container'),
        aliasName: 'container__id__visit_container__container_id',
      );

  i3.$VisitContainerProcessedTableManager get visitContainerRefs {
    final manager = i3
        .$VisitContainerTableManager(
          $_db,
          i9.ReadDatabaseContainer(
            $_db,
          ).resultSet<i3.VisitContainer>('visit_container'),
        )
        .filter((f) => f.containerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitContainerRefsTable($_db));
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ContainerFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.Container> {
  $ContainerFilterComposer({
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

  i0.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i2.Color, i2.Color, int> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    i1.ContainerMetadata?,
    i1.ContainerMetadata,
    String
  >
  get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.Expression<bool> tabRefs(
    i0.Expression<bool> Function(i3.$TabFilterComposer f) f,
  ) {
    final i3.$TabFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabFilterComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  i0.Expression<bool> visitContainerRefs(
    i0.Expression<bool> Function(i3.$VisitContainerFilterComposer f) f,
  ) {
    final i3.$VisitContainerFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.VisitContainer>('visit_container'),
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$VisitContainerFilterComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.VisitContainer>('visit_container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ContainerOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.Container> {
  $ContainerOrderingComposer({
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

  i0.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $ContainerAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.Container> {
  $ContainerAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i2.Color, int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  i0.GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  i0.GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i1.ContainerMetadata?, String>
  get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  i0.Expression<T> tabRefs<T extends Object>(
    i0.Expression<T> Function(i3.$TabAnnotationComposer a) f,
  ) {
    final i3.$TabAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabAnnotationComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  i0.Expression<T> visitContainerRefs<T extends Object>(
    i0.Expression<T> Function(i3.$VisitContainerAnnotationComposer a) f,
  ) {
    final i3.$VisitContainerAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.VisitContainer>('visit_container'),
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$VisitContainerAnnotationComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.VisitContainer>('visit_container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ContainerTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.Container,
          i1.ContainerData,
          i3.$ContainerFilterComposer,
          i3.$ContainerOrderingComposer,
          i3.$ContainerAnnotationComposer,
          $ContainerCreateCompanionBuilder,
          $ContainerUpdateCompanionBuilder,
          (i1.ContainerData, i3.$ContainerReferences),
          i1.ContainerData,
          i0.PrefetchHooks Function({bool tabRefs, bool visitContainerRefs})
        > {
  $ContainerTableManager(i0.GeneratedDatabase db, i3.Container table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$ContainerFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$ContainerOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$ContainerAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<String?> name = const i0.Value.absent(),
                i0.Value<i2.Color> color = const i0.Value.absent(),
                i0.Value<String> orderKey = const i0.Value.absent(),
                i0.Value<bool> isPinned = const i0.Value.absent(),
                i0.Value<i1.ContainerMetadata?> metadata =
                    const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.ContainerCompanion(
                id: id,
                name: name,
                color: color,
                orderKey: orderKey,
                isPinned: isPinned,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                i0.Value<String?> name = const i0.Value.absent(),
                required i2.Color color,
                required String orderKey,
                i0.Value<bool> isPinned = const i0.Value.absent(),
                i0.Value<i1.ContainerMetadata?> metadata =
                    const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.ContainerCompanion.insert(
                id: id,
                name: name,
                color: color,
                orderKey: orderKey,
                isPinned: isPinned,
                metadata: metadata,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), i3.$ContainerReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({tabRefs = false, visitContainerRefs = false}) {
                return i0.PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tabRefs)
                      i9.ReadDatabaseContainer(db).resultSet<i3.Tab>('tab'),
                    if (visitContainerRefs)
                      i9.ReadDatabaseContainer(
                        db,
                      ).resultSet<i3.VisitContainer>('visit_container'),
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tabRefs)
                        await i0.$_getPrefetchedData<
                          i1.ContainerData,
                          i3.Container,
                          i3.TabData
                        >(
                          currentTable: table,
                          referencedTable: i3.$ContainerReferences
                              ._tabRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              i3.$ContainerReferences(db, table, p0).tabRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.containerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (visitContainerRefs)
                        await i0.$_getPrefetchedData<
                          i1.ContainerData,
                          i3.Container,
                          i3.VisitContainerData
                        >(
                          currentTable: table,
                          referencedTable: i3.$ContainerReferences
                              ._visitContainerRefsTable(db),
                          managerFromTypedResult: (p0) => i3
                              .$ContainerReferences(db, table, p0)
                              .visitContainerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.containerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ContainerProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.Container,
      i1.ContainerData,
      i3.$ContainerFilterComposer,
      i3.$ContainerOrderingComposer,
      i3.$ContainerAnnotationComposer,
      $ContainerCreateCompanionBuilder,
      $ContainerUpdateCompanionBuilder,
      (i1.ContainerData, i3.$ContainerReferences),
      i1.ContainerData,
      i0.PrefetchHooks Function({bool tabRefs, bool visitContainerRefs})
    >;
typedef $TabCreateCompanionBuilder =
    i3.TabCompanion Function({
      required String id,
      required i6.TabSource source,
      i0.Value<String?> parentId,
      i0.Value<String?> containerId,
      required String orderKey,
      i0.Value<Uri?> url,
      i0.Value<String?> title,
      i0.Value<i7.TabModeDbValue> tabMode,
      i0.Value<String?> isolationContextId,
      i0.Value<bool> isPinned,
      i0.Value<bool?> isProbablyReaderable,
      i0.Value<String?> extractedContentMarkdown,
      i0.Value<String?> extractedContentPlain,
      i0.Value<String?> fullContentMarkdown,
      i0.Value<String?> fullContentPlain,
      required DateTime timestamp,
      i0.Value<int> rowid,
    });
typedef $TabUpdateCompanionBuilder =
    i3.TabCompanion Function({
      i0.Value<String> id,
      i0.Value<i6.TabSource> source,
      i0.Value<String?> parentId,
      i0.Value<String?> containerId,
      i0.Value<String> orderKey,
      i0.Value<Uri?> url,
      i0.Value<String?> title,
      i0.Value<i7.TabModeDbValue> tabMode,
      i0.Value<String?> isolationContextId,
      i0.Value<bool> isPinned,
      i0.Value<bool?> isProbablyReaderable,
      i0.Value<String?> extractedContentMarkdown,
      i0.Value<String?> extractedContentPlain,
      i0.Value<String?> fullContentMarkdown,
      i0.Value<String?> fullContentPlain,
      i0.Value<DateTime> timestamp,
      i0.Value<int> rowid,
    });

final class $TabReferences
    extends i0.BaseReferences<i0.GeneratedDatabase, i3.Tab, i3.TabData> {
  $TabReferences(super.$_db, super.$_table, super.$_typedResult);

  static i3.Tab _parentIdTable(i0.GeneratedDatabase db) =>
      i9.ReadDatabaseContainer(
        db,
      ).resultSet<i3.Tab>('tab').createAlias('tab__parent_id__tab__id');

  i3.$TabProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = i3
        .$TabTableManager(
          $_db,
          i9.ReadDatabaseContainer($_db).resultSet<i3.Tab>('tab'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static i3.Container _containerIdTable(i0.GeneratedDatabase db) =>
      i9.ReadDatabaseContainer(db)
          .resultSet<i3.Container>('container')
          .createAlias('tab__container_id__container__id');

  i3.$ContainerProcessedTableManager? get containerId {
    final $_column = $_itemColumn<String>('container_id');
    if ($_column == null) return null;
    final manager = i3
        .$ContainerTableManager(
          $_db,
          i9.ReadDatabaseContainer($_db).resultSet<i3.Container>('container'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_containerIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static i0.MultiTypedResultKey<i3.CaptureTab, List<i3.CaptureTabData>>
  _captureTabRefsTable(i0.GeneratedDatabase db) =>
      i0.MultiTypedResultKey.fromTable(
        i9.ReadDatabaseContainer(db).resultSet<i3.CaptureTab>('capture_tab'),
        aliasName: 'tab__id__capture_tab__tab_id',
      );

  i3.$CaptureTabProcessedTableManager get captureTabRefs {
    final manager = i3
        .$CaptureTabTableManager(
          $_db,
          i9.ReadDatabaseContainer(
            $_db,
          ).resultSet<i3.CaptureTab>('capture_tab'),
        )
        .filter((f) => f.tabId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_captureTabRefsTable($_db));
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $TabFilterComposer extends i0.Composer<i0.GeneratedDatabase, i3.Tab> {
  $TabFilterComposer({
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

  i0.ColumnWithTypeConverterFilters<i6.TabSource, i6.TabSource, int>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<Uri?, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i7.TabModeDbValue, i7.TabModeDbValue, int>
  get tabMode => $composableBuilder(
    column: $table.tabMode,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get isolationContextId => $composableBuilder(
    column: $table.isolationContextId,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => i0.ColumnFilters(column),
  );

  i3.$TabFilterComposer get parentId {
    final i3.$TabFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabFilterComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  i3.$ContainerFilterComposer get containerId {
    final i3.$ContainerFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerFilterComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  i0.Expression<bool> captureTabRefs(
    i0.Expression<bool> Function(i3.$CaptureTabFilterComposer f) f,
  ) {
    final i3.$CaptureTabFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.CaptureTab>('capture_tab'),
      getReferencedColumn: (t) => t.tabId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$CaptureTabFilterComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.CaptureTab>('capture_tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TabOrderingComposer extends i0.Composer<i0.GeneratedDatabase, i3.Tab> {
  $TabOrderingComposer({
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

  i0.ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get tabMode => $composableBuilder(
    column: $table.tabMode,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get isolationContextId => $composableBuilder(
    column: $table.isolationContextId,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i3.$TabOrderingComposer get parentId {
    final i3.$TabOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabOrderingComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  i3.$ContainerOrderingComposer get containerId {
    final i3.$ContainerOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerOrderingComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TabAnnotationComposer extends i0.Composer<i0.GeneratedDatabase, i3.Tab> {
  $TabAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i6.TabSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  i0.GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri?, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i7.TabModeDbValue, int> get tabMode =>
      $composableBuilder(column: $table.tabMode, builder: (column) => column);

  i0.GeneratedColumn<String> get isolationContextId => $composableBuilder(
    column: $table.isolationContextId,
    builder: (column) => column,
  );

  i0.GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  i0.GeneratedColumn<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  i0.GeneratedColumn<int> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  i3.$TabAnnotationComposer get parentId {
    final i3.$TabAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabAnnotationComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  i3.$ContainerAnnotationComposer get containerId {
    final i3.$ContainerAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerAnnotationComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  i0.Expression<T> captureTabRefs<T extends Object>(
    i0.Expression<T> Function(i3.$CaptureTabAnnotationComposer a) f,
  ) {
    final i3.$CaptureTabAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.CaptureTab>('capture_tab'),
      getReferencedColumn: (t) => t.tabId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$CaptureTabAnnotationComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.CaptureTab>('capture_tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TabTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.Tab,
          i3.TabData,
          i3.$TabFilterComposer,
          i3.$TabOrderingComposer,
          i3.$TabAnnotationComposer,
          $TabCreateCompanionBuilder,
          $TabUpdateCompanionBuilder,
          (i3.TabData, i3.$TabReferences),
          i3.TabData,
          i0.PrefetchHooks Function({
            bool parentId,
            bool containerId,
            bool captureTabRefs,
          })
        > {
  $TabTableManager(i0.GeneratedDatabase db, i3.Tab table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$TabFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$TabOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$TabAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<i6.TabSource> source = const i0.Value.absent(),
                i0.Value<String?> parentId = const i0.Value.absent(),
                i0.Value<String?> containerId = const i0.Value.absent(),
                i0.Value<String> orderKey = const i0.Value.absent(),
                i0.Value<Uri?> url = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<i7.TabModeDbValue> tabMode = const i0.Value.absent(),
                i0.Value<String?> isolationContextId = const i0.Value.absent(),
                i0.Value<bool> isPinned = const i0.Value.absent(),
                i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
                i0.Value<String?> extractedContentMarkdown =
                    const i0.Value.absent(),
                i0.Value<String?> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
                i0.Value<String?> fullContentPlain = const i0.Value.absent(),
                i0.Value<DateTime> timestamp = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabCompanion(
                id: id,
                source: source,
                parentId: parentId,
                containerId: containerId,
                orderKey: orderKey,
                url: url,
                title: title,
                tabMode: tabMode,
                isolationContextId: isolationContextId,
                isPinned: isPinned,
                isProbablyReaderable: isProbablyReaderable,
                extractedContentMarkdown: extractedContentMarkdown,
                extractedContentPlain: extractedContentPlain,
                fullContentMarkdown: fullContentMarkdown,
                fullContentPlain: fullContentPlain,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required i6.TabSource source,
                i0.Value<String?> parentId = const i0.Value.absent(),
                i0.Value<String?> containerId = const i0.Value.absent(),
                required String orderKey,
                i0.Value<Uri?> url = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<i7.TabModeDbValue> tabMode = const i0.Value.absent(),
                i0.Value<String?> isolationContextId = const i0.Value.absent(),
                i0.Value<bool> isPinned = const i0.Value.absent(),
                i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
                i0.Value<String?> extractedContentMarkdown =
                    const i0.Value.absent(),
                i0.Value<String?> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
                i0.Value<String?> fullContentPlain = const i0.Value.absent(),
                required DateTime timestamp,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabCompanion.insert(
                id: id,
                source: source,
                parentId: parentId,
                containerId: containerId,
                orderKey: orderKey,
                url: url,
                title: title,
                tabMode: tabMode,
                isolationContextId: isolationContextId,
                isPinned: isPinned,
                isProbablyReaderable: isProbablyReaderable,
                extractedContentMarkdown: extractedContentMarkdown,
                extractedContentPlain: extractedContentPlain,
                fullContentMarkdown: fullContentMarkdown,
                fullContentPlain: fullContentPlain,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i3.$TabReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                containerId = false,
                captureTabRefs = false,
              }) {
                return i0.PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (captureTabRefs)
                      i9.ReadDatabaseContainer(
                        db,
                      ).resultSet<i3.CaptureTab>('capture_tab'),
                  ],
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
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable: i3.$TabReferences
                                        ._parentIdTable(db),
                                    referencedColumn: i3.$TabReferences
                                        ._parentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (containerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.containerId,
                                    referencedTable: i3.$TabReferences
                                        ._containerIdTable(db),
                                    referencedColumn: i3.$TabReferences
                                        ._containerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (captureTabRefs)
                        await i0.$_getPrefetchedData<
                          i3.TabData,
                          i3.Tab,
                          i3.CaptureTabData
                        >(
                          currentTable: table,
                          referencedTable: i3.$TabReferences
                              ._captureTabRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              i3.$TabReferences(db, table, p0).captureTabRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tabId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $TabProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.Tab,
      i3.TabData,
      i3.$TabFilterComposer,
      i3.$TabOrderingComposer,
      i3.$TabAnnotationComposer,
      $TabCreateCompanionBuilder,
      $TabUpdateCompanionBuilder,
      (i3.TabData, i3.$TabReferences),
      i3.TabData,
      i0.PrefetchHooks Function({
        bool parentId,
        bool containerId,
        bool captureTabRefs,
      })
    >;
typedef $ClosedTabTombstoneCreateCompanionBuilder =
    i3.ClosedTabTombstoneCompanion Function({
      required String tabId,
      required DateTime closedAt,
      i0.Value<int> rowid,
    });
typedef $ClosedTabTombstoneUpdateCompanionBuilder =
    i3.ClosedTabTombstoneCompanion Function({
      i0.Value<String> tabId,
      i0.Value<DateTime> closedAt,
      i0.Value<int> rowid,
    });

class $ClosedTabTombstoneFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.ClosedTabTombstone> {
  $ClosedTabTombstoneFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get tabId => $composableBuilder(
    column: $table.tabId,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $ClosedTabTombstoneOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.ClosedTabTombstone> {
  $ClosedTabTombstoneOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get tabId => $composableBuilder(
    column: $table.tabId,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $ClosedTabTombstoneAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.ClosedTabTombstone> {
  $ClosedTabTombstoneAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get tabId =>
      $composableBuilder(column: $table.tabId, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $ClosedTabTombstoneTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.ClosedTabTombstone,
          i3.ClosedTabTombstoneData,
          i3.$ClosedTabTombstoneFilterComposer,
          i3.$ClosedTabTombstoneOrderingComposer,
          i3.$ClosedTabTombstoneAnnotationComposer,
          $ClosedTabTombstoneCreateCompanionBuilder,
          $ClosedTabTombstoneUpdateCompanionBuilder,
          (
            i3.ClosedTabTombstoneData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i3.ClosedTabTombstone,
              i3.ClosedTabTombstoneData
            >,
          ),
          i3.ClosedTabTombstoneData,
          i0.PrefetchHooks Function()
        > {
  $ClosedTabTombstoneTableManager(
    i0.GeneratedDatabase db,
    i3.ClosedTabTombstone table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$ClosedTabTombstoneFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$ClosedTabTombstoneOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$ClosedTabTombstoneAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> tabId = const i0.Value.absent(),
                i0.Value<DateTime> closedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.ClosedTabTombstoneCompanion(
                tabId: tabId,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tabId,
                required DateTime closedAt,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.ClosedTabTombstoneCompanion.insert(
                tabId: tabId,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ClosedTabTombstoneProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.ClosedTabTombstone,
      i3.ClosedTabTombstoneData,
      i3.$ClosedTabTombstoneFilterComposer,
      i3.$ClosedTabTombstoneOrderingComposer,
      i3.$ClosedTabTombstoneAnnotationComposer,
      $ClosedTabTombstoneCreateCompanionBuilder,
      $ClosedTabTombstoneUpdateCompanionBuilder,
      (
        i3.ClosedTabTombstoneData,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.ClosedTabTombstone,
          i3.ClosedTabTombstoneData
        >,
      ),
      i3.ClosedTabTombstoneData,
      i0.PrefetchHooks Function()
    >;
typedef $CaptureTabCreateCompanionBuilder =
    i3.CaptureTabCompanion Function({
      required String tabId,
      required String captureId,
      required String sourceUrl,
      i0.Value<String> status,
      required DateTime createdAt,
      i0.Value<int> rowid,
    });
typedef $CaptureTabUpdateCompanionBuilder =
    i3.CaptureTabCompanion Function({
      i0.Value<String> tabId,
      i0.Value<String> captureId,
      i0.Value<String> sourceUrl,
      i0.Value<String> status,
      i0.Value<DateTime> createdAt,
      i0.Value<int> rowid,
    });

final class $CaptureTabReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.CaptureTab,
          i3.CaptureTabData
        > {
  $CaptureTabReferences(super.$_db, super.$_table, super.$_typedResult);

  static i3.Tab _tabIdTable(i0.GeneratedDatabase db) =>
      i9.ReadDatabaseContainer(
        db,
      ).resultSet<i3.Tab>('tab').createAlias('capture_tab__tab_id__tab__id');

  i3.$TabProcessedTableManager get tabId {
    final $_column = $_itemColumn<String>('tab_id')!;

    final manager = i3
        .$TabTableManager(
          $_db,
          i9.ReadDatabaseContainer($_db).resultSet<i3.Tab>('tab'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tabIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CaptureTabFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.CaptureTab> {
  $CaptureTabFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get captureId => $composableBuilder(
    column: $table.captureId,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i3.$TabFilterComposer get tabId {
    final i3.$TabFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tabId,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabFilterComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CaptureTabOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.CaptureTab> {
  $CaptureTabOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get captureId => $composableBuilder(
    column: $table.captureId,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i3.$TabOrderingComposer get tabId {
    final i3.$TabOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tabId,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabOrderingComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CaptureTabAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.CaptureTab> {
  $CaptureTabAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get captureId =>
      $composableBuilder(column: $table.captureId, builder: (column) => column);

  i0.GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  i0.GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  i3.$TabAnnotationComposer get tabId {
    final i3.$TabAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tabId,
      referencedTable: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabAnnotationComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CaptureTabTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.CaptureTab,
          i3.CaptureTabData,
          i3.$CaptureTabFilterComposer,
          i3.$CaptureTabOrderingComposer,
          i3.$CaptureTabAnnotationComposer,
          $CaptureTabCreateCompanionBuilder,
          $CaptureTabUpdateCompanionBuilder,
          (i3.CaptureTabData, i3.$CaptureTabReferences),
          i3.CaptureTabData,
          i0.PrefetchHooks Function({bool tabId})
        > {
  $CaptureTabTableManager(i0.GeneratedDatabase db, i3.CaptureTab table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$CaptureTabFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$CaptureTabOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$CaptureTabAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> tabId = const i0.Value.absent(),
                i0.Value<String> captureId = const i0.Value.absent(),
                i0.Value<String> sourceUrl = const i0.Value.absent(),
                i0.Value<String> status = const i0.Value.absent(),
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.CaptureTabCompanion(
                tabId: tabId,
                captureId: captureId,
                sourceUrl: sourceUrl,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tabId,
                required String captureId,
                required String sourceUrl,
                i0.Value<String> status = const i0.Value.absent(),
                required DateTime createdAt,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.CaptureTabCompanion.insert(
                tabId: tabId,
                captureId: captureId,
                sourceUrl: sourceUrl,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i3.$CaptureTabReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tabId = false}) {
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
                    if (tabId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tabId,
                                referencedTable: i3.$CaptureTabReferences
                                    ._tabIdTable(db),
                                referencedColumn: i3.$CaptureTabReferences
                                    ._tabIdTable(db)
                                    .id,
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

typedef $CaptureTabProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.CaptureTab,
      i3.CaptureTabData,
      i3.$CaptureTabFilterComposer,
      i3.$CaptureTabOrderingComposer,
      i3.$CaptureTabAnnotationComposer,
      $CaptureTabCreateCompanionBuilder,
      $CaptureTabUpdateCompanionBuilder,
      (i3.CaptureTabData, i3.$CaptureTabReferences),
      i3.CaptureTabData,
      i0.PrefetchHooks Function({bool tabId})
    >;
typedef $TabFtsCreateCompanionBuilder =
    i3.TabFtsCompanion Function({
      required String title,
      required String url,
      required String extractedContentPlain,
      required String fullContentPlain,
      i0.Value<int> rowid,
    });
typedef $TabFtsUpdateCompanionBuilder =
    i3.TabFtsCompanion Function({
      i0.Value<String> title,
      i0.Value<String> url,
      i0.Value<String> extractedContentPlain,
      i0.Value<String> fullContentPlain,
      i0.Value<int> rowid,
    });

class $TabFtsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.TabFts> {
  $TabFtsFilterComposer({
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

  i0.ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $TabFtsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.TabFts> {
  $TabFtsOrderingComposer({
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

  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $TabFtsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.TabFts> {
  $TabFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );
}

class $TabFtsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.TabFts,
          i3.TabFt,
          i3.$TabFtsFilterComposer,
          i3.$TabFtsOrderingComposer,
          i3.$TabFtsAnnotationComposer,
          $TabFtsCreateCompanionBuilder,
          $TabFtsUpdateCompanionBuilder,
          (
            i3.TabFt,
            i0.BaseReferences<i0.GeneratedDatabase, i3.TabFts, i3.TabFt>,
          ),
          i3.TabFt,
          i0.PrefetchHooks Function()
        > {
  $TabFtsTableManager(i0.GeneratedDatabase db, i3.TabFts table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$TabFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$TabFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$TabFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> title = const i0.Value.absent(),
                i0.Value<String> url = const i0.Value.absent(),
                i0.Value<String> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String> fullContentPlain = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabFtsCompanion(
                title: title,
                url: url,
                extractedContentPlain: extractedContentPlain,
                fullContentPlain: fullContentPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String url,
                required String extractedContentPlain,
                required String fullContentPlain,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabFtsCompanion.insert(
                title: title,
                url: url,
                extractedContentPlain: extractedContentPlain,
                fullContentPlain: fullContentPlain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TabFtsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.TabFts,
      i3.TabFt,
      i3.$TabFtsFilterComposer,
      i3.$TabFtsOrderingComposer,
      i3.$TabFtsAnnotationComposer,
      $TabFtsCreateCompanionBuilder,
      $TabFtsUpdateCompanionBuilder,
      (i3.TabFt, i0.BaseReferences<i0.GeneratedDatabase, i3.TabFts, i3.TabFt>),
      i3.TabFt,
      i0.PrefetchHooks Function()
    >;
typedef $LocalIndexSettingCreateCompanionBuilder =
    i3.LocalIndexSettingCompanion Function({
      required String key,
      required int value,
      i0.Value<int> rowid,
    });
typedef $LocalIndexSettingUpdateCompanionBuilder =
    i3.LocalIndexSettingCompanion Function({
      i0.Value<String> key,
      i0.Value<int> value,
      i0.Value<int> rowid,
    });

class $LocalIndexSettingFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.LocalIndexSetting> {
  $LocalIndexSettingFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $LocalIndexSettingOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.LocalIndexSetting> {
  $LocalIndexSettingOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $LocalIndexSettingAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.LocalIndexSetting> {
  $LocalIndexSettingAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  i0.GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $LocalIndexSettingTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.LocalIndexSetting,
          i3.LocalIndexSettingData,
          i3.$LocalIndexSettingFilterComposer,
          i3.$LocalIndexSettingOrderingComposer,
          i3.$LocalIndexSettingAnnotationComposer,
          $LocalIndexSettingCreateCompanionBuilder,
          $LocalIndexSettingUpdateCompanionBuilder,
          (
            i3.LocalIndexSettingData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i3.LocalIndexSetting,
              i3.LocalIndexSettingData
            >,
          ),
          i3.LocalIndexSettingData,
          i0.PrefetchHooks Function()
        > {
  $LocalIndexSettingTableManager(
    i0.GeneratedDatabase db,
    i3.LocalIndexSetting table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$LocalIndexSettingFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$LocalIndexSettingOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$LocalIndexSettingAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> key = const i0.Value.absent(),
                i0.Value<int> value = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.LocalIndexSettingCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required int value,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.LocalIndexSettingCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $LocalIndexSettingProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.LocalIndexSetting,
      i3.LocalIndexSettingData,
      i3.$LocalIndexSettingFilterComposer,
      i3.$LocalIndexSettingOrderingComposer,
      i3.$LocalIndexSettingAnnotationComposer,
      $LocalIndexSettingCreateCompanionBuilder,
      $LocalIndexSettingUpdateCompanionBuilder,
      (
        i3.LocalIndexSettingData,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.LocalIndexSetting,
          i3.LocalIndexSettingData
        >,
      ),
      i3.LocalIndexSettingData,
      i0.PrefetchHooks Function()
    >;
typedef $HistoryCreateCompanionBuilder =
    i3.HistoryCompanion Function({
      required String urlCanonical,
      required String urlHost,
      i0.Value<String?> urlPath,
      i0.Value<String?> title,
      i0.Value<bool?> isProbablyReaderable,
      i0.Value<String?> extractedContentMarkdown,
      i0.Value<String?> extractedContentPlain,
      i0.Value<String?> fullContentMarkdown,
      i0.Value<String?> fullContentPlain,
      i0.Value<int?> contentHash,
      required DateTime observedAt,
      i0.Value<int> observedCount,
      i0.Value<int> rowid,
    });
typedef $HistoryUpdateCompanionBuilder =
    i3.HistoryCompanion Function({
      i0.Value<String> urlCanonical,
      i0.Value<String> urlHost,
      i0.Value<String?> urlPath,
      i0.Value<String?> title,
      i0.Value<bool?> isProbablyReaderable,
      i0.Value<String?> extractedContentMarkdown,
      i0.Value<String?> extractedContentPlain,
      i0.Value<String?> fullContentMarkdown,
      i0.Value<String?> fullContentPlain,
      i0.Value<int?> contentHash,
      i0.Value<DateTime> observedAt,
      i0.Value<int> observedCount,
      i0.Value<int> rowid,
    });

class $HistoryFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.History> {
  $HistoryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get urlCanonical => $composableBuilder(
    column: $table.urlCanonical,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get urlHost => $composableBuilder(
    column: $table.urlHost,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get urlPath => $composableBuilder(
    column: $table.urlPath,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get observedCount => $composableBuilder(
    column: $table.observedCount,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $HistoryOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.History> {
  $HistoryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get urlCanonical => $composableBuilder(
    column: $table.urlCanonical,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get urlHost => $composableBuilder(
    column: $table.urlHost,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get urlPath => $composableBuilder(
    column: $table.urlPath,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get observedCount => $composableBuilder(
    column: $table.observedCount,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $HistoryAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.History> {
  $HistoryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get urlCanonical => $composableBuilder(
    column: $table.urlCanonical,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get urlHost =>
      $composableBuilder(column: $table.urlHost, builder: (column) => column);

  i0.GeneratedColumn<String> get urlPath =>
      $composableBuilder(column: $table.urlPath, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<int> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  i0.GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );

  i0.GeneratedColumn<int> get observedCount => $composableBuilder(
    column: $table.observedCount,
    builder: (column) => column,
  );
}

class $HistoryTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.History,
          i3.HistoryData,
          i3.$HistoryFilterComposer,
          i3.$HistoryOrderingComposer,
          i3.$HistoryAnnotationComposer,
          $HistoryCreateCompanionBuilder,
          $HistoryUpdateCompanionBuilder,
          (
            i3.HistoryData,
            i0.BaseReferences<i0.GeneratedDatabase, i3.History, i3.HistoryData>,
          ),
          i3.HistoryData,
          i0.PrefetchHooks Function()
        > {
  $HistoryTableManager(i0.GeneratedDatabase db, i3.History table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$HistoryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$HistoryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$HistoryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> urlCanonical = const i0.Value.absent(),
                i0.Value<String> urlHost = const i0.Value.absent(),
                i0.Value<String?> urlPath = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
                i0.Value<String?> extractedContentMarkdown =
                    const i0.Value.absent(),
                i0.Value<String?> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
                i0.Value<String?> fullContentPlain = const i0.Value.absent(),
                i0.Value<int?> contentHash = const i0.Value.absent(),
                i0.Value<DateTime> observedAt = const i0.Value.absent(),
                i0.Value<int> observedCount = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.HistoryCompanion(
                urlCanonical: urlCanonical,
                urlHost: urlHost,
                urlPath: urlPath,
                title: title,
                isProbablyReaderable: isProbablyReaderable,
                extractedContentMarkdown: extractedContentMarkdown,
                extractedContentPlain: extractedContentPlain,
                fullContentMarkdown: fullContentMarkdown,
                fullContentPlain: fullContentPlain,
                contentHash: contentHash,
                observedAt: observedAt,
                observedCount: observedCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String urlCanonical,
                required String urlHost,
                i0.Value<String?> urlPath = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
                i0.Value<String?> extractedContentMarkdown =
                    const i0.Value.absent(),
                i0.Value<String?> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
                i0.Value<String?> fullContentPlain = const i0.Value.absent(),
                i0.Value<int?> contentHash = const i0.Value.absent(),
                required DateTime observedAt,
                i0.Value<int> observedCount = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.HistoryCompanion.insert(
                urlCanonical: urlCanonical,
                urlHost: urlHost,
                urlPath: urlPath,
                title: title,
                isProbablyReaderable: isProbablyReaderable,
                extractedContentMarkdown: extractedContentMarkdown,
                extractedContentPlain: extractedContentPlain,
                fullContentMarkdown: fullContentMarkdown,
                fullContentPlain: fullContentPlain,
                contentHash: contentHash,
                observedAt: observedAt,
                observedCount: observedCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $HistoryProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.History,
      i3.HistoryData,
      i3.$HistoryFilterComposer,
      i3.$HistoryOrderingComposer,
      i3.$HistoryAnnotationComposer,
      $HistoryCreateCompanionBuilder,
      $HistoryUpdateCompanionBuilder,
      (
        i3.HistoryData,
        i0.BaseReferences<i0.GeneratedDatabase, i3.History, i3.HistoryData>,
      ),
      i3.HistoryData,
      i0.PrefetchHooks Function()
    >;
typedef $HistoryFtsCreateCompanionBuilder =
    i3.HistoryFtsCompanion Function({
      required String title,
      required String urlHost,
      required String urlPath,
      required String extractedContentPlain,
      required String fullContentPlain,
      i0.Value<int> rowid,
    });
typedef $HistoryFtsUpdateCompanionBuilder =
    i3.HistoryFtsCompanion Function({
      i0.Value<String> title,
      i0.Value<String> urlHost,
      i0.Value<String> urlPath,
      i0.Value<String> extractedContentPlain,
      i0.Value<String> fullContentPlain,
      i0.Value<int> rowid,
    });

class $HistoryFtsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.HistoryFts> {
  $HistoryFtsFilterComposer({
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

  i0.ColumnFilters<String> get urlHost => $composableBuilder(
    column: $table.urlHost,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get urlPath => $composableBuilder(
    column: $table.urlPath,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $HistoryFtsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.HistoryFts> {
  $HistoryFtsOrderingComposer({
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

  i0.ColumnOrderings<String> get urlHost => $composableBuilder(
    column: $table.urlHost,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get urlPath => $composableBuilder(
    column: $table.urlPath,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $HistoryFtsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.HistoryFts> {
  $HistoryFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get urlHost =>
      $composableBuilder(column: $table.urlHost, builder: (column) => column);

  i0.GeneratedColumn<String> get urlPath =>
      $composableBuilder(column: $table.urlPath, builder: (column) => column);

  i0.GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );
}

class $HistoryFtsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.HistoryFts,
          i3.HistoryFt,
          i3.$HistoryFtsFilterComposer,
          i3.$HistoryFtsOrderingComposer,
          i3.$HistoryFtsAnnotationComposer,
          $HistoryFtsCreateCompanionBuilder,
          $HistoryFtsUpdateCompanionBuilder,
          (
            i3.HistoryFt,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i3.HistoryFts,
              i3.HistoryFt
            >,
          ),
          i3.HistoryFt,
          i0.PrefetchHooks Function()
        > {
  $HistoryFtsTableManager(i0.GeneratedDatabase db, i3.HistoryFts table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$HistoryFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$HistoryFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$HistoryFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> title = const i0.Value.absent(),
                i0.Value<String> urlHost = const i0.Value.absent(),
                i0.Value<String> urlPath = const i0.Value.absent(),
                i0.Value<String> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String> fullContentPlain = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.HistoryFtsCompanion(
                title: title,
                urlHost: urlHost,
                urlPath: urlPath,
                extractedContentPlain: extractedContentPlain,
                fullContentPlain: fullContentPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String urlHost,
                required String urlPath,
                required String extractedContentPlain,
                required String fullContentPlain,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.HistoryFtsCompanion.insert(
                title: title,
                urlHost: urlHost,
                urlPath: urlPath,
                extractedContentPlain: extractedContentPlain,
                fullContentPlain: fullContentPlain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $HistoryFtsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.HistoryFts,
      i3.HistoryFt,
      i3.$HistoryFtsFilterComposer,
      i3.$HistoryFtsOrderingComposer,
      i3.$HistoryFtsAnnotationComposer,
      $HistoryFtsCreateCompanionBuilder,
      $HistoryFtsUpdateCompanionBuilder,
      (
        i3.HistoryFt,
        i0.BaseReferences<i0.GeneratedDatabase, i3.HistoryFts, i3.HistoryFt>,
      ),
      i3.HistoryFt,
      i0.PrefetchHooks Function()
    >;
typedef $VisitContainerCreateCompanionBuilder =
    i3.VisitContainerCompanion Function({
      i0.Value<int> id,
      required String rawUrl,
      required String urlCanonical,
      required int visitTime,
      required String containerId,
    });
typedef $VisitContainerUpdateCompanionBuilder =
    i3.VisitContainerCompanion Function({
      i0.Value<int> id,
      i0.Value<String> rawUrl,
      i0.Value<String> urlCanonical,
      i0.Value<int> visitTime,
      i0.Value<String> containerId,
    });

final class $VisitContainerReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.VisitContainer,
          i3.VisitContainerData
        > {
  $VisitContainerReferences(super.$_db, super.$_table, super.$_typedResult);

  static i3.Container _containerIdTable(i0.GeneratedDatabase db) =>
      i9.ReadDatabaseContainer(db)
          .resultSet<i3.Container>('container')
          .createAlias('visit_container__container_id__container__id');

  i3.$ContainerProcessedTableManager get containerId {
    final $_column = $_itemColumn<String>('container_id')!;

    final manager = i3
        .$ContainerTableManager(
          $_db,
          i9.ReadDatabaseContainer($_db).resultSet<i3.Container>('container'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_containerIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $VisitContainerFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.VisitContainer> {
  $VisitContainerFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get rawUrl => $composableBuilder(
    column: $table.rawUrl,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get urlCanonical => $composableBuilder(
    column: $table.urlCanonical,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get visitTime => $composableBuilder(
    column: $table.visitTime,
    builder: (column) => i0.ColumnFilters(column),
  );

  i3.$ContainerFilterComposer get containerId {
    final i3.$ContainerFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerFilterComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $VisitContainerOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.VisitContainer> {
  $VisitContainerOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get rawUrl => $composableBuilder(
    column: $table.rawUrl,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get urlCanonical => $composableBuilder(
    column: $table.urlCanonical,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get visitTime => $composableBuilder(
    column: $table.visitTime,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i3.$ContainerOrderingComposer get containerId {
    final i3.$ContainerOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerOrderingComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $VisitContainerAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.VisitContainer> {
  $VisitContainerAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get rawUrl =>
      $composableBuilder(column: $table.rawUrl, builder: (column) => column);

  i0.GeneratedColumn<String> get urlCanonical => $composableBuilder(
    column: $table.urlCanonical,
    builder: (column) => column,
  );

  i0.GeneratedColumn<int> get visitTime =>
      $composableBuilder(column: $table.visitTime, builder: (column) => column);

  i3.$ContainerAnnotationComposer get containerId {
    final i3.$ContainerAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i9.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerAnnotationComposer(
            $db: $db,
            $table: i9.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $VisitContainerTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.VisitContainer,
          i3.VisitContainerData,
          i3.$VisitContainerFilterComposer,
          i3.$VisitContainerOrderingComposer,
          i3.$VisitContainerAnnotationComposer,
          $VisitContainerCreateCompanionBuilder,
          $VisitContainerUpdateCompanionBuilder,
          (i3.VisitContainerData, i3.$VisitContainerReferences),
          i3.VisitContainerData,
          i0.PrefetchHooks Function({bool containerId})
        > {
  $VisitContainerTableManager(i0.GeneratedDatabase db, i3.VisitContainer table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$VisitContainerFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$VisitContainerOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$VisitContainerAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                i0.Value<String> rawUrl = const i0.Value.absent(),
                i0.Value<String> urlCanonical = const i0.Value.absent(),
                i0.Value<int> visitTime = const i0.Value.absent(),
                i0.Value<String> containerId = const i0.Value.absent(),
              }) => i3.VisitContainerCompanion(
                id: id,
                rawUrl: rawUrl,
                urlCanonical: urlCanonical,
                visitTime: visitTime,
                containerId: containerId,
              ),
          createCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                required String rawUrl,
                required String urlCanonical,
                required int visitTime,
                required String containerId,
              }) => i3.VisitContainerCompanion.insert(
                id: id,
                rawUrl: rawUrl,
                urlCanonical: urlCanonical,
                visitTime: visitTime,
                containerId: containerId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i3.$VisitContainerReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({containerId = false}) {
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
                    if (containerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.containerId,
                                referencedTable: i3.$VisitContainerReferences
                                    ._containerIdTable(db),
                                referencedColumn: i3.$VisitContainerReferences
                                    ._containerIdTable(db)
                                    .id,
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

typedef $VisitContainerProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.VisitContainer,
      i3.VisitContainerData,
      i3.$VisitContainerFilterComposer,
      i3.$VisitContainerOrderingComposer,
      i3.$VisitContainerAnnotationComposer,
      $VisitContainerCreateCompanionBuilder,
      $VisitContainerUpdateCompanionBuilder,
      (i3.VisitContainerData, i3.$VisitContainerReferences),
      i3.VisitContainerData,
      i0.PrefetchHooks Function({bool containerId})
    >;

class Container extends i0.Table
    with i0.TableInfo<Container, i1.ContainerData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Container(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<String> name = i0.GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumnWithTypeConverter<i2.Color, int> color =
      i0.GeneratedColumn<int>(
        'color',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i2.Color>(i3.Container.$convertercolor);
  late final i0.GeneratedColumn<String> orderKey = i0.GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<bool> isPinned = i0.GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: i0.DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const i0.CustomExpression('0'),
  );
  late final i0.GeneratedColumnWithTypeConverter<i1.ContainerMetadata?, String>
  metadata = i0.GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<i1.ContainerMetadata?>(i3.Container.$convertermetadatan);
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    name,
    color,
    orderKey,
    isPinned,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'container';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i1.ContainerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.ContainerData(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      color: i3.Container.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}color'],
        )!,
      ),
      orderKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      metadata: i3.Container.$convertermetadatan.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}metadata'],
        ),
      ),
    );
  }

  @override
  Container createAlias(String alias) {
    return Container(attachedDatabase, alias);
  }

  static i0.TypeConverter<i2.Color, int> $convertercolor =
      const i4.ColorConverter();
  static i0.TypeConverter<i1.ContainerMetadata, String> $convertermetadata =
      const i5.ContainerMetadataConverter();
  static i0.TypeConverter<i1.ContainerMetadata?, String?> $convertermetadatan =
      i0.NullAwareTypeConverter.wrap($convertermetadata);
  @override
  bool get dontWriteConstraints => true;
}

class ContainerCompanion extends i0.UpdateCompanion<i1.ContainerData> {
  final i0.Value<String> id;
  final i0.Value<String?> name;
  final i0.Value<i2.Color> color;
  final i0.Value<String> orderKey;
  final i0.Value<bool> isPinned;
  final i0.Value<i1.ContainerMetadata?> metadata;
  final i0.Value<int> rowid;
  const ContainerCompanion({
    this.id = const i0.Value.absent(),
    this.name = const i0.Value.absent(),
    this.color = const i0.Value.absent(),
    this.orderKey = const i0.Value.absent(),
    this.isPinned = const i0.Value.absent(),
    this.metadata = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  ContainerCompanion.insert({
    required String id,
    this.name = const i0.Value.absent(),
    required i2.Color color,
    required String orderKey,
    this.isPinned = const i0.Value.absent(),
    this.metadata = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       color = i0.Value(color),
       orderKey = i0.Value(orderKey);
  static i0.Insertable<i1.ContainerData> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? name,
    i0.Expression<int>? color,
    i0.Expression<String>? orderKey,
    i0.Expression<bool>? isPinned,
    i0.Expression<String>? metadata,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (orderKey != null) 'order_key': orderKey,
      if (isPinned != null) 'is_pinned': isPinned,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.ContainerCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String?>? name,
    i0.Value<i2.Color>? color,
    i0.Value<String>? orderKey,
    i0.Value<bool>? isPinned,
    i0.Value<i1.ContainerMetadata?>? metadata,
    i0.Value<int>? rowid,
  }) {
    return i3.ContainerCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      orderKey: orderKey ?? this.orderKey,
      isPinned: isPinned ?? this.isPinned,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = i0.Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = i0.Variable<int>(
        i3.Container.$convertercolor.toSql(color.value),
      );
    }
    if (orderKey.present) {
      map['order_key'] = i0.Variable<String>(orderKey.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = i0.Variable<bool>(isPinned.value);
    }
    if (metadata.present) {
      map['metadata'] = i0.Variable<String>(
        i3.Container.$convertermetadatan.toSql(metadata.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContainerCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('orderKey: $orderKey, ')
          ..write('isPinned: $isPinned, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Tab extends i0.Table with i0.TableInfo<Tab, i3.TabData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tab(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<i6.TabSource, int> source =
      i0.GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i6.TabSource>(i3.Tab.$convertersource);
  late final i0.GeneratedColumn<String> parentId = i0.GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES tab(id)ON DELETE SET NULL',
  );
  late final i0.GeneratedColumn<String> containerId =
      i0.GeneratedColumn<String>(
        'container_id',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'REFERENCES container(id)ON DELETE CASCADE',
      );
  late final i0.GeneratedColumn<String> orderKey = i0.GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> url =
      i0.GeneratedColumn<String>(
        'url',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(i3.Tab.$converterurl);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumnWithTypeConverter<i7.TabModeDbValue, int>
  tabMode = i0.GeneratedColumn<int>(
    'tab_mode',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const i0.CustomExpression('0'),
  ).withConverter<i7.TabModeDbValue>(i3.Tab.$convertertabMode);
  late final i0.GeneratedColumn<String> isolationContextId =
      i0.GeneratedColumn<String>(
        'isolation_context_id',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<bool> isPinned = i0.GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: i0.DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const i0.CustomExpression('0'),
  );
  late final i0.GeneratedColumn<bool> isProbablyReaderable =
      i0.GeneratedColumn<bool>(
        'is_probably_readerable',
        aliasedName,
        true,
        type: i0.DriftSqlType.bool,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> extractedContentMarkdown =
      i0.GeneratedColumn<String>(
        'extracted_content_markdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> extractedContentPlain =
      i0.GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentMarkdown =
      i0.GeneratedColumn<String>(
        'full_content_markdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentPlain =
      i0.GeneratedColumn<String>(
        'full_content_plain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<DateTime> timestamp =
      i0.GeneratedColumn<DateTime>(
        'timestamp',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<int> contentHash = i0.GeneratedColumn<int>(
    'content_hash',
    aliasedName,
    true,
    generatedAs: i0.GeneratedAs(
      const i0.CustomExpression(
        'generate_content_hash(title, extracted_content_plain, full_content_plain)',
      ),
      false,
    ),
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'GENERATED ALWAYS AS (generate_content_hash(title, extracted_content_plain, full_content_plain)) VIRTUAL',
  );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    source,
    parentId,
    containerId,
    orderKey,
    url,
    title,
    tabMode,
    isolationContextId,
    isPinned,
    isProbablyReaderable,
    extractedContentMarkdown,
    extractedContentPlain,
    fullContentMarkdown,
    fullContentPlain,
    timestamp,
    contentHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tab';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i3.TabData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.TabData(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: i3.Tab.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      parentId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      containerId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}container_id'],
      ),
      orderKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      )!,
      url: i3.Tab.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}url'],
        ),
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      tabMode: i3.Tab.$convertertabMode.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}tab_mode'],
        )!,
      ),
      isolationContextId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}isolation_context_id'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isProbablyReaderable: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}is_probably_readerable'],
      ),
      extractedContentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_markdown'],
      ),
      extractedContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      ),
      fullContentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_markdown'],
      ),
      fullContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_plain'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}content_hash'],
      ),
    );
  }

  @override
  Tab createAlias(String alias) {
    return Tab(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i6.TabSource, int, int> $convertersource =
      const i0.EnumIndexConverter<i6.TabSource>(i6.TabSource.values);
  static i0.TypeConverter<Uri?, String?> $converterurl =
      const i8.UriConverterNullable();
  static i0.JsonTypeConverter2<i7.TabModeDbValue, int, int> $convertertabMode =
      const i0.EnumIndexConverter<i7.TabModeDbValue>(i7.TabModeDbValue.values);
  @override
  List<String> get customConstraints => const [
    'CHECK((tab_mode = 2 AND isolation_context_id IS NOT NULL)OR(tab_mode != 2 AND isolation_context_id IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class TabData extends i0.DataClass implements i0.Insertable<i3.TabData> {
  final String id;
  final i6.TabSource source;
  final String? parentId;
  final String? containerId;
  final String orderKey;
  final Uri? url;
  final String? title;
  final i7.TabModeDbValue tabMode;
  final String? isolationContextId;
  final bool isPinned;
  final bool? isProbablyReaderable;
  final String? extractedContentMarkdown;
  final String? extractedContentPlain;
  final String? fullContentMarkdown;
  final String? fullContentPlain;
  final DateTime timestamp;

  /// xxh3-64 over (title, extracted_content_plain, full_content_plain).
  /// Used by the FTS update trigger and the tab→history fan-out trigger to
  /// short-circuit when the row's UPDATE didn't actually change content.
  /// VIRTUAL (computed on read) to avoid recreating the table on migration;
  /// recomputation cost is negligible vs. the FTS rewrite it skips.
  final int? contentHash;
  const TabData({
    required this.id,
    required this.source,
    this.parentId,
    this.containerId,
    required this.orderKey,
    this.url,
    this.title,
    required this.tabMode,
    this.isolationContextId,
    required this.isPinned,
    this.isProbablyReaderable,
    this.extractedContentMarkdown,
    this.extractedContentPlain,
    this.fullContentMarkdown,
    this.fullContentPlain,
    required this.timestamp,
    this.contentHash,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<String>(id);
    {
      map['source'] = i0.Variable<int>(i3.Tab.$convertersource.toSql(source));
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = i0.Variable<String>(parentId);
    }
    if (!nullToAbsent || containerId != null) {
      map['container_id'] = i0.Variable<String>(containerId);
    }
    map['order_key'] = i0.Variable<String>(orderKey);
    if (!nullToAbsent || url != null) {
      map['url'] = i0.Variable<String>(i3.Tab.$converterurl.toSql(url));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = i0.Variable<String>(title);
    }
    {
      map['tab_mode'] = i0.Variable<int>(
        i3.Tab.$convertertabMode.toSql(tabMode),
      );
    }
    if (!nullToAbsent || isolationContextId != null) {
      map['isolation_context_id'] = i0.Variable<String>(isolationContextId);
    }
    map['is_pinned'] = i0.Variable<bool>(isPinned);
    if (!nullToAbsent || isProbablyReaderable != null) {
      map['is_probably_readerable'] = i0.Variable<bool>(isProbablyReaderable);
    }
    if (!nullToAbsent || extractedContentMarkdown != null) {
      map['extracted_content_markdown'] = i0.Variable<String>(
        extractedContentMarkdown,
      );
    }
    if (!nullToAbsent || extractedContentPlain != null) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain,
      );
    }
    if (!nullToAbsent || fullContentMarkdown != null) {
      map['full_content_markdown'] = i0.Variable<String>(fullContentMarkdown);
    }
    if (!nullToAbsent || fullContentPlain != null) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain);
    }
    map['timestamp'] = i0.Variable<DateTime>(timestamp);
    return map;
  }

  factory TabData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return TabData(
      id: serializer.fromJson<String>(json['id']),
      source: i3.Tab.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      parentId: serializer.fromJson<String?>(json['parent_id']),
      containerId: serializer.fromJson<String?>(json['container_id']),
      orderKey: serializer.fromJson<String>(json['order_key']),
      url: serializer.fromJson<Uri?>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      tabMode: i3.Tab.$convertertabMode.fromJson(
        serializer.fromJson<int>(json['tab_mode']),
      ),
      isolationContextId: serializer.fromJson<String?>(
        json['isolation_context_id'],
      ),
      isPinned: serializer.fromJson<bool>(json['is_pinned']),
      isProbablyReaderable: serializer.fromJson<bool?>(
        json['is_probably_readerable'],
      ),
      extractedContentMarkdown: serializer.fromJson<String?>(
        json['extracted_content_markdown'],
      ),
      extractedContentPlain: serializer.fromJson<String?>(
        json['extracted_content_plain'],
      ),
      fullContentMarkdown: serializer.fromJson<String?>(
        json['full_content_markdown'],
      ),
      fullContentPlain: serializer.fromJson<String?>(
        json['full_content_plain'],
      ),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      contentHash: serializer.fromJson<int?>(json['content_hash']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<int>(i3.Tab.$convertersource.toJson(source)),
      'parent_id': serializer.toJson<String?>(parentId),
      'container_id': serializer.toJson<String?>(containerId),
      'order_key': serializer.toJson<String>(orderKey),
      'url': serializer.toJson<Uri?>(url),
      'title': serializer.toJson<String?>(title),
      'tab_mode': serializer.toJson<int>(
        i3.Tab.$convertertabMode.toJson(tabMode),
      ),
      'isolation_context_id': serializer.toJson<String?>(isolationContextId),
      'is_pinned': serializer.toJson<bool>(isPinned),
      'is_probably_readerable': serializer.toJson<bool?>(isProbablyReaderable),
      'extracted_content_markdown': serializer.toJson<String?>(
        extractedContentMarkdown,
      ),
      'extracted_content_plain': serializer.toJson<String?>(
        extractedContentPlain,
      ),
      'full_content_markdown': serializer.toJson<String?>(fullContentMarkdown),
      'full_content_plain': serializer.toJson<String?>(fullContentPlain),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'content_hash': serializer.toJson<int?>(contentHash),
    };
  }

  i3.TabData copyWith({
    String? id,
    i6.TabSource? source,
    i0.Value<String?> parentId = const i0.Value.absent(),
    i0.Value<String?> containerId = const i0.Value.absent(),
    String? orderKey,
    i0.Value<Uri?> url = const i0.Value.absent(),
    i0.Value<String?> title = const i0.Value.absent(),
    i7.TabModeDbValue? tabMode,
    i0.Value<String?> isolationContextId = const i0.Value.absent(),
    bool? isPinned,
    i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
    i0.Value<String?> extractedContentMarkdown = const i0.Value.absent(),
    i0.Value<String?> extractedContentPlain = const i0.Value.absent(),
    i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
    i0.Value<String?> fullContentPlain = const i0.Value.absent(),
    DateTime? timestamp,
    i0.Value<int?> contentHash = const i0.Value.absent(),
  }) => i3.TabData(
    id: id ?? this.id,
    source: source ?? this.source,
    parentId: parentId.present ? parentId.value : this.parentId,
    containerId: containerId.present ? containerId.value : this.containerId,
    orderKey: orderKey ?? this.orderKey,
    url: url.present ? url.value : this.url,
    title: title.present ? title.value : this.title,
    tabMode: tabMode ?? this.tabMode,
    isolationContextId: isolationContextId.present
        ? isolationContextId.value
        : this.isolationContextId,
    isPinned: isPinned ?? this.isPinned,
    isProbablyReaderable: isProbablyReaderable.present
        ? isProbablyReaderable.value
        : this.isProbablyReaderable,
    extractedContentMarkdown: extractedContentMarkdown.present
        ? extractedContentMarkdown.value
        : this.extractedContentMarkdown,
    extractedContentPlain: extractedContentPlain.present
        ? extractedContentPlain.value
        : this.extractedContentPlain,
    fullContentMarkdown: fullContentMarkdown.present
        ? fullContentMarkdown.value
        : this.fullContentMarkdown,
    fullContentPlain: fullContentPlain.present
        ? fullContentPlain.value
        : this.fullContentPlain,
    timestamp: timestamp ?? this.timestamp,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
  );
  @override
  String toString() {
    return (StringBuffer('TabData(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('parentId: $parentId, ')
          ..write('containerId: $containerId, ')
          ..write('orderKey: $orderKey, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('tabMode: $tabMode, ')
          ..write('isolationContextId: $isolationContextId, ')
          ..write('isPinned: $isPinned, ')
          ..write('isProbablyReaderable: $isProbablyReaderable, ')
          ..write('extractedContentMarkdown: $extractedContentMarkdown, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentMarkdown: $fullContentMarkdown, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('timestamp: $timestamp, ')
          ..write('contentHash: $contentHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    parentId,
    containerId,
    orderKey,
    url,
    title,
    tabMode,
    isolationContextId,
    isPinned,
    isProbablyReaderable,
    extractedContentMarkdown,
    extractedContentPlain,
    fullContentMarkdown,
    fullContentPlain,
    timestamp,
    contentHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.TabData &&
          other.id == this.id &&
          other.source == this.source &&
          other.parentId == this.parentId &&
          other.containerId == this.containerId &&
          other.orderKey == this.orderKey &&
          other.url == this.url &&
          other.title == this.title &&
          other.tabMode == this.tabMode &&
          other.isolationContextId == this.isolationContextId &&
          other.isPinned == this.isPinned &&
          other.isProbablyReaderable == this.isProbablyReaderable &&
          other.extractedContentMarkdown == this.extractedContentMarkdown &&
          other.extractedContentPlain == this.extractedContentPlain &&
          other.fullContentMarkdown == this.fullContentMarkdown &&
          other.fullContentPlain == this.fullContentPlain &&
          other.timestamp == this.timestamp &&
          other.contentHash == this.contentHash);
}

class TabCompanion extends i0.UpdateCompanion<i3.TabData> {
  final i0.Value<String> id;
  final i0.Value<i6.TabSource> source;
  final i0.Value<String?> parentId;
  final i0.Value<String?> containerId;
  final i0.Value<String> orderKey;
  final i0.Value<Uri?> url;
  final i0.Value<String?> title;
  final i0.Value<i7.TabModeDbValue> tabMode;
  final i0.Value<String?> isolationContextId;
  final i0.Value<bool> isPinned;
  final i0.Value<bool?> isProbablyReaderable;
  final i0.Value<String?> extractedContentMarkdown;
  final i0.Value<String?> extractedContentPlain;
  final i0.Value<String?> fullContentMarkdown;
  final i0.Value<String?> fullContentPlain;
  final i0.Value<DateTime> timestamp;
  final i0.Value<int> rowid;
  const TabCompanion({
    this.id = const i0.Value.absent(),
    this.source = const i0.Value.absent(),
    this.parentId = const i0.Value.absent(),
    this.containerId = const i0.Value.absent(),
    this.orderKey = const i0.Value.absent(),
    this.url = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.tabMode = const i0.Value.absent(),
    this.isolationContextId = const i0.Value.absent(),
    this.isPinned = const i0.Value.absent(),
    this.isProbablyReaderable = const i0.Value.absent(),
    this.extractedContentMarkdown = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentMarkdown = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    this.timestamp = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  TabCompanion.insert({
    required String id,
    required i6.TabSource source,
    this.parentId = const i0.Value.absent(),
    this.containerId = const i0.Value.absent(),
    required String orderKey,
    this.url = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.tabMode = const i0.Value.absent(),
    this.isolationContextId = const i0.Value.absent(),
    this.isPinned = const i0.Value.absent(),
    this.isProbablyReaderable = const i0.Value.absent(),
    this.extractedContentMarkdown = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentMarkdown = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    required DateTime timestamp,
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       source = i0.Value(source),
       orderKey = i0.Value(orderKey),
       timestamp = i0.Value(timestamp);
  static i0.Insertable<i3.TabData> custom({
    i0.Expression<String>? id,
    i0.Expression<int>? source,
    i0.Expression<String>? parentId,
    i0.Expression<String>? containerId,
    i0.Expression<String>? orderKey,
    i0.Expression<String>? url,
    i0.Expression<String>? title,
    i0.Expression<int>? tabMode,
    i0.Expression<String>? isolationContextId,
    i0.Expression<bool>? isPinned,
    i0.Expression<bool>? isProbablyReaderable,
    i0.Expression<String>? extractedContentMarkdown,
    i0.Expression<String>? extractedContentPlain,
    i0.Expression<String>? fullContentMarkdown,
    i0.Expression<String>? fullContentPlain,
    i0.Expression<DateTime>? timestamp,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (parentId != null) 'parent_id': parentId,
      if (containerId != null) 'container_id': containerId,
      if (orderKey != null) 'order_key': orderKey,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (tabMode != null) 'tab_mode': tabMode,
      if (isolationContextId != null)
        'isolation_context_id': isolationContextId,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isProbablyReaderable != null)
        'is_probably_readerable': isProbablyReaderable,
      if (extractedContentMarkdown != null)
        'extracted_content_markdown': extractedContentMarkdown,
      if (extractedContentPlain != null)
        'extracted_content_plain': extractedContentPlain,
      if (fullContentMarkdown != null)
        'full_content_markdown': fullContentMarkdown,
      if (fullContentPlain != null) 'full_content_plain': fullContentPlain,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.TabCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<i6.TabSource>? source,
    i0.Value<String?>? parentId,
    i0.Value<String?>? containerId,
    i0.Value<String>? orderKey,
    i0.Value<Uri?>? url,
    i0.Value<String?>? title,
    i0.Value<i7.TabModeDbValue>? tabMode,
    i0.Value<String?>? isolationContextId,
    i0.Value<bool>? isPinned,
    i0.Value<bool?>? isProbablyReaderable,
    i0.Value<String?>? extractedContentMarkdown,
    i0.Value<String?>? extractedContentPlain,
    i0.Value<String?>? fullContentMarkdown,
    i0.Value<String?>? fullContentPlain,
    i0.Value<DateTime>? timestamp,
    i0.Value<int>? rowid,
  }) {
    return i3.TabCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      parentId: parentId ?? this.parentId,
      containerId: containerId ?? this.containerId,
      orderKey: orderKey ?? this.orderKey,
      url: url ?? this.url,
      title: title ?? this.title,
      tabMode: tabMode ?? this.tabMode,
      isolationContextId: isolationContextId ?? this.isolationContextId,
      isPinned: isPinned ?? this.isPinned,
      isProbablyReaderable: isProbablyReaderable ?? this.isProbablyReaderable,
      extractedContentMarkdown:
          extractedContentMarkdown ?? this.extractedContentMarkdown,
      extractedContentPlain:
          extractedContentPlain ?? this.extractedContentPlain,
      fullContentMarkdown: fullContentMarkdown ?? this.fullContentMarkdown,
      fullContentPlain: fullContentPlain ?? this.fullContentPlain,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = i0.Variable<int>(
        i3.Tab.$convertersource.toSql(source.value),
      );
    }
    if (parentId.present) {
      map['parent_id'] = i0.Variable<String>(parentId.value);
    }
    if (containerId.present) {
      map['container_id'] = i0.Variable<String>(containerId.value);
    }
    if (orderKey.present) {
      map['order_key'] = i0.Variable<String>(orderKey.value);
    }
    if (url.present) {
      map['url'] = i0.Variable<String>(i3.Tab.$converterurl.toSql(url.value));
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (tabMode.present) {
      map['tab_mode'] = i0.Variable<int>(
        i3.Tab.$convertertabMode.toSql(tabMode.value),
      );
    }
    if (isolationContextId.present) {
      map['isolation_context_id'] = i0.Variable<String>(
        isolationContextId.value,
      );
    }
    if (isPinned.present) {
      map['is_pinned'] = i0.Variable<bool>(isPinned.value);
    }
    if (isProbablyReaderable.present) {
      map['is_probably_readerable'] = i0.Variable<bool>(
        isProbablyReaderable.value,
      );
    }
    if (extractedContentMarkdown.present) {
      map['extracted_content_markdown'] = i0.Variable<String>(
        extractedContentMarkdown.value,
      );
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentMarkdown.present) {
      map['full_content_markdown'] = i0.Variable<String>(
        fullContentMarkdown.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain.value);
    }
    if (timestamp.present) {
      map['timestamp'] = i0.Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('parentId: $parentId, ')
          ..write('containerId: $containerId, ')
          ..write('orderKey: $orderKey, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('tabMode: $tabMode, ')
          ..write('isolationContextId: $isolationContextId, ')
          ..write('isPinned: $isPinned, ')
          ..write('isProbablyReaderable: $isProbablyReaderable, ')
          ..write('extractedContentMarkdown: $extractedContentMarkdown, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentMarkdown: $fullContentMarkdown, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ClosedTabTombstone extends i0.Table
    with i0.TableInfo<ClosedTabTombstone, i3.ClosedTabTombstoneData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  ClosedTabTombstone(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> tabId = i0.GeneratedColumn<String>(
    'tab_id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<DateTime> closedAt =
      i0.GeneratedColumn<DateTime>(
        'closed_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [tabId, closedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'closed_tab_tombstone';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {tabId};
  @override
  i3.ClosedTabTombstoneData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.ClosedTabTombstoneData(
      tabId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}tab_id'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      )!,
    );
  }

  @override
  ClosedTabTombstone createAlias(String alias) {
    return ClosedTabTombstone(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ClosedTabTombstoneData extends i0.DataClass
    implements i0.Insertable<i3.ClosedTabTombstoneData> {
  final String tabId;
  final DateTime closedAt;
  const ClosedTabTombstoneData({required this.tabId, required this.closedAt});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['tab_id'] = i0.Variable<String>(tabId);
    map['closed_at'] = i0.Variable<DateTime>(closedAt);
    return map;
  }

  factory ClosedTabTombstoneData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return ClosedTabTombstoneData(
      tabId: serializer.fromJson<String>(json['tab_id']),
      closedAt: serializer.fromJson<DateTime>(json['closed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tab_id': serializer.toJson<String>(tabId),
      'closed_at': serializer.toJson<DateTime>(closedAt),
    };
  }

  i3.ClosedTabTombstoneData copyWith({String? tabId, DateTime? closedAt}) =>
      i3.ClosedTabTombstoneData(
        tabId: tabId ?? this.tabId,
        closedAt: closedAt ?? this.closedAt,
      );
  ClosedTabTombstoneData copyWithCompanion(
    i3.ClosedTabTombstoneCompanion data,
  ) {
    return ClosedTabTombstoneData(
      tabId: data.tabId.present ? data.tabId.value : this.tabId,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClosedTabTombstoneData(')
          ..write('tabId: $tabId, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tabId, closedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.ClosedTabTombstoneData &&
          other.tabId == this.tabId &&
          other.closedAt == this.closedAt);
}

class ClosedTabTombstoneCompanion
    extends i0.UpdateCompanion<i3.ClosedTabTombstoneData> {
  final i0.Value<String> tabId;
  final i0.Value<DateTime> closedAt;
  final i0.Value<int> rowid;
  const ClosedTabTombstoneCompanion({
    this.tabId = const i0.Value.absent(),
    this.closedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  ClosedTabTombstoneCompanion.insert({
    required String tabId,
    required DateTime closedAt,
    this.rowid = const i0.Value.absent(),
  }) : tabId = i0.Value(tabId),
       closedAt = i0.Value(closedAt);
  static i0.Insertable<i3.ClosedTabTombstoneData> custom({
    i0.Expression<String>? tabId,
    i0.Expression<DateTime>? closedAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (tabId != null) 'tab_id': tabId,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.ClosedTabTombstoneCompanion copyWith({
    i0.Value<String>? tabId,
    i0.Value<DateTime>? closedAt,
    i0.Value<int>? rowid,
  }) {
    return i3.ClosedTabTombstoneCompanion(
      tabId: tabId ?? this.tabId,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (tabId.present) {
      map['tab_id'] = i0.Variable<String>(tabId.value);
    }
    if (closedAt.present) {
      map['closed_at'] = i0.Variable<DateTime>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClosedTabTombstoneCompanion(')
          ..write('tabId: $tabId, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxTabParentContainer => i0.Index(
  'idx_tab_parent_container',
  'CREATE INDEX idx_tab_parent_container ON tab (parent_id, container_id)',
);
i0.Index get idxTabTimestamp => i0.Index(
  'idx_tab_timestamp',
  'CREATE INDEX idx_tab_timestamp ON tab (timestamp DESC, id DESC)',
);
i0.Index get idxTabContainerOrder => i0.Index(
  'idx_tab_container_order',
  'CREATE INDEX idx_tab_container_order ON tab (container_id, order_key)',
);

class CaptureTab extends i0.Table
    with i0.TableInfo<CaptureTab, i3.CaptureTabData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  CaptureTab(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> tabId = i0.GeneratedColumn<String>(
    'tab_id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES tab(id)ON DELETE CASCADE',
  );
  late final i0.GeneratedColumn<String> captureId = i0.GeneratedColumn<String>(
    'capture_id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> sourceUrl = i0.GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> status = i0.GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'pending\'',
    defaultValue: const i0.CustomExpression('\'pending\''),
  );
  late final i0.GeneratedColumn<DateTime> createdAt =
      i0.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    tabId,
    captureId,
    sourceUrl,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_tab';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {tabId};
  @override
  i3.CaptureTabData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.CaptureTabData(
      tabId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}tab_id'],
      )!,
      captureId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}capture_id'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      status: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  CaptureTab createAlias(String alias) {
    return CaptureTab(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CaptureTabData extends i0.DataClass
    implements i0.Insertable<i3.CaptureTabData> {
  final String tabId;
  final String captureId;
  final String sourceUrl;
  final String status;
  final DateTime createdAt;
  const CaptureTabData({
    required this.tabId,
    required this.captureId,
    required this.sourceUrl,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['tab_id'] = i0.Variable<String>(tabId);
    map['capture_id'] = i0.Variable<String>(captureId);
    map['source_url'] = i0.Variable<String>(sourceUrl);
    map['status'] = i0.Variable<String>(status);
    map['created_at'] = i0.Variable<DateTime>(createdAt);
    return map;
  }

  factory CaptureTabData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return CaptureTabData(
      tabId: serializer.fromJson<String>(json['tab_id']),
      captureId: serializer.fromJson<String>(json['capture_id']),
      sourceUrl: serializer.fromJson<String>(json['source_url']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tab_id': serializer.toJson<String>(tabId),
      'capture_id': serializer.toJson<String>(captureId),
      'source_url': serializer.toJson<String>(sourceUrl),
      'status': serializer.toJson<String>(status),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  i3.CaptureTabData copyWith({
    String? tabId,
    String? captureId,
    String? sourceUrl,
    String? status,
    DateTime? createdAt,
  }) => i3.CaptureTabData(
    tabId: tabId ?? this.tabId,
    captureId: captureId ?? this.captureId,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  CaptureTabData copyWithCompanion(i3.CaptureTabCompanion data) {
    return CaptureTabData(
      tabId: data.tabId.present ? data.tabId.value : this.tabId,
      captureId: data.captureId.present ? data.captureId.value : this.captureId,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureTabData(')
          ..write('tabId: $tabId, ')
          ..write('captureId: $captureId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tabId, captureId, sourceUrl, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.CaptureTabData &&
          other.tabId == this.tabId &&
          other.captureId == this.captureId &&
          other.sourceUrl == this.sourceUrl &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class CaptureTabCompanion extends i0.UpdateCompanion<i3.CaptureTabData> {
  final i0.Value<String> tabId;
  final i0.Value<String> captureId;
  final i0.Value<String> sourceUrl;
  final i0.Value<String> status;
  final i0.Value<DateTime> createdAt;
  final i0.Value<int> rowid;
  const CaptureTabCompanion({
    this.tabId = const i0.Value.absent(),
    this.captureId = const i0.Value.absent(),
    this.sourceUrl = const i0.Value.absent(),
    this.status = const i0.Value.absent(),
    this.createdAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  CaptureTabCompanion.insert({
    required String tabId,
    required String captureId,
    required String sourceUrl,
    this.status = const i0.Value.absent(),
    required DateTime createdAt,
    this.rowid = const i0.Value.absent(),
  }) : tabId = i0.Value(tabId),
       captureId = i0.Value(captureId),
       sourceUrl = i0.Value(sourceUrl),
       createdAt = i0.Value(createdAt);
  static i0.Insertable<i3.CaptureTabData> custom({
    i0.Expression<String>? tabId,
    i0.Expression<String>? captureId,
    i0.Expression<String>? sourceUrl,
    i0.Expression<String>? status,
    i0.Expression<DateTime>? createdAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (tabId != null) 'tab_id': tabId,
      if (captureId != null) 'capture_id': captureId,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.CaptureTabCompanion copyWith({
    i0.Value<String>? tabId,
    i0.Value<String>? captureId,
    i0.Value<String>? sourceUrl,
    i0.Value<String>? status,
    i0.Value<DateTime>? createdAt,
    i0.Value<int>? rowid,
  }) {
    return i3.CaptureTabCompanion(
      tabId: tabId ?? this.tabId,
      captureId: captureId ?? this.captureId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (tabId.present) {
      map['tab_id'] = i0.Variable<String>(tabId.value);
    }
    if (captureId.present) {
      map['capture_id'] = i0.Variable<String>(captureId.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = i0.Variable<String>(sourceUrl.value);
    }
    if (status.present) {
      map['status'] = i0.Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = i0.Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureTabCompanion(')
          ..write('tabId: $tabId, ')
          ..write('captureId: $captureId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxCaptureTabCaptureId => i0.Index(
  'idx_capture_tab_capture_id',
  'CREATE INDEX idx_capture_tab_capture_id ON capture_tab (capture_id)',
);

class TabFts extends i0.Table
    with i0.TableInfo<TabFts, i3.TabFt>, i0.VirtualTableInfo<TabFts, i3.TabFt> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  TabFts(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> url = i0.GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> extractedContentPlain =
      i0.GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentPlain =
      i0.GeneratedColumn<String>(
        'full_content_plain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    title,
    url,
    extractedContentPlain,
    fullContentPlain,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tab_fts';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i3.TabFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.TabFt(
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      extractedContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      )!,
      fullContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_plain'],
      )!,
    );
  }

  @override
  TabFts createAlias(String alias) {
    return TabFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, url, extracted_content_plain, full_content_plain, content=tab, tokenize="trigram")';
}

class TabFt extends i0.DataClass implements i0.Insertable<i3.TabFt> {
  final String title;
  final String url;
  final String extractedContentPlain;
  final String fullContentPlain;
  const TabFt({
    required this.title,
    required this.url,
    required this.extractedContentPlain,
    required this.fullContentPlain,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['title'] = i0.Variable<String>(title);
    map['url'] = i0.Variable<String>(url);
    map['extracted_content_plain'] = i0.Variable<String>(extractedContentPlain);
    map['full_content_plain'] = i0.Variable<String>(fullContentPlain);
    return map;
  }

  factory TabFt.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return TabFt(
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      extractedContentPlain: serializer.fromJson<String>(
        json['extracted_content_plain'],
      ),
      fullContentPlain: serializer.fromJson<String>(json['full_content_plain']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'extracted_content_plain': serializer.toJson<String>(
        extractedContentPlain,
      ),
      'full_content_plain': serializer.toJson<String>(fullContentPlain),
    };
  }

  i3.TabFt copyWith({
    String? title,
    String? url,
    String? extractedContentPlain,
    String? fullContentPlain,
  }) => i3.TabFt(
    title: title ?? this.title,
    url: url ?? this.url,
    extractedContentPlain: extractedContentPlain ?? this.extractedContentPlain,
    fullContentPlain: fullContentPlain ?? this.fullContentPlain,
  );
  TabFt copyWithCompanion(i3.TabFtsCompanion data) {
    return TabFt(
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      extractedContentPlain: data.extractedContentPlain.present
          ? data.extractedContentPlain.value
          : this.extractedContentPlain,
      fullContentPlain: data.fullContentPlain.present
          ? data.fullContentPlain.value
          : this.fullContentPlain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabFt(')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentPlain: $fullContentPlain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(title, url, extractedContentPlain, fullContentPlain);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.TabFt &&
          other.title == this.title &&
          other.url == this.url &&
          other.extractedContentPlain == this.extractedContentPlain &&
          other.fullContentPlain == this.fullContentPlain);
}

class TabFtsCompanion extends i0.UpdateCompanion<i3.TabFt> {
  final i0.Value<String> title;
  final i0.Value<String> url;
  final i0.Value<String> extractedContentPlain;
  final i0.Value<String> fullContentPlain;
  final i0.Value<int> rowid;
  const TabFtsCompanion({
    this.title = const i0.Value.absent(),
    this.url = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  TabFtsCompanion.insert({
    required String title,
    required String url,
    required String extractedContentPlain,
    required String fullContentPlain,
    this.rowid = const i0.Value.absent(),
  }) : title = i0.Value(title),
       url = i0.Value(url),
       extractedContentPlain = i0.Value(extractedContentPlain),
       fullContentPlain = i0.Value(fullContentPlain);
  static i0.Insertable<i3.TabFt> custom({
    i0.Expression<String>? title,
    i0.Expression<String>? url,
    i0.Expression<String>? extractedContentPlain,
    i0.Expression<String>? fullContentPlain,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (extractedContentPlain != null)
        'extracted_content_plain': extractedContentPlain,
      if (fullContentPlain != null) 'full_content_plain': fullContentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.TabFtsCompanion copyWith({
    i0.Value<String>? title,
    i0.Value<String>? url,
    i0.Value<String>? extractedContentPlain,
    i0.Value<String>? fullContentPlain,
    i0.Value<int>? rowid,
  }) {
    return i3.TabFtsCompanion(
      title: title ?? this.title,
      url: url ?? this.url,
      extractedContentPlain:
          extractedContentPlain ?? this.extractedContentPlain,
      fullContentPlain: fullContentPlain ?? this.fullContentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = i0.Variable<String>(url.value);
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabFtsCompanion(')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Trigger get tabMaintainParentChainOnDelete => i0.Trigger(
  'CREATE TRIGGER tab_maintain_parent_chain_on_delete BEFORE DELETE ON tab BEGIN UPDATE tab SET parent_id = CASE WHEN OLD.parent_id IS NOT NULL AND EXISTS (SELECT 1 FROM tab WHERE id = OLD.parent_id) THEN OLD.parent_id ELSE NULL END WHERE parent_id = OLD.id;END',
  'tab_maintain_parent_chain_on_delete',
);
i0.Trigger get tabAfterInsert => i0.Trigger(
  'CREATE TRIGGER tab_after_insert AFTER INSERT ON tab BEGIN INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
  'tab_after_insert',
);
i0.Trigger get tabAfterDelete => i0.Trigger(
  'CREATE TRIGGER tab_after_delete AFTER DELETE ON tab BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);END',
  'tab_after_delete',
);
i0.Trigger get tabAfterUpdate => i0.Trigger(
  'CREATE TRIGGER tab_after_update AFTER UPDATE OF title, url, extracted_content_plain, full_content_plain ON tab WHEN OLD.content_hash IS NOT NEW.content_hash OR OLD.url IS NOT NEW.url BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
  'tab_after_update',
);

class LocalIndexSetting extends i0.Table
    with i0.TableInfo<LocalIndexSetting, i3.LocalIndexSettingData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalIndexSetting(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> key = i0.GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<int> value = i0.GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<i0.GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_index_setting';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {key};
  @override
  i3.LocalIndexSettingData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.LocalIndexSettingData(
      key: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  LocalIndexSetting createAlias(String alias) {
    return LocalIndexSetting(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class LocalIndexSettingData extends i0.DataClass
    implements i0.Insertable<i3.LocalIndexSettingData> {
  final String key;
  final int value;
  const LocalIndexSettingData({required this.key, required this.value});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['key'] = i0.Variable<String>(key);
    map['value'] = i0.Variable<int>(value);
    return map;
  }

  factory LocalIndexSettingData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return LocalIndexSettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<int>(value),
    };
  }

  i3.LocalIndexSettingData copyWith({String? key, int? value}) =>
      i3.LocalIndexSettingData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  LocalIndexSettingData copyWithCompanion(i3.LocalIndexSettingCompanion data) {
    return LocalIndexSettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIndexSettingData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.LocalIndexSettingData &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalIndexSettingCompanion
    extends i0.UpdateCompanion<i3.LocalIndexSettingData> {
  final i0.Value<String> key;
  final i0.Value<int> value;
  final i0.Value<int> rowid;
  const LocalIndexSettingCompanion({
    this.key = const i0.Value.absent(),
    this.value = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  LocalIndexSettingCompanion.insert({
    required String key,
    required int value,
    this.rowid = const i0.Value.absent(),
  }) : key = i0.Value(key),
       value = i0.Value(value);
  static i0.Insertable<i3.LocalIndexSettingData> custom({
    i0.Expression<String>? key,
    i0.Expression<int>? value,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.LocalIndexSettingCompanion copyWith({
    i0.Value<String>? key,
    i0.Value<int>? value,
    i0.Value<int>? rowid,
  }) {
    return i3.LocalIndexSettingCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (key.present) {
      map['key'] = i0.Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = i0.Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIndexSettingCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class History extends i0.Table with i0.TableInfo<History, i3.HistoryData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  History(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> urlCanonical =
      i0.GeneratedColumn<String>(
        'url_canonical',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'PRIMARY KEY NOT NULL',
      );
  late final i0.GeneratedColumn<String> urlHost = i0.GeneratedColumn<String>(
    'url_host',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> urlPath = i0.GeneratedColumn<String>(
    'url_path',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
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
  late final i0.GeneratedColumn<bool> isProbablyReaderable =
      i0.GeneratedColumn<bool>(
        'is_probably_readerable',
        aliasedName,
        true,
        type: i0.DriftSqlType.bool,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> extractedContentMarkdown =
      i0.GeneratedColumn<String>(
        'extracted_content_markdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> extractedContentPlain =
      i0.GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentMarkdown =
      i0.GeneratedColumn<String>(
        'full_content_markdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentPlain =
      i0.GeneratedColumn<String>(
        'full_content_plain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<int> contentHash = i0.GeneratedColumn<int>(
    'content_hash',
    aliasedName,
    true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<DateTime> observedAt =
      i0.GeneratedColumn<DateTime>(
        'observed_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<int> observedCount = i0.GeneratedColumn<int>(
    'observed_count',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const i0.CustomExpression('1'),
  );
  @override
  List<i0.GeneratedColumn> get $columns => [
    urlCanonical,
    urlHost,
    urlPath,
    title,
    isProbablyReaderable,
    extractedContentMarkdown,
    extractedContentPlain,
    fullContentMarkdown,
    fullContentPlain,
    contentHash,
    observedAt,
    observedCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {urlCanonical};
  @override
  i3.HistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.HistoryData(
      urlCanonical: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_canonical'],
      )!,
      urlHost: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_host'],
      )!,
      urlPath: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_path'],
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      isProbablyReaderable: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}is_probably_readerable'],
      ),
      extractedContentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_markdown'],
      ),
      extractedContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      ),
      fullContentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_markdown'],
      ),
      fullContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_plain'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}content_hash'],
      ),
      observedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
      observedCount: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}observed_count'],
      )!,
    );
  }

  @override
  History createAlias(String alias) {
    return History(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class HistoryData extends i0.DataClass
    implements i0.Insertable<i3.HistoryData> {
  final String urlCanonical;
  final String urlHost;
  final String? urlPath;
  final String? title;
  final bool? isProbablyReaderable;
  final String? extractedContentMarkdown;
  final String? extractedContentPlain;
  final String? fullContentMarkdown;
  final String? fullContentPlain;
  final int? contentHash;
  final DateTime observedAt;
  final int observedCount;
  const HistoryData({
    required this.urlCanonical,
    required this.urlHost,
    this.urlPath,
    this.title,
    this.isProbablyReaderable,
    this.extractedContentMarkdown,
    this.extractedContentPlain,
    this.fullContentMarkdown,
    this.fullContentPlain,
    this.contentHash,
    required this.observedAt,
    required this.observedCount,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['url_canonical'] = i0.Variable<String>(urlCanonical);
    map['url_host'] = i0.Variable<String>(urlHost);
    if (!nullToAbsent || urlPath != null) {
      map['url_path'] = i0.Variable<String>(urlPath);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = i0.Variable<String>(title);
    }
    if (!nullToAbsent || isProbablyReaderable != null) {
      map['is_probably_readerable'] = i0.Variable<bool>(isProbablyReaderable);
    }
    if (!nullToAbsent || extractedContentMarkdown != null) {
      map['extracted_content_markdown'] = i0.Variable<String>(
        extractedContentMarkdown,
      );
    }
    if (!nullToAbsent || extractedContentPlain != null) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain,
      );
    }
    if (!nullToAbsent || fullContentMarkdown != null) {
      map['full_content_markdown'] = i0.Variable<String>(fullContentMarkdown);
    }
    if (!nullToAbsent || fullContentPlain != null) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain);
    }
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = i0.Variable<int>(contentHash);
    }
    map['observed_at'] = i0.Variable<DateTime>(observedAt);
    map['observed_count'] = i0.Variable<int>(observedCount);
    return map;
  }

  factory HistoryData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return HistoryData(
      urlCanonical: serializer.fromJson<String>(json['url_canonical']),
      urlHost: serializer.fromJson<String>(json['url_host']),
      urlPath: serializer.fromJson<String?>(json['url_path']),
      title: serializer.fromJson<String?>(json['title']),
      isProbablyReaderable: serializer.fromJson<bool?>(
        json['is_probably_readerable'],
      ),
      extractedContentMarkdown: serializer.fromJson<String?>(
        json['extracted_content_markdown'],
      ),
      extractedContentPlain: serializer.fromJson<String?>(
        json['extracted_content_plain'],
      ),
      fullContentMarkdown: serializer.fromJson<String?>(
        json['full_content_markdown'],
      ),
      fullContentPlain: serializer.fromJson<String?>(
        json['full_content_plain'],
      ),
      contentHash: serializer.fromJson<int?>(json['content_hash']),
      observedAt: serializer.fromJson<DateTime>(json['observed_at']),
      observedCount: serializer.fromJson<int>(json['observed_count']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url_canonical': serializer.toJson<String>(urlCanonical),
      'url_host': serializer.toJson<String>(urlHost),
      'url_path': serializer.toJson<String?>(urlPath),
      'title': serializer.toJson<String?>(title),
      'is_probably_readerable': serializer.toJson<bool?>(isProbablyReaderable),
      'extracted_content_markdown': serializer.toJson<String?>(
        extractedContentMarkdown,
      ),
      'extracted_content_plain': serializer.toJson<String?>(
        extractedContentPlain,
      ),
      'full_content_markdown': serializer.toJson<String?>(fullContentMarkdown),
      'full_content_plain': serializer.toJson<String?>(fullContentPlain),
      'content_hash': serializer.toJson<int?>(contentHash),
      'observed_at': serializer.toJson<DateTime>(observedAt),
      'observed_count': serializer.toJson<int>(observedCount),
    };
  }

  i3.HistoryData copyWith({
    String? urlCanonical,
    String? urlHost,
    i0.Value<String?> urlPath = const i0.Value.absent(),
    i0.Value<String?> title = const i0.Value.absent(),
    i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
    i0.Value<String?> extractedContentMarkdown = const i0.Value.absent(),
    i0.Value<String?> extractedContentPlain = const i0.Value.absent(),
    i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
    i0.Value<String?> fullContentPlain = const i0.Value.absent(),
    i0.Value<int?> contentHash = const i0.Value.absent(),
    DateTime? observedAt,
    int? observedCount,
  }) => i3.HistoryData(
    urlCanonical: urlCanonical ?? this.urlCanonical,
    urlHost: urlHost ?? this.urlHost,
    urlPath: urlPath.present ? urlPath.value : this.urlPath,
    title: title.present ? title.value : this.title,
    isProbablyReaderable: isProbablyReaderable.present
        ? isProbablyReaderable.value
        : this.isProbablyReaderable,
    extractedContentMarkdown: extractedContentMarkdown.present
        ? extractedContentMarkdown.value
        : this.extractedContentMarkdown,
    extractedContentPlain: extractedContentPlain.present
        ? extractedContentPlain.value
        : this.extractedContentPlain,
    fullContentMarkdown: fullContentMarkdown.present
        ? fullContentMarkdown.value
        : this.fullContentMarkdown,
    fullContentPlain: fullContentPlain.present
        ? fullContentPlain.value
        : this.fullContentPlain,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
    observedAt: observedAt ?? this.observedAt,
    observedCount: observedCount ?? this.observedCount,
  );
  HistoryData copyWithCompanion(i3.HistoryCompanion data) {
    return HistoryData(
      urlCanonical: data.urlCanonical.present
          ? data.urlCanonical.value
          : this.urlCanonical,
      urlHost: data.urlHost.present ? data.urlHost.value : this.urlHost,
      urlPath: data.urlPath.present ? data.urlPath.value : this.urlPath,
      title: data.title.present ? data.title.value : this.title,
      isProbablyReaderable: data.isProbablyReaderable.present
          ? data.isProbablyReaderable.value
          : this.isProbablyReaderable,
      extractedContentMarkdown: data.extractedContentMarkdown.present
          ? data.extractedContentMarkdown.value
          : this.extractedContentMarkdown,
      extractedContentPlain: data.extractedContentPlain.present
          ? data.extractedContentPlain.value
          : this.extractedContentPlain,
      fullContentMarkdown: data.fullContentMarkdown.present
          ? data.fullContentMarkdown.value
          : this.fullContentMarkdown,
      fullContentPlain: data.fullContentPlain.present
          ? data.fullContentPlain.value
          : this.fullContentPlain,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
      observedCount: data.observedCount.present
          ? data.observedCount.value
          : this.observedCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryData(')
          ..write('urlCanonical: $urlCanonical, ')
          ..write('urlHost: $urlHost, ')
          ..write('urlPath: $urlPath, ')
          ..write('title: $title, ')
          ..write('isProbablyReaderable: $isProbablyReaderable, ')
          ..write('extractedContentMarkdown: $extractedContentMarkdown, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentMarkdown: $fullContentMarkdown, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('contentHash: $contentHash, ')
          ..write('observedAt: $observedAt, ')
          ..write('observedCount: $observedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    urlCanonical,
    urlHost,
    urlPath,
    title,
    isProbablyReaderable,
    extractedContentMarkdown,
    extractedContentPlain,
    fullContentMarkdown,
    fullContentPlain,
    contentHash,
    observedAt,
    observedCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.HistoryData &&
          other.urlCanonical == this.urlCanonical &&
          other.urlHost == this.urlHost &&
          other.urlPath == this.urlPath &&
          other.title == this.title &&
          other.isProbablyReaderable == this.isProbablyReaderable &&
          other.extractedContentMarkdown == this.extractedContentMarkdown &&
          other.extractedContentPlain == this.extractedContentPlain &&
          other.fullContentMarkdown == this.fullContentMarkdown &&
          other.fullContentPlain == this.fullContentPlain &&
          other.contentHash == this.contentHash &&
          other.observedAt == this.observedAt &&
          other.observedCount == this.observedCount);
}

class HistoryCompanion extends i0.UpdateCompanion<i3.HistoryData> {
  final i0.Value<String> urlCanonical;
  final i0.Value<String> urlHost;
  final i0.Value<String?> urlPath;
  final i0.Value<String?> title;
  final i0.Value<bool?> isProbablyReaderable;
  final i0.Value<String?> extractedContentMarkdown;
  final i0.Value<String?> extractedContentPlain;
  final i0.Value<String?> fullContentMarkdown;
  final i0.Value<String?> fullContentPlain;
  final i0.Value<int?> contentHash;
  final i0.Value<DateTime> observedAt;
  final i0.Value<int> observedCount;
  final i0.Value<int> rowid;
  const HistoryCompanion({
    this.urlCanonical = const i0.Value.absent(),
    this.urlHost = const i0.Value.absent(),
    this.urlPath = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.isProbablyReaderable = const i0.Value.absent(),
    this.extractedContentMarkdown = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentMarkdown = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    this.contentHash = const i0.Value.absent(),
    this.observedAt = const i0.Value.absent(),
    this.observedCount = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  HistoryCompanion.insert({
    required String urlCanonical,
    required String urlHost,
    this.urlPath = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.isProbablyReaderable = const i0.Value.absent(),
    this.extractedContentMarkdown = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentMarkdown = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    this.contentHash = const i0.Value.absent(),
    required DateTime observedAt,
    this.observedCount = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : urlCanonical = i0.Value(urlCanonical),
       urlHost = i0.Value(urlHost),
       observedAt = i0.Value(observedAt);
  static i0.Insertable<i3.HistoryData> custom({
    i0.Expression<String>? urlCanonical,
    i0.Expression<String>? urlHost,
    i0.Expression<String>? urlPath,
    i0.Expression<String>? title,
    i0.Expression<bool>? isProbablyReaderable,
    i0.Expression<String>? extractedContentMarkdown,
    i0.Expression<String>? extractedContentPlain,
    i0.Expression<String>? fullContentMarkdown,
    i0.Expression<String>? fullContentPlain,
    i0.Expression<int>? contentHash,
    i0.Expression<DateTime>? observedAt,
    i0.Expression<int>? observedCount,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (urlCanonical != null) 'url_canonical': urlCanonical,
      if (urlHost != null) 'url_host': urlHost,
      if (urlPath != null) 'url_path': urlPath,
      if (title != null) 'title': title,
      if (isProbablyReaderable != null)
        'is_probably_readerable': isProbablyReaderable,
      if (extractedContentMarkdown != null)
        'extracted_content_markdown': extractedContentMarkdown,
      if (extractedContentPlain != null)
        'extracted_content_plain': extractedContentPlain,
      if (fullContentMarkdown != null)
        'full_content_markdown': fullContentMarkdown,
      if (fullContentPlain != null) 'full_content_plain': fullContentPlain,
      if (contentHash != null) 'content_hash': contentHash,
      if (observedAt != null) 'observed_at': observedAt,
      if (observedCount != null) 'observed_count': observedCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.HistoryCompanion copyWith({
    i0.Value<String>? urlCanonical,
    i0.Value<String>? urlHost,
    i0.Value<String?>? urlPath,
    i0.Value<String?>? title,
    i0.Value<bool?>? isProbablyReaderable,
    i0.Value<String?>? extractedContentMarkdown,
    i0.Value<String?>? extractedContentPlain,
    i0.Value<String?>? fullContentMarkdown,
    i0.Value<String?>? fullContentPlain,
    i0.Value<int?>? contentHash,
    i0.Value<DateTime>? observedAt,
    i0.Value<int>? observedCount,
    i0.Value<int>? rowid,
  }) {
    return i3.HistoryCompanion(
      urlCanonical: urlCanonical ?? this.urlCanonical,
      urlHost: urlHost ?? this.urlHost,
      urlPath: urlPath ?? this.urlPath,
      title: title ?? this.title,
      isProbablyReaderable: isProbablyReaderable ?? this.isProbablyReaderable,
      extractedContentMarkdown:
          extractedContentMarkdown ?? this.extractedContentMarkdown,
      extractedContentPlain:
          extractedContentPlain ?? this.extractedContentPlain,
      fullContentMarkdown: fullContentMarkdown ?? this.fullContentMarkdown,
      fullContentPlain: fullContentPlain ?? this.fullContentPlain,
      contentHash: contentHash ?? this.contentHash,
      observedAt: observedAt ?? this.observedAt,
      observedCount: observedCount ?? this.observedCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (urlCanonical.present) {
      map['url_canonical'] = i0.Variable<String>(urlCanonical.value);
    }
    if (urlHost.present) {
      map['url_host'] = i0.Variable<String>(urlHost.value);
    }
    if (urlPath.present) {
      map['url_path'] = i0.Variable<String>(urlPath.value);
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (isProbablyReaderable.present) {
      map['is_probably_readerable'] = i0.Variable<bool>(
        isProbablyReaderable.value,
      );
    }
    if (extractedContentMarkdown.present) {
      map['extracted_content_markdown'] = i0.Variable<String>(
        extractedContentMarkdown.value,
      );
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentMarkdown.present) {
      map['full_content_markdown'] = i0.Variable<String>(
        fullContentMarkdown.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain.value);
    }
    if (contentHash.present) {
      map['content_hash'] = i0.Variable<int>(contentHash.value);
    }
    if (observedAt.present) {
      map['observed_at'] = i0.Variable<DateTime>(observedAt.value);
    }
    if (observedCount.present) {
      map['observed_count'] = i0.Variable<int>(observedCount.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('urlCanonical: $urlCanonical, ')
          ..write('urlHost: $urlHost, ')
          ..write('urlPath: $urlPath, ')
          ..write('title: $title, ')
          ..write('isProbablyReaderable: $isProbablyReaderable, ')
          ..write('extractedContentMarkdown: $extractedContentMarkdown, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentMarkdown: $fullContentMarkdown, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('contentHash: $contentHash, ')
          ..write('observedAt: $observedAt, ')
          ..write('observedCount: $observedCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxHistoryHost => i0.Index(
  'idx_history_host',
  'CREATE INDEX idx_history_host ON history (url_host)',
);
i0.Index get idxHistoryObserved => i0.Index(
  'idx_history_observed',
  'CREATE INDEX idx_history_observed ON history (observed_at DESC)',
);

class HistoryFts extends i0.Table
    with
        i0.TableInfo<HistoryFts, i3.HistoryFt>,
        i0.VirtualTableInfo<HistoryFts, i3.HistoryFt> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  HistoryFts(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> urlHost = i0.GeneratedColumn<String>(
    'url_host',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> urlPath = i0.GeneratedColumn<String>(
    'url_path',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> extractedContentPlain =
      i0.GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentPlain =
      i0.GeneratedColumn<String>(
        'full_content_plain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    title,
    urlHost,
    urlPath,
    extractedContentPlain,
    fullContentPlain,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_fts';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i3.HistoryFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.HistoryFt(
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      urlHost: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_host'],
      )!,
      urlPath: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_path'],
      )!,
      extractedContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      )!,
      fullContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_plain'],
      )!,
    );
  }

  @override
  HistoryFts createAlias(String alias) {
    return HistoryFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, url_host, url_path, extracted_content_plain, full_content_plain, content=history, tokenize="trigram")';
}

class HistoryFt extends i0.DataClass implements i0.Insertable<i3.HistoryFt> {
  final String title;
  final String urlHost;
  final String urlPath;
  final String extractedContentPlain;
  final String fullContentPlain;
  const HistoryFt({
    required this.title,
    required this.urlHost,
    required this.urlPath,
    required this.extractedContentPlain,
    required this.fullContentPlain,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['title'] = i0.Variable<String>(title);
    map['url_host'] = i0.Variable<String>(urlHost);
    map['url_path'] = i0.Variable<String>(urlPath);
    map['extracted_content_plain'] = i0.Variable<String>(extractedContentPlain);
    map['full_content_plain'] = i0.Variable<String>(fullContentPlain);
    return map;
  }

  factory HistoryFt.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return HistoryFt(
      title: serializer.fromJson<String>(json['title']),
      urlHost: serializer.fromJson<String>(json['url_host']),
      urlPath: serializer.fromJson<String>(json['url_path']),
      extractedContentPlain: serializer.fromJson<String>(
        json['extracted_content_plain'],
      ),
      fullContentPlain: serializer.fromJson<String>(json['full_content_plain']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'url_host': serializer.toJson<String>(urlHost),
      'url_path': serializer.toJson<String>(urlPath),
      'extracted_content_plain': serializer.toJson<String>(
        extractedContentPlain,
      ),
      'full_content_plain': serializer.toJson<String>(fullContentPlain),
    };
  }

  i3.HistoryFt copyWith({
    String? title,
    String? urlHost,
    String? urlPath,
    String? extractedContentPlain,
    String? fullContentPlain,
  }) => i3.HistoryFt(
    title: title ?? this.title,
    urlHost: urlHost ?? this.urlHost,
    urlPath: urlPath ?? this.urlPath,
    extractedContentPlain: extractedContentPlain ?? this.extractedContentPlain,
    fullContentPlain: fullContentPlain ?? this.fullContentPlain,
  );
  HistoryFt copyWithCompanion(i3.HistoryFtsCompanion data) {
    return HistoryFt(
      title: data.title.present ? data.title.value : this.title,
      urlHost: data.urlHost.present ? data.urlHost.value : this.urlHost,
      urlPath: data.urlPath.present ? data.urlPath.value : this.urlPath,
      extractedContentPlain: data.extractedContentPlain.present
          ? data.extractedContentPlain.value
          : this.extractedContentPlain,
      fullContentPlain: data.fullContentPlain.present
          ? data.fullContentPlain.value
          : this.fullContentPlain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryFt(')
          ..write('title: $title, ')
          ..write('urlHost: $urlHost, ')
          ..write('urlPath: $urlPath, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentPlain: $fullContentPlain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    title,
    urlHost,
    urlPath,
    extractedContentPlain,
    fullContentPlain,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.HistoryFt &&
          other.title == this.title &&
          other.urlHost == this.urlHost &&
          other.urlPath == this.urlPath &&
          other.extractedContentPlain == this.extractedContentPlain &&
          other.fullContentPlain == this.fullContentPlain);
}

class HistoryFtsCompanion extends i0.UpdateCompanion<i3.HistoryFt> {
  final i0.Value<String> title;
  final i0.Value<String> urlHost;
  final i0.Value<String> urlPath;
  final i0.Value<String> extractedContentPlain;
  final i0.Value<String> fullContentPlain;
  final i0.Value<int> rowid;
  const HistoryFtsCompanion({
    this.title = const i0.Value.absent(),
    this.urlHost = const i0.Value.absent(),
    this.urlPath = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  HistoryFtsCompanion.insert({
    required String title,
    required String urlHost,
    required String urlPath,
    required String extractedContentPlain,
    required String fullContentPlain,
    this.rowid = const i0.Value.absent(),
  }) : title = i0.Value(title),
       urlHost = i0.Value(urlHost),
       urlPath = i0.Value(urlPath),
       extractedContentPlain = i0.Value(extractedContentPlain),
       fullContentPlain = i0.Value(fullContentPlain);
  static i0.Insertable<i3.HistoryFt> custom({
    i0.Expression<String>? title,
    i0.Expression<String>? urlHost,
    i0.Expression<String>? urlPath,
    i0.Expression<String>? extractedContentPlain,
    i0.Expression<String>? fullContentPlain,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (title != null) 'title': title,
      if (urlHost != null) 'url_host': urlHost,
      if (urlPath != null) 'url_path': urlPath,
      if (extractedContentPlain != null)
        'extracted_content_plain': extractedContentPlain,
      if (fullContentPlain != null) 'full_content_plain': fullContentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.HistoryFtsCompanion copyWith({
    i0.Value<String>? title,
    i0.Value<String>? urlHost,
    i0.Value<String>? urlPath,
    i0.Value<String>? extractedContentPlain,
    i0.Value<String>? fullContentPlain,
    i0.Value<int>? rowid,
  }) {
    return i3.HistoryFtsCompanion(
      title: title ?? this.title,
      urlHost: urlHost ?? this.urlHost,
      urlPath: urlPath ?? this.urlPath,
      extractedContentPlain:
          extractedContentPlain ?? this.extractedContentPlain,
      fullContentPlain: fullContentPlain ?? this.fullContentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (urlHost.present) {
      map['url_host'] = i0.Variable<String>(urlHost.value);
    }
    if (urlPath.present) {
      map['url_path'] = i0.Variable<String>(urlPath.value);
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryFtsCompanion(')
          ..write('title: $title, ')
          ..write('urlHost: $urlHost, ')
          ..write('urlPath: $urlPath, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Trigger get historyAfterInsert => i0.Trigger(
  'CREATE TRIGGER history_after_insert AFTER INSERT ON history BEGIN INSERT INTO history_fts ("rowid", title, url_host, url_path, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url_host, new.url_path, new.extracted_content_plain, new.full_content_plain);END',
  'history_after_insert',
);
i0.Trigger get historyAfterDelete => i0.Trigger(
  'CREATE TRIGGER history_after_delete AFTER DELETE ON history BEGIN INSERT INTO history_fts (history_fts, "rowid", title, url_host, url_path, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url_host, old.url_path, old.extracted_content_plain, old.full_content_plain);END',
  'history_after_delete',
);
i0.Trigger get historyAfterUpdate => i0.Trigger(
  'CREATE TRIGGER history_after_update AFTER UPDATE OF title, url_host, url_path, extracted_content_plain, full_content_plain ON history BEGIN INSERT INTO history_fts (history_fts, "rowid", title, url_host, url_path, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url_host, old.url_path, old.extracted_content_plain, old.full_content_plain);INSERT INTO history_fts ("rowid", title, url_host, url_path, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url_host, new.url_path, new.extracted_content_plain, new.full_content_plain);END',
  'history_after_update',
);
i0.Trigger get tabToHistoryOnInsert => i0.Trigger(
  'CREATE TRIGGER tab_to_history_on_insert AFTER INSERT ON tab WHEN NEW.url IS NOT NULL AND url_indexable(CAST(NEW.url AS TEXT)) = 1 AND (SELECT value FROM local_index_setting WHERE "key" = \'enabled\') = 1 AND(NEW.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = NEW.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)) BEGIN INSERT INTO history (url_canonical, url_host, url_path, title, is_probably_readerable, extracted_content_markdown, extracted_content_plain, full_content_markdown, full_content_plain, content_hash, observed_at, observed_count) VALUES (url_canonical(CAST(NEW.url AS TEXT)), url_host(CAST(NEW.url AS TEXT)), url_path(CAST(NEW.url AS TEXT)), NEW.title, NEW.is_probably_readerable, NEW.extracted_content_markdown, NEW.extracted_content_plain, NEW.full_content_markdown, NEW.full_content_plain, NEW.content_hash, strftime(\'%s\', \'now\') * 1000, 1) ON CONFLICT (url_canonical) DO UPDATE SET title = COALESCE(excluded.title, history.title), is_probably_readerable = excluded.is_probably_readerable, extracted_content_markdown = excluded.extracted_content_markdown, extracted_content_plain = excluded.extracted_content_plain, full_content_markdown = excluded.full_content_markdown, full_content_plain = excluded.full_content_plain, content_hash = excluded.content_hash, observed_at = excluded.observed_at, observed_count = history.observed_count + 1 WHERE history.content_hash IS NOT excluded.content_hash;END',
  'tab_to_history_on_insert',
);
i0.Trigger get tabToHistoryOnUpdate => i0.Trigger(
  'CREATE TRIGGER tab_to_history_on_update AFTER UPDATE OF title, url, extracted_content_plain, extracted_content_markdown, full_content_plain, full_content_markdown, is_probably_readerable ON tab WHEN NEW.url IS NOT NULL AND url_indexable(CAST(NEW.url AS TEXT)) = 1 AND(OLD.content_hash IS NOT NEW.content_hash OR OLD.url IS NOT NEW.url)AND (SELECT value FROM local_index_setting WHERE "key" = \'enabled\') = 1 AND(NEW.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = NEW.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)) BEGIN INSERT INTO history (url_canonical, url_host, url_path, title, is_probably_readerable, extracted_content_markdown, extracted_content_plain, full_content_markdown, full_content_plain, content_hash, observed_at, observed_count) VALUES (url_canonical(CAST(NEW.url AS TEXT)), url_host(CAST(NEW.url AS TEXT)), url_path(CAST(NEW.url AS TEXT)), NEW.title, NEW.is_probably_readerable, NEW.extracted_content_markdown, NEW.extracted_content_plain, NEW.full_content_markdown, NEW.full_content_plain, NEW.content_hash, strftime(\'%s\', \'now\') * 1000, 1) ON CONFLICT (url_canonical) DO UPDATE SET title = COALESCE(excluded.title, history.title), is_probably_readerable = excluded.is_probably_readerable, extracted_content_markdown = excluded.extracted_content_markdown, extracted_content_plain = excluded.extracted_content_plain, full_content_markdown = excluded.full_content_markdown, full_content_plain = excluded.full_content_plain, content_hash = excluded.content_hash, observed_at = excluded.observed_at, observed_count = history.observed_count + 1 WHERE history.content_hash IS NOT excluded.content_hash;END',
  'tab_to_history_on_update',
);
i0.Trigger get tabToHistoryOnContainerUpdate => i0.Trigger(
  'CREATE TRIGGER tab_to_history_on_container_update AFTER UPDATE OF container_id ON tab WHEN NEW.url IS NOT NULL AND url_indexable(CAST(NEW.url AS TEXT)) = 1 AND (SELECT value FROM local_index_setting WHERE "key" = \'enabled\') = 1 BEGIN DELETE FROM history WHERE url_canonical = url_canonical(CAST(NEW.url AS TEXT)) AND NOT EXISTS (SELECT 1 FROM tab AS candidate WHERE candidate.url IS NOT NULL AND url_indexable(CAST(candidate.url AS TEXT)) = 1 AND url_canonical(CAST(candidate.url AS TEXT)) = history.url_canonical AND(candidate.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = candidate.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)));INSERT INTO history (url_canonical, url_host, url_path, title, is_probably_readerable, extracted_content_markdown, extracted_content_plain, full_content_markdown, full_content_plain, content_hash, observed_at, observed_count) SELECT url_canonical(CAST(candidate.url AS TEXT)), url_host(CAST(candidate.url AS TEXT)), url_path(CAST(candidate.url AS TEXT)), candidate.title, candidate.is_probably_readerable, candidate.extracted_content_markdown, candidate.extracted_content_plain, candidate.full_content_markdown, candidate.full_content_plain, candidate.content_hash, strftime(\'%s\', \'now\') * 1000, 1 FROM tab AS candidate WHERE candidate.url IS NOT NULL AND url_indexable(CAST(candidate.url AS TEXT)) = 1 AND url_canonical(CAST(candidate.url AS TEXT)) = url_canonical(CAST(NEW.url AS TEXT)) AND(candidate.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = candidate.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)) ORDER BY candidate.timestamp DESC, candidate."rowid" DESC LIMIT 1 ON CONFLICT (url_canonical) DO UPDATE SET title = COALESCE(excluded.title, history.title), is_probably_readerable = excluded.is_probably_readerable, extracted_content_markdown = excluded.extracted_content_markdown, extracted_content_plain = excluded.extracted_content_plain, full_content_markdown = excluded.full_content_markdown, full_content_plain = excluded.full_content_plain, content_hash = excluded.content_hash, observed_at = excluded.observed_at, observed_count = history.observed_count + 1;END',
  'tab_to_history_on_container_update',
);
i0.Trigger get containerToHistoryOnMetadataUpdate => i0.Trigger(
  'CREATE TRIGGER container_to_history_on_metadata_update AFTER UPDATE OF metadata ON container WHEN COALESCE(json_extract(OLD.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(OLD.metadata, \'\$.excludeFromHistory\') = 1, 0) != COALESCE(json_extract(NEW.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(NEW.metadata, \'\$.excludeFromHistory\') = 1, 0) AND (SELECT value FROM local_index_setting WHERE "key" = \'enabled\') = 1 BEGIN DELETE FROM history WHERE url_canonical IN (SELECT DISTINCT url_canonical(CAST(affected.url AS TEXT)) FROM tab AS affected WHERE affected.container_id = NEW.id AND affected.url IS NOT NULL AND url_indexable(CAST(affected.url AS TEXT)) = 1) AND NOT EXISTS (SELECT 1 FROM tab AS candidate WHERE candidate.url IS NOT NULL AND url_indexable(CAST(candidate.url AS TEXT)) = 1 AND url_canonical(CAST(candidate.url AS TEXT)) = history.url_canonical AND(candidate.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = candidate.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)));INSERT INTO history (url_canonical, url_host, url_path, title, is_probably_readerable, extracted_content_markdown, extracted_content_plain, full_content_markdown, full_content_plain, content_hash, observed_at, observed_count) SELECT url_canonical(CAST(candidate.url AS TEXT)), url_host(CAST(candidate.url AS TEXT)), url_path(CAST(candidate.url AS TEXT)), candidate.title, candidate.is_probably_readerable, candidate.extracted_content_markdown, candidate.extracted_content_plain, candidate.full_content_markdown, candidate.full_content_plain, candidate.content_hash, strftime(\'%s\', \'now\') * 1000, 1 FROM tab AS candidate WHERE candidate.url IS NOT NULL AND url_indexable(CAST(candidate.url AS TEXT)) = 1 AND url_canonical(CAST(candidate.url AS TEXT)) IN (SELECT DISTINCT url_canonical(CAST(affected.url AS TEXT)) FROM tab AS affected WHERE affected.container_id = NEW.id AND affected.url IS NOT NULL AND url_indexable(CAST(affected.url AS TEXT)) = 1) AND(candidate.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = candidate.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)) AND NOT EXISTS (SELECT 1 FROM tab AS newer WHERE newer.url IS NOT NULL AND url_indexable(CAST(newer.url AS TEXT)) = 1 AND url_canonical(CAST(newer.url AS TEXT)) = url_canonical(CAST(candidate.url AS TEXT)) AND(newer.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = newer.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)) AND(newer.timestamp > candidate.timestamp OR(newer.timestamp = candidate.timestamp AND newer."rowid" > candidate."rowid"))) ON CONFLICT (url_canonical) DO UPDATE SET title = COALESCE(excluded.title, history.title), is_probably_readerable = excluded.is_probably_readerable, extracted_content_markdown = excluded.extracted_content_markdown, extracted_content_plain = excluded.extracted_content_plain, full_content_markdown = excluded.full_content_markdown, full_content_plain = excluded.full_content_plain, content_hash = excluded.content_hash, observed_at = excluded.observed_at, observed_count = history.observed_count + 1;END',
  'container_to_history_on_metadata_update',
);

class VisitContainer extends i0.Table
    with i0.TableInfo<VisitContainer, i3.VisitContainerData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  VisitContainer(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final i0.GeneratedColumn<String> rawUrl = i0.GeneratedColumn<String>(
    'raw_url',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> urlCanonical =
      i0.GeneratedColumn<String>(
        'url_canonical',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<int> visitTime = i0.GeneratedColumn<int>(
    'visit_time',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> containerId =
      i0.GeneratedColumn<String>(
        'container_id',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL REFERENCES container(id)ON DELETE CASCADE',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    rawUrl,
    urlCanonical,
    visitTime,
    containerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_container';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i3.VisitContainerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.VisitContainerData(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawUrl: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}raw_url'],
      )!,
      urlCanonical: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_canonical'],
      )!,
      visitTime: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}visit_time'],
      )!,
      containerId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}container_id'],
      )!,
    );
  }

  @override
  VisitContainer createAlias(String alias) {
    return VisitContainer(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class VisitContainerData extends i0.DataClass
    implements i0.Insertable<i3.VisitContainerData> {
  final int id;

  /// Original visited URL; used to open the page and as the key for the Places
  /// delete mirror (Places keys visits by URL + time).
  final String rawUrl;

  /// Structural canonical form; the join key to Places visits (computed in Dart
  /// via canonicalizeUrl so it matches the local index's canonicalization).
  final String urlCanonical;

  /// Epoch MILLISECONDS (plain INTEGER, not a drift DATETIME which stores
  /// seconds). Matches Places `VisitInfo.visitTime`.
  final int visitTime;
  final String containerId;
  const VisitContainerData({
    required this.id,
    required this.rawUrl,
    required this.urlCanonical,
    required this.visitTime,
    required this.containerId,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<int>(id);
    map['raw_url'] = i0.Variable<String>(rawUrl);
    map['url_canonical'] = i0.Variable<String>(urlCanonical);
    map['visit_time'] = i0.Variable<int>(visitTime);
    map['container_id'] = i0.Variable<String>(containerId);
    return map;
  }

  factory VisitContainerData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return VisitContainerData(
      id: serializer.fromJson<int>(json['id']),
      rawUrl: serializer.fromJson<String>(json['raw_url']),
      urlCanonical: serializer.fromJson<String>(json['url_canonical']),
      visitTime: serializer.fromJson<int>(json['visit_time']),
      containerId: serializer.fromJson<String>(json['container_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'raw_url': serializer.toJson<String>(rawUrl),
      'url_canonical': serializer.toJson<String>(urlCanonical),
      'visit_time': serializer.toJson<int>(visitTime),
      'container_id': serializer.toJson<String>(containerId),
    };
  }

  i3.VisitContainerData copyWith({
    int? id,
    String? rawUrl,
    String? urlCanonical,
    int? visitTime,
    String? containerId,
  }) => i3.VisitContainerData(
    id: id ?? this.id,
    rawUrl: rawUrl ?? this.rawUrl,
    urlCanonical: urlCanonical ?? this.urlCanonical,
    visitTime: visitTime ?? this.visitTime,
    containerId: containerId ?? this.containerId,
  );
  VisitContainerData copyWithCompanion(i3.VisitContainerCompanion data) {
    return VisitContainerData(
      id: data.id.present ? data.id.value : this.id,
      rawUrl: data.rawUrl.present ? data.rawUrl.value : this.rawUrl,
      urlCanonical: data.urlCanonical.present
          ? data.urlCanonical.value
          : this.urlCanonical,
      visitTime: data.visitTime.present ? data.visitTime.value : this.visitTime,
      containerId: data.containerId.present
          ? data.containerId.value
          : this.containerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitContainerData(')
          ..write('id: $id, ')
          ..write('rawUrl: $rawUrl, ')
          ..write('urlCanonical: $urlCanonical, ')
          ..write('visitTime: $visitTime, ')
          ..write('containerId: $containerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rawUrl, urlCanonical, visitTime, containerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.VisitContainerData &&
          other.id == this.id &&
          other.rawUrl == this.rawUrl &&
          other.urlCanonical == this.urlCanonical &&
          other.visitTime == this.visitTime &&
          other.containerId == this.containerId);
}

class VisitContainerCompanion
    extends i0.UpdateCompanion<i3.VisitContainerData> {
  final i0.Value<int> id;
  final i0.Value<String> rawUrl;
  final i0.Value<String> urlCanonical;
  final i0.Value<int> visitTime;
  final i0.Value<String> containerId;
  const VisitContainerCompanion({
    this.id = const i0.Value.absent(),
    this.rawUrl = const i0.Value.absent(),
    this.urlCanonical = const i0.Value.absent(),
    this.visitTime = const i0.Value.absent(),
    this.containerId = const i0.Value.absent(),
  });
  VisitContainerCompanion.insert({
    this.id = const i0.Value.absent(),
    required String rawUrl,
    required String urlCanonical,
    required int visitTime,
    required String containerId,
  }) : rawUrl = i0.Value(rawUrl),
       urlCanonical = i0.Value(urlCanonical),
       visitTime = i0.Value(visitTime),
       containerId = i0.Value(containerId);
  static i0.Insertable<i3.VisitContainerData> custom({
    i0.Expression<int>? id,
    i0.Expression<String>? rawUrl,
    i0.Expression<String>? urlCanonical,
    i0.Expression<int>? visitTime,
    i0.Expression<String>? containerId,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawUrl != null) 'raw_url': rawUrl,
      if (urlCanonical != null) 'url_canonical': urlCanonical,
      if (visitTime != null) 'visit_time': visitTime,
      if (containerId != null) 'container_id': containerId,
    });
  }

  i3.VisitContainerCompanion copyWith({
    i0.Value<int>? id,
    i0.Value<String>? rawUrl,
    i0.Value<String>? urlCanonical,
    i0.Value<int>? visitTime,
    i0.Value<String>? containerId,
  }) {
    return i3.VisitContainerCompanion(
      id: id ?? this.id,
      rawUrl: rawUrl ?? this.rawUrl,
      urlCanonical: urlCanonical ?? this.urlCanonical,
      visitTime: visitTime ?? this.visitTime,
      containerId: containerId ?? this.containerId,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (rawUrl.present) {
      map['raw_url'] = i0.Variable<String>(rawUrl.value);
    }
    if (urlCanonical.present) {
      map['url_canonical'] = i0.Variable<String>(urlCanonical.value);
    }
    if (visitTime.present) {
      map['visit_time'] = i0.Variable<int>(visitTime.value);
    }
    if (containerId.present) {
      map['container_id'] = i0.Variable<String>(containerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitContainerCompanion(')
          ..write('id: $id, ')
          ..write('rawUrl: $rawUrl, ')
          ..write('urlCanonical: $urlCanonical, ')
          ..write('visitTime: $visitTime, ')
          ..write('containerId: $containerId')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxVcCanonical => i0.Index(
  'idx_vc_canonical',
  'CREATE INDEX idx_vc_canonical ON visit_container (url_canonical, visit_time)',
);
i0.Index get idxVcContainer => i0.Index(
  'idx_vc_container',
  'CREATE INDEX idx_vc_container ON visit_container (container_id, visit_time DESC)',
);

class DefinitionsDrift extends i9.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO tab_fts (tab_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {tabFts},
    );
  }

  Future<int> optimizeHistoryFtsIndex() {
    return customInsert(
      'INSERT INTO history_fts (history_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {historyFts},
    );
  }

  i0.Selectable<i10.HistoryQueryResult> queryHistoryFullContent({
    required String beforeMatch,
    required String afterMatch,
    required String ellipsis,
    required int snippetLength,
    required String query,
    required int limit,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 8.0 AS host_weight, 2.0 AS path_weight, 3.0 AS extracted_weight, 1.0 AS full_weight) SELECT h.url_canonical, h.url_host, h.url_path, highlight(history_fts, 0, ?1, ?2) AS title, snippet(history_fts, 3, ?1, ?2, ?3, ?4) AS extracted_content, snippet(history_fts, 4, ?1, ?2, ?3, ?4) AS full_content, h.observed_at, bm25(history_fts, weights.title_weight, weights.host_weight, weights.path_weight, weights.extracted_weight, weights.full_weight) AS weighted_rank FROM history_fts(?5)AS fts INNER JOIN history AS h ON h."rowid" = fts."rowid" CROSS JOIN weights ORDER BY weighted_rank ASC, h.observed_at DESC LIMIT ?6',
      variables: [
        i0.Variable<String>(beforeMatch),
        i0.Variable<String>(afterMatch),
        i0.Variable<String>(ellipsis),
        i0.Variable<int>(snippetLength),
        i0.Variable<String>(query),
        i0.Variable<int>(limit),
      ],
      readsFrom: {history, historyFts},
    ).map(
      (i0.QueryRow row) => i10.HistoryQueryResult(
        urlCanonical: row.read<String>('url_canonical'),
        urlHost: row.read<String>('url_host'),
        urlPath: row.readNullable<String>('url_path'),
        title: row.readNullable<String>('title'),
        extractedContent: row.readNullable<String>('extracted_content'),
        fullContent: row.readNullable<String>('full_content'),
        weightedRank: row.read<double>('weighted_rank'),
        observedAt: row.read<DateTime>('observed_at'),
      ),
    );
  }

  i0.Selectable<i10.HistoryQueryResult> queryHistoryByHostPrefix({
    required String hostPrefix,
    required int limit,
  }) {
    return customSelect(
      'SELECT h.url_canonical, h.url_host, h.url_path, h.title, NULL AS extracted_content, NULL AS full_content, h.observed_at, 0.0 AS weighted_rank FROM history AS h WHERE h.url_host LIKE ?1 ORDER BY h.observed_at DESC LIMIT ?2',
      variables: [i0.Variable<String>(hostPrefix), i0.Variable<int>(limit)],
      readsFrom: {history},
    ).map(
      (i0.QueryRow row) => i10.HistoryQueryResult(
        urlCanonical: row.read<String>('url_canonical'),
        urlHost: row.read<String>('url_host'),
        urlPath: row.readNullable<String>('url_path'),
        title: row.readNullable<String>('title'),
        extractedContent: row.readNullable<String>('extracted_content'),
        fullContent: row.readNullable<String>('full_content'),
        weightedRank: row.read<double>('weighted_rank'),
        observedAt: row.read<DateTime>('observed_at'),
      ),
    );
  }

  i0.Selectable<i10.HistoryQueryResult> historyByCanonicalUrls({
    required List<String> canonicalUrls,
  }) {
    var $arrayStartIndex = 1;
    final expandedcanonicalUrls = $expandVar(
      $arrayStartIndex,
      canonicalUrls.length,
    );
    $arrayStartIndex += canonicalUrls.length;
    return customSelect(
      'SELECT h.url_canonical, h.url_host, h.url_path, h.title, NULL AS extracted_content, NULL AS full_content, h.observed_at, 0.0 AS weighted_rank FROM history AS h WHERE h.url_canonical IN ($expandedcanonicalUrls)',
      variables: [for (var $ in canonicalUrls) i0.Variable<String>($)],
      readsFrom: {history},
    ).map(
      (i0.QueryRow row) => i10.HistoryQueryResult(
        urlCanonical: row.read<String>('url_canonical'),
        urlHost: row.read<String>('url_host'),
        urlPath: row.readNullable<String>('url_path'),
        title: row.readNullable<String>('title'),
        extractedContent: row.readNullable<String>('extracted_content'),
        fullContent: row.readNullable<String>('full_content'),
        weightedRank: row.read<double>('weighted_rank'),
        observedAt: row.read<DateTime>('observed_at'),
      ),
    );
  }

  Future<int> upsertLocalIndexSetting({
    required String key,
    required int value,
  }) {
    return customInsert(
      'INSERT INTO local_index_setting ("key", value) VALUES (?1, ?2) ON CONFLICT ("key") DO UPDATE SET value = excluded.value',
      variables: [i0.Variable<String>(key), i0.Variable<int>(value)],
      updates: {localIndexSetting},
    );
  }

  i0.Selectable<int> countHistoryRows() {
    return customSelect(
      'SELECT COUNT(*) AS count FROM history',
      variables: [],
      readsFrom: {history},
    ).map((i0.QueryRow row) => row.read<int>('count'));
  }

  Future<int> clearHistory() {
    return customUpdate(
      'DELETE FROM history',
      variables: [],
      updates: {history},
      updateKind: i0.UpdateKind.delete,
    );
  }

  i0.Selectable<String> historyUrlsPage({
    required int limit,
    required int offset,
  }) {
    return customSelect(
      'SELECT url_canonical FROM history ORDER BY observed_at ASC, url_canonical ASC LIMIT ?1 OFFSET ?2',
      variables: [i0.Variable<int>(limit), i0.Variable<int>(offset)],
      readsFrom: {history},
    ).map((i0.QueryRow row) => row.read<String>('url_canonical'));
  }

  Future<int> deleteHistoryByCanonicalUrls({
    required List<String> canonicalUrls,
  }) {
    var $arrayStartIndex = 1;
    final expandedcanonicalUrls = $expandVar(
      $arrayStartIndex,
      canonicalUrls.length,
    );
    $arrayStartIndex += canonicalUrls.length;
    return customUpdate(
      'DELETE FROM history WHERE url_canonical IN ($expandedcanonicalUrls)',
      variables: [for (var $ in canonicalUrls) i0.Variable<String>($)],
      updates: {history},
      updateKind: i0.UpdateKind.delete,
    );
  }

  Future<int> evictExcludedHistoryPages() {
    return customUpdate(
      'DELETE FROM history WHERE url_canonical IN (SELECT DISTINCT url_canonical(CAST(affected.url AS TEXT)) FROM tab AS affected INNER JOIN container ON container.id = affected.container_id WHERE json_extract(container.metadata, \'\$.excludeFromHistory\') = 1 AND affected.url IS NOT NULL AND url_indexable(CAST(affected.url AS TEXT)) = 1) AND NOT EXISTS (SELECT 1 FROM tab AS candidate WHERE candidate.url IS NOT NULL AND url_indexable(CAST(candidate.url AS TEXT)) = 1 AND url_canonical(CAST(candidate.url AS TEXT)) = history.url_canonical AND(candidate.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = candidate.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)))',
      variables: [],
      updates: {history},
      updateKind: i0.UpdateKind.delete,
    );
  }

  Future<int> reindexAfterExcludedHistoryEviction() {
    return customInsert(
      'INSERT INTO history (url_canonical, url_host, url_path, title, is_probably_readerable, extracted_content_markdown, extracted_content_plain, full_content_markdown, full_content_plain, content_hash, observed_at, observed_count) SELECT url_canonical(CAST(candidate.url AS TEXT)), url_host(CAST(candidate.url AS TEXT)), url_path(CAST(candidate.url AS TEXT)), candidate.title, candidate.is_probably_readerable, candidate.extracted_content_markdown, candidate.extracted_content_plain, candidate.full_content_markdown, candidate.full_content_plain, candidate.content_hash, strftime(\'%s\', \'now\') * 1000, 1 FROM tab AS candidate WHERE (SELECT value FROM local_index_setting WHERE "key" = \'enabled\') = 1 AND candidate.url IS NOT NULL AND url_indexable(CAST(candidate.url AS TEXT)) = 1 AND url_canonical(CAST(candidate.url AS TEXT)) IN (SELECT DISTINCT url_canonical(CAST(affected.url AS TEXT)) FROM tab AS affected INNER JOIN container ON container.id = affected.container_id WHERE json_extract(container.metadata, \'\$.excludeFromHistory\') = 1 AND affected.url IS NOT NULL AND url_indexable(CAST(affected.url AS TEXT)) = 1) AND(candidate.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = candidate.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)) AND NOT EXISTS (SELECT 1 FROM tab AS newer WHERE newer.url IS NOT NULL AND url_indexable(CAST(newer.url AS TEXT)) = 1 AND url_canonical(CAST(newer.url AS TEXT)) = url_canonical(CAST(candidate.url AS TEXT)) AND(newer.tab_mode != 1 OR (SELECT value FROM local_index_setting WHERE "key" = \'index_private\') = 1)AND NOT EXISTS (SELECT 1 FROM container WHERE container.id = newer.container_id AND(json_extract(container.metadata, \'\$.excludeFromIndex\') = 1 OR json_extract(container.metadata, \'\$.excludeFromHistory\') = 1)) AND(newer.timestamp > candidate.timestamp OR(newer.timestamp = candidate.timestamp AND newer."rowid" > candidate."rowid"))) ON CONFLICT (url_canonical) DO UPDATE SET title = COALESCE(excluded.title, history.title), is_probably_readerable = excluded.is_probably_readerable, extracted_content_markdown = excluded.extracted_content_markdown, extracted_content_plain = excluded.extracted_content_plain, full_content_markdown = excluded.full_content_markdown, full_content_plain = excluded.full_content_plain, content_hash = excluded.content_hash, observed_at = excluded.observed_at, observed_count = history.observed_count + 1',
      variables: [],
      updates: {history},
    );
  }

  i0.Selectable<i1.ContainerDataWithCount> containersWithCount() {
    return customSelect(
      'SELECT container.*, tab_agg.tab_count FROM container LEFT JOIN (SELECT container_id, COUNT(*) AS tab_count, MAX(timestamp) AS last_updated FROM tab GROUP BY container_id) AS tab_agg ON container.id = tab_agg.container_id ORDER BY container.is_pinned DESC, container.order_key ASC',
      variables: [],
      readsFrom: {container, tab},
    ).map(
      (i0.QueryRow row) => i1.ContainerDataWithCount(
        id: row.read<String>('id'),
        name: row.readNullable<String>('name'),
        color: i3.Container.$convertercolor.fromSql(row.read<int>('color')),
        orderKey: row.read<String>('order_key'),
        isPinned: row.read<bool>('is_pinned'),
        metadata: i0.NullAwareTypeConverter.wrapFromSql(
          i3.Container.$convertermetadata,
          row.readNullable<String>('metadata'),
        ),
        tabCount: row.readNullable<int>('tab_count'),
      ),
    );
  }

  i0.Selectable<String> containerIdsByLastUpdated() {
    return customSelect(
      'SELECT container.id FROM container LEFT JOIN (SELECT container_id, MAX(timestamp) AS last_updated FROM tab GROUP BY container_id) AS tab_agg ON container.id = tab_agg.container_id ORDER BY tab_agg.last_updated DESC NULLS LAST, container."rowid" ASC',
      variables: [],
      readsFrom: {container, tab},
    ).map((i0.QueryRow row) => row.read<String>('id'));
  }

  i0.Selectable<String> leadingContainerOrderKey({
    required int bucket,
    required bool isPinned,
  }) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM container WHERE is_pinned = ?2 ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<bool>(isPinned)],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> trailingContainerOrderKey({
    required int bucket,
    required bool isPinned,
  }) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM container WHERE is_pinned = ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<bool>(isPinned)],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> containerOrderKeyAfter({
    required bool isPinned,
    required String containerId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM container WHERE is_pinned = ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
      variables: [
        i0.Variable<bool>(isPinned),
        i0.Variable<String>(containerId),
      ],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> containerOrderKeyBefore({
    required bool isPinned,
    required String containerId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LAG(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_order_key FROM container WHERE is_pinned = ?1) SELECT lexo_rank_reorder_before(order_key, prev_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
      variables: [
        i0.Variable<bool>(isPinned),
        i0.Variable<String>(containerId),
      ],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> leadingOrderKey({
    required int bucket,
    required String? containerId,
  }) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<String>(containerId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> trailingOrderKey({
    required int bucket,
    required String? containerId,
  }) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<String>(containerId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> lastChildTabId({
    required String parentId,
    required String? containerId,
  }) {
    return customSelect(
      'SELECT id FROM tab WHERE parent_id = ?1 AND container_id IS ?2 ORDER BY order_key DESC LIMIT 1',
      variables: [
        i0.Variable<String>(parentId),
        i0.Variable<String>(containerId),
      ],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('id'));
  }

  i0.Selectable<String> orderKeyAfterTab({
    required String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM tab WHERE container_id IS ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
      variables: [i0.Variable<String>(containerId), i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> orderKeyBeforeTab({
    required String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LAG(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_order_key FROM tab WHERE container_id IS ?1) SELECT lexo_rank_reorder_before(order_key, prev_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
      variables: [i0.Variable<String>(containerId), i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<i11.TabQueryResult> queryTabsBasic({
    required String query,
    required int limit,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight) SELECT t.id, t.container_id, t.tab_mode, t.title, CAST(t.url AS TEXT) AS url, t.url AS clean_url, bm25(tab_fts, weights.title_weight, weights.url_weight) AS weighted_rank FROM tab_fts AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights WHERE fts.title LIKE ?1 OR fts.url LIKE ?1 ORDER BY weighted_rank ASC, t.timestamp DESC LIMIT ?2',
      variables: [i0.Variable<String>(query), i0.Variable<int>(limit)],
      readsFrom: {tab, tabFts},
    ).map(
      (i0.QueryRow row) => i11.TabQueryResult(
        id: row.read<String>('id'),
        containerId: row.readNullable<String>('container_id'),
        tabMode: i3.Tab.$convertertabMode.fromSql(row.read<int>('tab_mode')),
        title: row.readNullable<String>('title'),
        url: row.readNullable<String>('url'),
        cleanUrl: i3.Tab.$converterurl.fromSql(
          row.readNullable<String>('clean_url'),
        ),
        weightedRank: row.read<double>('weighted_rank'),
      ),
    );
  }

  i0.Selectable<i11.TabQueryResult> queryTabsFullContent({
    required String beforeMatch,
    required String afterMatch,
    required String ellipsis,
    required int snippetLength,
    required String query,
    required int limit,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight, 3.0 AS extracted_weight, 1.0 AS full_weight) SELECT t.id, t.container_id, t.tab_mode, highlight(tab_fts, 0, ?1, ?2) AS title, highlight(tab_fts, 1, ?1, ?2) AS url, snippet(tab_fts, 2, ?1, ?2, ?3, ?4) AS extracted_content, snippet(tab_fts, 3, ?1, ?2, ?3, ?4) AS full_content, t.url AS clean_url,(bm25(tab_fts, weights.title_weight, weights.url_weight, weights.extracted_weight, weights.full_weight))AS weighted_rank FROM tab_fts(?5)AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights ORDER BY weighted_rank ASC, t.timestamp DESC LIMIT ?6',
      variables: [
        i0.Variable<String>(beforeMatch),
        i0.Variable<String>(afterMatch),
        i0.Variable<String>(ellipsis),
        i0.Variable<int>(snippetLength),
        i0.Variable<String>(query),
        i0.Variable<int>(limit),
      ],
      readsFrom: {tab, tabFts},
    ).map(
      (i0.QueryRow row) => i11.TabQueryResult(
        id: row.read<String>('id'),
        containerId: row.readNullable<String>('container_id'),
        tabMode: i3.Tab.$convertertabMode.fromSql(row.read<int>('tab_mode')),
        title: row.readNullable<String>('title'),
        url: row.readNullable<String>('url'),
        cleanUrl: i3.Tab.$converterurl.fromSql(
          row.readNullable<String>('clean_url'),
        ),
        extractedContent: row.readNullable<String>('extracted_content'),
        fullContent: row.readNullable<String>('full_content'),
        weightedRank: row.read<double>('weighted_rank'),
      ),
    );
  }

  i0.Selectable<TabTreesResult> tabTrees({
    required bool skipContainerCheck,
    required String? containerId,
  }) {
    return customSelect(
      'WITH RECURSIVE descendants AS (SELECT t.id, t.parent_id, t.timestamp, t.id AS root_id FROM tab AS t WHERE(?1 OR t.container_id IS ?2)AND(t.parent_id IS NULL OR NOT EXISTS (SELECT 1 AS _c0 FROM tab AS p WHERE p.id = t.parent_id AND(?1 OR p.container_id IS ?2)))UNION ALL SELECT t.id, t.parent_id, t.timestamp, d.root_id FROM tab AS t JOIN descendants AS d ON t.parent_id = d.id WHERE ?1 OR t.container_id IS ?2), root_stats AS (SELECT root_id, MAX(timestamp) AS max_timestamp, COUNT(*) AS total_children FROM descendants GROUP BY root_id) SELECT d.root_id AS root_tab_id, d.id AS latest_tab_id, d.timestamp AS latest_timestamp, rs.total_children AS total_tabs FROM descendants AS d JOIN root_stats AS rs ON d.root_id = rs.root_id AND d.timestamp = rs.max_timestamp ORDER BY d.timestamp DESC',
      variables: [
        i0.Variable<bool>(skipContainerCheck),
        i0.Variable<String>(containerId),
      ],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => TabTreesResult(
        rootTabId: row.read<String>('root_tab_id'),
        latestTabId: row.read<String>('latest_tab_id'),
        latestTimestamp: row.read<DateTime>('latest_timestamp'),
        totalTabs: row.read<int>('total_tabs'),
      ),
    );
  }

  i0.Selectable<TabsWithRootAndDepthResult> tabsWithRootAndDepth({
    required String? containerId,
  }) {
    return customSelect(
      'WITH RECURSIVE walk (id, parent_id, order_key, root_id, depth) AS (SELECT t.id, t.parent_id, t.order_key, t.id AS root_id, 0 AS depth FROM tab AS t WHERE t.container_id IS ?1 AND(t.parent_id IS NULL OR NOT EXISTS (SELECT 1 FROM tab AS p WHERE p.id = t.parent_id AND p.container_id IS ?1))UNION ALL SELECT t.id, t.parent_id, t.order_key, w.root_id, w.depth + 1 FROM tab AS t INNER JOIN walk AS w ON t.parent_id = w.id WHERE t.container_id IS ?1) SELECT id, parent_id, order_key, root_id, depth FROM walk',
      variables: [i0.Variable<String>(containerId)],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => TabsWithRootAndDepthResult(
        id: row.read<String>('id'),
        parentId: row.readNullable<String>('parent_id'),
        orderKey: row.read<String>('order_key'),
        rootId: row.read<String>('root_id'),
        depth: row.read<int>('depth'),
      ),
    );
  }

  i0.Selectable<String> lastSubtreeTabIdByOrderKey({
    required String tabId,
    required String? containerId,
  }) {
    return customSelect(
      'WITH RECURSIVE subtree AS (SELECT id, order_key FROM tab WHERE id = ?1 AND container_id IS ?2 UNION ALL SELECT t.id, t.order_key FROM tab AS t INNER JOIN subtree AS s ON t.parent_id = s.id WHERE t.container_id IS ?2) SELECT id FROM subtree ORDER BY order_key DESC LIMIT 1',
      variables: [i0.Variable<String>(tabId), i0.Variable<String>(containerId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('id'));
  }

  i0.Selectable<ContainerScopeSiblingsResult> containerScopeSiblings({
    required String? containerId,
    required String? parentId,
  }) {
    return customSelect(
      'SELECT t.id, t.order_key FROM tab AS t WHERE t.container_id IS ?1 AND(CASE WHEN EXISTS (SELECT 1 AS _c0 FROM tab AS p WHERE p.id = t.parent_id AND p.container_id IS t.container_id) THEN t.parent_id ELSE NULL END)IS ?2 ORDER BY t.order_key ASC',
      variables: [
        i0.Variable<String>(containerId),
        i0.Variable<String>(parentId),
      ],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => ContainerScopeSiblingsResult(
        id: row.read<String>('id'),
        orderKey: row.read<String>('order_key'),
      ),
    );
  }

  i0.Selectable<UnorderedTabDescendantsResult> unorderedTabDescendants({
    required String tabId,
  }) {
    return customSelect(
      'WITH RECURSIVE descendants AS (SELECT id, parent_id FROM tab WHERE id = ?1 UNION ALL SELECT t.id, t.parent_id FROM tab AS t JOIN descendants AS d ON t.parent_id = d.id) SELECT id, parent_id FROM descendants',
      variables: [i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => UnorderedTabDescendantsResult(
        id: row.read<String>('id'),
        parentId: row.readNullable<String>('parent_id'),
      ),
    );
  }

  i0.Selectable<UnorderedContainerTabDescendantsResult>
  unorderedContainerTabDescendants({required String tabId}) {
    return customSelect(
      'WITH RECURSIVE descendants AS (SELECT id, parent_id, container_id FROM tab WHERE id = ?1 UNION ALL SELECT t.id, t.parent_id, t.container_id FROM tab AS t JOIN descendants AS d ON t.parent_id = d.id WHERE t.container_id IS d.container_id) SELECT id, parent_id FROM descendants',
      variables: [i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => UnorderedContainerTabDescendantsResult(
        id: row.read<String>('id'),
        parentId: row.readNullable<String>('parent_id'),
      ),
    );
  }

  i0.Selectable<String?> previousTabByTimestamp({required String tabId}) {
    return customSelect(
      'WITH ranked_tabs AS (SELECT id, timestamp, LAG(id)OVER (ORDER BY timestamp RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_tab_id FROM tab) SELECT prev_tab_id FROM ranked_tabs WHERE id = ?1',
      variables: [i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.readNullable<String>('prev_tab_id'));
  }

  i0.Selectable<String?> previousTabByOrderKey({
    required bool skipContainerCheck,
    String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ranked_tabs AS (SELECT id, order_key, LAG(id)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_tab_id FROM tab WHERE ?1 OR container_id IS ?2) SELECT prev_tab_id FROM ranked_tabs WHERE id = ?3',
      variables: [
        i0.Variable<bool>(skipContainerCheck),
        i0.Variable<String>(containerId),
        i0.Variable<String>(tabId),
      ],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.readNullable<String>('prev_tab_id'));
  }

  i0.Selectable<String?> nextTabByOrderKey({
    required bool skipContainerCheck,
    String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ranked_tabs AS (SELECT id, order_key, LEAD(id)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_tab_id FROM tab WHERE ?1 OR container_id IS ?2) SELECT next_tab_id FROM ranked_tabs WHERE id = ?3',
      variables: [
        i0.Variable<bool>(skipContainerCheck),
        i0.Variable<String>(containerId),
        i0.Variable<String>(tabId),
      ],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.readNullable<String>('next_tab_id'));
  }

  i0.Selectable<bool> areSitesAvailable({
    required String uriList,
    required String ignoreContainerId,
  }) {
    return customSelect(
      'SELECT NOT EXISTS (SELECT 1 AS _c0 FROM container CROSS JOIN json_each(container.metadata, \'\$.assignedSites\')WHERE json_each.value IN (SELECT value FROM json_each(?1)) AND container.id IS NOT ?2) AS existing',
      variables: [
        i0.Variable<String>(uriList),
        i0.Variable<String>(ignoreContainerId),
      ],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<bool>('existing'));
  }

  i0.Selectable<i12.SiteAssignment> allAssignedSites() {
    return customSelect(
      'SELECT container.id, COALESCE(container.metadata ->> \'\$.contextualIdentity\', \'general\') AS contextualIdentity, value AS assigned_site FROM container CROSS JOIN json_each(container.metadata, \'\$.assignedSites\')WHERE value IS NOT NULL',
      variables: [],
      readsFrom: {container},
    ).map(
      (i0.QueryRow row) => i12.SiteAssignment(
        id: row.read<String>('id'),
        contextualIdentity: row.read<String>('contextualIdentity'),
        assignedSite: row.readNullable<String>('assigned_site'),
      ),
    );
  }

  i0.Selectable<i1.ContainerData> containerByContextualIdentity({
    required String contextId,
  }) {
    return customSelect(
      'SELECT * FROM container WHERE container.metadata ->> \'\$.contextualIdentity\' = ?1 LIMIT 1',
      variables: [i0.Variable<String>(contextId)],
      readsFrom: {container},
    ).asyncMap(container.mapFromRow);
  }

  i0.Selectable<ContainerIdsByContextualIdentitiesResult>
  containerIdsByContextualIdentities({required List<String> contextIds}) {
    var $arrayStartIndex = 1;
    final expandedcontextIds = $expandVar($arrayStartIndex, contextIds.length);
    $arrayStartIndex += contextIds.length;
    return customSelect(
      'SELECT id, CAST(container.metadata ->> \'\$.contextualIdentity\' AS TEXT) AS contextual_identity FROM container WHERE CAST(container.metadata ->> \'\$.contextualIdentity\' AS TEXT) IN ($expandedcontextIds)',
      variables: [for (var $ in contextIds) i0.Variable<String>($)],
      readsFrom: {container},
    ).map(
      (i0.QueryRow row) => ContainerIdsByContextualIdentitiesResult(
        id: row.read<String>('id'),
        contextualIdentity: row.read<String>('contextual_identity'),
      ),
    );
  }

  i0.Selectable<String?> containersToClearOnExit() {
    return customSelect(
      'SELECT container.metadata ->> \'\$.contextualIdentity\' AS contextual_identity FROM container WHERE json_extract(container.metadata, \'\$.clearDataOnExit\') = 1 AND container.metadata ->> \'\$.contextualIdentity\' IS NOT NULL',
      variables: [],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.readNullable<String>('contextual_identity'));
  }

  i0.Selectable<HistoryExclusionTabsResult> historyExclusionTabs() {
    return customSelect(
      'SELECT tab.id AS tab_id, tab.container_id AS container_id, COALESCE(json_extract(container.metadata, \'\$.excludeFromHistory\'), 0) AS excluded FROM tab LEFT JOIN container ON container.id = tab.container_id',
      variables: [],
      readsFrom: {tab, container},
    ).map(
      (i0.QueryRow row) => HistoryExclusionTabsResult(
        tabId: row.read<String>('tab_id'),
        containerId: row.readNullable<String>('container_id'),
        excluded: row.read<int>('excluded'),
      ),
    );
  }

  i0.Selectable<String?> excludedHistoryContextIds() {
    return customSelect(
      'SELECT container.metadata ->> \'\$.contextualIdentity\' AS context_id FROM container WHERE json_extract(container.metadata, \'\$.excludeFromHistory\') = 1 AND container.metadata ->> \'\$.contextualIdentity\' IS NOT NULL',
      variables: [],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.readNullable<String>('context_id'));
  }

  i0.Selectable<StrictContextAssignmentsResult> strictContextAssignments() {
    return customSelect(
      'SELECT container.metadata ->> \'\$.contextualIdentity\' AS context_id, container.metadata ->> \'\$.contextualIdentity\' AS assignment_context_id FROM container WHERE json_extract(container.metadata, \'\$.strictMode\') = 1 AND container.metadata ->> \'\$.contextualIdentity\' IS NOT NULL UNION SELECT DISTINCT t.isolation_context_id AS context_id, c.metadata ->> \'\$.contextualIdentity\' AS assignment_context_id FROM tab AS t INNER JOIN container AS c ON c.id = t.container_id WHERE t.tab_mode = 2 AND t.isolation_context_id IS NOT NULL AND json_extract(c.metadata, \'\$.strictMode\') = 1 AND c.metadata ->> \'\$.contextualIdentity\' IS NOT NULL',
      variables: [],
      readsFrom: {container, tab},
    ).map(
      (i0.QueryRow row) => StrictContextAssignmentsResult(
        contextId: row.readNullable<String>('context_id'),
        assignmentContextId: row.readNullable<String>('assignment_context_id'),
      ),
    );
  }

  i0.Selectable<int> tabsInIsolationGroup({String? contextId}) {
    return customSelect(
      'SELECT COUNT(*) AS count FROM tab WHERE isolation_context_id = ?1',
      variables: [i0.Variable<String>(contextId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<int>('count'));
  }

  i0.Selectable<String?> allIsolationContextIds() {
    return customSelect(
      'SELECT DISTINCT isolation_context_id FROM tab WHERE isolation_context_id IS NOT NULL',
      variables: [],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => row.readNullable<String>('isolation_context_id'),
    );
  }

  i0.Selectable<IsolatedContextContainerPairsResult>
  isolatedContextContainerPairs() {
    return customSelect(
      'SELECT DISTINCT t.isolation_context_id, t.container_id FROM tab AS t WHERE t.tab_mode = 2 AND t.isolation_context_id IS NOT NULL AND t.container_id IS NOT NULL',
      variables: [],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => IsolatedContextContainerPairsResult(
        isolationContextId: row.readNullable<String>('isolation_context_id'),
        containerId: row.readNullable<String>('container_id'),
      ),
    );
  }

  i3.TabFts get tabFts => i9.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.TabFts>('tab_fts');
  i3.HistoryFts get historyFts => i9.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.HistoryFts>('history_fts');
  i3.History get history => i9.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.History>('history');
  i3.LocalIndexSetting get localIndexSetting => i9.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.LocalIndexSetting>('local_index_setting');
  i3.Tab get tab =>
      i9.ReadDatabaseContainer(attachedDatabase).resultSet<i3.Tab>('tab');
  i3.Container get container => i9.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.Container>('container');
}

class TabTreesResult {
  final String rootTabId;
  final String latestTabId;
  final DateTime latestTimestamp;
  final int totalTabs;
  TabTreesResult({
    required this.rootTabId,
    required this.latestTabId,
    required this.latestTimestamp,
    required this.totalTabs,
  });
}

class TabsWithRootAndDepthResult {
  final String id;
  final String? parentId;
  final String orderKey;
  final String rootId;
  final int depth;
  TabsWithRootAndDepthResult({
    required this.id,
    this.parentId,
    required this.orderKey,
    required this.rootId,
    required this.depth,
  });
}

class ContainerScopeSiblingsResult {
  final String id;
  final String orderKey;
  ContainerScopeSiblingsResult({required this.id, required this.orderKey});
}

class UnorderedTabDescendantsResult {
  final String id;
  final String? parentId;
  UnorderedTabDescendantsResult({required this.id, this.parentId});
}

class UnorderedContainerTabDescendantsResult {
  final String id;
  final String? parentId;
  UnorderedContainerTabDescendantsResult({required this.id, this.parentId});
}

class ContainerIdsByContextualIdentitiesResult {
  final String id;
  final String contextualIdentity;
  ContainerIdsByContextualIdentitiesResult({
    required this.id,
    required this.contextualIdentity,
  });
}

class HistoryExclusionTabsResult {
  final String tabId;
  final String? containerId;
  final int excluded;
  HistoryExclusionTabsResult({
    required this.tabId,
    this.containerId,
    required this.excluded,
  });
}

class StrictContextAssignmentsResult {
  final String? contextId;
  final String? assignmentContextId;
  StrictContextAssignmentsResult({this.contextId, this.assignmentContextId});
}

class IsolatedContextContainerPairsResult {
  final String? isolationContextId;
  final String? containerId;
  IsolatedContextContainerPairsResult({
    this.isolationContextId,
    this.containerId,
  });
}
