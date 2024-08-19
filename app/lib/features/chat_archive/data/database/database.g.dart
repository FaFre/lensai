// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Chat extends Table with TableInfo<Chat, ChatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Chat(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [fileName, title, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat';
  @override
  Set<GeneratedColumn> get $primaryKey => {fileName};
  @override
  ChatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatData(
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  Chat createAlias(String alias) {
    return Chat(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ChatData extends DataClass implements Insertable<ChatData> {
  final String fileName;
  final String title;
  final String content;
  const ChatData(
      {required this.fileName, required this.title, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_name'] = Variable<String>(fileName);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    return map;
  }

  factory ChatData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatData(
      fileName: serializer.fromJson<String>(json['file_name']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'file_name': serializer.toJson<String>(fileName),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
    };
  }

  ChatData copyWith({String? fileName, String? title, String? content}) =>
      ChatData(
        fileName: fileName ?? this.fileName,
        title: title ?? this.title,
        content: content ?? this.content,
      );
  ChatData copyWithCompanion(ChatCompanion data) {
    return ChatData(
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatData(')
          ..write('fileName: $fileName, ')
          ..write('title: $title, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileName, title, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatData &&
          other.fileName == this.fileName &&
          other.title == this.title &&
          other.content == this.content);
}

class ChatCompanion extends UpdateCompanion<ChatData> {
  final Value<String> fileName;
  final Value<String> title;
  final Value<String> content;
  final Value<int> rowid;
  const ChatCompanion({
    this.fileName = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatCompanion.insert({
    required String fileName,
    required String title,
    required String content,
    this.rowid = const Value.absent(),
  })  : fileName = Value(fileName),
        title = Value(title),
        content = Value(content);
  static Insertable<ChatData> custom({
    Expression<String>? fileName,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileName != null) 'file_name': fileName,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatCompanion copyWith(
      {Value<String>? fileName,
      Value<String>? title,
      Value<String>? content,
      Value<int>? rowid}) {
    return ChatCompanion(
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatCompanion(')
          ..write('fileName: $fileName, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ChatFts extends Table
    with TableInfo<ChatFts, ChatFt>, VirtualTableInfo<ChatFts, ChatFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChatFts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [title, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_fts';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ChatFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatFt(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  ChatFts createAlias(String alias) {
    return ChatFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, content, content=chat, tokenize="trigram")';
}

class ChatFt extends DataClass implements Insertable<ChatFt> {
  final String title;
  final String content;
  const ChatFt({required this.title, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    return map;
  }

  factory ChatFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatFt(
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
    };
  }

  ChatFt copyWith({String? title, String? content}) => ChatFt(
        title: title ?? this.title,
        content: content ?? this.content,
      );
  ChatFt copyWithCompanion(ChatFtsCompanion data) {
    return ChatFt(
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatFt(')
          ..write('title: $title, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatFt &&
          other.title == this.title &&
          other.content == this.content);
}

class ChatFtsCompanion extends UpdateCompanion<ChatFt> {
  final Value<String> title;
  final Value<String> content;
  final Value<int> rowid;
  const ChatFtsCompanion({
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatFtsCompanion.insert({
    required String title,
    required String content,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        content = Value(content);
  static Insertable<ChatFt> custom({
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatFtsCompanion copyWith(
      {Value<String>? title, Value<String>? content, Value<int>? rowid}) {
    return ChatFtsCompanion(
      title: title ?? this.title,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatFtsCompanion(')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ChatSearchDatabase extends GeneratedDatabase {
  _$ChatSearchDatabase(QueryExecutor e) : super(e);
  $ChatSearchDatabaseManager get managers => $ChatSearchDatabaseManager(this);
  late final Chat chat = Chat(this);
  late final ChatFts chatFts = ChatFts(this);
  late final Trigger chatAfterInsert = Trigger(
      'CREATE TRIGGER chat_after_insert AFTER INSERT ON chat BEGIN INSERT INTO chat_fts ("rowid", title, content) VALUES (new."rowid", new.title, new.content);END',
      'chat_after_insert');
  late final Trigger chatAfterDelete = Trigger(
      'CREATE TRIGGER chat_after_delete AFTER DELETE ON chat BEGIN INSERT INTO chat_fts (chat_fts, "rowid", title, content) VALUES (\'delete\', old."rowid", old.title, old.content);END',
      'chat_after_delete');
  late final Trigger chatAfterUpdate = Trigger(
      'CREATE TRIGGER chat_after_update AFTER UPDATE ON chat BEGIN INSERT INTO chat_fts (chat_fts, "rowid", title, content) VALUES (\'delete\', old."rowid", old.title, old.content);INSERT INTO chat_fts (chat_fts, title, content) VALUES (new."rowid", new.title, new.content);END',
      'chat_after_update');
  late final SearchDao searchDao = SearchDao(this as ChatSearchDatabase);
  Selectable<ChatQueryResult> chatQuery(
      {required String beforeMatch,
      required String afterMatch,
      required String ellipsis,
      required int snippetLength,
      required String query}) {
    return customSelect(
        'SELECT c.file_name, highlight(chat_fts, 0, ?1, ?2) AS title, snippet(chat_fts, 1, ?1, ?2, ?3, ?4) AS content_snippet FROM chat_fts(?5)AS fts INNER JOIN chat AS c ON c."rowid" = fts."rowid" ORDER BY RANK',
        variables: [
          Variable<String>(beforeMatch),
          Variable<String>(afterMatch),
          Variable<String>(ellipsis),
          Variable<int>(snippetLength),
          Variable<String>(query)
        ],
        readsFrom: {
          chat,
          chatFts,
        }).map((QueryRow row) => ChatQueryResult(
          fileName: row.read<String>('file_name'),
          title: row.read<String>('title'),
          contentSnippet: row.read<String>('content_snippet'),
        ));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [chat, chatFts, chatAfterInsert, chatAfterDelete, chatAfterUpdate];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('chat',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('chat_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('chat',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('chat_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('chat',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('chat_fts', kind: UpdateKind.insert),
            ],
          ),
        ],
      );
}

typedef $ChatCreateCompanionBuilder = ChatCompanion Function({
  required String fileName,
  required String title,
  required String content,
  Value<int> rowid,
});
typedef $ChatUpdateCompanionBuilder = ChatCompanion Function({
  Value<String> fileName,
  Value<String> title,
  Value<String> content,
  Value<int> rowid,
});

class $ChatFilterComposer extends FilterComposer<_$ChatSearchDatabase, Chat> {
  $ChatFilterComposer(super.$state);
  ColumnFilters<String> get fileName => $state.composableBuilder(
      column: $state.table.fileName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $ChatOrderingComposer
    extends OrderingComposer<_$ChatSearchDatabase, Chat> {
  $ChatOrderingComposer(super.$state);
  ColumnOrderings<String> get fileName => $state.composableBuilder(
      column: $state.table.fileName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $ChatTableManager extends RootTableManager<
    _$ChatSearchDatabase,
    Chat,
    ChatData,
    $ChatFilterComposer,
    $ChatOrderingComposer,
    $ChatCreateCompanionBuilder,
    $ChatUpdateCompanionBuilder,
    (ChatData, BaseReferences<_$ChatSearchDatabase, Chat, ChatData>),
    ChatData,
    PrefetchHooks Function()> {
  $ChatTableManager(_$ChatSearchDatabase db, Chat table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $ChatFilterComposer(ComposerState(db, table)),
          orderingComposer: $ChatOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> fileName = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatCompanion(
            fileName: fileName,
            title: title,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String fileName,
            required String title,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatCompanion.insert(
            fileName: fileName,
            title: title,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $ChatProcessedTableManager = ProcessedTableManager<
    _$ChatSearchDatabase,
    Chat,
    ChatData,
    $ChatFilterComposer,
    $ChatOrderingComposer,
    $ChatCreateCompanionBuilder,
    $ChatUpdateCompanionBuilder,
    (ChatData, BaseReferences<_$ChatSearchDatabase, Chat, ChatData>),
    ChatData,
    PrefetchHooks Function()>;
typedef $ChatFtsCreateCompanionBuilder = ChatFtsCompanion Function({
  required String title,
  required String content,
  Value<int> rowid,
});
typedef $ChatFtsUpdateCompanionBuilder = ChatFtsCompanion Function({
  Value<String> title,
  Value<String> content,
  Value<int> rowid,
});

class $ChatFtsFilterComposer
    extends FilterComposer<_$ChatSearchDatabase, ChatFts> {
  $ChatFtsFilterComposer(super.$state);
  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $ChatFtsOrderingComposer
    extends OrderingComposer<_$ChatSearchDatabase, ChatFts> {
  $ChatFtsOrderingComposer(super.$state);
  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $ChatFtsTableManager extends RootTableManager<
    _$ChatSearchDatabase,
    ChatFts,
    ChatFt,
    $ChatFtsFilterComposer,
    $ChatFtsOrderingComposer,
    $ChatFtsCreateCompanionBuilder,
    $ChatFtsUpdateCompanionBuilder,
    (ChatFt, BaseReferences<_$ChatSearchDatabase, ChatFts, ChatFt>),
    ChatFt,
    PrefetchHooks Function()> {
  $ChatFtsTableManager(_$ChatSearchDatabase db, ChatFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $ChatFtsFilterComposer(ComposerState(db, table)),
          orderingComposer: $ChatFtsOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatFtsCompanion(
            title: title,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatFtsCompanion.insert(
            title: title,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $ChatFtsProcessedTableManager = ProcessedTableManager<
    _$ChatSearchDatabase,
    ChatFts,
    ChatFt,
    $ChatFtsFilterComposer,
    $ChatFtsOrderingComposer,
    $ChatFtsCreateCompanionBuilder,
    $ChatFtsUpdateCompanionBuilder,
    (ChatFt, BaseReferences<_$ChatSearchDatabase, ChatFts, ChatFt>),
    ChatFt,
    PrefetchHooks Function()>;

class $ChatSearchDatabaseManager {
  final _$ChatSearchDatabase _db;
  $ChatSearchDatabaseManager(this._db);
  $ChatTableManager get chat => $ChatTableManager(_db, _db.chat);
  $ChatFtsTableManager get chatFts => $ChatFtsTableManager(_db, _db.chatFts);
}

class ChatQueryResult {
  final String fileName;
  final String title;
  final String contentSnippet;
  ChatQueryResult({
    required this.fileName,
    required this.title,
    required this.contentSnippet,
  });
}
