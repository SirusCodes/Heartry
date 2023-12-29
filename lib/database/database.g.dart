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
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _lastEditMeta =
      const VerificationMeta('lastEdit');
  @override
  late final GeneratedColumn<DateTime> lastEdit = GeneratedColumn<DateTime>(
      'last_edit', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  static const VerificationMeta _poemMeta = const VerificationMeta('poem');
  @override
  late final GeneratedColumn<String> poem = GeneratedColumn<String>(
      'poem', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, lastEdit, title, poem];
  @override
  String get aliasedName => _alias ?? 'poem';
  @override
  String get actualTableName => 'poem';
  @override
  VerificationContext validateIntegrity(Insertable<PoemModel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_edit')) {
      context.handle(_lastEditMeta,
          lastEdit.isAcceptableOrUnknown(data['last_edit']!, _lastEditMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('poem')) {
      context.handle(
          _poemMeta, poem.isAcceptableOrUnknown(data['poem']!, _poemMeta));
    } else if (isInserting) {
      context.missing(_poemMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoemModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoemModel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      lastEdit: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_edit']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      poem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poem'])!,
    );
  }

  @override
  $PoemTable createAlias(String alias) {
    return $PoemTable(attachedDatabase, alias);
  }
}

class PoemModel extends DataClass implements Insertable<PoemModel> {
  final int? id;
  final DateTime? lastEdit;
  final String title;
  final String poem;
  const PoemModel(
      {this.id, this.lastEdit, required this.title, required this.poem});
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
    );
  }

  factory PoemModel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoemModel(
      id: serializer.fromJson<int?>(json['id']),
      lastEdit: serializer.fromJson<DateTime?>(json['lastEdit']),
      title: serializer.fromJson<String>(json['title']),
      poem: serializer.fromJson<String>(json['poem']),
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
    };
  }

  PoemModel copyWith(
          {Value<int?> id = const Value.absent(),
          Value<DateTime?> lastEdit = const Value.absent(),
          String? title,
          String? poem}) =>
      PoemModel(
        id: id.present ? id.value : this.id,
        lastEdit: lastEdit.present ? lastEdit.value : this.lastEdit,
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
  int get hashCode => Object.hash(id, lastEdit, title, poem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoemModel &&
          other.id == this.id &&
          other.lastEdit == this.lastEdit &&
          other.title == this.title &&
          other.poem == this.poem);
}

class PoemCompanion extends UpdateCompanion<PoemModel> {
  final Value<int?> id;
  final Value<DateTime?> lastEdit;
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
    required String poem,
  }) : poem = Value(poem);
  static Insertable<PoemModel> custom({
    Expression<int>? id,
    Expression<DateTime>? lastEdit,
    Expression<String>? title,
    Expression<String>? poem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastEdit != null) 'last_edit': lastEdit,
      if (title != null) 'title': title,
      if (poem != null) 'poem': poem,
    });
  }

  PoemCompanion copyWith(
      {Value<int?>? id,
      Value<DateTime?>? lastEdit,
      Value<String>? title,
      Value<String>? poem}) {
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

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  late final $PoemTable poem = $PoemTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [poem];
}
