// GENERATED CODE, DO NOT EDIT BY HAND.

import 'package:moor/moor.dart';

class _Poem extends Table with TableInfo {
  _Poem(this._db, [this._alias]);
  final GeneratedDatabase _db;
  final String? _alias;
  GeneratedIntColumn? _id;
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, true,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  GeneratedDateTimeColumn? _lastEdit;
  GeneratedDateTimeColumn get lastEdit => _lastEdit ??= _constructLastEdit();
  GeneratedDateTimeColumn _constructLastEdit() {
    return GeneratedDateTimeColumn('last_edit', $tableName, true,
        defaultValue: Constant(DateTime.now()));
  }

  GeneratedTextColumn? _title;
  GeneratedTextColumn get title => _title ??= _constructTitle();
  GeneratedTextColumn _constructTitle() {
    return GeneratedTextColumn('title', $tableName, false,
        defaultValue: const Constant(""));
  }

  GeneratedTextColumn? _poem;
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
  _Poem get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'poem';
  @override
  final String actualTableName = 'poem';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Never map(Map<String, dynamic> data, {String? tablePrefix}) {
    throw UnsupportedError('TableInfo.map in schema verification code');
  }

  @override
  _Poem createAlias(String alias) {
    return _Poem(_db, alias);
  }

  @override
  bool get dontWriteConstraints => false;
}

class DatabaseAtV1 extends GeneratedDatabase {
  DatabaseAtV1(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  _Poem? _poem;
  _Poem get poem => _poem ??= _Poem(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [poem];
  @override
  int get schemaVersion => 1;
}
