import 'package:flutter/foundation.dart';

enum SelectableChipListType { single, multi }

class SelectableChipListController<T> extends ChangeNotifier {
  final SelectableChipListType type;

  T? singleSelectedItem;
  List<T> multiSelectedItems = [];

  SelectableChipListController({required this.type});

  void initSingle(T? initial) {
    singleSelectedItem = initial;
  }

  void initMulti(List<T>? initial) {
    if (initial != null) {
      multiSelectedItems = List.from(initial);
    }
  }

  void toggle(T value) {
    if (type == SelectableChipListType.single) {
      singleSelectedItem = value;
    } else {
      if (multiSelectedItems.contains(value)) {
        multiSelectedItems.remove(value);
      } else {
        multiSelectedItems.add(value);
      }
    }
    notifyListeners();
  }

  bool isSelected(T value) {
    if (type == SelectableChipListType.single) {
      return singleSelectedItem == value;
    } else {
      return multiSelectedItems.contains(value);
    }
  }
}
