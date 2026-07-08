import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown_quill/markdown_quill.dart';

extension PoemDeltaExt on Delta {
  String toMarkdown() => deltaToMarkdown(this);

  String toPlainText() {
    final buffer = StringBuffer();
    for (final op in toList()) {
      final insert = op.data;
      if (insert is String) {
        buffer.write(insert);
      }
    }
    return buffer.toString();
  }
}

String deltaToMarkdown(Delta delta) {
  return DeltaToMarkdown().convert(delta);
}

Delta stringToDelta(String value) {
  if (value.isEmpty) return Delta();
  try {
    final json = jsonDecode(value);
    if (json is List) {
      return Delta.fromJson(json);
    }
  } catch (_) {}

  // If the string is not a valid JSON, treat it as plain text and
  // create a Delta with a single insert operation.
  return Delta()..insert('$value\n');
}

List<Delta> splitDeltaIntoLines(Delta delta) {
  final lines = <Delta>[];
  var currentLine = Delta();
  for (final op in delta.toList()) {
    final insert = op.data;
    if (insert is String) {
      var remaining = insert;
      while (remaining.contains('\n')) {
        final idx = remaining.indexOf('\n');
        final lineText = remaining.substring(0, idx + 1);
        remaining = remaining.substring(idx + 1);
        currentLine.insert(lineText, op.attributes);
        lines.add(currentLine);
        currentLine = Delta();
      }
      if (remaining.isNotEmpty) {
        currentLine.insert(remaining, op.attributes);
      }
    } else {
      currentLine.insert(insert, op.attributes);
    }
  }
  if (currentLine.isNotEmpty) {
    lines.add(currentLine);
  }
  return lines;
}

TextSpan deltaToTextSpan(Delta delta, TextStyle defaultStyle) {
  final children = <TextSpan>[];
  for (final op in delta.toList()) {
    final insert = op.data;
    if (insert is String) {
      var style = defaultStyle;
      final attrs = op.attributes;
      if (attrs != null) {
        if (attrs['bold'] == true) {
          style = style.copyWith(fontWeight: FontWeight.bold);
        }
        if (attrs['italic'] == true) {
          style = style.copyWith(fontStyle: FontStyle.italic);
        }
        if (attrs['underline'] == true) {
          style = style.copyWith(decoration: TextDecoration.underline);
        }
        if (attrs['strike'] == true) {
          style = style.copyWith(decoration: TextDecoration.lineThrough);
        }
      }
      children.add(TextSpan(text: insert, style: style));
    }
  }
  return TextSpan(children: children, style: defaultStyle);
}
