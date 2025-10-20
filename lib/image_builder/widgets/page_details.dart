import 'package:flutter/widgets.dart';

extension CurrenPageController on PageController {
  int get currentPage {
    return hasClients ? page?.round() ?? initialPage : initialPage;
  }
}

class PageDetails extends InheritedWidget {
  const PageDetails({
    super.key,
    required super.child,
    required this.currentPage,
  });

  final int currentPage;

  static PageDetails of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<PageDetails>();
    assert(result != null, 'No PoemDetails found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant PageDetails oldWidget) {
    return currentPage != oldWidget.currentPage;
  }
}
