import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/controller/selectable_chip_list_controller.dart';
import 'package:halati/shared/widgets/cards/my_card.dart';
import 'package:halati/shared/widgets/chips/animated_chip.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';

/// Helper class to pass custom titles, leading, and trailing widgets per chip.
class SelectableChip<T> {
  final T value;
  final String title;
  final Widget? leading;
  final Widget? trailing;

  const SelectableChip({
    required this.value,
    required this.title,
    this.leading,
    this.trailing,
  });
}

class SelectableChipList<T> extends StatefulWidget {
  final SelectableChipListType _type;
  final List<dynamic> items;

  // Single selection specific properties
  final T? initialSingleSelected;
  final ValueChanged<T>? onSingleChanged;

  // Multi selection specific properties
  final List<T>? initialMultiSelected;
  final ValueChanged<List<T>>? onMultiChanged;

  final bool showFilter;
  final VoidCallback? onFilterTap;
  final String Function(T item)? itemTitleBuilder;
  final Widget? Function(T item)? leadingBuilder;
  final Widget? Function(T item)? trailingBuilder;
  final double? height;
  final double? itemWidth;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  // ignore: unintended_html_in_doc_comment
  /// Optional tag to prevent GetX controller collision if multiple lists of the same type <T> are on screen.
  final String? controllerTag;

  const SelectableChipList._({
    super.key,
    required SelectableChipListType type,
    required this.items,
    this.initialSingleSelected,
    this.onSingleChanged,
    this.initialMultiSelected,
    this.onMultiChanged,
    this.itemTitleBuilder,
    this.leadingBuilder,
    this.trailingBuilder,
    this.height,
    this.itemWidth,
    this.padding,
    this.physics,
    this.showFilter = false,
    this.onFilterTap,
    this.controllerTag,
  }) : _type = type;

  /// Creates a horizontal list where only one chip can be selected at a time.
  factory SelectableChipList.single({
    Key? key,
    required List<dynamic> items,
    T? initialSelected,
    ValueChanged<T>? onChanged,
    String Function(T item)? itemTitleBuilder,
    Widget? Function(T item)? leadingBuilder,
    Widget? Function(T item)? trailingBuilder,
    double? height,
    double? itemWidth,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool showFilter = false,
    VoidCallback? onFilterTap,
    String? controllerTag,
  }) {
    return SelectableChipList._(
      key: key,
      type: SelectableChipListType.single,
      items: items,
      initialSingleSelected: initialSelected,
      onSingleChanged: onChanged,
      itemTitleBuilder: itemTitleBuilder,
      leadingBuilder: leadingBuilder,
      trailingBuilder: trailingBuilder,
      height: height,
      itemWidth: itemWidth,
      padding: padding,
      physics: physics,
      showFilter: showFilter,
      onFilterTap: onFilterTap,
      controllerTag: controllerTag,
    );
  }

  /// Creates a horizontal list where multiple chips can be selected.
  factory SelectableChipList.multi({
    Key? key,
    required List<dynamic> items,
    List<T>? initialSelected,
    ValueChanged<List<T>>? onChanged,
    String Function(T item)? itemTitleBuilder,
    Widget? Function(T item)? leadingBuilder,
    Widget? Function(T item)? trailingBuilder,
    double? height,
    double? itemWidth,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool showFilter = false,
    VoidCallback? onFilterTap,
    String? controllerTag,
  }) {
    return SelectableChipList._(
      key: key,
      type: SelectableChipListType.multi,
      items: items,
      initialMultiSelected: initialSelected,
      onMultiChanged: onChanged,
      itemTitleBuilder: itemTitleBuilder,
      leadingBuilder: leadingBuilder,
      trailingBuilder: trailingBuilder,
      height: height,
      itemWidth: itemWidth,
      padding: padding,
      physics: physics,
      showFilter: showFilter,
      onFilterTap: onFilterTap,
      controllerTag: controllerTag,
    );
  }

  @override
  State<SelectableChipList<T>> createState() => _SelectableChipListState<T>();
}

class _SelectableChipListState<T> extends State<SelectableChipList<T>> {
  late final SelectableChipListController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SelectableChipListController<T>(type: widget._type)
      ..initSingle(widget.initialSingleSelected)
      ..initMulti(widget.initialMultiSelected);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return SizedBox(
      height: widget.height ?? context.setSize(40),
      child: Row(
        children: [
          if (widget.showFilter) ...[
            SizedBox(width: context.setSize(16)),
            MyCard.outlined(
              onTap: widget.onFilterTap,
              width: context.setSize(40),
              height: context.setSize(40),
              padding: EdgeInsets.zero,
              color: colors.surfaceContainer,
              child: MyIcon(icon: AppIcons.filter),
            ),
            VerticalDivider(
              indent: context.setSize(4),
              endIndent: context.setSize(4),
            ),
          ],
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final controller = _controller;
                return ListView.separated(
                  padding:
                      widget.padding ??
                      (widget.showFilter
                          ? EdgeInsetsDirectional.only(end: context.spaceM)
                          : EdgeInsets.symmetric(horizontal: context.spaceM)),
                  scrollDirection: Axis.horizontal,
                  physics: widget.physics ?? const BouncingScrollPhysics(),
                  itemCount: widget.items.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(width: context.setSize(8)),
                  itemBuilder: (context, index) {
                    final dynamic rawItem = widget.items[index];

                    // Resolve Item Properties
                    late final T value;
                    late final String title;
                    Widget? leading;
                    Widget? trailing;

                    if (rawItem is SelectableChip) {
                      value = rawItem.value as T;
                      title = rawItem.title;
                      leading = rawItem.leading;
                      trailing = rawItem.trailing;
                    } else {
                      value = rawItem as T;
                      title =
                          widget.itemTitleBuilder?.call(value) ??
                          value.toString();
                      leading = widget.leadingBuilder?.call(value);
                      trailing = widget.trailingBuilder?.call(value);
                    }

                    final bool isSelected = controller.isSelected(value);

                    return AnimatedChip(
                      text: title,
                      isSelected: isSelected,
                      prefix: leading,
                      suffix: trailing,
                      onTap: () {
                        controller.toggle(value);
                        // Fire the appropriate callback
                        if (widget._type == SelectableChipListType.single) {
                          widget.onSingleChanged?.call(value);
                        } else {
                          widget.onMultiChanged?.call(
                            controller.multiSelectedItems,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
