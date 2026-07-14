import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:heartry/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = Database(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    final oldPoemData = <v1.PoemData>[
      v1.PoemData(
        id: 1,
        lastEdit: DateTime(2025, 11, 13, 12, 0, 0),
        title: 'Title 1',
        poem: 'Poem 1',
      ),
      v1.PoemData(
        id: 2,
        lastEdit: DateTime(2025, 11, 13, 12, 0, 0),
        title: 'Title 2',
        poem: 'Poem 2',
      ),
    ];
    final expectedNewPoemData = oldPoemData;

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: Database.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.poem, oldPoemData);
      },
      validateItems: (newDb) async {
        final data = await newDb.select(newDb.poem).get();
        for (int i = 0; i < expectedNewPoemData.length; i++) {
          expect(data[i].toJsonString(), expectedNewPoemData[i].toJsonString());
        }

        // Is foreign keys are preserved
        expect(
          1,
          (await newDb.customSelect('PRAGMA foreign_keys;').getSingle())
              .data['foreign_keys'],
        );

        expect(
          2,
          (await newDb
                  .customSelect('SELECT COUNT(*) AS c FROM poem_fts;')
                  .getSingle())
              .data['c'],
        );

        await newDb
            .customSelect('''
            SELECT rowid, title, poem FROM poem_fts
            WHERE poem_fts MATCH '1';
            ''')
            .getSingle()
            .then((row) {
              expect(row.data['rowid'], 1);
              expect(row.data['title'], 'Title 1');
              expect(row.data['poem'], 'Poem 1');
            });

        final version = await newDb
            .customSelect('PRAGMA user_version;')
            .getSingle();
        log(
          'DATABASE VERSION IN TEST: ${version.data['user_version']}',
          name: 'migration_test',
        );

        await newDb
            .into(newDb.poem)
            .insert(
              v2.PoemCompanion.insert(
                id: const Value(3),
                lastEdit: Value(DateTime(2025, 11, 14, 12, 0, 0)),
                title: const Value('Title 3'),
                poem: 'Poem 3',
              ),
            );

        expect(
          3,
          (await newDb
                  .customSelect('SELECT COUNT(*) AS c FROM poem_fts;')
                  .getSingle())
              .data['c'],
        );

        await (newDb.update(newDb.poem)..where((t) => t.id.equals(3))).write(
          v2.PoemCompanion(
            title: const Value('Updated Title 3'),
            poem: const Value('Updated Poem 3'),
          ),
        );

        final ftsRows = await newDb
            .customSelect(
              'SELECT p.* FROM poem as p '
              'JOIN poem_fts as fts ON p.id = fts.rowid '
              'WHERE poem_fts MATCH ?',
              variables: [Variable<String>('Updated*')],
            )
            .get();

        expect(ftsRows.length, 1);
        final firstFtsPoem = ftsRows.first;
        expect(firstFtsPoem.read<String>('title'), 'Updated Title 3');
        expect(firstFtsPoem.read<String>('poem'), 'Updated Poem 3');

        await (newDb.delete(newDb.poem)..where((t) => t.id.equals(3))).go();

        expect(
          2,
          (await newDb
                  .customSelect('SELECT COUNT(*) AS c FROM poem_fts;')
                  .getSingle())
              .data['c'],
        );
      },
    );
  });

  test('migration from v3 to v4 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    final oldPoemData = <v3.PoemData>[
      v3.PoemData(
        id: 1,
        lastEdit: DateTime(2025, 11, 13, 12, 0, 0),
        title: 'Title 1',
        poem: 'Poem 1',
      ),
      v3.PoemData(
        id: 2,
        lastEdit: DateTime(2025, 11, 13, 12, 0, 0),
        title: 'Title 2',
        poem: 'Poem 2',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: Database.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.poem, oldPoemData);
      },
      validateItems: (newDb) async {
        final db = Database(newDb.executor);
        final poems = await db.getPoems();
        for (int i = 0; i < poems.length; i++) {
          expect(poems[i].deletedAt, null);
        }

        await db.softDeletePoem(poems.first);

        final updatedPoems = await db.getPoems();
        expect(updatedPoems.length, poems.length - 1);

        final binPoems = await db.getBinPoems();
        expect(binPoems.length, 1);
        expect(binPoems.first.id, poems.first.id);
        expect(binPoems.first.deletedAt, isNot(null));

        final search = await db.searchPoems('1');
        expect(search.length, 0);
      },
    );
  });

  test('migration from v5 to v6 does not corrupt data', () async {
    final oldPoemData = <v5.PoemData>[
      v5.PoemData(
        id: 1,
        lastEdit: DateTime(2025, 11, 13, 12, 0, 0),
        title: 'Title 1',
        poem: 'Poem 1',
      ),
      v5.PoemData(
        id: 2,
        lastEdit: DateTime(2025, 11, 13, 12, 0, 0),
        title: 'Title 2',
        poem: 'Poem 2',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: Database.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.poem, oldPoemData);
      },
      validateItems: (newDb) async {
        final db = Database(newDb.executor);
        final poems = await db.getPoems();
        expect(poems.length, 2);

        // Verify poemRich is populated with converted rich-text delta JSON
        expect(poems.firstWhere((p) => p.id == 1).poemRich.toJson(), [
          {'insert': 'Poem 1\n'},
        ]);
        expect(poems.firstWhere((p) => p.id == 2).poemRich.toJson(), [
          {'insert': 'Poem 2\n'},
        ]);

        // Verify we can update and retrieve poemRich with rich text
        final updatedPoem = poems.first.copyWith(
          poemRich: Delta()..insert('Hello\n'),
        );
        await db.updatePoem(updatedPoem);

        final readPoems = await db.getPoems();
        final firstRead = readPoems.firstWhere((p) => p.id == updatedPoem.id);
        expect(firstRead.poemRich.toJson(), [
          {'insert': 'Hello\n'},
        ]);
      },
    );
  });

  test(
    'migration from v5 to v6 succeeds if poem_rich column already exists',
    () async {
      final schema = await verifier.schemaAt(5);

      // Setup: open connection as v5 database, insert data,
      // and manually alter schema
      {
        final connection = schema.newConnection();
        final oldDb = v5.DatabaseAtV5(connection);

        // Insert some data in v5 db
        await oldDb
            .into(oldDb.poem)
            .insert(
              v5.PoemData(
                id: 1,
                lastEdit: DateTime(2025, 11, 13, 12, 0, 0),
                title: 'Title 1',
                poem: 'Poem 1',
              ),
            );

        // Manually add the column to simulate a partially completed/crashed migration
        await oldDb.customStatement(
          'ALTER TABLE "poem" ADD COLUMN "poem_rich" '
          'BLOB NOT NULL DEFAULT (X\'0b\');',
        );

        await oldDb.close();
      }

      // Migration and verification: open latest Database with a
      // new connection to the same file
      {
        final connection = schema.newConnection();
        final db = Database(connection);
        final poems = await db.getPoems();
        expect(poems.length, 1);

        // Verify poemRich is populated with converted rich-text delta JSON
        expect(poems.first.poemRich.toJson(), [
          {'insert': 'Poem 1\n'},
        ]);
        await db.close();
      }
    },
  );
}
