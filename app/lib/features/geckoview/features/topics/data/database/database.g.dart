// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Topic extends Table with TableInfo<Topic, TopicData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Topic(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumnWithTypeConverter<Color, int> color =
      GeneratedColumn<int>('color', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Color>(Topic.$convertercolor);
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topic';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TopicData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      color: Topic.$convertercolor.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!),
    );
  }

  @override
  Topic createAlias(String alias) {
    return Topic(attachedDatabase, alias);
  }

  static TypeConverter<Color, int> $convertercolor = const ColorConverter();
  @override
  bool get dontWriteConstraints => true;
}

class TopicCompanion extends UpdateCompanion<TopicData> {
  final Value<String> id;
  final Value<String?> name;
  final Value<Color> color;
  final Value<int> rowid;
  const TopicCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required Color color,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        color = Value(color);
  static Insertable<TopicData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<Color>? color,
      Value<int>? rowid}) {
    return TopicCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(Topic.$convertercolor.toSql(color.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TabLink extends Table with TableInfo<TabLink, TabLinkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TabLink(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES topic(id)ON DELETE CASCADE');
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, topicId, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tab_link';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TabLinkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TabLinkData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  TabLink createAlias(String alias) {
    return TabLink(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TabLinkData extends DataClass implements Insertable<TabLinkData> {
  final String id;
  final String? topicId;
  final DateTime timestamp;
  const TabLinkData({required this.id, this.topicId, required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  factory TabLinkData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabLinkData(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String?>(json['topic_id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topic_id': serializer.toJson<String?>(topicId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TabLinkData copyWith(
          {String? id,
          Value<String?> topicId = const Value.absent(),
          DateTime? timestamp}) =>
      TabLinkData(
        id: id ?? this.id,
        topicId: topicId.present ? topicId.value : this.topicId,
        timestamp: timestamp ?? this.timestamp,
      );
  TabLinkData copyWithCompanion(TabLinkCompanion data) {
    return TabLinkData(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabLinkData(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, topicId, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TabLinkData &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.timestamp == this.timestamp);
}

class TabLinkCompanion extends UpdateCompanion<TabLinkData> {
  final Value<String> id;
  final Value<String?> topicId;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const TabLinkCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabLinkCompanion.insert({
    required String id,
    this.topicId = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        timestamp = Value(timestamp);
  static Insertable<TabLinkData> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabLinkCompanion copyWith(
      {Value<String>? id,
      Value<String?>? topicId,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return TabLinkCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabLinkCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TabDatabase extends GeneratedDatabase {
  _$TabDatabase(QueryExecutor e) : super(e);
  $TabDatabaseManager get managers => $TabDatabaseManager(this);
  late final Topic topic = Topic(this);
  late final TabLink tabLink = TabLink(this);
  late final TopicDao topicDao = TopicDao(this as TabDatabase);
  late final TabLinkDao tabLinkDao = TabLinkDao(this as TabDatabase);
  Selectable<TopicDataWithCount> topicsWithCount() {
    return customSelect(
        'SELECT topic.*, tab_agg.tab_count FROM topic LEFT JOIN (SELECT topic_id, COUNT(*) AS tab_count, MAX(timestamp) AS last_updated FROM tab_link GROUP BY topic_id) AS tab_agg ON topic.id = tab_agg.topic_id ORDER BY tab_agg.last_updated DESC NULLS FIRST',
        variables: [],
        readsFrom: {
          topic,
          tabLink,
        }).map((QueryRow row) => TopicDataWithCount(
          id: row.read<String>('id'),
          name: row.readNullable<String>('name'),
          color: Topic.$convertercolor.fromSql(row.read<int>('color')),
          tabCount: row.readNullable<int>('tab_count'),
        ));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [topic, tabLink];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('topic',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tab_link', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $TopicCreateCompanionBuilder = TopicCompanion Function({
  required String id,
  Value<String?> name,
  required Color color,
  Value<int> rowid,
});
typedef $TopicUpdateCompanionBuilder = TopicCompanion Function({
  Value<String> id,
  Value<String?> name,
  Value<Color> color,
  Value<int> rowid,
});

final class $TopicReferences
    extends BaseReferences<_$TabDatabase, Topic, TopicData> {
  $TopicReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<TabLink, List<TabLinkData>> _tabLinkRefsTable(
          _$TabDatabase db) =>
      MultiTypedResultKey.fromTable(db.tabLink,
          aliasName: $_aliasNameGenerator(db.topic.id, db.tabLink.topicId));

  $TabLinkProcessedTableManager get tabLinkRefs {
    final manager = $TabLinkTableManager($_db, $_db.tabLink)
        .filter((f) => f.topicId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tabLinkRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $TopicFilterComposer extends FilterComposer<_$TabDatabase, Topic> {
  $TopicFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Color, Color, int> get color =>
      $state.composableBuilder(
          column: $state.table.color,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ComposableFilter tabLinkRefs(
      ComposableFilter Function($TabLinkFilterComposer f) f) {
    final $TabLinkFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.tabLink,
        getReferencedColumn: (t) => t.topicId,
        builder: (joinBuilder, parentComposers) => $TabLinkFilterComposer(
            ComposerState(
                $state.db, $state.db.tabLink, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $TopicOrderingComposer extends OrderingComposer<_$TabDatabase, Topic> {
  $TopicOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $TopicTableManager extends RootTableManager<
    _$TabDatabase,
    Topic,
    TopicData,
    $TopicFilterComposer,
    $TopicOrderingComposer,
    $TopicCreateCompanionBuilder,
    $TopicUpdateCompanionBuilder,
    (TopicData, $TopicReferences),
    TopicData,
    PrefetchHooks Function({bool tabLinkRefs})> {
  $TopicTableManager(_$TabDatabase db, Topic table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $TopicFilterComposer(ComposerState(db, table)),
          orderingComposer: $TopicOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<Color> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicCompanion(
            id: id,
            name: name,
            color: color,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> name = const Value.absent(),
            required Color color,
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicCompanion.insert(
            id: id,
            name: name,
            color: color,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $TopicReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tabLinkRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tabLinkRefs) db.tabLink],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tabLinkRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $TopicReferences._tabLinkRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $TopicReferences(db, table, p0).tabLinkRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.topicId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $TopicProcessedTableManager = ProcessedTableManager<
    _$TabDatabase,
    Topic,
    TopicData,
    $TopicFilterComposer,
    $TopicOrderingComposer,
    $TopicCreateCompanionBuilder,
    $TopicUpdateCompanionBuilder,
    (TopicData, $TopicReferences),
    TopicData,
    PrefetchHooks Function({bool tabLinkRefs})>;
typedef $TabLinkCreateCompanionBuilder = TabLinkCompanion Function({
  required String id,
  Value<String?> topicId,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $TabLinkUpdateCompanionBuilder = TabLinkCompanion Function({
  Value<String> id,
  Value<String?> topicId,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

final class $TabLinkReferences
    extends BaseReferences<_$TabDatabase, TabLink, TabLinkData> {
  $TabLinkReferences(super.$_db, super.$_table, super.$_typedResult);

  static Topic _topicIdTable(_$TabDatabase db) => db.topic
      .createAlias($_aliasNameGenerator(db.tabLink.topicId, db.topic.id));

  $TopicProcessedTableManager? get topicId {
    if ($_item.topicId == null) return null;
    final manager = $TopicTableManager($_db, $_db.topic)
        .filter((f) => f.id($_item.topicId!));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $TabLinkFilterComposer extends FilterComposer<_$TabDatabase, TabLink> {
  $TabLinkFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $TopicFilterComposer get topicId {
    final $TopicFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $state.db.topic,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $TopicFilterComposer(
            ComposerState(
                $state.db, $state.db.topic, joinBuilder, parentComposers)));
    return composer;
  }
}

class $TabLinkOrderingComposer
    extends OrderingComposer<_$TabDatabase, TabLink> {
  $TabLinkOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $TopicOrderingComposer get topicId {
    final $TopicOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $state.db.topic,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $TopicOrderingComposer(
            ComposerState(
                $state.db, $state.db.topic, joinBuilder, parentComposers)));
    return composer;
  }
}

class $TabLinkTableManager extends RootTableManager<
    _$TabDatabase,
    TabLink,
    TabLinkData,
    $TabLinkFilterComposer,
    $TabLinkOrderingComposer,
    $TabLinkCreateCompanionBuilder,
    $TabLinkUpdateCompanionBuilder,
    (TabLinkData, $TabLinkReferences),
    TabLinkData,
    PrefetchHooks Function({bool topicId})> {
  $TabLinkTableManager(_$TabDatabase db, TabLink table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $TabLinkFilterComposer(ComposerState(db, table)),
          orderingComposer: $TabLinkOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TabLinkCompanion(
            id: id,
            topicId: topicId,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> topicId = const Value.absent(),
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              TabLinkCompanion.insert(
            id: id,
            topicId: topicId,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map(
                  (e) => (e.readTable(table), $TabLinkReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({topicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (topicId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.topicId,
                    referencedTable: $TabLinkReferences._topicIdTable(db),
                    referencedColumn: $TabLinkReferences._topicIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $TabLinkProcessedTableManager = ProcessedTableManager<
    _$TabDatabase,
    TabLink,
    TabLinkData,
    $TabLinkFilterComposer,
    $TabLinkOrderingComposer,
    $TabLinkCreateCompanionBuilder,
    $TabLinkUpdateCompanionBuilder,
    (TabLinkData, $TabLinkReferences),
    TabLinkData,
    PrefetchHooks Function({bool topicId})>;

class $TabDatabaseManager {
  final _$TabDatabase _db;
  $TabDatabaseManager(this._db);
  $TopicTableManager get topic => $TopicTableManager(_db, _db.topic);
  $TabLinkTableManager get tabLink => $TabLinkTableManager(_db, _db.tabLink);
}
