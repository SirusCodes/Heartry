// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PoemTable extends Poem with TableInfo<$PoemTable, PoemModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoemTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    true,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lastEditMeta = const VerificationMeta(
    'lastEdit',
  );
  @override
  late final GeneratedColumn<DateTime> lastEdit = GeneratedColumn<DateTime>(
    'last_edit',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  static const VerificationMeta _poemMeta = const VerificationMeta('poem');
  @override
  late final GeneratedColumn<String> poem = GeneratedColumn<String>(
    'poem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Delta, Uint8List> poemRich =
      GeneratedColumn<Uint8List>(
        'poem_rich',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
        defaultValue: Constant(Uint8List.fromList([11])),
      ).withConverter<Delta>($PoemTable.$converterpoemRich);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastEdit,
    title,
    poem,
    deletedAt,
    poemRich,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'poem';
  @override
  VerificationContext validateIntegrity(
    Insertable<PoemModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_edit')) {
      context.handle(
        _lastEditMeta,
        lastEdit.isAcceptableOrUnknown(data['last_edit']!, _lastEditMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('poem')) {
      context.handle(
        _poemMeta,
        poem.isAcceptableOrUnknown(data['poem']!, _poemMeta),
      );
    } else if (isInserting) {
      context.missing(_poemMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoemModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoemModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      ),
      lastEdit: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_edit'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      poem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poem'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      poemRich: $PoemTable.$converterpoemRich.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}poem_rich'],
        )!,
      ),
    );
  }

  @override
  $PoemTable createAlias(String alias) {
    return $PoemTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Delta, Uint8List, Object?> $converterpoemRich =
      poemRichConverter;
}

class PoemModel extends DataClass implements Insertable<PoemModel> {
  final int? id;
  final DateTime? lastEdit;
  final String title;
  final String poem;
  final DateTime? deletedAt;
  final Delta poemRich;
  const PoemModel({
    this.id,
    this.lastEdit,
    required this.title,
    required this.poem,
    this.deletedAt,
    required this.poemRich,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || lastEdit != null) {
      map['last_edit'] = Variable<DateTime>(lastEdit);
    }
    map['title'] = Variable<String>(title);
    map['poem'] = Variable<String>(poem);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['poem_rich'] = Variable<Uint8List>(
        $PoemTable.$converterpoemRich.toSql(poemRich),
      );
    }
    return map;
  }

  PoemCompanion toCompanion(bool nullToAbsent) {
    return PoemCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      lastEdit: lastEdit == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEdit),
      title: Value(title),
      poem: Value(poem),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      poemRich: Value(poemRich),
    );
  }

  factory PoemModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoemModel(
      id: serializer.fromJson<int?>(json['id']),
      lastEdit: serializer.fromJson<DateTime?>(json['lastEdit']),
      title: serializer.fromJson<String>(json['title']),
      poem: serializer.fromJson<String>(json['poem']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      poemRich: $PoemTable.$converterpoemRich.fromJson(
        serializer.fromJson<Object?>(json['poemRich']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'lastEdit': serializer.toJson<DateTime?>(lastEdit),
      'title': serializer.toJson<String>(title),
      'poem': serializer.toJson<String>(poem),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'poemRich': serializer.toJson<Object?>(
        $PoemTable.$converterpoemRich.toJson(poemRich),
      ),
    };
  }

  PoemModel copyWith({
    Value<int?> id = const Value.absent(),
    Value<DateTime?> lastEdit = const Value.absent(),
    String? title,
    String? poem,
    Value<DateTime?> deletedAt = const Value.absent(),
    Delta? poemRich,
  }) => PoemModel(
    id: id.present ? id.value : this.id,
    lastEdit: lastEdit.present ? lastEdit.value : this.lastEdit,
    title: title ?? this.title,
    poem: poem ?? this.poem,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    poemRich: poemRich ?? this.poemRich,
  );
  PoemModel copyWithCompanion(PoemCompanion data) {
    return PoemModel(
      id: data.id.present ? data.id.value : this.id,
      lastEdit: data.lastEdit.present ? data.lastEdit.value : this.lastEdit,
      title: data.title.present ? data.title.value : this.title,
      poem: data.poem.present ? data.poem.value : this.poem,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      poemRich: data.poemRich.present ? data.poemRich.value : this.poemRich,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoemModel(')
          ..write('id: $id, ')
          ..write('lastEdit: $lastEdit, ')
          ..write('title: $title, ')
          ..write('poem: $poem, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('poemRich: $poemRich')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lastEdit, title, poem, deletedAt, poemRich);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoemModel &&
          other.id == this.id &&
          other.lastEdit == this.lastEdit &&
          other.title == this.title &&
          other.poem == this.poem &&
          other.deletedAt == this.deletedAt &&
          other.poemRich == this.poemRich);
}

class PoemCompanion extends UpdateCompanion<PoemModel> {
  final Value<int?> id;
  final Value<DateTime?> lastEdit;
  final Value<String> title;
  final Value<String> poem;
  final Value<DateTime?> deletedAt;
  final Value<Delta> poemRich;
  const PoemCompanion({
    this.id = const Value.absent(),
    this.lastEdit = const Value.absent(),
    this.title = const Value.absent(),
    this.poem = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.poemRich = const Value.absent(),
  });
  PoemCompanion.insert({
    this.id = const Value.absent(),
    this.lastEdit = const Value.absent(),
    this.title = const Value.absent(),
    required String poem,
    this.deletedAt = const Value.absent(),
    this.poemRich = const Value.absent(),
  }) : poem = Value(poem);
  static Insertable<PoemModel> custom({
    Expression<int>? id,
    Expression<DateTime>? lastEdit,
    Expression<String>? title,
    Expression<String>? poem,
    Expression<DateTime>? deletedAt,
    Expression<Uint8List>? poemRich,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastEdit != null) 'last_edit': lastEdit,
      if (title != null) 'title': title,
      if (poem != null) 'poem': poem,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (poemRich != null) 'poem_rich': poemRich,
    });
  }

  PoemCompanion copyWith({
    Value<int?>? id,
    Value<DateTime?>? lastEdit,
    Value<String>? title,
    Value<String>? poem,
    Value<DateTime?>? deletedAt,
    Value<Delta>? poemRich,
  }) {
    return PoemCompanion(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      title: title ?? this.title,
      poem: poem ?? this.poem,
      deletedAt: deletedAt ?? this.deletedAt,
      poemRich: poemRich ?? this.poemRich,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastEdit.present) {
      map['last_edit'] = Variable<DateTime>(lastEdit.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (poem.present) {
      map['poem'] = Variable<String>(poem.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (poemRich.present) {
      map['poem_rich'] = Variable<Uint8List>(
        $PoemTable.$converterpoemRich.toSql(poemRich.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoemCompanion(')
          ..write('id: $id, ')
          ..write('lastEdit: $lastEdit, ')
          ..write('title: $title, ')
          ..write('poem: $poem, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('poemRich: $poemRich')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, TemplateModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    true,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, data, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class TemplateModel extends DataClass implements Insertable<TemplateModel> {
  final int? id;
  final String name;
  final String data;
  final bool isDefault;
  const TemplateModel({
    this.id,
    required this.name,
    required this.data,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['name'] = Variable<String>(name);
    map['data'] = Variable<String>(data);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: Value(name),
      data: Value(data),
      isDefault: Value(isDefault),
    );
  }

  factory TemplateModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateModel(
      id: serializer.fromJson<int?>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      data: serializer.fromJson<String>(json['data']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'name': serializer.toJson<String>(name),
      'data': serializer.toJson<String>(data),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  TemplateModel copyWith({
    Value<int?> id = const Value.absent(),
    String? name,
    String? data,
    bool? isDefault,
  }) => TemplateModel(
    id: id.present ? id.value : this.id,
    name: name ?? this.name,
    data: data ?? this.data,
    isDefault: isDefault ?? this.isDefault,
  );
  TemplateModel copyWithCompanion(TemplatesCompanion data) {
    return TemplateModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      data: data.data.present ? data.data.value : this.data,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('data: $data, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, data, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.data == this.data &&
          other.isDefault == this.isDefault);
}

class TemplatesCompanion extends UpdateCompanion<TemplateModel> {
  final Value<int?> id;
  final Value<String> name;
  final Value<String> data;
  final Value<bool> isDefault;
  const TemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.data = const Value.absent(),
    this.isDefault = const Value.absent(),
  });
  TemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String data,
    this.isDefault = const Value.absent(),
  }) : name = Value(name),
       data = Value(data);
  static Insertable<TemplateModel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? data,
    Expression<bool>? isDefault,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (isDefault != null) 'is_default': isDefault,
    });
  }

  TemplatesCompanion copyWith({
    Value<int?>? id,
    Value<String>? name,
    Value<String>? data,
    Value<bool>? isDefault,
  }) {
    return TemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('data: $data, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $PoemTable poem = $PoemTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [poem, templates];
}

typedef $$PoemTableCreateCompanionBuilder =
    PoemCompanion Function({
      Value<int?> id,
      Value<DateTime?> lastEdit,
      Value<String> title,
      required String poem,
      Value<DateTime?> deletedAt,
      Value<Delta> poemRich,
    });
typedef $$PoemTableUpdateCompanionBuilder =
    PoemCompanion Function({
      Value<int?> id,
      Value<DateTime?> lastEdit,
      Value<String> title,
      Value<String> poem,
      Value<DateTime?> deletedAt,
      Value<Delta> poemRich,
    });

class $$PoemTableFilterComposer extends Composer<_$Database, $PoemTable> {
  $$PoemTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastEdit => $composableBuilder(
    column: $table.lastEdit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poem => $composableBuilder(
    column: $table.poem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Delta, Delta, Uint8List> get poemRich =>
      $composableBuilder(
        column: $table.poemRich,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$PoemTableOrderingComposer extends Composer<_$Database, $PoemTable> {
  $$PoemTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastEdit => $composableBuilder(
    column: $table.lastEdit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poem => $composableBuilder(
    column: $table.poem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get poemRich => $composableBuilder(
    column: $table.poemRich,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PoemTableAnnotationComposer extends Composer<_$Database, $PoemTable> {
  $$PoemTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastEdit =>
      $composableBuilder(column: $table.lastEdit, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get poem =>
      $composableBuilder(column: $table.poem, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Delta, Uint8List> get poemRich =>
      $composableBuilder(column: $table.poemRich, builder: (column) => column);
}

class $$PoemTableTableManager
    extends
        RootTableManager<
          _$Database,
          $PoemTable,
          PoemModel,
          $$PoemTableFilterComposer,
          $$PoemTableOrderingComposer,
          $$PoemTableAnnotationComposer,
          $$PoemTableCreateCompanionBuilder,
          $$PoemTableUpdateCompanionBuilder,
          (PoemModel, BaseReferences<_$Database, $PoemTable, PoemModel>),
          PoemModel,
          PrefetchHooks Function()
        > {
  $$PoemTableTableManager(_$Database db, $PoemTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoemTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoemTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoemTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                Value<DateTime?> lastEdit = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> poem = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<Delta> poemRich = const Value.absent(),
              }) => PoemCompanion(
                id: id,
                lastEdit: lastEdit,
                title: title,
                poem: poem,
                deletedAt: deletedAt,
                poemRich: poemRich,
              ),
          createCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                Value<DateTime?> lastEdit = const Value.absent(),
                Value<String> title = const Value.absent(),
                required String poem,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<Delta> poemRich = const Value.absent(),
              }) => PoemCompanion.insert(
                id: id,
                lastEdit: lastEdit,
                title: title,
                poem: poem,
                deletedAt: deletedAt,
                poemRich: poemRich,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PoemTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $PoemTable,
      PoemModel,
      $$PoemTableFilterComposer,
      $$PoemTableOrderingComposer,
      $$PoemTableAnnotationComposer,
      $$PoemTableCreateCompanionBuilder,
      $$PoemTableUpdateCompanionBuilder,
      (PoemModel, BaseReferences<_$Database, $PoemTable, PoemModel>),
      PoemModel,
      PrefetchHooks Function()
    >;
typedef $$TemplatesTableCreateCompanionBuilder =
    TemplatesCompanion Function({
      Value<int?> id,
      required String name,
      required String data,
      Value<bool> isDefault,
    });
typedef $$TemplatesTableUpdateCompanionBuilder =
    TemplatesCompanion Function({
      Value<int?> id,
      Value<String> name,
      Value<String> data,
      Value<bool> isDefault,
    });

class $$TemplatesTableFilterComposer
    extends Composer<_$Database, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TemplatesTableOrderingComposer
    extends Composer<_$Database, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemplatesTableAnnotationComposer
    extends Composer<_$Database, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$TemplatesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TemplatesTable,
          TemplateModel,
          $$TemplatesTableFilterComposer,
          $$TemplatesTableOrderingComposer,
          $$TemplatesTableAnnotationComposer,
          $$TemplatesTableCreateCompanionBuilder,
          $$TemplatesTableUpdateCompanionBuilder,
          (
            TemplateModel,
            BaseReferences<_$Database, $TemplatesTable, TemplateModel>,
          ),
          TemplateModel,
          PrefetchHooks Function()
        > {
  $$TemplatesTableTableManager(_$Database db, $TemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
              }) => TemplatesCompanion(
                id: id,
                name: name,
                data: data,
                isDefault: isDefault,
              ),
          createCompanionCallback:
              ({
                Value<int?> id = const Value.absent(),
                required String name,
                required String data,
                Value<bool> isDefault = const Value.absent(),
              }) => TemplatesCompanion.insert(
                id: id,
                name: name,
                data: data,
                isDefault: isDefault,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TemplatesTable,
      TemplateModel,
      $$TemplatesTableFilterComposer,
      $$TemplatesTableOrderingComposer,
      $$TemplatesTableAnnotationComposer,
      $$TemplatesTableCreateCompanionBuilder,
      $$TemplatesTableUpdateCompanionBuilder,
      (
        TemplateModel,
        BaseReferences<_$Database, $TemplatesTable, TemplateModel>,
      ),
      TemplateModel,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$PoemTableTableManager get poem => $$PoemTableTableManager(_db, _db.poem);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
}
