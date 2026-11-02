import 'package:flutter/foundation.dart';

class SegmentButtonController<T> extends ChangeNotifier {
  SegmentButtonController({required T initial}) {
    init(initial);
  }

  /// Currently selected segment value
  late T selected;

  /// Previously selected segment value
  late T previousSelected;

  void init(T initial) {
    selected = initial;
    previousSelected = initial;
  }

  void updateSelection(Set<T> value) {
    if (value.isEmpty) return;

    final newValue = value.first;
    if (newValue == selected) return;

    previousSelected = selected;
    selected = newValue;

    notifyListeners();
  }

  void resetSelection() {
    if (selected == previousSelected) return;

    selected = previousSelected;
    notifyListeners();
  }
}
