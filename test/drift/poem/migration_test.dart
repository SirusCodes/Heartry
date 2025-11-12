// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:heartry/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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

        final db = Database(newDb.executor);

        final poem3 = PoemModel(
          id: 3,
          lastEdit: DateTime(2025, 11, 14, 12, 0, 0),
          title: 'Title 3',
          poem: 'Poem 3',
        );
        await db.insertPoem(poem3);

        expect(
          3,
          (await newDb
                  .customSelect('SELECT COUNT(*) AS c FROM poem_fts;')
                  .getSingle())
              .data['c'],
        );

        await db.updatePoem(
          PoemModel(id: 3, title: 'Updated Title 3', poem: 'Updated Poem 3'),
        );

        final allPoems = await db.getPoems();
        final ftsPeom = await db.searchPoems("Update");

        expect(
          allPoems
              .firstWhere((p) => p.id == 3)
              .copyWith(lastEdit: Value(DateTime(2025, 11, 14, 12, 0, 0)))
              .toJsonString(),
          ftsPeom.first
              .copyWith(lastEdit: Value(DateTime(2025, 11, 14, 12, 0, 0)))
              .toJsonString(),
        );

        await db.deletePoem(poem3);

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
}
