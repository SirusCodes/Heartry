import 'package:flutter/widgets.dart';

import 'text_spliting_service.dart';

class ImageController extends ChangeNotifier {
  ImageController({
    required this.context,
    required this.title,
    required this.author,
    required this.poem,
    BoxConstraints constraints = const BoxConstraints(),
    double textSizeFactor = 1.0,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    TextStyle? textStyle,
  }) : _textSizeFactor = textSizeFactor,
       _constraints = constraints,
       _padding = padding,
       _textStyle = DefaultTextStyle.of(context).style.merge(textStyle);

  final String author, poem;
  final String? title;
  final BuildContext context;

  List<List<String>> _poemSeparated = [];
  List<List<String>> get poemSeparated => _poemSeparated;

  BoxConstraints _constraints;
  set constraints(BoxConstraints value) {
    if (value != _constraints) {
      _constraints = value;
      _updatePoemSeparated();
    }
  }

  BoxConstraints get constraints => _constraints;

  TextStyle _textStyle;
  set textStyle(TextStyle value) {
    if (value != _textStyle) {
      _textStyle = value;
      _updatePoemSeparated();
    }
  }

  TextStyle get textStyle => _textStyle;

  double _textSizeFactor;
  set textSizeFactor(double value) {
    if (value != _textSizeFactor) {
      _textSizeFactor = value;
      _updatePoemSeparated();
    }
  }

  double get textSizeFactor => _textSizeFactor;

  EdgeInsetsGeometry _padding;
  set padding(EdgeInsetsGeometry value) {
    if (value != _padding) {
      _padding = value;
      _updatePoemSeparated();
    }
  }

  EdgeInsetsGeometry get padding => _padding;

  void _updatePoemSeparated() {
    final textSplittingService = TextSplittingService(
      context: context,
      constraints: constraints,
      title: title,
      poet: author,
      poem: poem.split('\n'),
      contentPadding: padding,
      textStyle: textStyle,
    );

    _poemSeparated = textSplittingService.getPoemSeparated(_textSizeFactor);

    notifyListeners();
  }
}
