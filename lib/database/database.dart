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
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Poem])
class Database extends _$Database {
  Database([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();

      // Create the FTS table and triggers on a fwresh install so search works
      await _createFTS5();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await customStatement('PRAGMA foreign_keys = OFF');

        // To update default type of lastEdit column
        await m.alterTable(TableMigration(schema.poem));

        await _createFTS5();

        await customStatement('PRAGMA foreign_keys = ON');
      },
      from2To3: (m, schema) async {
        await _createFTSTableIfNotExist();
      },
      from3To4: (m, schema) async {
        await _createFTSTableIfNotExist();

        await m.addColumn(poem, poem.deletedAt);
      },
    ),
  );

  Future<List<PoemModel>> searchPoems(String query) async {
    final ftsQuery = '$query*';
    final hasDeletedAt = await _poemHasDeletedAt();

    final whereClause = hasDeletedAt
        ? 'WHERE p.deleted_at IS NULL AND poem_fts MATCH ?'
        : 'WHERE poem_fts MATCH ?';

    return customSelect(
      'SELECT p.* FROM poem as p JOIN poem_fts as fts ON p.id = fts.rowid '
      '$whereClause ORDER BY rank LIMIT 10',
      variables: [Variable<String>(ftsQuery)],
      readsFrom: {poem},
    ).map((row) => PoemModel.fromJson(row.data)).get();
  }

  Future<bool> _poemHasDeletedAt() async {
    final columns = await customSelect('PRAGMA table_info(poem);').get();
    return columns.any((row) => row.data['name'] == 'deleted_at');
  }

  Stream<List<PoemModel>> get getPoemStream =>
      (select(poem)
            ..where((tbl) => tbl.deletedAt.isNull())
            ..orderBy([(u) => OrderingTerm.desc(u.lastEdit)]))
          .watch();

  Stream<List<PoemModel>> get getBin =>
      (select(poem)
            ..where((tbl) => tbl.deletedAt.isNotNull())
            ..orderBy([(u) => OrderingTerm.desc(u.deletedAt)]))
          .watch();

  Future<List<PoemModel>> getPoems() =>
      (select(poem)
            ..where((tbl) => tbl.deletedAt.isNull())
            ..orderBy([(u) => OrderingTerm.desc(u.lastEdit)]))
          .get();

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

  Future<int> softDeletePoem(PoemModel model) {
    final updatedModel = model.copyWith(deletedAt: Value(DateTime.now()));
    return updatePoem(updatedModel);
  }

  Future<int> deletePoem(PoemModel model) {
    return delete(poem).delete(model);
  }

  Future<int> softDeletePoems(Iterable<PoemModel> models) {
    return (update(poem)..where((tbl) => tbl.id.isIn(models.map((e) => e.id!))))
        .write(PoemCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<int> restorePoems(Iterable<PoemModel> models) {
    return (update(poem)..where((tbl) => tbl.id.isIn(models.map((e) => e.id!))))
        .write(PoemCompanion(deletedAt: const Value(null)));
  }

  Future<int> deleteBinAfter30Days() {
    // soft delete date + 30 days <= current date
    // => deletedAt <= current date - 30 days
    final pastDate = DateTime.now().subtract(const Duration(days: 30));

    return (delete(
      poem,
    )..where((tbl) => tbl.deletedAt.isSmallerOrEqualValue(pastDate))).go();
  }

  Future<int> hardDeletePoems(Iterable<PoemModel> models) {
    return (delete(
      poem,
    )..where((tbl) => tbl.id.isIn(models.map((e) => e.id!)))).go();
  }

  Future<void> _createFTSTableIfNotExist() async {
    final ftsExists = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='poem_fts';",
    ).get();

    if (ftsExists.isEmpty) {
      await _createFTS5();
    }
  }

  Future<void> _createFTS5() async {
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
  }
}
