import 'package:flutter_riverpod/flutter_riverpod.dart';

final listGridProvider = NotifierProvider<ListGridNotifier, bool>(
  ListGridNotifier.new,
);

class ListGridNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}
