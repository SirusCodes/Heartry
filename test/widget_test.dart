import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:heartry/utils/poem_utils.dart';

void main() {
  group('Delta to Markdown conversion tests', () {
    test('converts plain text correctly', () {
      final delta = Delta()..insert('Hello World\n');
      expect(delta.toMarkdown(), 'Hello World\n\n');
    });

    test('converts bold text correctly', () {
      final delta = Delta()
        ..insert('Hello ')
        ..insert('Bold', {'bold': true})
        ..insert(' World\n');
      expect(delta.toMarkdown(), 'Hello **Bold** World\n\n');
    });

    test('converts italic text correctly', () {
      final delta = Delta()
        ..insert('Hello ')
        ..insert('Italic', {'italic': true})
        ..insert(' World\n');
      expect(delta.toMarkdown(), 'Hello _Italic_ World\n\n');
    });

    test('converts strikethrough text correctly', () {
      final delta = Delta()
        ..insert('Hello ')
        ..insert('Strike', {'strike': true})
        ..insert(' World\n');
      expect(delta.toMarkdown(), 'Hello ~~Strike~~ World\n\n');
    });

    test('converts underline text correctly', () {
      final delta = Delta()
        ..insert('Hello ')
        ..insert('Underline', {'underline': true})
        ..insert(' World\n');
      expect(delta.toMarkdown(), 'Hello Underline World\n\n');
    });

    test('converts combined styles correctly', () {
      final delta = Delta()
        ..insert('Hello ')
        ..insert('BoldItalic', {'bold': true, 'italic': true})
        ..insert(' World\n');
      expect(delta.toMarkdown(), 'Hello **_BoldItalic_** World\n\n');
    });

    test(
      'handles leading/trailing whitespaces correctly inside formatted runs',
      () {
        final delta = Delta()
          ..insert('Hello ')
          ..insert('  Formatted  ', {'bold': true})
          ..insert(' World\n');
        expect(delta.toMarkdown(), 'Hello **  Formatted  ** World\n\n');
      },
    );

    test('adds package-default extra trailing newline', () {
      final delta = Delta()..insert('Hello World\n');
      final markdown = delta.toMarkdown();

      expect(markdown.endsWith('\n\n'), isTrue);
      expect(markdown, 'Hello World\n\n');
    });

    test('preserves intentional blank lines in content', () {
      final delta = Delta()..insert('Line 1\n\nLine 3\n');
      expect(delta.toMarkdown(), 'Line 1\n\n\n\nLine 3\n\n');
    });
  });
}
