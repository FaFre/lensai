// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Container extends Table with TableInfo<Container, ContainerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Container(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumn<String> contextualIdentity =
      GeneratedColumn<String>('contextual_identity', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
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
          .withConverter<Color>(Container.$convertercolor);
  late final GeneratedColumnWithTypeConverter<IconData?, String> icon =
      GeneratedColumn<String>('icon', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              $customConstraints: '')
          .withConverter<IconData?>(Container.$convertericonn);
  @override
  List<GeneratedColumn> get $columns =>
      [id, contextualIdentity, name, color, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'container';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContainerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContainerData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      contextualIdentity: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contextual_identity']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      color: Container.$convertercolor.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!),
      icon: Container.$convertericonn.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])),
    );
  }

  @override
  Container createAlias(String alias) {
    return Container(attachedDatabase, alias);
  }

  static TypeConverter<Color, int> $convertercolor = const ColorConverter();
  static TypeConverter<IconData, String> $convertericon =
      const IconDataTypeConverter();
  static TypeConverter<IconData?, String?> $convertericonn =
      NullAwareTypeConverter.wrap($convertericon);
  @override
  bool get dontWriteConstraints => true;
}

class ContainerCompanion extends UpdateCompanion<ContainerData> {
  final Value<String> id;
  final Value<String?> contextualIdentity;
  final Value<String?> name;
  final Value<Color> color;
  final Value<IconData?> icon;
  final Value<int> rowid;
  const ContainerCompanion({
    this.id = const Value.absent(),
    this.contextualIdentity = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContainerCompanion.insert({
    required String id,
    this.contextualIdentity = const Value.absent(),
    this.name = const Value.absent(),
    required Color color,
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        color = Value(color);
  static Insertable<ContainerData> custom({
    Expression<String>? id,
    Expression<String>? contextualIdentity,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contextualIdentity != null) 'contextual_identity': contextualIdentity,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContainerCompanion copyWith(
      {Value<String>? id,
      Value<String?>? contextualIdentity,
      Value<String?>? name,
      Value<Color>? color,
      Value<IconData?>? icon,
      Value<int>? rowid}) {
    return ContainerCompanion(
      id: id ?? this.id,
      contextualIdentity: contextualIdentity ?? this.contextualIdentity,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contextualIdentity.present) {
      map['contextual_identity'] = Variable<String>(contextualIdentity.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] =
          Variable<int>(Container.$convertercolor.toSql(color.value));
    }
    if (icon.present) {
      map['icon'] =
          Variable<String>(Container.$convertericonn.toSql(icon.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContainerCompanion(')
          ..write('id: $id, ')
          ..write('contextualIdentity: $contextualIdentity, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
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
  late final GeneratedColumn<String> containerId = GeneratedColumn<String>(
      'container_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES container(id)ON DELETE CASCADE');
  late final GeneratedColumn<String> orderKey = GeneratedColumn<String>(
      'order_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, containerId, orderKey, timestamp];
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
      containerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}container_id']),
      orderKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_key'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  Tab createAlias(String alias) {
    return Tab(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TabData extends DataClass implements Insertable<TabData> {
  final String id;
  final String? containerId;
  final String orderKey;
  final DateTime timestamp;
  const TabData(
      {required this.id,
      this.containerId,
      required this.orderKey,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || containerId != null) {
      map['container_id'] = Variable<String>(containerId);
    }
    map['order_key'] = Variable<String>(orderKey);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  factory TabData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabData(
      id: serializer.fromJson<String>(json['id']),
      containerId: serializer.fromJson<String?>(json['container_id']),
      orderKey: serializer.fromJson<String>(json['order_key']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'container_id': serializer.toJson<String?>(containerId),
      'order_key': serializer.toJson<String>(orderKey),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TabData copyWith(
          {String? id,
          Value<String?> containerId = const Value.absent(),
          String? orderKey,
          DateTime? timestamp}) =>
      TabData(
        id: id ?? this.id,
        containerId: containerId.present ? containerId.value : this.containerId,
        orderKey: orderKey ?? this.orderKey,
        timestamp: timestamp ?? this.timestamp,
      );
  TabData copyWithCompanion(TabCompanion data) {
    return TabData(
      id: data.id.present ? data.id.value : this.id,
      containerId:
          data.containerId.present ? data.containerId.value : this.containerId,
      orderKey: data.orderKey.present ? data.orderKey.value : this.orderKey,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabData(')
          ..write('id: $id, ')
          ..write('containerId: $containerId, ')
          ..write('orderKey: $orderKey, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, containerId, orderKey, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TabData &&
          other.id == this.id &&
          other.containerId == this.containerId &&
          other.orderKey == this.orderKey &&
          other.timestamp == this.timestamp);
}

class TabCompanion extends UpdateCompanion<TabData> {
  final Value<String> id;
  final Value<String?> containerId;
  final Value<String> orderKey;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const TabCompanion({
    this.id = const Value.absent(),
    this.containerId = const Value.absent(),
    this.orderKey = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabCompanion.insert({
    required String id,
    this.containerId = const Value.absent(),
    required String orderKey,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        orderKey = Value(orderKey),
        timestamp = Value(timestamp);
  static Insertable<TabData> custom({
    Expression<String>? id,
    Expression<String>? containerId,
    Expression<String>? orderKey,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (containerId != null) 'container_id': containerId,
      if (orderKey != null) 'order_key': orderKey,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabCompanion copyWith(
      {Value<String>? id,
      Value<String?>? containerId,
      Value<String>? orderKey,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return TabCompanion(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      orderKey: orderKey ?? this.orderKey,
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
    if (containerId.present) {
      map['container_id'] = Variable<String>(containerId.value);
    }
    if (orderKey.present) {
      map['order_key'] = Variable<String>(orderKey.value);
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
    return (StringBuffer('TabCompanion(')
          ..write('id: $id, ')
          ..write('containerId: $containerId, ')
          ..write('orderKey: $orderKey, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TabDatabase extends GeneratedDatabase {
  _$TabDatabase(QueryExecutor e) : super(e);
  $TabDatabaseManager get managers => $TabDatabaseManager(this);
  late final Container container = Container(this);
  late final Tab tab = Tab(this);
  late final ContainerDao containerDao = ContainerDao(this as TabDatabase);
  late final TabDao tabDao = TabDao(this as TabDatabase);
  Selectable<ContainerDataWithCount> containersWithCount() {
    return customSelect(
        'SELECT container.*, tab_agg.tab_count FROM container LEFT JOIN (SELECT container_id, COUNT(*) AS tab_count, MAX(timestamp) AS last_updated FROM tab GROUP BY container_id) AS tab_agg ON container.id = tab_agg.container_id ORDER BY tab_agg.last_updated DESC NULLS FIRST',
        variables: [],
        readsFrom: {
          container,
          tab,
        }).map((QueryRow row) => ContainerDataWithCount(
          id: row.read<String>('id'),
          contextualIdentity: row.readNullable<String>('contextual_identity'),
          name: row.readNullable<String>('name'),
          color: Container.$convertercolor.fromSql(row.read<int>('color')),
          icon: NullAwareTypeConverter.wrapFromSql(
              Container.$convertericon, row.readNullable<String>('icon')),
          tabCount: row.readNullable<int>('tab_count'),
        ));
  }

  Selectable<String> leadingOrderKey(
      {required int bucket, String? containerId}) {
    return customSelect(
        'SELECT lexo_rank_previous(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key LIMIT 1)) AS _c0',
        variables: [
          Variable<int>(bucket),
          Variable<String>(containerId)
        ],
        readsFrom: {
          tab,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> trailingOrderKey(
      {required int bucket, String? containerId}) {
    return customSelect(
        'SELECT lexo_rank_next(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
        variables: [
          Variable<int>(bucket),
          Variable<String>(containerId)
        ],
        readsFrom: {
          tab,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> orderKeyAfterTab(
      {String? containerId, required String tabId}) {
    return customSelect(
        'WITH ordered_table AS (SELECT id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM tab WHERE container_id IS ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
        variables: [
          Variable<String>(containerId),
          Variable<String>(tabId)
        ],
        readsFrom: {
          tab,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [container, tab];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('container',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tab', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $ContainerCreateCompanionBuilder = ContainerCompanion Function({
  required String id,
  Value<String?> contextualIdentity,
  Value<String?> name,
  required Color color,
  Value<IconData?> icon,
  Value<int> rowid,
});
typedef $ContainerUpdateCompanionBuilder = ContainerCompanion Function({
  Value<String> id,
  Value<String?> contextualIdentity,
  Value<String?> name,
  Value<Color> color,
  Value<IconData?> icon,
  Value<int> rowid,
});

final class $ContainerReferences
    extends BaseReferences<_$TabDatabase, Container, ContainerData> {
  $ContainerReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Tab, List<TabData>> _tabRefsTable(
          _$TabDatabase db) =>
      MultiTypedResultKey.fromTable(db.tab,
          aliasName: $_aliasNameGenerator(db.container.id, db.tab.containerId));

  $TabProcessedTableManager get tabRefs {
    final manager = $TabTableManager($_db, $_db.tab)
        .filter((f) => f.containerId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tabRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $ContainerFilterComposer extends Composer<_$TabDatabase, Container> {
  $ContainerFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextualIdentity => $composableBuilder(
      column: $table.contextualIdentity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Color, Color, int> get color =>
      $composableBuilder(
          column: $table.color,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<IconData?, IconData, String> get icon =>
      $composableBuilder(
          column: $table.icon,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> tabRefs(Expression<bool> Function($TabFilterComposer f) f) {
    final $TabFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tab,
        getReferencedColumn: (t) => t.containerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TabFilterComposer(
              $db: $db,
              $table: $db.tab,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $ContainerOrderingComposer extends Composer<_$TabDatabase, Container> {
  $ContainerOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextualIdentity => $composableBuilder(
      column: $table.contextualIdentity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));
}

class $ContainerAnnotationComposer extends Composer<_$TabDatabase, Container> {
  $ContainerAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contextualIdentity => $composableBuilder(
      column: $table.contextualIdentity, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IconData?, String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  Expression<T> tabRefs<T extends Object>(
      Expression<T> Function($TabAnnotationComposer a) f) {
    final $TabAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tab,
        getReferencedColumn: (t) => t.containerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TabAnnotationComposer(
              $db: $db,
              $table: $db.tab,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $ContainerTableManager extends RootTableManager<
    _$TabDatabase,
    Container,
    ContainerData,
    $ContainerFilterComposer,
    $ContainerOrderingComposer,
    $ContainerAnnotationComposer,
    $ContainerCreateCompanionBuilder,
    $ContainerUpdateCompanionBuilder,
    (ContainerData, $ContainerReferences),
    ContainerData,
    PrefetchHooks Function({bool tabRefs})> {
  $ContainerTableManager(_$TabDatabase db, Container table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ContainerFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ContainerOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ContainerAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> contextualIdentity = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<Color> color = const Value.absent(),
            Value<IconData?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContainerCompanion(
            id: id,
            contextualIdentity: contextualIdentity,
            name: name,
            color: color,
            icon: icon,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> contextualIdentity = const Value.absent(),
            Value<String?> name = const Value.absent(),
            required Color color,
            Value<IconData?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContainerCompanion.insert(
            id: id,
            contextualIdentity: contextualIdentity,
            name: name,
            color: color,
            icon: icon,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $ContainerReferences(db, table, e)))
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
                        referencedTable: $ContainerReferences._tabRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $ContainerReferences(db, table, p0).tabRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.containerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $ContainerProcessedTableManager = ProcessedTableManager<
    _$TabDatabase,
    Container,
    ContainerData,
    $ContainerFilterComposer,
    $ContainerOrderingComposer,
    $ContainerAnnotationComposer,
    $ContainerCreateCompanionBuilder,
    $ContainerUpdateCompanionBuilder,
    (ContainerData, $ContainerReferences),
    ContainerData,
    PrefetchHooks Function({bool tabRefs})>;
typedef $TabCreateCompanionBuilder = TabCompanion Function({
  required String id,
  Value<String?> containerId,
  required String orderKey,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $TabUpdateCompanionBuilder = TabCompanion Function({
  Value<String> id,
  Value<String?> containerId,
  Value<String> orderKey,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

final class $TabReferences extends BaseReferences<_$TabDatabase, Tab, TabData> {
  $TabReferences(super.$_db, super.$_table, super.$_typedResult);

  static Container _containerIdTable(_$TabDatabase db) => db.container
      .createAlias($_aliasNameGenerator(db.tab.containerId, db.container.id));

  $ContainerProcessedTableManager? get containerId {
    if ($_item.containerId == null) return null;
    final manager = $ContainerTableManager($_db, $_db.container)
        .filter((f) => f.id($_item.containerId!));
    final item = $_typedResult.readTableOrNull(_containerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $TabFilterComposer extends Composer<_$TabDatabase, Tab> {
  $TabFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderKey => $composableBuilder(
      column: $table.orderKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $ContainerFilterComposer get containerId {
    final $ContainerFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.containerId,
        referencedTable: $db.container,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $ContainerFilterComposer(
              $db: $db,
              $table: $db.container,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TabOrderingComposer extends Composer<_$TabDatabase, Tab> {
  $TabOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderKey => $composableBuilder(
      column: $table.orderKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $ContainerOrderingComposer get containerId {
    final $ContainerOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.containerId,
        referencedTable: $db.container,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $ContainerOrderingComposer(
              $db: $db,
              $table: $db.container,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TabAnnotationComposer extends Composer<_$TabDatabase, Tab> {
  $TabAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $ContainerAnnotationComposer get containerId {
    final $ContainerAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.containerId,
        referencedTable: $db.container,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $ContainerAnnotationComposer(
              $db: $db,
              $table: $db.container,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TabTableManager extends RootTableManager<
    _$TabDatabase,
    Tab,
    TabData,
    $TabFilterComposer,
    $TabOrderingComposer,
    $TabAnnotationComposer,
    $TabCreateCompanionBuilder,
    $TabUpdateCompanionBuilder,
    (TabData, $TabReferences),
    TabData,
    PrefetchHooks Function({bool containerId})> {
  $TabTableManager(_$TabDatabase db, Tab table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TabFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TabOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TabAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> containerId = const Value.absent(),
            Value<String> orderKey = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TabCompanion(
            id: id,
            containerId: containerId,
            orderKey: orderKey,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> containerId = const Value.absent(),
            required String orderKey,
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              TabCompanion.insert(
            id: id,
            containerId: containerId,
            orderKey: orderKey,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $TabReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({containerId = false}) {
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
                      dynamic,
                      dynamic>>(state) {
                if (containerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.containerId,
                    referencedTable: $TabReferences._containerIdTable(db),
                    referencedColumn: $TabReferences._containerIdTable(db).id,
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
    $TabAnnotationComposer,
    $TabCreateCompanionBuilder,
    $TabUpdateCompanionBuilder,
    (TabData, $TabReferences),
    TabData,
    PrefetchHooks Function({bool containerId})>;

class $TabDatabaseManager {
  final _$TabDatabase _db;
  $TabDatabaseManager(this._db);
  $ContainerTableManager get container =>
      $ContainerTableManager(_db, _db.container);
  $TabTableManager get tab => $TabTableManager(_db, _db.tab);
}
