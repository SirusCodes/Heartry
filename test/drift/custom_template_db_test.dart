import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartry/database/database.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database pre-population and CRUD operations work', () async {
    final defaultTemplates = await db.getTemplates();
    expect(defaultTemplates.length, 5);
    expect(
      defaultTemplates.any((t) => t.isDefault && t.name == 'Solid Background'),
      isTrue,
    );

    final customTemplate = TemplateModel(
      id: 6,
      name: 'Custom Template 1',
      data: '{"type":"solid_background","color":4284613234}',
      isDefault: false,
    );

    await db.insertTemplate(customTemplate);

    final allTemplates = await db.getTemplates();
    expect(allTemplates.length, 6);
    expect(
      allTemplates.any((t) => !t.isDefault && t.name == 'Custom Template 1'),
      isTrue,
    );

    await db.deleteTemplate(customTemplate);

    final finalTemplates = await db.getTemplates();
    expect(finalTemplates.length, 5);
    expect(finalTemplates.any((t) => t.name == 'Custom Template 1'), isFalse);
  });
}
