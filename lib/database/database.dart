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
}

@UseMoor(tables: [Poem])
class Database extends _$Database {
  Database() : super(openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<PoemModel>> get getPoemStream => (select(poem)
        ..orderBy(
          [(u) => OrderingTerm.desc(u.lastEdit)],
        ))
      .watch();

  Future<List<PoemModel>> get poemsFuture =>
      (select(poem)..orderBy([(u) => OrderingTerm.asc(u.id)])).get();

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
