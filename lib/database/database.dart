import 'package:drift/drift.dart';

import 'database.steps.dart';
import 'open_connection.dart';

part 'database.g.dart';

@DataClassName("PoemModel")
class Poem extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  DateTimeColumn get lastEdit =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  TextColumn get title => text().withDefault(const Constant(""))();
  TextColumn get poem => text()();
}

@DriftDatabase(tables: [Poem])
class Database extends _$Database {
  Database([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await customStatement('PRAGMA foreign_keys = OFF');

        // To update default type of lastEdit column
        await m.alterTable(TableMigration(schema.poem));

        await transaction(() async {
          await customStatement('''
          CREATE VIRTUAL TABLE poem_fts USING fts5(
            title,
            poem,
            content='poem',
            content_rowid='id'
          );
        ''');

          await customStatement(
            'INSERT INTO poem_fts(poem_fts) VALUES(\'rebuild\')',
          );

          // Trigger to sync FTS table on INSERT
          await customStatement('''
          CREATE TRIGGER poem_fts_insert AFTER INSERT ON poem BEGIN
            INSERT INTO poem_fts(rowid, title, poem)
            VALUES (new.id, new.title, new.poem);
          END;
        ''');

          // Trigger to sync FTS table on UPDATE
          await customStatement('''
          CREATE TRIGGER poem_fts_update AFTER UPDATE ON poem BEGIN
            UPDATE poem_fts SET title = new.title, poem = new.poem
            WHERE rowid = new.id;
          END;
        ''');

          // Trigger to sync FTS table on DELETE
          await customStatement('''
          CREATE TRIGGER poem_fts_delete AFTER DELETE ON poem BEGIN
            DELETE FROM poem_fts WHERE rowid = old.id;
          END;
        ''');
        });
      },
    ),
  );

  Future<List<PoemModel>> searchPoems(String query) {
    final ftsQuery = '$query*';
    return customSelect(
      'SELECT p.* FROM poem as p JOIN poem_fts as fts ON p.id = fts.rowid '
      'WHERE poem_fts MATCH ? ORDER BY rank LIMIT 10',
      variables: [Variable<String>(ftsQuery)],
      readsFrom: {poem},
    ).map((row) => PoemModel.fromJson(row.data)).get();
  }

  Stream<List<PoemModel>> get getPoemStream =>
      (select(poem)..orderBy([(u) => OrderingTerm.desc(u.lastEdit)])).watch();

  Future<List<PoemModel>> getPoems() =>
      (select(poem)..orderBy([(u) => OrderingTerm.desc(u.lastEdit)])).get();

  Future<void> insertBatchPoems(List<PoemModel> models) => batch((batch) {
    batch.insertAll(poem, models);
  });

  Future<int> deleteAllPoems() => delete(poem).go();

  Future<int> insertPoem(PoemModel model) {
    return into(poem).insert(model);
  }

  Future<int> updatePoem(PoemModel model) {
    return (update(
      poem,
    )..where((tbl) => tbl.id.equals(model.id!))).write(model);
  }

  Future<int> deletePoem(PoemModel model) {
    return delete(poem).delete(model);
  }
}
