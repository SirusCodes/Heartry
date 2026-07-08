import 'dart:convert';
import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:flutter_quill/quill_delta.dart';

import 'database.steps.dart';
import 'open_connection.dart';

part 'database.g.dart';

final poemRichConverter = TypeConverter.jsonb<Delta>(
  fromJson: (json) => Delta.fromJson(json as List<dynamic>),
  toJson: (delta) => delta.toJson(),
);

@DataClassName("PoemModel")
class Poem extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  DateTimeColumn get lastEdit =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  TextColumn get title => text().withDefault(const Constant(""))();
  TextColumn get poem => text()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BlobColumn get poemRich => blob()
      .withDefault(Constant(Uint8List.fromList([11])))
      .map(poemRichConverter)();
}

@DataClassName("TemplateModel")
class Templates extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get data => text()(); // Stores recursive JSON layer tree
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Poem, Templates])
class Database extends _$Database {
  Database([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();

      // Create the FTS table and triggers on a fresh install so search works
      await _createFTS5();
      await _prepopulateDefaultTemplates();
    },
    beforeOpen: (details) async {
      log(
        'BEFORE OPEN: WAS CREATED: ${details.wasCreated}, '
        'HAD UPGRADE: ${details.hadUpgrade}, FROM: ${details.versionBefore}, '
        'TO: ${details.versionNow}',
        name: 'Database',
      );
      await customStatement('PRAGMA foreign_keys = ON');
      // Only recreate triggers and rebuild if the legacy triggers
      // (using direct UPDATE) are found.
      // This ensures we only run the expensive FTS rebuild
      // once to repair corrupted databases.
      final triggerRow = await customSelect(
        "SELECT sql FROM sqlite_master WHERE type='trigger' "
        "AND name='poem_fts_update';",
      ).getSingleOrNull();

      if (triggerRow != null) {
        final triggerSql = triggerRow.read<String>('sql');
        if (triggerSql.contains('UPDATE poem_fts')) {
          await _recreateTriggersAndRebuildFTS();
        }
      }
    },
    onUpgrade: (m, from, to) async {
      log('ON UPGRADE CALLED: FROM $from TO $to', name: 'Database');
      final upgrade = stepByStep(
        from1To2: (m, schema) async {
          await customStatement('PRAGMA foreign_keys = OFF');

          // To update default type of lastEdit column
          // ignore: experimental_member_use
          await m.alterTable(TableMigration(schema.poem));

          await _createFTS5();

          await customStatement('PRAGMA foreign_keys = ON');
        },
        from2To3: (m, schema) async {
          log('RUNNING MIGRATION from2To3', name: 'Database');
          await _createFTSTableIfNotExist();
        },
        from3To4: (m, schema) async {
          log('RUNNING MIGRATION from3To4', name: 'Database');
          await _createFTSTableIfNotExist();

          await m.addColumn(poem, poem.deletedAt);
        },
        from4To5: (m, schema) async {
          log('RUNNING MIGRATION from4To5', name: 'Database');
          await m.createTable(schema.templates);
          await _prepopulateDefaultTemplates();
        },
        from5To6: (m, schema) async {
          log('RUNNING MIGRATION from5To6', name: 'Database');
          await m.addColumn(schema.poem, schema.poem.poemRich);

          // Migrate existing rows in Dart
          final rows = await customSelect('SELECT id, poem FROM poem').get();
          for (final row in rows) {
            final id = row.read<int>('id');
            final rawPoem = row.read<String>('poem');
            log('MIGRATED id: $id', name: 'Database');

            final deltaJson = jsonEncode([
              {'insert': rawPoem.endsWith('\n') ? rawPoem : '$rawPoem\n'},
            ]);

            await customStatement(
              'UPDATE poem SET poem_rich = jsonb(?) WHERE id = ?',
              [deltaJson, id],
            );
          }
        },
      );
      await upgrade(m, from, to);
    },
  );

  Future<List<PoemModel>> searchPoems(String query) async {
    String sanitized = query.trim();
    if (sanitized.endsWith('*')) {
      sanitized = sanitized.substring(0, sanitized.length - 1).trim();
    }
    if (sanitized.isEmpty) {
      return [];
    }
    final escapedQuery = sanitized.replaceAll('"', '""');
    final ftsQuery = '"$escapedQuery"*';

    return customSelect(
      'SELECT p.* FROM poem as p JOIN poem_fts as fts ON p.id = fts.rowid '
      'WHERE p.deleted_at IS NULL AND poem_fts MATCH ? ORDER BY rank LIMIT 10',
      variables: [Variable<String>(ftsQuery)],
      readsFrom: {poem},
    ).map((row) => poem.map(row.data)).get();
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

  Future<List<PoemModel>> getBinPoems() =>
      (select(poem)..where((tbl) => tbl.deletedAt.isNotNull())).get();

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
            INSERT INTO poem_fts(poem_fts, rowid, title, poem)
            VALUES ('delete', old.id, old.title, old.poem);
            INSERT INTO poem_fts(rowid, title, poem)
            VALUES (new.id, new.title, new.poem);
          END;
        ''');

      // Trigger to sync FTS table on DELETE
      await customStatement('''
          CREATE TRIGGER poem_fts_delete AFTER DELETE ON poem BEGIN
            INSERT INTO poem_fts(poem_fts, rowid, title, poem)
            VALUES ('delete', old.id, old.title, old.poem);
          END;
        ''');
    });
  }

  Future<void> _recreateTriggersAndRebuildFTS() async {
    await transaction(() async {
      await customStatement('DROP TRIGGER IF EXISTS poem_fts_insert;');
      await customStatement('DROP TRIGGER IF EXISTS poem_fts_update;');
      await customStatement('DROP TRIGGER IF EXISTS poem_fts_delete;');

      await customStatement('''
          CREATE TRIGGER poem_fts_insert AFTER INSERT ON poem BEGIN
            INSERT INTO poem_fts(rowid, title, poem)
            VALUES (new.id, new.title, new.poem);
          END;
        ''');

      await customStatement('''
          CREATE TRIGGER poem_fts_update AFTER UPDATE ON poem BEGIN
            INSERT INTO poem_fts(poem_fts, rowid, title, poem)
            VALUES ('delete', old.id, old.title, old.poem);
            INSERT INTO poem_fts(rowid, title, poem)
            VALUES (new.id, new.title, new.poem);
          END;
        ''');

      await customStatement('''
          CREATE TRIGGER poem_fts_delete AFTER DELETE ON poem BEGIN
            INSERT INTO poem_fts(poem_fts, rowid, title, poem)
            VALUES ('delete', old.id, old.title, old.poem);
          END;
        ''');

      await customStatement(
        'INSERT INTO poem_fts(poem_fts) VALUES(\'rebuild\');',
      );
    });
  }

  Future<void> _prepopulateDefaultTemplates() async {
    final defaultTemplates = [
      const TemplateModel(
        id: 1,
        name: 'Solid Background',
        data: _solidBackgroundTemplate,
        isDefault: true,
      ),
      const TemplateModel(
        id: 2,
        name: 'Gradient Background',
        data: _gradientBackgroundTemplate,
        isDefault: true,
      ),
      const TemplateModel(
        id: 3,
        name: 'Gradient Bubble Overlay',
        data: _gradientBubbleOverlayTemplate,
        isDefault: true,
      ),
      const TemplateModel(
        id: 4,
        name: 'Solid Bubble Overlay',
        data: _solidBubbleOverlayTemplate,
        isDefault: true,
      ),
      const TemplateModel(
        id: 5,
        name: 'Image Background',
        data: _imageBackgroundTemplate,
        isDefault: true,
      ),
    ];

    await batch((batch) {
      batch.insertAll(
        templates,
        defaultTemplates,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<PoemModel?> getPoemById(int id) =>
      (select(poem)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<TemplateModel>> getTemplates() => select(templates).get();

  Stream<List<TemplateModel>> getTemplatesStream() => select(templates).watch();

  Future<int> insertTemplate(TemplateModel model) =>
      into(templates).insert(model);

  Future<bool> updateTemplate(TemplateModel model) =>
      update(templates).replace(model);

  Future<int> deleteTemplate(TemplateModel model) =>
      delete(templates).delete(model);

  Future<void> insertBatchTemplates(List<TemplateModel> models) =>
      batch((batch) {
        batch.insertAll(templates, models);
      });

  Future<void> deleteAllTemplates() => delete(templates).go();
}

const String _solidBackgroundTemplate = '''
{
  "type": "solid_background",
  "color": null,
  "next": {
    "type": "page_counter",
    "next": {
      "type": "padding",
      "horizontal": 40.0,
      "vertical": 50.0,
      "next": {
        "type": "text"
      }
    }
  }
}''';

const String _gradientBackgroundTemplate = '''
{
  "type": "gradient_background",
  "gradient": null,
  "next": {
    "type": "page_counter",
    "next": {
      "type": "padding",
      "horizontal": 40.0,
      "vertical": 50.0,
      "next": {
        "type": "text"
      }
    }
  }
}''';

const String _gradientBubbleOverlayTemplate = '''
{
  "type": "gradient_background",
  "gradient": null,
  "next": {
    "type": "bubble_overlay",
    "next": {
      "type": "page_counter",
      "next": {
        "type": "padding",
        "horizontal": 40.0,
        "vertical": 50.0,
        "next": {
          "type": "frosted_glass",
          "next": {
            "type": "padding",
            "horizontal": 16.0,
            "vertical": 16.0,
            "next": {
              "type": "text"
            }
          }
        }
      }
    }
  }
}''';

const String _solidBubbleOverlayTemplate = '''
{
  "type": "solid_background",
  "color": null,
  "next": {
    "type": "bubble_overlay",
    "next": {
      "type": "page_counter",
      "next": {
        "type": "padding",
        "horizontal": 40.0,
        "vertical": 50.0,
        "next": {
          "type": "frosted_glass",
          "next": {
            "type": "padding",
            "horizontal": 16.0,
            "vertical": 16.0,
            "next": {
              "type": "text"
            }
          }
        }
      }
    }
  }
}''';

const String _imageBackgroundTemplate = '''
{
  "type": "image_background",
  "image_base64": null,
  "next": {
    "type": "blur_overlay",
    "blur": 5.0,
    "next": {
      "type": "translucent_overlay",
      "color": 4294967295,
      "opacity": 0.2,
      "next": {
        "type": "page_counter",
        "next": {
          "type": "padding",
          "horizontal": 40.0,
          "vertical": 50.0,
          "next": {
            "type": "text"
          }
        }
      }
    }
  }
}''';
