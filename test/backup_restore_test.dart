import 'dart:convert';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartry/database/database.dart';
import 'package:heartry/models/backup_model/backup_model.dart';
import 'package:heartry/models/converters.dart';

void main() {
  group('Backup and Restore Null Safety Tests', () {
    test('poemRichConverter handles null gracefully without throwing', () {
      final resultNull = poemRichConverter.fromJson(null);
      expect(resultNull, isA<Delta>());

      final resultInvalid = poemRichConverter.fromJson("not a list");
      expect(resultInvalid, isA<Delta>());

      final validList = [
        {'insert': 'Hello World\n'},
      ];
      final resultValid = poemRichConverter.fromJson(validList);
      expect(resultValid.isNotEmpty, true);
      expect(resultValid.operations.first.data, 'Hello World\n');
    });

    test('PoemModelConverter handles null list safely', () {
      const converter = PoemModelConverter();
      final result = converter.fromJson(null);
      expect(result, isEmpty);
    });

    test('BackupModel deserializes legacy poem JSON with poemRich: null', () {
      final jsonMap = {
        "poems": [
          {
            "id": 1,
            "lastEdit": "2023-01-01T00:00:00.000",
            "title": "Legacy Poem",
            "poem": "Content here",
            "deletedAt": null,
            "poemRich": null,
          },
        ],
        "prefs": {
          "theme": "dark",
          "font_size": 14,
          "recent_tags": ["tag1", "tag2"],
        },
        "image": null,
        "templates": null,
      };

      final backup = BackupModel.fromJson(jsonMap);
      expect(backup.poems.length, 1);
      expect(backup.poems.first.title, "Legacy Poem");
      expect(backup.poems.first.poemRich, isA<Delta>());
    });

    test('BackupModel deserializes JSON missing poemRich key completely', () {
      final jsonMap = {
        "poems": [
          {
            "id": 2,
            "lastEdit": "2023-01-01T00:00:00.000",
            "title": "Poem without poemRich key",
            "poem": "Another poem content",
            "deletedAt": null,
          },
        ],
        "prefs": <String, dynamic>{},
        "image": null,
      };

      final backup = BackupModel.fromJson(jsonMap);
      expect(backup.poems.length, 1);
      expect(backup.poems.first.title, "Poem without poemRich key");
      expect(backup.poems.first.poemRich, isA<Delta>());
    });

    test(
      'BackupModel deserializes JSON decoded string with untyped List prefs',
      () {
        const jsonString = '''
      {
        "poems": [
          {
            "id": 3,
            "title": "Test Poem",
            "poem": "Line 1",
            "poemRich": null
          }
        ],
        "prefs": {
          "categories": ["general", "poetry"]
        }
      }
      ''';

        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        final backup = BackupModel.fromJson(jsonMap);
        expect(backup.poems.length, 1);
        expect(backup.prefs["categories"], isA<List>());
      },
    );
  });
}
