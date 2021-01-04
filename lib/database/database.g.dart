// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class PoemModel extends DataClass implements Insertable<PoemModel> {
  final int id;
  final DateTime lastEdit;
  final String title;
  final String poem;
  PoemModel(
      {@required this.id,
      @required this.lastEdit,
      @required this.title,
      @required this.poem});
  factory PoemModel.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    return PoemModel(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      lastEdit: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_edit']),
      title:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}title']),
      poem: stringType.mapFromDatabaseResponse(data['${effectivePrefix}poem']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || lastEdit != null) {
      map['last_edit'] = Variable<DateTime>(lastEdit);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || poem != null) {
      map['poem'] = Variable<String>(poem);
    }
    return map;
  }

  PoemCompanion toCompanion(bool nullToAbsent) {
    return PoemCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      lastEdit: lastEdit == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEdit),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      poem: poem == null && nullToAbsent ? const Value.absent() : Value(poem),
    );
  }

  factory PoemModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return PoemModel(
      id: serializer.fromJson<int>(json['id']),
      lastEdit: serializer.fromJson<DateTime>(json['lastEdit']),
      title: serializer.fromJson<String>(json['title']),
      poem: serializer.fromJson<String>(json['poem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastEdit': serializer.toJson<DateTime>(lastEdit),
      'title': serializer.toJson<String>(title),
      'poem': serializer.toJson<String>(poem),
    };
  }

  PoemModel copyWith({int id, DateTime lastEdit, String title, String poem}) =>
      PoemModel(
        id: id ?? this.id,
        lastEdit: lastEdit ?? this.lastEdit,
        title: title ?? this.title,
        poem: poem ?? this.poem,
      );
  @override
  String toString() {
    return (StringBuffer('PoemModel(')
          ..write('id: $id, ')
          ..write('lastEdit: $lastEdit, ')
          ..write('title: $title, ')
          ..write('poem: $poem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(id.hashCode,
      $mrjc(lastEdit.hashCode, $mrjc(title.hashCode, poem.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is PoemModel &&
          other.id == this.id &&
          other.lastEdit == this.lastEdit &&
          other.title == this.title &&
          other.poem == this.poem);
}

class PoemCompanion extends UpdateCompanion<PoemModel> {
  final Value<int> id;
  final Value<DateTime> lastEdit;
  final Value<String> title;
  final Value<String> poem;
  const PoemCompanion({
    this.id = const Value.absent(),
    this.lastEdit = const Value.absent(),
    this.title = const Value.absent(),
    this.poem = const Value.absent(),
  });
  PoemCompanion.insert({
    this.id = const Value.absent(),
    this.lastEdit = const Value.absent(),
    this.title = const Value.absent(),
    @required String poem,
  }) : poem = Value(poem);
  static Insertable<PoemModel> custom({
    Expression<int> id,
    Expression<DateTime> lastEdit,
    Expression<String> title,
    Expression<String> poem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastEdit != null) 'last_edit': lastEdit,
      if (title != null) 'title': title,
      if (poem != null) 'poem': poem,
    });
  }

  PoemCompanion copyWith(
      {Value<int> id,
      Value<DateTime> lastEdit,
      Value<String> title,
      Value<String> poem}) {
    return PoemCompanion(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      title: title ?? this.title,
      poem: poem ?? this.poem,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoemCompanion(')
          ..write('id: $id, ')
          ..write('lastEdit: $lastEdit, ')
          ..write('title: $title, ')
          ..write('poem: $poem')
          ..write(')'))
        .toString();
  }
}

class $PoemTable extends Poem with TableInfo<$PoemTable, PoemModel> {
  final GeneratedDatabase _db;
  final String _alias;
  $PoemTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _lastEditMeta = const VerificationMeta('lastEdit');
  GeneratedDateTimeColumn _lastEdit;
  @override
  GeneratedDateTimeColumn get lastEdit => _lastEdit ??= _constructLastEdit();
  GeneratedDateTimeColumn _constructLastEdit() {
    return GeneratedDateTimeColumn('last_edit', $tableName, false,
        defaultValue: Constant(DateTime.now()));
  }

  final VerificationMeta _titleMeta = const VerificationMeta('title');
  GeneratedTextColumn _title;
  @override
  GeneratedTextColumn get title => _title ??= _constructTitle();
  GeneratedTextColumn _constructTitle() {
    return GeneratedTextColumn('title', $tableName, false,
        defaultValue: const Constant(""));
  }

  final VerificationMeta _poemMeta = const VerificationMeta('poem');
  GeneratedTextColumn _poem;
  @override
  GeneratedTextColumn get poem => _poem ??= _constructPoem();
  GeneratedTextColumn _constructPoem() {
    return GeneratedTextColumn(
      'poem',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, lastEdit, title, poem];
  @override
  $PoemTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'poem';
  @override
  final String actualTableName = 'poem';
  @override
  VerificationContext validateIntegrity(Insertable<PoemModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('last_edit')) {
      context.handle(_lastEditMeta,
          lastEdit.isAcceptableOrUnknown(data['last_edit'], _lastEditMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title'], _titleMeta));
    }
    if (data.containsKey('poem')) {
      context.handle(
          _poemMeta, poem.isAcceptableOrUnknown(data['poem'], _poemMeta));
    } else if (isInserting) {
      context.missing(_poemMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoemModel map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return PoemModel.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $PoemTable createAlias(String alias) {
    return $PoemTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $PoemTable _poem;
  $PoemTable get poem => _poem ??= $PoemTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [poem];
}
