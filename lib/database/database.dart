import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';

import 'open_connection.dart';

part 'database.g.dart';

@DataClassName("PoemModel")
class Poem extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  DateTimeColumn get lastEdit => dateTime().nullable().withDefault(
        Constant(DateTime.now()),
      )();
  TextColumn get title => text().withDefault(const Constant(""))();
  TextColumn get poem => text()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
}

@UseMoor(tables: [Poem])
class Database extends _$Database {
  Database() : super(openConnection());

  @visibleForTesting
  Database.connect(DatabaseConnection dbConnection)
      : super(dbConnection.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            // secrets was added in 2.
            await m.addColumn(poem, poem.isSecret);
          }
        },
      );

  Stream<List<PoemModel>> get getPoemStream => (select(poem)
        ..orderBy(
          [(u) => OrderingTerm.desc(u.lastEdit)],
        ))
      .watch();

  Future<int> insertPoem(PoemModel model) {
    return into(poem).insert(model);
  }

  Future<int> updatePoem(PoemModel model) {
    return (update(poem)..where((tbl) => tbl.id.equals(model.id))).write(model);
  }

  Future<int> deletePoem(PoemModel model) {
    return delete(poem).delete(model);
  }
}
