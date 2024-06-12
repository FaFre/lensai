// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class BangTable extends Table with TableInfo<BangTable, Bang> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumnWithTypeConverter<BangGroup, int> group =
      GeneratedColumn<int>('group', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<BangGroup>(BangTable.$convertergroup);
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
      'website_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> urlTemplate = GeneratedColumn<String>(
      'url_template', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumnWithTypeConverter<Set<BangFormat>?, String> format =
      GeneratedColumn<String>('format', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              $customConstraints: '')
          .withConverter<Set<BangFormat>?>(BangTable.$converterformat);
  @override
  List<GeneratedColumn> get $columns => [
        trigger,
        group,
        websiteName,
        domain,
        urlTemplate,
        category,
        subCategory,
        format
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang';
  @override
  Set<GeneratedColumn> get $primaryKey => {trigger};
  @override
  Bang map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bang(
      websiteName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website_name'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      urlTemplate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url_template'])!,
      group: BangTable.$convertergroup.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group'])!),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category']),
      format: BangTable.$converterformat.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])),
    );
  }

  @override
  BangTable createAlias(String alias) {
    return BangTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BangGroup, int, int> $convertergroup =
      const EnumIndexConverter<BangGroup>(BangGroup.values);
  static TypeConverter<Set<BangFormat>?, String?> $converterformat =
      const BangFormatConverter();
  @override
  bool get dontWriteConstraints => true;
}

class BangCompanion extends UpdateCompanion<Bang> {
  final Value<String> trigger;
  final Value<BangGroup> group;
  final Value<String> websiteName;
  final Value<String> domain;
  final Value<String> urlTemplate;
  final Value<String?> category;
  final Value<String?> subCategory;
  final Value<Set<BangFormat>?> format;
  final Value<int> rowid;
  const BangCompanion({
    this.trigger = const Value.absent(),
    this.group = const Value.absent(),
    this.websiteName = const Value.absent(),
    this.domain = const Value.absent(),
    this.urlTemplate = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.format = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangCompanion.insert({
    required String trigger,
    required BangGroup group,
    required String websiteName,
    required String domain,
    required String urlTemplate,
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.format = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : trigger = Value(trigger),
        group = Value(group),
        websiteName = Value(websiteName),
        domain = Value(domain),
        urlTemplate = Value(urlTemplate);
  static Insertable<Bang> custom({
    Expression<String>? trigger,
    Expression<int>? group,
    Expression<String>? websiteName,
    Expression<String>? domain,
    Expression<String>? urlTemplate,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? format,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (group != null) 'group': group,
      if (websiteName != null) 'website_name': websiteName,
      if (domain != null) 'domain': domain,
      if (urlTemplate != null) 'url_template': urlTemplate,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (format != null) 'format': format,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangCompanion copyWith(
      {Value<String>? trigger,
      Value<BangGroup>? group,
      Value<String>? websiteName,
      Value<String>? domain,
      Value<String>? urlTemplate,
      Value<String?>? category,
      Value<String?>? subCategory,
      Value<Set<BangFormat>?>? format,
      Value<int>? rowid}) {
    return BangCompanion(
      trigger: trigger ?? this.trigger,
      group: group ?? this.group,
      websiteName: websiteName ?? this.websiteName,
      domain: domain ?? this.domain,
      urlTemplate: urlTemplate ?? this.urlTemplate,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      format: format ?? this.format,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (group.present) {
      map['group'] =
          Variable<int>(BangTable.$convertergroup.toSql(group.value));
    }
    if (websiteName.present) {
      map['website_name'] = Variable<String>(websiteName.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (urlTemplate.present) {
      map['url_template'] = Variable<String>(urlTemplate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (format.present) {
      map['format'] =
          Variable<String>(BangTable.$converterformat.toSql(format.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangCompanion(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('websiteName: $websiteName, ')
          ..write('domain: $domain, ')
          ..write('urlTemplate: $urlTemplate, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('format: $format, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangSync extends Table with TableInfo<BangSync, BangSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangSync(this.attachedDatabase, [this._alias]);
  late final GeneratedColumnWithTypeConverter<BangGroup, int> group =
      GeneratedColumn<int>('group', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              $customConstraints: 'PRIMARY KEY NOT NULL')
          .withConverter<BangGroup>(BangSync.$convertergroup);
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
      'last_sync', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [group, lastSync];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_sync';
  @override
  Set<GeneratedColumn> get $primaryKey => {group};
  @override
  BangSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangSyncData(
      group: BangSync.$convertergroup.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group'])!),
      lastSync: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync'])!,
    );
  }

  @override
  BangSync createAlias(String alias) {
    return BangSync(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BangGroup, int, int> $convertergroup =
      const EnumIndexConverter<BangGroup>(BangGroup.values);
  @override
  bool get dontWriteConstraints => true;
}

class BangSyncData extends DataClass implements Insertable<BangSyncData> {
  final BangGroup group;
  final DateTime lastSync;
  const BangSyncData({required this.group, required this.lastSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['group'] = Variable<int>(BangSync.$convertergroup.toSql(group));
    }
    map['last_sync'] = Variable<DateTime>(lastSync);
    return map;
  }

  factory BangSyncData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangSyncData(
      group: BangSync.$convertergroup
          .fromJson(serializer.fromJson<int>(json['group'])),
      lastSync: serializer.fromJson<DateTime>(json['last_sync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'group': serializer.toJson<int>(BangSync.$convertergroup.toJson(group)),
      'last_sync': serializer.toJson<DateTime>(lastSync),
    };
  }

  BangSyncData copyWith({BangGroup? group, DateTime? lastSync}) => BangSyncData(
        group: group ?? this.group,
        lastSync: lastSync ?? this.lastSync,
      );
  @override
  String toString() {
    return (StringBuffer('BangSyncData(')
          ..write('group: $group, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(group, lastSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangSyncData &&
          other.group == this.group &&
          other.lastSync == this.lastSync);
}

class BangSyncCompanion extends UpdateCompanion<BangSyncData> {
  final Value<BangGroup> group;
  final Value<DateTime> lastSync;
  const BangSyncCompanion({
    this.group = const Value.absent(),
    this.lastSync = const Value.absent(),
  });
  BangSyncCompanion.insert({
    this.group = const Value.absent(),
    required DateTime lastSync,
  }) : lastSync = Value(lastSync);
  static Insertable<BangSyncData> custom({
    Expression<int>? group,
    Expression<DateTime>? lastSync,
  }) {
    return RawValuesInsertable({
      if (group != null) 'group': group,
      if (lastSync != null) 'last_sync': lastSync,
    });
  }

  BangSyncCompanion copyWith(
      {Value<BangGroup>? group, Value<DateTime>? lastSync}) {
    return BangSyncCompanion(
      group: group ?? this.group,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (group.present) {
      map['group'] = Variable<int>(BangSync.$convertergroup.toSql(group.value));
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangSyncCompanion(')
          ..write('group: $group, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }
}

class BangFrequency extends Table
    with TableInfo<BangFrequency, BangFrequencyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangFrequency(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'PRIMARY KEY NOT NULL REFERENCES bang("trigger")ON DELETE CASCADE');
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
      'last_used', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [trigger, frequency, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_frequency';
  @override
  Set<GeneratedColumn> get $primaryKey => {trigger};
  @override
  BangFrequencyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangFrequencyData(
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used'])!,
    );
  }

  @override
  BangFrequency createAlias(String alias) {
    return BangFrequency(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class BangFrequencyData extends DataClass
    implements Insertable<BangFrequencyData> {
  final String trigger;
  final int frequency;
  final DateTime lastUsed;
  const BangFrequencyData(
      {required this.trigger, required this.frequency, required this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['frequency'] = Variable<int>(frequency);
    map['last_used'] = Variable<DateTime>(lastUsed);
    return map;
  }

  factory BangFrequencyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangFrequencyData(
      trigger: serializer.fromJson<String>(json['trigger']),
      frequency: serializer.fromJson<int>(json['frequency']),
      lastUsed: serializer.fromJson<DateTime>(json['last_used']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'frequency': serializer.toJson<int>(frequency),
      'last_used': serializer.toJson<DateTime>(lastUsed),
    };
  }

  BangFrequencyData copyWith(
          {String? trigger, int? frequency, DateTime? lastUsed}) =>
      BangFrequencyData(
        trigger: trigger ?? this.trigger,
        frequency: frequency ?? this.frequency,
        lastUsed: lastUsed ?? this.lastUsed,
      );
  @override
  String toString() {
    return (StringBuffer('BangFrequencyData(')
          ..write('trigger: $trigger, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trigger, frequency, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangFrequencyData &&
          other.trigger == this.trigger &&
          other.frequency == this.frequency &&
          other.lastUsed == this.lastUsed);
}

class BangFrequencyCompanion extends UpdateCompanion<BangFrequencyData> {
  final Value<String> trigger;
  final Value<int> frequency;
  final Value<DateTime> lastUsed;
  final Value<int> rowid;
  const BangFrequencyCompanion({
    this.trigger = const Value.absent(),
    this.frequency = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangFrequencyCompanion.insert({
    required String trigger,
    required int frequency,
    required DateTime lastUsed,
    this.rowid = const Value.absent(),
  })  : trigger = Value(trigger),
        frequency = Value(frequency),
        lastUsed = Value(lastUsed);
  static Insertable<BangFrequencyData> custom({
    Expression<String>? trigger,
    Expression<int>? frequency,
    Expression<DateTime>? lastUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (frequency != null) 'frequency': frequency,
      if (lastUsed != null) 'last_used': lastUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangFrequencyCompanion copyWith(
      {Value<String>? trigger,
      Value<int>? frequency,
      Value<DateTime>? lastUsed,
      Value<int>? rowid}) {
    return BangFrequencyCompanion(
      trigger: trigger ?? this.trigger,
      frequency: frequency ?? this.frequency,
      lastUsed: lastUsed ?? this.lastUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangFrequencyCompanion(')
          ..write('trigger: $trigger, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangIcon extends Table with TableInfo<BangIcon, BangIconData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangIcon(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'PRIMARY KEY NOT NULL REFERENCES bang("trigger")ON DELETE CASCADE');
  late final GeneratedColumn<Uint8List> iconData = GeneratedColumn<Uint8List>(
      'icon_data', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<DateTime> fetchDate = GeneratedColumn<DateTime>(
      'fetch_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [trigger, iconData, fetchDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_icon';
  @override
  Set<GeneratedColumn> get $primaryKey => {trigger};
  @override
  BangIconData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangIconData(
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      iconData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}icon_data'])!,
      fetchDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetch_date'])!,
    );
  }

  @override
  BangIcon createAlias(String alias) {
    return BangIcon(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class BangIconData extends DataClass implements Insertable<BangIconData> {
  final String trigger;
  final Uint8List iconData;
  final DateTime fetchDate;
  const BangIconData(
      {required this.trigger, required this.iconData, required this.fetchDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['icon_data'] = Variable<Uint8List>(iconData);
    map['fetch_date'] = Variable<DateTime>(fetchDate);
    return map;
  }

  factory BangIconData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangIconData(
      trigger: serializer.fromJson<String>(json['trigger']),
      iconData: serializer.fromJson<Uint8List>(json['icon_data']),
      fetchDate: serializer.fromJson<DateTime>(json['fetch_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'icon_data': serializer.toJson<Uint8List>(iconData),
      'fetch_date': serializer.toJson<DateTime>(fetchDate),
    };
  }

  BangIconData copyWith(
          {String? trigger, Uint8List? iconData, DateTime? fetchDate}) =>
      BangIconData(
        trigger: trigger ?? this.trigger,
        iconData: iconData ?? this.iconData,
        fetchDate: fetchDate ?? this.fetchDate,
      );
  @override
  String toString() {
    return (StringBuffer('BangIconData(')
          ..write('trigger: $trigger, ')
          ..write('iconData: $iconData, ')
          ..write('fetchDate: $fetchDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(trigger, $driftBlobEquality.hash(iconData), fetchDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangIconData &&
          other.trigger == this.trigger &&
          $driftBlobEquality.equals(other.iconData, this.iconData) &&
          other.fetchDate == this.fetchDate);
}

class BangIconCompanion extends UpdateCompanion<BangIconData> {
  final Value<String> trigger;
  final Value<Uint8List> iconData;
  final Value<DateTime> fetchDate;
  final Value<int> rowid;
  const BangIconCompanion({
    this.trigger = const Value.absent(),
    this.iconData = const Value.absent(),
    this.fetchDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangIconCompanion.insert({
    required String trigger,
    required Uint8List iconData,
    required DateTime fetchDate,
    this.rowid = const Value.absent(),
  })  : trigger = Value(trigger),
        iconData = Value(iconData),
        fetchDate = Value(fetchDate);
  static Insertable<BangIconData> custom({
    Expression<String>? trigger,
    Expression<Uint8List>? iconData,
    Expression<DateTime>? fetchDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (iconData != null) 'icon_data': iconData,
      if (fetchDate != null) 'fetch_date': fetchDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangIconCompanion copyWith(
      {Value<String>? trigger,
      Value<Uint8List>? iconData,
      Value<DateTime>? fetchDate,
      Value<int>? rowid}) {
    return BangIconCompanion(
      trigger: trigger ?? this.trigger,
      iconData: iconData ?? this.iconData,
      fetchDate: fetchDate ?? this.fetchDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (iconData.present) {
      map['icon_data'] = Variable<Uint8List>(iconData.value);
    }
    if (fetchDate.present) {
      map['fetch_date'] = Variable<DateTime>(fetchDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangIconCompanion(')
          ..write('trigger: $trigger, ')
          ..write('iconData: $iconData, ')
          ..write('fetchDate: $fetchDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangFts extends Table
    with TableInfo<BangFts, BangFt>, VirtualTableInfo<BangFts, BangFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangFts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
      'website_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [trigger, websiteName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_fts';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  BangFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangFt(
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      websiteName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website_name'])!,
    );
  }

  @override
  BangFts createAlias(String alias) {
    return BangFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(trigger, website_name, content=bang, prefix=\'2 3\')';
}

class BangFt extends DataClass implements Insertable<BangFt> {
  final String trigger;
  final String websiteName;
  const BangFt({required this.trigger, required this.websiteName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['website_name'] = Variable<String>(websiteName);
    return map;
  }

  factory BangFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangFt(
      trigger: serializer.fromJson<String>(json['trigger']),
      websiteName: serializer.fromJson<String>(json['website_name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'website_name': serializer.toJson<String>(websiteName),
    };
  }

  BangFt copyWith({String? trigger, String? websiteName}) => BangFt(
        trigger: trigger ?? this.trigger,
        websiteName: websiteName ?? this.websiteName,
      );
  @override
  String toString() {
    return (StringBuffer('BangFt(')
          ..write('trigger: $trigger, ')
          ..write('websiteName: $websiteName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trigger, websiteName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangFt &&
          other.trigger == this.trigger &&
          other.websiteName == this.websiteName);
}

class BangFtsCompanion extends UpdateCompanion<BangFt> {
  final Value<String> trigger;
  final Value<String> websiteName;
  final Value<int> rowid;
  const BangFtsCompanion({
    this.trigger = const Value.absent(),
    this.websiteName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangFtsCompanion.insert({
    required String trigger,
    required String websiteName,
    this.rowid = const Value.absent(),
  })  : trigger = Value(trigger),
        websiteName = Value(websiteName);
  static Insertable<BangFt> custom({
    Expression<String>? trigger,
    Expression<String>? websiteName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (websiteName != null) 'website_name': websiteName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangFtsCompanion copyWith(
      {Value<String>? trigger, Value<String>? websiteName, Value<int>? rowid}) {
    return BangFtsCompanion(
      trigger: trigger ?? this.trigger,
      websiteName: websiteName ?? this.websiteName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (websiteName.present) {
      map['website_name'] = Variable<String>(websiteName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangFtsCompanion(')
          ..write('trigger: $trigger, ')
          ..write('websiteName: $websiteName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangDataView extends ViewInfo<BangDataView, BangData>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$BangDatabase attachedDatabase;
  BangDataView(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
        trigger,
        group,
        websiteName,
        domain,
        urlTemplate,
        category,
        subCategory,
        format,
        frequency,
        lastUsed,
        iconData
      ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'bang_data_view';
  @override
  Map<SqlDialect, String> get createViewStatements => {
        SqlDialect.sqlite:
            'CREATE VIEW bang_data_view AS SELECT b.*, bf.frequency, bf.last_used, bi.icon_data FROM bang AS b LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" LEFT JOIN bang_icon AS bi ON b."trigger" = bi."trigger"',
      };
  @override
  BangDataView get asDslTable => this;
  @override
  BangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangData(
      websiteName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website_name'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      urlTemplate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url_template'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category']),
      format: BangTable.$converterformat.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])),
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency']),
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used']),
      iconData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}icon_data']),
    );
  }

  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumnWithTypeConverter<BangGroup, int> group =
      GeneratedColumn<int>('group', aliasedName, false, type: DriftSqlType.int)
          .withConverter<BangGroup>(BangTable.$convertergroup);
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
      'website_name', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> urlTemplate = GeneratedColumn<String>(
      'url_template', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, true,
      type: DriftSqlType.string);
  late final GeneratedColumnWithTypeConverter<Set<BangFormat>?, String> format =
      GeneratedColumn<String>('format', aliasedName, true,
              type: DriftSqlType.string)
          .withConverter<Set<BangFormat>?>(BangTable.$converterformat);
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, true,
      type: DriftSqlType.int);
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
      'last_used', aliasedName, true,
      type: DriftSqlType.dateTime);
  late final GeneratedColumn<Uint8List> iconData = GeneratedColumn<Uint8List>(
      'icon_data', aliasedName, true,
      type: DriftSqlType.blob);
  @override
  BangDataView createAlias(String alias) {
    return BangDataView(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {'bang', 'bang_frequency', 'bang_icon'};
}

abstract class _$BangDatabase extends GeneratedDatabase {
  _$BangDatabase(QueryExecutor e) : super(e);
  _$BangDatabaseManager get managers => _$BangDatabaseManager(this);
  late final BangTable bang = BangTable(this);
  late final BangSync bangSync = BangSync(this);
  late final BangFrequency bangFrequency = BangFrequency(this);
  late final BangIcon bangIcon = BangIcon(this);
  late final BangFts bangFts = BangFts(this);
  late final BangDataView bangDataView = BangDataView(this);
  late final Trigger bangAfterInsert = Trigger(
      'CREATE TRIGGER bang_after_insert AFTER INSERT ON bang BEGIN INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
      'bang_after_insert');
  late final Trigger bangAfterDelete = Trigger(
      'CREATE TRIGGER bang_after_delete AFTER DELETE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);END',
      'bang_after_delete');
  late final Trigger bangAfterUpdate = Trigger(
      'CREATE TRIGGER bang_after_update AFTER UPDATE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
      'bang_after_update');
  late final BangDao bangDao = BangDao(this as BangDatabase);
  late final SyncDao syncDao = SyncDao(this as BangDatabase);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO bang_fts (bang_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {bangFts},
    );
  }

  Selectable<BangData> bangQuery({required String query}) {
    return customSelect(
        'SELECT b.*, bf.frequency, bf.last_used, bi.icon_data FROM bang_fts(?1)AS fts INNER JOIN bang AS b ON b."rowid" = fts."rowid" LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" LEFT JOIN bang_icon AS bi ON b."trigger" = bi."trigger" ORDER BY RANK, bf.frequency NULLS LAST',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          bangFrequency,
          bangIcon,
          bang,
          bangFts,
        }).map((QueryRow row) => BangData(
          websiteName: row.read<String>('website_name'),
          domain: row.read<String>('domain'),
          trigger: row.read<String>('trigger'),
          urlTemplate: row.read<String>('url_template'),
          category: row.readNullable<String>('category'),
          subCategory: row.readNullable<String>('sub_category'),
          format: BangTable.$converterformat
              .fromSql(row.readNullable<String>('format')),
          frequency: row.readNullable<int>('frequency'),
          lastUsed: row.readNullable<DateTime>('last_used'),
          iconData: row.readNullable<Uint8List>('icon_data'),
        ));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        bang,
        bangSync,
        bangFrequency,
        bangIcon,
        bangFts,
        bangDataView,
        bangAfterInsert,
        bangAfterDelete,
        bangAfterUpdate
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bang_frequency', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bang_icon', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('bang_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bang_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('bang_fts', kind: UpdateKind.insert),
            ],
          ),
        ],
      );
}

typedef $BangSyncInsertCompanionBuilder = BangSyncCompanion Function({
  Value<BangGroup> group,
  required DateTime lastSync,
});
typedef $BangSyncUpdateCompanionBuilder = BangSyncCompanion Function({
  Value<BangGroup> group,
  Value<DateTime> lastSync,
});

class $BangSyncTableManager extends RootTableManager<
    _$BangDatabase,
    BangSync,
    BangSyncData,
    $BangSyncFilterComposer,
    $BangSyncOrderingComposer,
    $BangSyncProcessedTableManager,
    $BangSyncInsertCompanionBuilder,
    $BangSyncUpdateCompanionBuilder> {
  $BangSyncTableManager(_$BangDatabase db, BangSync table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $BangSyncFilterComposer(ComposerState(db, table)),
          orderingComposer: $BangSyncOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $BangSyncProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<BangGroup> group = const Value.absent(),
            Value<DateTime> lastSync = const Value.absent(),
          }) =>
              BangSyncCompanion(
            group: group,
            lastSync: lastSync,
          ),
          getInsertCompanionBuilder: ({
            Value<BangGroup> group = const Value.absent(),
            required DateTime lastSync,
          }) =>
              BangSyncCompanion.insert(
            group: group,
            lastSync: lastSync,
          ),
        ));
}

class $BangSyncProcessedTableManager extends ProcessedTableManager<
    _$BangDatabase,
    BangSync,
    BangSyncData,
    $BangSyncFilterComposer,
    $BangSyncOrderingComposer,
    $BangSyncProcessedTableManager,
    $BangSyncInsertCompanionBuilder,
    $BangSyncUpdateCompanionBuilder> {
  $BangSyncProcessedTableManager(super.$state);
}

class $BangSyncFilterComposer extends FilterComposer<_$BangDatabase, BangSync> {
  $BangSyncFilterComposer(super.$state);
  ColumnWithTypeConverterFilters<BangGroup, BangGroup, int> get group =>
      $state.composableBuilder(
          column: $state.table.group,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSync => $state.composableBuilder(
      column: $state.table.lastSync,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $BangSyncOrderingComposer
    extends OrderingComposer<_$BangDatabase, BangSync> {
  $BangSyncOrderingComposer(super.$state);
  ColumnOrderings<int> get group => $state.composableBuilder(
      column: $state.table.group,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSync => $state.composableBuilder(
      column: $state.table.lastSync,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $BangFrequencyInsertCompanionBuilder = BangFrequencyCompanion Function({
  required String trigger,
  required int frequency,
  required DateTime lastUsed,
  Value<int> rowid,
});
typedef $BangFrequencyUpdateCompanionBuilder = BangFrequencyCompanion Function({
  Value<String> trigger,
  Value<int> frequency,
  Value<DateTime> lastUsed,
  Value<int> rowid,
});

class $BangFrequencyTableManager extends RootTableManager<
    _$BangDatabase,
    BangFrequency,
    BangFrequencyData,
    $BangFrequencyFilterComposer,
    $BangFrequencyOrderingComposer,
    $BangFrequencyProcessedTableManager,
    $BangFrequencyInsertCompanionBuilder,
    $BangFrequencyUpdateCompanionBuilder> {
  $BangFrequencyTableManager(_$BangDatabase db, BangFrequency table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $BangFrequencyFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $BangFrequencyOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $BangFrequencyProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> trigger = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<DateTime> lastUsed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFrequencyCompanion(
            trigger: trigger,
            frequency: frequency,
            lastUsed: lastUsed,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String trigger,
            required int frequency,
            required DateTime lastUsed,
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFrequencyCompanion.insert(
            trigger: trigger,
            frequency: frequency,
            lastUsed: lastUsed,
            rowid: rowid,
          ),
        ));
}

class $BangFrequencyProcessedTableManager extends ProcessedTableManager<
    _$BangDatabase,
    BangFrequency,
    BangFrequencyData,
    $BangFrequencyFilterComposer,
    $BangFrequencyOrderingComposer,
    $BangFrequencyProcessedTableManager,
    $BangFrequencyInsertCompanionBuilder,
    $BangFrequencyUpdateCompanionBuilder> {
  $BangFrequencyProcessedTableManager(super.$state);
}

class $BangFrequencyFilterComposer
    extends FilterComposer<_$BangDatabase, BangFrequency> {
  $BangFrequencyFilterComposer(super.$state);
  ColumnFilters<String> get trigger => $state.composableBuilder(
      column: $state.table.trigger,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastUsed => $state.composableBuilder(
      column: $state.table.lastUsed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $BangFrequencyOrderingComposer
    extends OrderingComposer<_$BangDatabase, BangFrequency> {
  $BangFrequencyOrderingComposer(super.$state);
  ColumnOrderings<String> get trigger => $state.composableBuilder(
      column: $state.table.trigger,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastUsed => $state.composableBuilder(
      column: $state.table.lastUsed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $BangIconInsertCompanionBuilder = BangIconCompanion Function({
  required String trigger,
  required Uint8List iconData,
  required DateTime fetchDate,
  Value<int> rowid,
});
typedef $BangIconUpdateCompanionBuilder = BangIconCompanion Function({
  Value<String> trigger,
  Value<Uint8List> iconData,
  Value<DateTime> fetchDate,
  Value<int> rowid,
});

class $BangIconTableManager extends RootTableManager<
    _$BangDatabase,
    BangIcon,
    BangIconData,
    $BangIconFilterComposer,
    $BangIconOrderingComposer,
    $BangIconProcessedTableManager,
    $BangIconInsertCompanionBuilder,
    $BangIconUpdateCompanionBuilder> {
  $BangIconTableManager(_$BangDatabase db, BangIcon table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $BangIconFilterComposer(ComposerState(db, table)),
          orderingComposer: $BangIconOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $BangIconProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> trigger = const Value.absent(),
            Value<Uint8List> iconData = const Value.absent(),
            Value<DateTime> fetchDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangIconCompanion(
            trigger: trigger,
            iconData: iconData,
            fetchDate: fetchDate,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String trigger,
            required Uint8List iconData,
            required DateTime fetchDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              BangIconCompanion.insert(
            trigger: trigger,
            iconData: iconData,
            fetchDate: fetchDate,
            rowid: rowid,
          ),
        ));
}

class $BangIconProcessedTableManager extends ProcessedTableManager<
    _$BangDatabase,
    BangIcon,
    BangIconData,
    $BangIconFilterComposer,
    $BangIconOrderingComposer,
    $BangIconProcessedTableManager,
    $BangIconInsertCompanionBuilder,
    $BangIconUpdateCompanionBuilder> {
  $BangIconProcessedTableManager(super.$state);
}

class $BangIconFilterComposer extends FilterComposer<_$BangDatabase, BangIcon> {
  $BangIconFilterComposer(super.$state);
  ColumnFilters<String> get trigger => $state.composableBuilder(
      column: $state.table.trigger,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<Uint8List> get iconData => $state.composableBuilder(
      column: $state.table.iconData,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get fetchDate => $state.composableBuilder(
      column: $state.table.fetchDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $BangIconOrderingComposer
    extends OrderingComposer<_$BangDatabase, BangIcon> {
  $BangIconOrderingComposer(super.$state);
  ColumnOrderings<String> get trigger => $state.composableBuilder(
      column: $state.table.trigger,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<Uint8List> get iconData => $state.composableBuilder(
      column: $state.table.iconData,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get fetchDate => $state.composableBuilder(
      column: $state.table.fetchDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $BangFtsInsertCompanionBuilder = BangFtsCompanion Function({
  required String trigger,
  required String websiteName,
  Value<int> rowid,
});
typedef $BangFtsUpdateCompanionBuilder = BangFtsCompanion Function({
  Value<String> trigger,
  Value<String> websiteName,
  Value<int> rowid,
});

class $BangFtsTableManager extends RootTableManager<
    _$BangDatabase,
    BangFts,
    BangFt,
    $BangFtsFilterComposer,
    $BangFtsOrderingComposer,
    $BangFtsProcessedTableManager,
    $BangFtsInsertCompanionBuilder,
    $BangFtsUpdateCompanionBuilder> {
  $BangFtsTableManager(_$BangDatabase db, BangFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $BangFtsFilterComposer(ComposerState(db, table)),
          orderingComposer: $BangFtsOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $BangFtsProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> trigger = const Value.absent(),
            Value<String> websiteName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFtsCompanion(
            trigger: trigger,
            websiteName: websiteName,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String trigger,
            required String websiteName,
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFtsCompanion.insert(
            trigger: trigger,
            websiteName: websiteName,
            rowid: rowid,
          ),
        ));
}

class $BangFtsProcessedTableManager extends ProcessedTableManager<
    _$BangDatabase,
    BangFts,
    BangFt,
    $BangFtsFilterComposer,
    $BangFtsOrderingComposer,
    $BangFtsProcessedTableManager,
    $BangFtsInsertCompanionBuilder,
    $BangFtsUpdateCompanionBuilder> {
  $BangFtsProcessedTableManager(super.$state);
}

class $BangFtsFilterComposer extends FilterComposer<_$BangDatabase, BangFts> {
  $BangFtsFilterComposer(super.$state);
  ColumnFilters<String> get trigger => $state.composableBuilder(
      column: $state.table.trigger,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get websiteName => $state.composableBuilder(
      column: $state.table.websiteName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $BangFtsOrderingComposer
    extends OrderingComposer<_$BangDatabase, BangFts> {
  $BangFtsOrderingComposer(super.$state);
  ColumnOrderings<String> get trigger => $state.composableBuilder(
      column: $state.table.trigger,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get websiteName => $state.composableBuilder(
      column: $state.table.websiteName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$BangDatabaseManager {
  final _$BangDatabase _db;
  _$BangDatabaseManager(this._db);
  $BangSyncTableManager get bangSync =>
      $BangSyncTableManager(_db, _db.bangSync);
  $BangFrequencyTableManager get bangFrequency =>
      $BangFrequencyTableManager(_db, _db.bangFrequency);
  $BangIconTableManager get bangIcon =>
      $BangIconTableManager(_db, _db.bangIcon);
  $BangFtsTableManager get bangFts => $BangFtsTableManager(_db, _db.bangFts);
}
