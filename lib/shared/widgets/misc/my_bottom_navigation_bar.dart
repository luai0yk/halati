import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';

enum MyBottomNavigationBarDisplayMode { iconOnly, titleOnly, both }

enum MyBottomNavigationBarAnimation { none, bounce, slide, scale }

enum MyBottomNavigationBarItemOrientation { vertical, horizontal }

class MyBottomNavigationBarItem {
  final String title;
  final Widget icon;
  final Widget? selectedIcon;

  const MyBottomNavigationBarItem({
    required this.title,
    required this.icon,
    this.selectedIcon,
  });
}

class MyBottomNavigationBar extends StatefulWidget {
  // Navigation Bar Properties
  final List<MyBottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final bool expandItems;
  final bool withBlur;

  // Item Properties
  final MyBottomNavigationBarDisplayMode displayMode;
  final MyBottomNavigationBarItemOrientation itemOrientation;
  final MyBottomNavigationBarAnimation itemAnimation;
  final Color? selectedForegroundColor;
  final Color? unselectedForegroundColor;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final BoxBorder? itemBorder;
  final BorderRadiusGeometry? itemBorderRadius;
  final double? unselectedIconSize;
  final double? selectedIconSize;
  final TextStyle? unselectedLabelStyle;
  final TextStyle? selectedLabelStyle;

  const MyBottomNavigationBar({
    super.key,
    // Navigation Bar Properties
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.elevation,
    this.expandItems = false,
    this.withBlur = true,

    // Item Properties
    this.displayMode = MyBottomNavigationBarDisplayMode.both,
    this.itemOrientation = MyBottomNavigationBarItemOrientation.vertical,
    this.itemAnimation = MyBottomNavigationBarAnimation.scale,
    this.selectedForegroundColor,
    this.unselectedForegroundColor,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.itemBorder,
    this.itemBorderRadius,
    this.unselectedIconSize,
    this.selectedIconSize,
    this.unselectedLabelStyle,
    this.selectedLabelStyle,
  });

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late List<GlobalKey> _keys;
  final GlobalKey _rowKey = GlobalKey();

  double _indicatorLeft = 0;
  double _indicatorTop = 0;
  double _indicatorWidth = 0;
  double _indicatorHeight = 0;
  bool _isInitialized = false;
  bool _skipNextAnimation = false;

  TextDirection? _lastDirectionality;
  Locale? _lastLocale;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.items.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateIndicatorPosition(immediate: true),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentDirectionality = Directionality.of(context);
    final currentLocale = Localizations.maybeLocaleOf(context);
    final currentSize = MediaQuery.sizeOf(context);

    final bool isDirectionalityChanged =
        _lastDirectionality != null &&
        _lastDirectionality != currentDirectionality;
    final bool isLocaleChanged =
        _lastLocale != null && _lastLocale != currentLocale;
    final bool isSizeChanged =
        _lastSize != null && _lastSize != currentSize;

    _lastDirectionality = currentDirectionality;
    _lastLocale = currentLocale;
    _lastSize = currentSize;

    if (isDirectionalityChanged || isLocaleChanged || isSizeChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateIndicatorPosition(immediate: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(MyBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _keys = List.generate(widget.items.length, (_) => GlobalKey());
    }

    final bool itemsCountChanged =
        oldWidget.items.length != widget.items.length;
    final bool layoutPropsChanged =
        oldWidget.expandItems != widget.expandItems ||
        oldWidget.displayMode != widget.displayMode ||
        oldWidget.itemOrientation != widget.itemOrientation;
    final bool selectionChanged = oldWidget.currentIndex != widget.currentIndex;

    bool itemsContentChanged = false;
    if (oldWidget.items.length == widget.items.length) {
      for (int i = 0; i < widget.items.length; i++) {
        if (oldWidget.items[i].title != widget.items[i].title) {
          itemsContentChanged = true;
          break;
        }
      }
    }

    if (itemsCountChanged || layoutPropsChanged || itemsContentChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateIndicatorPosition(
            immediate: itemsContentChanged || layoutPropsChanged,
          );
        }
      });
    } else if (selectionChanged) {
      _updateIndicatorPosition();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateIndicatorPosition();
        }
      });
    }
  }

  void _updateIndicatorPosition({bool immediate = false}) {
    if (!mounted) return;
    if (widget.currentIndex >= 0 && widget.currentIndex < _keys.length) {
      final keyContext = _keys[widget.currentIndex].currentContext;
      final rowContext = _rowKey.currentContext;
      if (keyContext != null && rowContext != null) {
        final rowBox = rowContext.findRenderObject() as RenderBox?;
        final itemBox = keyContext.findRenderObject() as RenderBox?;
        if (rowBox != null &&
            itemBox != null &&
            rowBox.attached &&
            itemBox.attached &&
            rowBox.hasSize &&
            itemBox.hasSize) {
          final offset = itemBox.localToGlobal(Offset.zero, ancestor: rowBox);
          setState(() {
            _indicatorLeft = offset.dx;
            _indicatorTop = offset.dy;
            _indicatorWidth = itemBox.size.width;
            _indicatorHeight = itemBox.size.height;
            _isInitialized = true;
            _skipNextAnimation = immediate;
          });
          if (immediate) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _skipNextAnimation) {
                setState(() {
                  _skipNextAnimation = false;
                });
              }
            });
          }
          return;
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateIndicatorPosition(immediate: immediate);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSlidingMode =
        widget.itemAnimation == MyBottomNavigationBarAnimation.bounce ||
        widget.itemAnimation == MyBottomNavigationBarAnimation.slide;

    List<Widget> children = [];
    for (int i = 0; i < widget.items.length; i++) {
      // Add a spacer between each item
      if (i > 0) children.add(SizedBox(width: context.spaceXs));
      Widget child = _BottomNavItem(
        item: widget.items[i],
        isSelected: widget.currentIndex == i,
        onTap: () => widget.onItemSelected(i),
        displayMode: widget.displayMode,
        activeColor:
            widget.selectedForegroundColor ?? theme.colorScheme.primary,
        inactiveColor:
            widget.unselectedForegroundColor ??
            theme.colorScheme.onSurfaceVariant,
        activeIconSize:
            widget.selectedIconSize ??
            widget.unselectedIconSize ??
            context.iconL * 0.90,
        inactiveIconSize: widget.unselectedIconSize ?? context.iconL * 0.90,
        activeStyle:
            widget.selectedLabelStyle ??
            widget.unselectedLabelStyle ??
            context.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: context.setSize(11),
            ),
        inactiveStyle:
            widget.unselectedLabelStyle ??
            context.textTheme.labelMedium!.copyWith(
              fontSize: context.setSize(11),
            ),
        selectedBackgroundColor: isSlidingMode
            ? Colors.transparent
            : (widget.selectedBackgroundColor ??
                  theme.colorScheme.primary.withValues(alpha: 0.1)),
        unselectedBackgroundColor:
            widget.unselectedBackgroundColor ?? Colors.transparent,
        itemBorder: widget.itemBorder,
        itemBorderRadius: widget.itemBorderRadius,
        itemAnimation: widget.itemAnimation,
        itemOrientation: widget.itemOrientation,
      );

      if (widget.expandItems) {
        children.add(Expanded(key: _keys[i], child: child));
      } else {
        children.add(KeyedSubtree(key: _keys[i], child: child));
      }
    }

    final defaultBgColor =
        widget.backgroundColor ??
        theme.bottomNavigationBarTheme.backgroundColor ??
        theme.colorScheme.surface;
    final bgColor = defaultBgColor.withValues(
      alpha: widget.withBlur ? 0.8 : 1.0,
    );

    final borderRadius = widget.borderRadius ?? BorderRadius.zero;
    final hasShadow = (widget.elevation ?? context.elevationNone) > 0;

    Widget navContainer = Container(
      height: widget.height,
      padding: widget.padding ?? context.insetsAllXs,
      decoration: BoxDecoration(
        color: bgColor,
        border: widget.border,
        borderRadius: borderRadius,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSlidingMode && _isInitialized)
            AnimatedPositioned(
              left: _indicatorLeft,
              top: _indicatorTop,
              width: _indicatorWidth,
              height: _indicatorHeight,
              duration:
                  _skipNextAnimation ? Duration.zero : AppDurations.slow,
              curve:
                  widget.itemAnimation ==
                          MyBottomNavigationBarAnimation.bounce
                      ? Curves.easeOutBack
                      : Curves.easeOutQuint,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      widget.selectedBackgroundColor ??
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: widget.itemBorder,
                  borderRadius: widget.itemBorderRadius ?? context.brL,
                ),
              ),
            ),
          NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (n) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _updateIndicatorPosition(immediate: true),
              );
              return true;
            },
            child: SizeChangedLayoutNotifier(
              child: Row(
                key: _rowKey,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );

    Widget content;
    if (widget.withBlur) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: navContainer,
        ),
      );
    } else {
      content = navContainer;
    }

    if (hasShadow) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: widget.elevation ?? context.elevationNone,
              offset: Offset(0, context.setSize(4)),
            ),
          ],
        ),
        child: content,
      );
    }

    return SafeArea(
      child: Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: content,
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final MyBottomNavigationBarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final MyBottomNavigationBarDisplayMode displayMode;
  final Color activeColor;
  final Color inactiveColor;
  final double activeIconSize;
  final double inactiveIconSize;
  final TextStyle activeStyle;
  final TextStyle inactiveStyle;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;
  final BoxBorder? itemBorder;
  final BorderRadiusGeometry? itemBorderRadius;
  final MyBottomNavigationBarAnimation itemAnimation;
  final MyBottomNavigationBarItemOrientation itemOrientation;

  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.displayMode,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeIconSize,
    required this.inactiveIconSize,
    required this.activeStyle,
    required this.inactiveStyle,
    required this.selectedBackgroundColor,
    required this.unselectedBackgroundColor,
    this.itemBorder,
    this.itemBorderRadius,
    required this.itemAnimation,
    required this.itemOrientation,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: itemBorderRadius is BorderRadius
              ? itemBorderRadius as BorderRadius
              : context.brL,
          splashColor: activeColor.withValues(alpha: 0.12),
          highlightColor: activeColor.withValues(alpha: 0.04),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
            duration: Duration(
              milliseconds: itemAnimation == MyBottomNavigationBarAnimation.none
                  ? 0
                  : 400,
            ),
            curve: itemAnimation == MyBottomNavigationBarAnimation.bounce
                ? Curves.easeOutBack
                : Curves.easeOutQuint,
            builder: (context, t, child) {
              final clampedT = t.clamp(0.0, 1.0);
              final color = Color.lerp(inactiveColor, activeColor, clampedT)!;
              final isAnimated =
                  itemAnimation != MyBottomNavigationBarAnimation.none;

              final isScaleAnimation =
                  itemAnimation == MyBottomNavigationBarAnimation.scale;

              Widget background = Container(
                decoration: BoxDecoration(
                  color: Color.lerp(
                    unselectedBackgroundColor,
                    selectedBackgroundColor,
                    clampedT,
                  ),
                  border: itemBorder,
                  borderRadius: itemBorderRadius ?? context.brL,
                ),
              );

              if (isScaleAnimation) {
                background = Transform.scale(
                  scale: lerpDouble(0.8, 1.0, clampedT)!,
                  child: Opacity(opacity: clampedT, child: background),
                );
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: background),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: context.spaceS,
                      horizontal: context.spaceM,
                    ),
                    child: Flex(
                      direction:
                          itemOrientation ==
                              MyBottomNavigationBarItemOrientation.horizontal
                          ? Axis.horizontal
                          : Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (displayMode !=
                            MyBottomNavigationBarDisplayMode.titleOnly)
                          Transform.translate(
                            offset: Offset(
                              0,
                              displayMode !=
                                          MyBottomNavigationBarDisplayMode
                                              .iconOnly &&
                                      isAnimated
                                  ? lerpDouble(0, context.setSize(-3), t)!
                                  : 0,
                            ),
                            child: Transform.scale(
                              scale:
                                  itemAnimation ==
                                      MyBottomNavigationBarAnimation.bounce
                                  ? lerpDouble(1.0, 1.1, t)!
                                  : (isScaleAnimation
                                        ? lerpDouble(1.0, 1.15, clampedT)!
                                        : 1.0),
                              child: IconTheme(
                                data: IconThemeData(
                                  color: color,
                                  size: lerpDouble(
                                    inactiveIconSize,
                                    activeIconSize,
                                    clampedT,
                                  ),
                                ),
                                child: item.selectedIcon != null
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Opacity(
                                            opacity: (1.0 - t).clamp(0.0, 1.0),
                                            child: item.icon,
                                          ),
                                          Opacity(
                                            opacity: clampedT,
                                            child: item.selectedIcon!,
                                          ),
                                        ],
                                      )
                                    : item.icon,
                              ),
                            ),
                          ),
                        if (displayMode ==
                            MyBottomNavigationBarDisplayMode.both)
                          SizedBox(
                            width:
                                itemOrientation ==
                                    MyBottomNavigationBarItemOrientation
                                        .horizontal
                                ? context.spaceS
                                : 0,
                            height:
                                itemOrientation ==
                                    MyBottomNavigationBarItemOrientation
                                        .vertical
                                ? context.spaceXs
                                : 0,
                          ),
                        if (displayMode !=
                            MyBottomNavigationBarDisplayMode.iconOnly)
                          Transform.translate(
                            offset: Offset(
                              0,
                              displayMode !=
                                          MyBottomNavigationBarDisplayMode
                                              .titleOnly &&
                                      isAnimated
                                  ? lerpDouble(context.setSize(2), 0, t)!
                                  : 0,
                            ),
                            child: Transform.scale(
                              scale: isScaleAnimation
                                  ? lerpDouble(1.0, 1.15, clampedT)!
                                  : 1.0,
                              child: Text(
                                item.title,
                                style: TextStyle.lerp(
                                  inactiveStyle,
                                  activeStyle,
                                  clampedT,
                                )?.copyWith(color: color),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
