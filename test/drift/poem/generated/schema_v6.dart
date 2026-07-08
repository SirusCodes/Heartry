// dart format width=80
import 'dart:typed_data' as i2;
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
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<i2.Uint8List> poemRich =
      GeneratedColumn<i2.Uint8List>(
        'poem_rich',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
        defaultValue: const CustomExpression('X\'0b\''),
      );
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
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      poemRich: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}poem_rich'],
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
  final DateTime? deletedAt;
  final i2.Uint8List poemRich;
  const PoemData({
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
    map['poem_rich'] = Variable<i2.Uint8List>(poemRich);
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
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      poemRich: serializer.fromJson<i2.Uint8List>(json['poemRich']),
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
      'poemRich': serializer.toJson<i2.Uint8List>(poemRich),
    };
  }

  PoemData copyWith({
    Value<int?> id = const Value.absent(),
    Value<DateTime?> lastEdit = const Value.absent(),
    String? title,
    String? poem,
    Value<DateTime?> deletedAt = const Value.absent(),
    i2.Uint8List? poemRich,
  }) => PoemData(
    id: id.present ? id.value : this.id,
    lastEdit: lastEdit.present ? lastEdit.value : this.lastEdit,
    title: title ?? this.title,
    poem: poem ?? this.poem,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    poemRich: poemRich ?? this.poemRich,
  );
  PoemData copyWithCompanion(PoemCompanion data) {
    return PoemData(
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
    return (StringBuffer('PoemData(')
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
  int get hashCode => Object.hash(
    id,
    lastEdit,
    title,
    poem,
    deletedAt,
    $driftBlobEquality.hash(poemRich),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoemData &&
          other.id == this.id &&
          other.lastEdit == this.lastEdit &&
          other.title == this.title &&
          other.poem == this.poem &&
          other.deletedAt == this.deletedAt &&
          $driftBlobEquality.equals(other.poemRich, this.poemRich));
}

class PoemCompanion extends UpdateCompanion<PoemData> {
  final Value<int?> id;
  final Value<DateTime?> lastEdit;
  final Value<String> title;
  final Value<String> poem;
  final Value<DateTime?> deletedAt;
  final Value<i2.Uint8List> poemRich;
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
  static Insertable<PoemData> custom({
    Expression<int>? id,
    Expression<DateTime>? lastEdit,
    Expression<String>? title,
    Expression<String>? poem,
    Expression<DateTime>? deletedAt,
    Expression<i2.Uint8List>? poemRich,
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
    Value<i2.Uint8List>? poemRich,
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
      map['poem_rich'] = Variable<i2.Uint8List>(poemRich.value);
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

class Templates extends Table with TableInfo<Templates, TemplatesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Templates(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, data, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplatesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplatesData(
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
  Templates createAlias(String alias) {
    return Templates(attachedDatabase, alias);
  }
}

class TemplatesData extends DataClass implements Insertable<TemplatesData> {
  final int? id;
  final String name;
  final String data;
  final bool isDefault;
  const TemplatesData({
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

  factory TemplatesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplatesData(
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

  TemplatesData copyWith({
    Value<int?> id = const Value.absent(),
    String? name,
    String? data,
    bool? isDefault,
  }) => TemplatesData(
    id: id.present ? id.value : this.id,
    name: name ?? this.name,
    data: data ?? this.data,
    isDefault: isDefault ?? this.isDefault,
  );
  TemplatesData copyWithCompanion(TemplatesCompanion data) {
    return TemplatesData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      data: data.data.present ? data.data.value : this.data,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesData(')
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
      (other is TemplatesData &&
          other.id == this.id &&
          other.name == this.name &&
          other.data == this.data &&
          other.isDefault == this.isDefault);
}

class TemplatesCompanion extends UpdateCompanion<TemplatesData> {
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
  static Insertable<TemplatesData> custom({
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

class DatabaseAtV6 extends GeneratedDatabase {
  DatabaseAtV6(QueryExecutor e) : super(e);
  late final Poem poem = Poem(this);
  late final Templates templates = Templates(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [poem, templates];
  @override
  int get schemaVersion => 6;
}
