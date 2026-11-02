import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app_template/core/constants/app_durations.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/input/my_text_field.dart';
import 'package:flutter_app_template/shared/widgets/lists/selectable_list.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

class MyDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const MyDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });
}

class MyDropdownField<T> extends StatefulWidget {
  final List<MyDropdownItem<T>> items;
  final void Function(T? value, String? label)? onChanged;
  final String? hintText;
  final String? labelText;
  final bool isRequired;
  final String? requiredMessage;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? icon;
  final bool enableSearch;
  final T? value;
  final FormFieldValidator<T>? validator;

  const MyDropdownField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.isRequired = false,
    this.requiredMessage,
    this.prefixIcon,
    this.prefixWidget,
    this.fillColor,
    this.contentPadding,
    this.validator,
    this.icon,
    this.enableSearch = false,
  });

  @override
  State<MyDropdownField<T>> createState() => _MyDropdownFieldState<T>();
}

class _MyDropdownFieldState<T> extends State<MyDropdownField<T>>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  bool _isMenuOpen = false;
  T? _selectedValue;

  bool _openUpward = false;
  double _menuMaxHeight = 300.0;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _selectedValue = widget.value;
    final initialItem = widget.items
        .where((e) => e.value == _selectedValue)
        .firstOrNull;
    _textController.text = initialItem?.label ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    ScrollPosition? newPosition;
    try {
      newPosition = scrollable?.position;
    } catch (_) {}

    if (_scrollPosition != newPosition) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(MyDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
      final selectedItem = widget.items
          .where((e) => e.value == _selectedValue)
          .firstOrNull;
      _textController.text = selectedItem?.label ?? '';
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _focusNode.dispose();
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isMenuOpen &&
        _scrollPosition?.userScrollDirection != ScrollDirection.idle) {
      _closeMenu();
    }
  }

  void _toggleMenu() {
    if (_overlayController.isShowing) {
      if (_animationController.status == AnimationStatus.reverse) {
        _openMenu();
      } else {
        _closeMenu();
      }
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    FocusScope.of(context).unfocus();
    _focusNode.requestFocus();

    if (!_overlayController.isShowing) {
      _overlayController.show();
    }

    setState(() {
      _isMenuOpen = true;
    });
    _animationController.forward();
  }

  void _closeMenu() {
    _focusNode.unfocus();

    _animationController.reverse().then((_) {
      if (mounted) {
        _overlayController.hide();
        setState(() {
          _isMenuOpen = false;
        });
      }
    });
  }

  void _selectItem(MyDropdownItem<T> item) {
    _closeMenu();
    setState(() {
      _selectedValue = item.value;
      _textController.text = item.label;
    });
    _fieldKey.currentState?.didChange(item.label);
    if (widget.onChanged != null) {
      widget.onChanged!(item.value, item.label);
    }
  }

  double? _baseFieldHeight;
  double _errorHeightOffset = 0.0;

  bool _wasLabelNull = false;

  void _calculateErrorOffset() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final bool hasError = _fieldKey.currentState?.hasError ?? false;
    final bool isLabelNull = _isMenuOpen && _openUpward;

    if (!hasError && !_wasLabelNull) {
      _baseFieldHeight = renderBox.size.height;
      _errorHeightOffset = 0.0;
    } else if (_baseFieldHeight != null) {
      if (!isLabelNull) {
        _errorHeightOffset = renderBox.size.height - _baseFieldHeight!;
        if (_errorHeightOffset < 0) _errorHeightOffset = 0.0;
      }
    } else {
      _errorHeightOffset = 24.0;
    }

    _wasLabelNull = isLabelNull;
  }

  void _updatePositionWithoutSetState(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final actualFieldHeight = size.height - _errorHeightOffset;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    double topBound = MediaQuery.paddingOf(context).top;
    double bottomBound = screenHeight - keyboardHeight;

    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      final RenderBox? scrollableBox =
          scrollable.context.findRenderObject() as RenderBox?;
      if (scrollableBox != null) {
        final scrollableOffset = scrollableBox.localToGlobal(Offset.zero);

        if (scrollableOffset.dy > topBound) {
          topBound = scrollableOffset.dy;
        }

        final scrollableBottom =
            scrollableOffset.dy + scrollableBox.size.height;
        if (scrollableBottom < bottomBound) {
          bottomBound = scrollableBottom;
        }
      }
    }

    final spaceBelow = bottomBound - (offset.dy + actualFieldHeight) - 16.0;
    final spaceAbove = offset.dy - topBound - 16.0;

    if (spaceBelow >= 200.0 || spaceBelow >= spaceAbove) {
      _openUpward = false;
      _menuMaxHeight = spaceBelow.clamp(150.0, 400.0);
    } else {
      _openUpward = true;
      _menuMaxHeight = spaceAbove.clamp(150.0, 400.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateErrorOffset();

    if (_isMenuOpen) {
      _updatePositionWithoutSetState(context);
    }

    final ColorScheme colors = context.colorScheme;

    final selectedItem = widget.items
        .where((e) => e.value == _selectedValue)
        .firstOrNull;

    return TapRegion(
      groupId: this,
      onTapOutside: (_) => _closeMenu(),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: OverlayPortal(
          controller: _overlayController,
          overlayChildBuilder: (BuildContext context) {
            return TapRegion(
              groupId: this,
              onTapOutside: (_) => _closeMenu(),
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: _openUpward
                    ? Alignment.topLeft
                    : Alignment.bottomLeft,
                followerAnchor: _openUpward
                    ? Alignment.bottomLeft
                    : Alignment.topLeft,
                offset: Offset(0, _openUpward ? 0 : -_errorHeightOffset),
                child: Align(
                  alignment: _openUpward
                      ? Alignment.bottomLeft
                      : Alignment.topLeft,
                  child: _buildMenu(context),
                ),
              ),
            );
          },
          child: MyTextField(
            fieldKey: _fieldKey,
            controller: _textController,

            readOnly: true,
            onTap: _toggleMenu,
            hintText: widget.hintText,
            labelText: (_isMenuOpen && _openUpward) ? null : widget.labelText,
            isRequired: widget.isRequired,
            requiredMessage: widget.requiredMessage,
            fillColor: widget.fillColor,
            contentPadding: widget.contentPadding,
            focusNode: _focusNode,
            borderRadius: _isMenuOpen
                ? (_openUpward
                      ? BorderRadius.vertical(
                          bottom: Radius.circular(context.radiusM),
                        )
                      : BorderRadius.vertical(
                          top: Radius.circular(context.radiusM),
                        ))
                : BorderRadius.circular(context.radiusM),
            prefixWidget: selectedItem != null && selectedItem.icon != null
                ? MyIcon(
                    icon: selectedItem.icon!,
                    color: selectedItem.iconColor ?? colors.onSurface,
                  )
                : widget.prefixWidget ??
                      (widget.prefixIcon != null
                          ? MyIcon(
                              icon: widget.prefixIcon!,
                              color: colors.onSurfaceVariant,
                            )
                          : null),
            suffixWidget: RotationTransition(
              turns: Tween(
                begin: 0.0,
                end: _openUpward ? -0.5 : 0.5,
              ).animate(_expandAnimation),
              child:
                  widget.icon ??
                  MyIcon(
                    icon: AppIcons.arrowDown,
                    color: colors.onSurfaceVariant,
                  ),
            ),

            validator: (text) {
              return widget.validator?.call(_selectedValue);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final RenderBox? renderBox = this.context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    final colors = context.colorScheme;
    final Color borderColor = colors.outlineVariant;
    final double borderWidth = context.setSize(1);

    return SizedBox(
      width: size.width,
      child: Container(
        clipBehavior: Clip.hardEdge,
        constraints: BoxConstraints(maxHeight: _menuMaxHeight),
        decoration: BoxDecoration(
          color: widget.fillColor ?? colors.surfaceContainer,
          borderRadius: _openUpward
              ? BorderRadius.vertical(top: Radius.circular(context.radiusM))
              : BorderRadius.vertical(bottom: Radius.circular(context.radiusM)),
          border: Border(
            left: BorderSide(color: borderColor, width: borderWidth),
            right: BorderSide(color: borderColor, width: borderWidth),
            top: _openUpward
                ? BorderSide(color: borderColor, width: borderWidth)
                : BorderSide.none,
            bottom: !_openUpward
                ? BorderSide(color: borderColor, width: borderWidth)
                : BorderSide.none,
          ),
        ),
        child: SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: _openUpward ? 1.0 : -1.0,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: SelectableList<MyDropdownItem<T>>.single(
              items: widget.items,
              initialSelected: widget.items
                  .where((e) => e.value == _selectedValue)
                  .firstOrNull,
              itemLabel: (item) => item.label,
              onChanged: (item) => _selectItem(item),
              searchFillColor: colors.surfaceContainerHighest,
              enableSearch: widget.enableSearch,
              padding: EdgeInsets.zero,
              separatorHeight: 0,
              itemBorderRadius: BorderRadius.zero,
              emptyStateWidget: Padding(
                padding: context.insetsAllM,
                child: Text(context.l10n.noResultsFound),
              ),
              emptySearchWidget: Padding(
                padding: context.insetsAllM,
                child: Text(context.l10n.noResultsFound),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
