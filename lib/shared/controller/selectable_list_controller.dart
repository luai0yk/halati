import 'package:flutter/cupertino.dart';

enum SelectableListType { single, multi }

class SelectableListController<T> extends ChangeNotifier {
  final SelectableListType type;

  T? singleSelectedItem;
  List<T> multiSelectedItems = [];

  List<T> originalItems = [];
  List<T> filteredItems = [];
  List<T> originalRecentItems = [];
  List<T> filteredRecentItems = [];

  late String Function(T) labelGetter;
  bool Function(T item, String query)? searchFilter;

  TextEditingController searchController = TextEditingController();

  SelectableListController({required this.type}) {
    searchController.addListener(filter);
  }

  void initSingle(
    List<T> items,
    T? initial,
    String Function(T) labelGetter, {
    List<T>? recentItems,
    bool Function(T item, String query)? searchFilter,
  }) {
    this.searchFilter = searchFilter;
    this.labelGetter = labelGetter;
    singleSelectedItem = initial;
    _setItems(items, recentItems);
  }

  void initMulti(
    List<T> items,
    List<T>? initial,
    String Function(T) labelGetter, {
    List<T>? recentItems,
    bool Function(T item, String query)? searchFilter,
  }) {
    this.searchFilter = searchFilter;
    this.labelGetter = labelGetter;
    multiSelectedItems = initial != null ? List.from(initial) : [];
    _setItems(items, recentItems);
  }

  void _setItems(List<T> items, List<T>? recentItems) {
    if (recentItems != null && recentItems.isNotEmpty) {
      originalRecentItems = List.from(recentItems);
      // Exclude recent items from the main list to prevent duplicates
      originalItems = items
          .where((item) => !originalRecentItems.contains(item))
          .toList();
    } else {
      originalRecentItems = [];
      originalItems = List.from(items);
    }
    filter();
  }

  void toggleItem(T item) {
    if (type == SelectableListType.single) {
      singleSelectedItem = item;
    } else {
      if (multiSelectedItems.contains(item)) {
        multiSelectedItems.remove(item);
      } else {
        multiSelectedItems.add(item);
      }
    }
    notifyListeners();
  }

  bool isSelected(T item) {
    if (type == SelectableListType.single) {
      return singleSelectedItem == item;
    } else {
      return multiSelectedItems.contains(item);
    }
  }

  @override
  void dispose() {
    searchController.removeListener(filter);
    searchController.dispose();
    super.dispose();
  }

  void updateItems(List<T> newItems, {List<T>? newRecentItems}) {
    _setItems(newItems, newRecentItems ?? originalRecentItems);
  }

  void filter() {
    String query = searchController.text.trim().toLowerCase();
    bool matches(T item) {
      if (query.isEmpty) return true;
      if (searchFilter != null) {
        return searchFilter!(item, query);
      }
      return labelGetter(item).toLowerCase().contains(query);
    }

    if (query.isEmpty) {
      filteredRecentItems = List.from(originalRecentItems);
      filteredItems = List.from(originalItems);
    } else {
      filteredRecentItems = originalRecentItems.where(matches).toList();
      filteredItems = originalItems.where(matches).toList();
    }
    notifyListeners();
  }
}
