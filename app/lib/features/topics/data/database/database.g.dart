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

class TopicData extends DataClass implements Insertable<TopicData> {
  final String id;
  final String? name;
  final Color color;
  const TopicData({required this.id, this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    {
      map['color'] = Variable<int>(Topic.$convertercolor.toSql(color));
    }
    return map;
  }

  factory TopicData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      color: serializer.fromJson<Color>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'color': serializer.toJson<Color>(color),
    };
  }

  TopicData copyWith(
          {String? id,
          Value<String?> name = const Value.absent(),
          Color? color}) =>
      TopicData(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        color: color ?? this.color,
      );
  TopicData copyWithCompanion(TopicCompanion data) {
    return TopicData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicData &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
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

class Tab extends Table with TableInfo<Tab, TabData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tab(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<Uri, String> url =
      GeneratedColumn<String>('url', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Uri>(Tab.$converterurl);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<Uint8List> screenshot = GeneratedColumn<Uint8List>(
      'screenshot', aliasedName, true,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [id, topicId, timestamp, url, title, screenshot];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tab';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TabData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TabData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      url: Tab.$converterurl.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      screenshot: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}screenshot']),
    );
  }

  @override
  Tab createAlias(String alias) {
    return Tab(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converterurl = const UriConverter();
  @override
  bool get dontWriteConstraints => true;
}

class TabData extends DataClass implements Insertable<TabData> {
  final String id;
  final String? topicId;
  final DateTime timestamp;
  final Uri url;
  final String? title;
  final Uint8List? screenshot;
  const TabData(
      {required this.id,
      this.topicId,
      required this.timestamp,
      required this.url,
      this.title,
      this.screenshot});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    {
      map['url'] = Variable<String>(Tab.$converterurl.toSql(url));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || screenshot != null) {
      map['screenshot'] = Variable<Uint8List>(screenshot);
    }
    return map;
  }

  factory TabData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabData(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String?>(json['topic_id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      url: serializer.fromJson<Uri>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      screenshot: serializer.fromJson<Uint8List?>(json['screenshot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topic_id': serializer.toJson<String?>(topicId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'url': serializer.toJson<Uri>(url),
      'title': serializer.toJson<String?>(title),
      'screenshot': serializer.toJson<Uint8List?>(screenshot),
    };
  }

  TabData copyWith(
          {String? id,
          Value<String?> topicId = const Value.absent(),
          DateTime? timestamp,
          Uri? url,
          Value<String?> title = const Value.absent(),
          Value<Uint8List?> screenshot = const Value.absent()}) =>
      TabData(
        id: id ?? this.id,
        topicId: topicId.present ? topicId.value : this.topicId,
        timestamp: timestamp ?? this.timestamp,
        url: url ?? this.url,
        title: title.present ? title.value : this.title,
        screenshot: screenshot.present ? screenshot.value : this.screenshot,
      );
  TabData copyWithCompanion(TabCompanion data) {
    return TabData(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      screenshot:
          data.screenshot.present ? data.screenshot.value : this.screenshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabData(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('timestamp: $timestamp, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('screenshot: $screenshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, topicId, timestamp, url, title, $driftBlobEquality.hash(screenshot));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TabData &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.timestamp == this.timestamp &&
          other.url == this.url &&
          other.title == this.title &&
          $driftBlobEquality.equals(other.screenshot, this.screenshot));
}

class TabCompanion extends UpdateCompanion<TabData> {
  final Value<String> id;
  final Value<String?> topicId;
  final Value<DateTime> timestamp;
  final Value<Uri> url;
  final Value<String?> title;
  final Value<Uint8List?> screenshot;
  final Value<int> rowid;
  const TabCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.screenshot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabCompanion.insert({
    required String id,
    this.topicId = const Value.absent(),
    required DateTime timestamp,
    required Uri url,
    this.title = const Value.absent(),
    this.screenshot = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        timestamp = Value(timestamp),
        url = Value(url);
  static Insertable<TabData> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<DateTime>? timestamp,
    Expression<String>? url,
    Expression<String>? title,
    Expression<Uint8List>? screenshot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (timestamp != null) 'timestamp': timestamp,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (screenshot != null) 'screenshot': screenshot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabCompanion copyWith(
      {Value<String>? id,
      Value<String?>? topicId,
      Value<DateTime>? timestamp,
      Value<Uri>? url,
      Value<String?>? title,
      Value<Uint8List?>? screenshot,
      Value<int>? rowid}) {
    return TabCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      timestamp: timestamp ?? this.timestamp,
      url: url ?? this.url,
      title: title ?? this.title,
      screenshot: screenshot ?? this.screenshot,
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
    if (url.present) {
      map['url'] = Variable<String>(Tab.$converterurl.toSql(url.value));
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (screenshot.present) {
      map['screenshot'] = Variable<Uint8List>(screenshot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('timestamp: $timestamp, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('screenshot: $screenshot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TabDatabase extends GeneratedDatabase {
  _$TabDatabase(QueryExecutor e) : super(e);
  $TabDatabaseManager get managers => $TabDatabaseManager(this);
  late final Topic topic = Topic(this);
  late final Tab tab = Tab(this);
  late final TopicDao topicDao = TopicDao(this as TabDatabase);
  late final TabDao tabDao = TabDao(this as TabDatabase);
  Selectable<TopicData> topics() {
    return customSelect(
        'SELECT topic.* FROM topic LEFT JOIN (SELECT topic_id, MAX(timestamp) AS last_updated FROM tab GROUP BY topic_id) AS tab_max ON topic.id = tab_max.topic_id ORDER BY tab_max.last_updated DESC NULLS FIRST',
        variables: [],
        readsFrom: {
          topic,
          tab,
        }).asyncMap(topic.mapFromRow);
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [topic, tab];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('topic',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tab', kind: UpdateKind.delete),
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

  static MultiTypedResultKey<Tab, List<TabData>> _tabRefsTable(
          _$TabDatabase db) =>
      MultiTypedResultKey.fromTable(db.tab,
          aliasName: $_aliasNameGenerator(db.topic.id, db.tab.topicId));

  $TabProcessedTableManager get tabRefs {
    final manager =
        $TabTableManager($_db, $_db.tab).filter((f) => f.topicId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tabRefsTable($_db));
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

  ComposableFilter tabRefs(ComposableFilter Function($TabFilterComposer f) f) {
    final $TabFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.tab,
        getReferencedColumn: (t) => t.topicId,
        builder: (joinBuilder, parentComposers) => $TabFilterComposer(
            ComposerState(
                $state.db, $state.db.tab, joinBuilder, parentComposers)));
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
    PrefetchHooks Function({bool tabRefs})> {
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
          prefetchHooksCallback: ({tabRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tabRefs) db.tab],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tabRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $TopicReferences._tabRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $TopicReferences(db, table, p0).tabRefs,
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
    PrefetchHooks Function({bool tabRefs})>;
typedef $TabCreateCompanionBuilder = TabCompanion Function({
  required String id,
  Value<String?> topicId,
  required DateTime timestamp,
  required Uri url,
  Value<String?> title,
  Value<Uint8List?> screenshot,
  Value<int> rowid,
});
typedef $TabUpdateCompanionBuilder = TabCompanion Function({
  Value<String> id,
  Value<String?> topicId,
  Value<DateTime> timestamp,
  Value<Uri> url,
  Value<String?> title,
  Value<Uint8List?> screenshot,
  Value<int> rowid,
});

final class $TabReferences extends BaseReferences<_$TabDatabase, Tab, TabData> {
  $TabReferences(super.$_db, super.$_table, super.$_typedResult);

  static Topic _topicIdTable(_$TabDatabase db) =>
      db.topic.createAlias($_aliasNameGenerator(db.tab.topicId, db.topic.id));

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

class $TabFilterComposer extends FilterComposer<_$TabDatabase, Tab> {
  $TabFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Uri, Uri, String> get url =>
      $state.composableBuilder(
          column: $state.table.url,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<Uint8List> get screenshot => $state.composableBuilder(
      column: $state.table.screenshot,
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

class $TabOrderingComposer extends OrderingComposer<_$TabDatabase, Tab> {
  $TabOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<Uint8List> get screenshot => $state.composableBuilder(
      column: $state.table.screenshot,
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

class $TabTableManager extends RootTableManager<
    _$TabDatabase,
    Tab,
    TabData,
    $TabFilterComposer,
    $TabOrderingComposer,
    $TabCreateCompanionBuilder,
    $TabUpdateCompanionBuilder,
    (TabData, $TabReferences),
    TabData,
    PrefetchHooks Function({bool topicId})> {
  $TabTableManager(_$TabDatabase db, Tab table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $TabFilterComposer(ComposerState(db, table)),
          orderingComposer: $TabOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<Uri> url = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<Uint8List?> screenshot = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TabCompanion(
            id: id,
            topicId: topicId,
            timestamp: timestamp,
            url: url,
            title: title,
            screenshot: screenshot,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> topicId = const Value.absent(),
            required DateTime timestamp,
            required Uri url,
            Value<String?> title = const Value.absent(),
            Value<Uint8List?> screenshot = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TabCompanion.insert(
            id: id,
            topicId: topicId,
            timestamp: timestamp,
            url: url,
            title: title,
            screenshot: screenshot,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $TabReferences(db, table, e)))
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
                    referencedTable: $TabReferences._topicIdTable(db),
                    referencedColumn: $TabReferences._topicIdTable(db).id,
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

typedef $TabProcessedTableManager = ProcessedTableManager<
    _$TabDatabase,
    Tab,
    TabData,
    $TabFilterComposer,
    $TabOrderingComposer,
    $TabCreateCompanionBuilder,
    $TabUpdateCompanionBuilder,
    (TabData, $TabReferences),
    TabData,
    PrefetchHooks Function({bool topicId})>;

class $TabDatabaseManager {
  final _$TabDatabase _db;
  $TabDatabaseManager(this._db);
  $TopicTableManager get topic => $TopicTableManager(_db, _db.topic);
  $TabTableManager get tab => $TabTableManager(_db, _db.tab);
}
