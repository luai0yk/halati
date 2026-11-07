import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/controller/selectable_list_controller.dart';
import 'package:halati/shared/widgets/animations/my_animated_scale_switcher.dart';
import 'package:halati/shared/widgets/input/my_text_field.dart';
import 'package:halati/shared/widgets/misc/my_empty_state.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/texts/text_separator.dart';
import 'package:halati/shared/widgets/tiles/my_list_tile.dart';

class SelectableList<T> extends StatefulWidget {
  final SelectableListType _type;
  final List<T> items;
  final List<T>? recentItems;
  final String? recentSectionTitle;
  final String? allSectionTitle;

  // Single selection specific properties
  final T? initialSingleSelected;
  final ValueChanged<T>? onSingleChanged;

  // Multi selection specific properties
  final List<T>? initialMultiSelected;
  final ValueChanged<List<T>>? onMultiChanged;

  final String Function(T itemLabel) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final Widget? Function(T item)? itemLeading;
  final Widget? Function(T item)? itemTrailing;
  final void Function(T value, int index)? onTap;
  final bool enableSearch;
  final bool Function(T item, String query)? searchFilter;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? searchFillColor;
  final Widget? emptyStateWidget;
  final Widget? emptySearchWidget;
  final EdgeInsetsGeometry? padding;
  final double? separatorHeight;
  final BorderRadius? itemBorderRadius;
  final TextDirection? subtitleDirection;
  final bool Function(T item)? canSelectItem;
  final void Function(T item)? onRestrictedItemTap;

  // ignore: unintended_html_in_doc_comment
  /// Optional tag to prevent GetX controllers collision if multiple lists of the same type <T> are on screen.
  final String? controllerTag;

  const SelectableList._({
    super.key,
    required SelectableListType type,
    required this.items,
    this.recentItems,
    this.recentSectionTitle,
    this.allSectionTitle,
    required this.itemLabel,
    this.itemSubtitle,
    this.itemLeading,
    this.itemTrailing,
    this.initialSingleSelected,
    this.onSingleChanged,
    this.initialMultiSelected,
    this.onMultiChanged,
    this.enableSearch = false,
    this.searchFilter,
    this.onTap,
    this.fontSize,
    this.fontWeight,
    this.searchFillColor,
    this.emptyStateWidget,
    this.emptySearchWidget,
    this.padding,
    this.separatorHeight,
    this.itemBorderRadius,
    this.controllerTag,
    this.subtitleDirection,
    this.canSelectItem,
    this.onRestrictedItemTap,
  }) : _type = type;

  /// Creates a list where only one item can be selected at a time.
  factory SelectableList.single({
    Key? key,
    required List<T> items,
    List<T>? recentItems,
    String? recentSectionTitle,
    String? allSectionTitle,
    T? initialSelected,
    required String Function(T itemLabel) itemLabel,
    String? Function(T item)? itemSubtitle,
    Widget? Function(T item)? itemLeading,
    Widget? Function(T item)? itemTrailing,
    required ValueChanged<T> onChanged,
    bool enableSearch = false,
    bool Function(T item, String query)? searchFilter,
    void Function(T value, int index)? onTap,
    bool showDivider = false,
    double? fontSize,
    FontWeight? fontWeight,
    Color? searchFillColor,
    Widget? emptyStateWidget,
    Widget? emptySearchWidget,
    EdgeInsetsGeometry? padding,
    double? separatorHeight,
    BorderRadius? itemBorderRadius,
    String? controllerTag,
    TextDirection? subtitleDirection,
    bool Function(T item)? canSelectItem,
    void Function(T item)? onRestrictedItemTap,
  }) {
    return SelectableList._(
      key: key,
      type: SelectableListType.single,
      items: items,
      recentItems: recentItems,
      recentSectionTitle: recentSectionTitle,
      allSectionTitle: allSectionTitle,
      initialSingleSelected: initialSelected,
      onSingleChanged: onChanged,
      itemLabel: itemLabel,
      itemSubtitle: itemSubtitle,
      itemLeading: itemLeading,
      itemTrailing: itemTrailing,
      enableSearch: enableSearch,
      searchFilter: searchFilter,
      onTap: onTap,
      fontSize: fontSize,
      fontWeight: fontWeight,
      searchFillColor: searchFillColor,
      emptyStateWidget: emptyStateWidget,
      emptySearchWidget: emptySearchWidget,
      padding: padding,
      separatorHeight: separatorHeight,
      itemBorderRadius: itemBorderRadius,
      controllerTag: controllerTag,
      subtitleDirection: subtitleDirection,
      canSelectItem: canSelectItem,
      onRestrictedItemTap: onRestrictedItemTap,
    );
  }

  /// Creates a list where multiple items can be selected.
  factory SelectableList.multi({
    Key? key,
    required List<T> items,
    List<T>? recentItems,
    String? recentSectionTitle,
    String? allSectionTitle,
    List<T>? initialSelected,
    required String Function(T itemLabel) itemLabel,
    String? Function(T item)? itemSubtitle,
    Widget? Function(T item)? itemLeading,
    Widget? Function(T item)? itemTrailing,
    required ValueChanged<List<T>> onChanged,
    bool enableSearch = false,
    bool Function(T item, String query)? searchFilter,
    void Function(T value, int index)? onTap,
    bool showDivider = false,
    double? fontSize,
    FontWeight? fontWeight,
    Color? searchFillColor,
    Widget? emptyStateWidget,
    Widget? emptySearchWidget,
    EdgeInsetsGeometry? padding,
    double? separatorHeight,
    BorderRadius? itemBorderRadius,
    String? controllerTag,
    TextDirection? subtitleDirection,
  }) {
    return SelectableList._(
      key: key,
      type: SelectableListType.multi,
      items: items,
      recentItems: recentItems,
      recentSectionTitle: recentSectionTitle,
      allSectionTitle: allSectionTitle,
      initialMultiSelected: initialSelected,
      onMultiChanged: onChanged,
      itemLabel: itemLabel,
      itemSubtitle: itemSubtitle,
      itemLeading: itemLeading,
      itemTrailing: itemTrailing,
      enableSearch: enableSearch,
      searchFilter: searchFilter,
      onTap: onTap,
      fontSize: fontSize,
      fontWeight: fontWeight,
      searchFillColor: searchFillColor,
      emptyStateWidget: emptyStateWidget,
      emptySearchWidget: emptySearchWidget,
      padding: padding,
      separatorHeight: separatorHeight,
      itemBorderRadius: itemBorderRadius,
      controllerTag: controllerTag,
      subtitleDirection: subtitleDirection,
    );
  }

  @override
  State<SelectableList<T>> createState() => _SelectableListState<T>();
}

class _SelectableListState<T> extends State<SelectableList<T>> {
  late final SelectableListController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SelectableListController<T>(type: widget._type)
      ..initSingle(
        widget.items,
        widget.initialSingleSelected,
        widget.itemLabel,
        recentItems: widget.recentItems,
        searchFilter: widget.searchFilter,
      )
      ..initMulti(
        widget.items,
        widget.initialMultiSelected,
        widget.itemLabel,
        recentItems: widget.recentItems,
        searchFilter: widget.searchFilter,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SelectableList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items ||
        widget.recentItems != oldWidget.recentItems) {
      _controller.updateItems(widget.items, newRecentItems: widget.recentItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final controller = _controller;
        final hasAnyItems =
            controller.originalItems.isNotEmpty ||
            controller.originalRecentItems.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.enableSearch) ...[
              Padding(
                padding: EdgeInsets.only(
                  top: context.spaceM,
                  left: context.spaceM,
                  right: context.spaceM,
                ),
                child: MyTextField(
                  controller: controller.searchController,
                  hintText: context.l10n.search,
                  prefixIcon: AppIcons.search,
                  fillColor: widget.searchFillColor,
                  contentPadding: EdgeInsets.zero,
                  isSearch: true,
                  enabled: hasAnyItems,
                ),
              ),
              SizedBox(height: context.spaceM),
            ],

            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: context.screenHeight * 0.95,
                ),
                child: _buildBody(controller, context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    SelectableListController<T> controller,
    BuildContext context,
  ) {
    final hasNoMatches =
        controller.filteredItems.isEmpty &&
        controller.filteredRecentItems.isEmpty;

    if (hasNoMatches) {
      if (widget.items.isEmpty &&
          (widget.recentItems == null || widget.recentItems!.isEmpty)) {
        return Center(
          child:
              widget.emptyStateWidget ??
              MyEmptyState(
                icon: AppIcons.box,
                title: context.l10n.noData,
                subtitle: context.l10n.noDataSubtitle,
              ),
        );
      }

      return Center(
        child:
            widget.emptySearchWidget ??
            MyEmptyState(
              icon: AppIcons.searchOff,
              title: context.l10n.noResultsFound,
              subtitle: context.l10n.tryAdjustingSearch,
            ),
      );
    }

    final hasRecentConfigured = controller.originalRecentItems.isNotEmpty;
    final showRecentSection = controller.filteredRecentItems.isNotEmpty;
    final showAllSection = controller.filteredItems.isNotEmpty;

    if (!hasRecentConfigured) {
      return ListView.separated(
        shrinkWrap: true,
        padding:
            widget.padding ??
            (widget.enableSearch
                ? EdgeInsets.only(
                    bottom: context.spaceM,
                    left: context.spaceM,
                    right: context.spaceM,
                  )
                : context.insetsAllM),
        itemCount: controller.filteredItems.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: widget.separatorHeight ?? context.spaceXs);
        },
        itemBuilder: (context, index) {
          final item = controller.filteredItems[index];
          return _buildTile(context, controller, item, index);
        },
      );
    }

    final showRecentHeader =
        showRecentSection && widget.recentSectionTitle != null;
    final showAllHeader =
        hasRecentConfigured && showAllSection && widget.allSectionTitle != null;

    return ListView(
      shrinkWrap: true,
      padding:
          widget.padding ??
          (widget.enableSearch
              ? EdgeInsets.only(
                  bottom: context.spaceM,
                  left: context.spaceM,
                  right: context.spaceM,
                )
              : context.insetsAllM),
      children: [
        if (showRecentSection) ...[
          if (showRecentHeader)
            TextSeparator(
              text: widget.recentSectionTitle!,
              top: 0,
              bottom: widget.separatorHeight ?? context.spaceXs,
            ),
          for (int i = 0; i < controller.filteredRecentItems.length; i++) ...[
            _buildTile(
              context,
              controller,
              controller.filteredRecentItems[i],
              i,
            ),
            SizedBox(height: widget.separatorHeight ?? context.spaceXs),
          ],
        ],
        if (showAllSection) ...[
          if (showAllHeader)
            TextSeparator(
              text: widget.allSectionTitle!,
              top: showRecentSection ? context.spaceM : 0,
              bottom: widget.separatorHeight ?? context.spaceXs,
            ),
          for (int i = 0; i < controller.filteredItems.length; i++) ...[
            _buildTile(
              context,
              controller,
              controller.filteredItems[i],
              i + controller.filteredRecentItems.length,
            ),
            if (i < controller.filteredItems.length - 1)
              SizedBox(height: widget.separatorHeight ?? context.spaceXs),
          ],
        ],
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    SelectableListController<T> controller,
    T item,
    int index,
  ) {
    final isSelected = controller.isSelected(item);

    Widget? trailingContent;
    final customTrailing = widget.itemTrailing?.call(item);
    final checkmark = MyAnimatedScaleSwitcher(
      child: isSelected
          ? MyIcon(
              key: ValueKey('selected_$index'),
              color: context.colorScheme.primary,
              icon: widget._type == SelectableListType.multi
                  ? AppIcons.checkSquare
                  : AppIcons.checkCircle,
            )
          : const SizedBox.shrink(),
    );

    if (customTrailing != null) {
      trailingContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customTrailing,
          if (isSelected) ...[context.horizontalSpace(8), checkmark],
        ],
      );
    } else {
      trailingContent = checkmark;
    }

    return MyListTile(
      leading: widget.itemLeading?.call(item),
      title: widget.itemLabel(item),
      subtitle: widget.itemSubtitle?.call(item),
      subtitleDirection: widget.subtitleDirection,
      borderRadius: widget.itemBorderRadius ?? context.brS,
      titleStyle: context.textTheme.titleSmall?.copyWith(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight ?? FontWeight.w500,
      ),
      selectedTitleStyle: context.textTheme.titleSmall?.copyWith(
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w700,
        color: context.colorScheme.primary,
      ),
      selected: isSelected,
      trailing: trailingContent,
      onTap: () {
        if (widget.canSelectItem != null && !widget.canSelectItem!(item)) {
          widget.onRestrictedItemTap?.call(item);
          return;
        }

        controller.toggleItem(item);

        // Fire the appropriate callback based on the type
        if (widget._type == SelectableListType.single) {
          widget.onSingleChanged?.call(item);
        } else {
          widget.onMultiChanged?.call(controller.multiSelectedItems);
        }

        widget.onTap?.call(item, index);
      },
    );
  }
}
