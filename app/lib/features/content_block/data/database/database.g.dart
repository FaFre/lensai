// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Host extends Table with TableInfo<Host, HostData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Host(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> hostname = GeneratedColumn<String>(
      'hostname', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumnWithTypeConverter<HostSource, int> source =
      GeneratedColumn<int>('source', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<HostSource>(Host.$convertersource);
  @override
  List<GeneratedColumn> get $columns => [hostname, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'host';
  @override
  Set<GeneratedColumn> get $primaryKey => {hostname};
  @override
  HostData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HostData(
      hostname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hostname'])!,
      source: Host.$convertersource.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!),
    );
  }

  @override
  Host createAlias(String alias) {
    return Host(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HostSource, int, int> $convertersource =
      const EnumIndexConverter<HostSource>(HostSource.values);
  @override
  bool get dontWriteConstraints => true;
}

class HostData extends DataClass implements Insertable<HostData> {
  final String hostname;
  final HostSource source;
  const HostData({required this.hostname, required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hostname'] = Variable<String>(hostname);
    {
      map['source'] = Variable<int>(Host.$convertersource.toSql(source));
    }
    return map;
  }

  factory HostData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HostData(
      hostname: serializer.fromJson<String>(json['hostname']),
      source: Host.$convertersource
          .fromJson(serializer.fromJson<int>(json['source'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hostname': serializer.toJson<String>(hostname),
      'source': serializer.toJson<int>(Host.$convertersource.toJson(source)),
    };
  }

  HostData copyWith({String? hostname, HostSource? source}) => HostData(
        hostname: hostname ?? this.hostname,
        source: source ?? this.source,
      );
  @override
  String toString() {
    return (StringBuffer('HostData(')
          ..write('hostname: $hostname, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hostname, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HostData &&
          other.hostname == this.hostname &&
          other.source == this.source);
}

class HostCompanion extends UpdateCompanion<HostData> {
  final Value<String> hostname;
  final Value<HostSource> source;
  final Value<int> rowid;
  const HostCompanion({
    this.hostname = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HostCompanion.insert({
    required String hostname,
    required HostSource source,
    this.rowid = const Value.absent(),
  })  : hostname = Value(hostname),
        source = Value(source);
  static Insertable<HostData> custom({
    Expression<String>? hostname,
    Expression<int>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hostname != null) 'hostname': hostname,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HostCompanion copyWith(
      {Value<String>? hostname, Value<HostSource>? source, Value<int>? rowid}) {
    return HostCompanion(
      hostname: hostname ?? this.hostname,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hostname.present) {
      map['hostname'] = Variable<String>(hostname.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(Host.$convertersource.toSql(source.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HostCompanion(')
          ..write('hostname: $hostname, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class HostSync extends Table with TableInfo<HostSync, HostSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  HostSync(this.attachedDatabase, [this._alias]);
  late final GeneratedColumnWithTypeConverter<HostSource, int> source =
      GeneratedColumn<int>('source', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              $customConstraints: 'PRIMARY KEY NOT NULL')
          .withConverter<HostSource>(HostSync.$convertersource);
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
      'last_sync', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [source, lastSync];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'host_sync';
  @override
  Set<GeneratedColumn> get $primaryKey => {source};
  @override
  HostSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HostSyncData(
      source: HostSync.$convertersource.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!),
      lastSync: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync'])!,
    );
  }

  @override
  HostSync createAlias(String alias) {
    return HostSync(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HostSource, int, int> $convertersource =
      const EnumIndexConverter<HostSource>(HostSource.values);
  @override
  bool get dontWriteConstraints => true;
}

class HostSyncData extends DataClass implements Insertable<HostSyncData> {
  final HostSource source;
  final DateTime lastSync;
  const HostSyncData({required this.source, required this.lastSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['source'] = Variable<int>(HostSync.$convertersource.toSql(source));
    }
    map['last_sync'] = Variable<DateTime>(lastSync);
    return map;
  }

  factory HostSyncData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HostSyncData(
      source: HostSync.$convertersource
          .fromJson(serializer.fromJson<int>(json['source'])),
      lastSync: serializer.fromJson<DateTime>(json['last_sync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source':
          serializer.toJson<int>(HostSync.$convertersource.toJson(source)),
      'last_sync': serializer.toJson<DateTime>(lastSync),
    };
  }

  HostSyncData copyWith({HostSource? source, DateTime? lastSync}) =>
      HostSyncData(
        source: source ?? this.source,
        lastSync: lastSync ?? this.lastSync,
      );
  @override
  String toString() {
    return (StringBuffer('HostSyncData(')
          ..write('source: $source, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(source, lastSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HostSyncData &&
          other.source == this.source &&
          other.lastSync == this.lastSync);
}

class HostSyncCompanion extends UpdateCompanion<HostSyncData> {
  final Value<HostSource> source;
  final Value<DateTime> lastSync;
  const HostSyncCompanion({
    this.source = const Value.absent(),
    this.lastSync = const Value.absent(),
  });
  HostSyncCompanion.insert({
    this.source = const Value.absent(),
    required DateTime lastSync,
  }) : lastSync = Value(lastSync);
  static Insertable<HostSyncData> custom({
    Expression<int>? source,
    Expression<DateTime>? lastSync,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (lastSync != null) 'last_sync': lastSync,
    });
  }

  HostSyncCompanion copyWith(
      {Value<HostSource>? source, Value<DateTime>? lastSync}) {
    return HostSyncCompanion(
      source: source ?? this.source,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] =
          Variable<int>(HostSync.$convertersource.toSql(source.value));
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HostSyncCompanion(')
          ..write('source: $source, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }
}

abstract class _$HostDatabase extends GeneratedDatabase {
  _$HostDatabase(QueryExecutor e) : super(e);
  _$HostDatabaseManager get managers => _$HostDatabaseManager(this);
  late final Host host = Host(this);
  late final HostSync hostSync = HostSync(this);
  late final HostDao hostDao = HostDao(this as HostDatabase);
  late final SyncDao syncDao = SyncDao(this as HostDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [host, hostSync];
}

typedef $HostInsertCompanionBuilder = HostCompanion Function({
  required String hostname,
  required HostSource source,
  Value<int> rowid,
});
typedef $HostUpdateCompanionBuilder = HostCompanion Function({
  Value<String> hostname,
  Value<HostSource> source,
  Value<int> rowid,
});

class $HostTableManager extends RootTableManager<
    _$HostDatabase,
    Host,
    HostData,
    $HostFilterComposer,
    $HostOrderingComposer,
    $HostProcessedTableManager,
    $HostInsertCompanionBuilder,
    $HostUpdateCompanionBuilder> {
  $HostTableManager(_$HostDatabase db, Host table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $HostFilterComposer(ComposerState(db, table)),
          orderingComposer: $HostOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $HostProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> hostname = const Value.absent(),
            Value<HostSource> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HostCompanion(
            hostname: hostname,
            source: source,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String hostname,
            required HostSource source,
            Value<int> rowid = const Value.absent(),
          }) =>
              HostCompanion.insert(
            hostname: hostname,
            source: source,
            rowid: rowid,
          ),
        ));
}

class $HostProcessedTableManager extends ProcessedTableManager<
    _$HostDatabase,
    Host,
    HostData,
    $HostFilterComposer,
    $HostOrderingComposer,
    $HostProcessedTableManager,
    $HostInsertCompanionBuilder,
    $HostUpdateCompanionBuilder> {
  $HostProcessedTableManager(super.$state);
}

class $HostFilterComposer extends FilterComposer<_$HostDatabase, Host> {
  $HostFilterComposer(super.$state);
  ColumnFilters<String> get hostname => $state.composableBuilder(
      column: $state.table.hostname,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<HostSource, HostSource, int> get source =>
      $state.composableBuilder(
          column: $state.table.source,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $HostOrderingComposer extends OrderingComposer<_$HostDatabase, Host> {
  $HostOrderingComposer(super.$state);
  ColumnOrderings<String> get hostname => $state.composableBuilder(
      column: $state.table.hostname,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $HostSyncInsertCompanionBuilder = HostSyncCompanion Function({
  Value<HostSource> source,
  required DateTime lastSync,
});
typedef $HostSyncUpdateCompanionBuilder = HostSyncCompanion Function({
  Value<HostSource> source,
  Value<DateTime> lastSync,
});

class $HostSyncTableManager extends RootTableManager<
    _$HostDatabase,
    HostSync,
    HostSyncData,
    $HostSyncFilterComposer,
    $HostSyncOrderingComposer,
    $HostSyncProcessedTableManager,
    $HostSyncInsertCompanionBuilder,
    $HostSyncUpdateCompanionBuilder> {
  $HostSyncTableManager(_$HostDatabase db, HostSync table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $HostSyncFilterComposer(ComposerState(db, table)),
          orderingComposer: $HostSyncOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $HostSyncProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<HostSource> source = const Value.absent(),
            Value<DateTime> lastSync = const Value.absent(),
          }) =>
              HostSyncCompanion(
            source: source,
            lastSync: lastSync,
          ),
          getInsertCompanionBuilder: ({
            Value<HostSource> source = const Value.absent(),
            required DateTime lastSync,
          }) =>
              HostSyncCompanion.insert(
            source: source,
            lastSync: lastSync,
          ),
        ));
}

class $HostSyncProcessedTableManager extends ProcessedTableManager<
    _$HostDatabase,
    HostSync,
    HostSyncData,
    $HostSyncFilterComposer,
    $HostSyncOrderingComposer,
    $HostSyncProcessedTableManager,
    $HostSyncInsertCompanionBuilder,
    $HostSyncUpdateCompanionBuilder> {
  $HostSyncProcessedTableManager(super.$state);
}

class $HostSyncFilterComposer extends FilterComposer<_$HostDatabase, HostSync> {
  $HostSyncFilterComposer(super.$state);
  ColumnWithTypeConverterFilters<HostSource, HostSource, int> get source =>
      $state.composableBuilder(
          column: $state.table.source,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSync => $state.composableBuilder(
      column: $state.table.lastSync,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $HostSyncOrderingComposer
    extends OrderingComposer<_$HostDatabase, HostSync> {
  $HostSyncOrderingComposer(super.$state);
  ColumnOrderings<int> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSync => $state.composableBuilder(
      column: $state.table.lastSync,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$HostDatabaseManager {
  final _$HostDatabase _db;
  _$HostDatabaseManager(this._db);
  $HostTableManager get host => $HostTableManager(_db, _db.host);
  $HostSyncTableManager get hostSync =>
      $HostSyncTableManager(_db, _db.hostSync);
}
