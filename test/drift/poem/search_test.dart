import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartry/database/database.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Database db;

  setUp(() {
    db = Database(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('FTS5 Search with special characters does not crash', () async {
    // Insert a poem
    final poem = PoemModel(id: 1, title: 'చందమామ', poem: 'మామా. చందమామ రావే');
    await db.insertPoem(poem);

    // This search should not throw a SqliteException
    final results1 = await db.searchPoems('మామా. చందమామ*');
    expect(results1.length, 1);

    // Other test cases with special characters
    final results2 = await db.searchPoems('మామా.');
    expect(results2.length, 1);

    final results3 = await db.searchPoems('"మామా"');
    expect(results3.length, 1);
  });

  test('FTS5 table keeps in sync after update and delete', () async {
    final poem = PoemModel(id: 1, title: 'Title', poem: 'Original body');
    await db.insertPoem(poem);

    var results = await db.searchPoems('Original');
    expect(results.length, 1);

    await db.updatePoem(
      PoemModel(id: 1, title: 'Updated Title', poem: 'Updated body'),
    );

    results = await db.searchPoems('Original');
    expect(results.length, 0);

    results = await db.searchPoems('Updated');
    expect(results.length, 1);

    await db.deletePoem(
      PoemModel(id: 1, title: 'Updated Title', poem: 'Updated body'),
    );

    results = await db.searchPoems('Updated');
    expect(results.length, 0);
  });

  test(
    'Upgrades legacy FTS triggers to correct triggers and rebuilds correctly',
    () async {
      final file = File('${Directory.current.path}/test_upgrade.db');
      if (await file.exists()) {
        await file.delete();
      }

      // 1. Open database and let it create the tables
      var dbToSetup = Database(NativeDatabase(file));
      // Let's force it to open by running a query
      await dbToSetup.select(dbToSetup.poem).get();

      // Insert a poem
      final poem = PoemModel(id: 1, title: 'Title', poem: 'Original body');
      await dbToSetup.insertPoem(poem);

      // 2. Force-replace triggers with the legacy malformed triggers
      await dbToSetup.customStatement(
        'DROP TRIGGER IF EXISTS poem_fts_update;',
      );
      await dbToSetup.customStatement(
        'DROP TRIGGER IF EXISTS poem_fts_delete;',
      );
      await dbToSetup.customStatement('''
      CREATE TRIGGER poem_fts_update AFTER UPDATE ON poem BEGIN
        UPDATE poem_fts SET title = new.title, poem = new.poem
        WHERE rowid = new.id;
      END;
    ''');
      await dbToSetup.customStatement('''
      CREATE TRIGGER poem_fts_delete AFTER DELETE ON poem BEGIN
        DELETE FROM poem_fts WHERE rowid = old.id;
      END;
    ''');

      // Verify that updating a poem now fails with the malformed exception
      // (reproducing the legacy crash)
      expect(
        () => dbToSetup.updatePoem(
          PoemModel(id: 1, title: 'Updated Title', poem: 'Updated body'),
        ),
        throwsA(isA<SqliteException>()),
      );

      // Close the old database connection
      await dbToSetup.close();

      // 3. Open a new database connection
      // (simulating app start with upgraded code)
      var dbToVerify = Database(NativeDatabase(file));

      // Open it, which triggers the beforeOpen hook to repair triggers
      await dbToVerify.select(dbToVerify.poem).get();

      // 4. Verify the triggers were corrected and update/delete now work perfectly without crashing
      await dbToVerify.updatePoem(
        PoemModel(id: 1, title: 'Updated Title', poem: 'Updated body'),
      );

      final results = await dbToVerify.searchPoems('Updated');
      expect(results.length, 1);

      await dbToVerify.deletePoem(
        PoemModel(id: 1, title: 'Updated Title', poem: 'Updated body'),
      );

      await dbToVerify.close();
      if (await file.exists()) {
        await file.delete();
      }
    },
  );
}
