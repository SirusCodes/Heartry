// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Poem extends Table with TableInfo<Poem, PoemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Poem(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<DateTime> lastEdit = GeneratedColumn<DateTime>(
    'last_edit',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'\''),
  );
  late final GeneratedColumn<String> poem = GeneratedColumn<String>(
    'poem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastEdit, title, poem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'poem';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoemData(
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
    );
  }

  @override
  Poem createAlias(String alias) {
    return Poem(attachedDatabase, alias);
  }
}

class PoemData extends DataClass implements Insertable<PoemData> {
  final int? id;
  final DateTime? lastEdit;
  final String title;
  final String poem;
  const PoemData({
    this.id,
    this.lastEdit,
    required this.title,
    required this.poem,
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

  factory PoemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoemData(
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

  PoemData copyWith({
    Value<int?> id = const Value.absent(),
    Value<DateTime?> lastEdit = const Value.absent(),
    String? title,
    String? poem,
  }) => PoemData(
    id: id.present ? id.value : this.id,
    lastEdit: lastEdit.present ? lastEdit.value : this.lastEdit,
    title: title ?? this.title,
    poem: poem ?? this.poem,
  );
  PoemData copyWithCompanion(PoemCompanion data) {
    return PoemData(
      id: data.id.present ? data.id.value : this.id,
      lastEdit: data.lastEdit.present ? data.lastEdit.value : this.lastEdit,
      title: data.title.present ? data.title.value : this.title,
      poem: data.poem.present ? data.poem.value : this.poem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoemData(')
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
      (other is PoemData &&
          other.id == this.id &&
          other.lastEdit == this.lastEdit &&
          other.title == this.title &&
          other.poem == this.poem);
}

class PoemCompanion extends UpdateCompanion<PoemData> {
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
  static Insertable<PoemData> custom({
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

  PoemCompanion copyWith({
    Value<int?>? id,
    Value<DateTime?>? lastEdit,
    Value<String>? title,
    Value<String>? poem,
  }) {
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

class DatabaseAtV3 extends GeneratedDatabase {
  DatabaseAtV3(QueryExecutor e) : super(e);
  late final Poem poem = Poem(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [poem];
  @override
  int get schemaVersion => 3;
}
