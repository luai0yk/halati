import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/animations/my_animated_visibility.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_progress_indicator.dart';

enum _MyIconButtonType { solid, outlined, ghost, bordered }

class MyIconButton extends StatefulWidget {
  /// The icon to display inside the button.
  final IconData icon;

  /// Callback when the button is tapped. If null, the button is disabled.
  final Function()? onPressed;

  final _MyIconButtonType _type;

  /// The total size (width and height) of the circular button.
  /// Defaults to [context.setSize(38)].
  final double? buttonSize;

  /// The size of the icon.
  /// Defaults to [context.iconM] (scaled 20.0).
  final double? iconSize;

  /// Custom background color for the button.
  /// Defaults depend on the factory used (e.g., [context.colorScheme.surfaceContainer] for solid).
  final Color? backgroundColor;

  /// The color of the icon and the loading spinner.
  /// Defaults to standard icon color unless overridden by states (like [isSelected]).
  final Color? iconColor;

  /// The color of the border.
  /// Used in [MyIconButton.outlined] and [MyIconButton.bordered].
  final Color? borderColor;

  /// Whether the button is currently selected.
  /// Only applies to [MyIconButton.bordered], highlighting the border and icon.
  final bool isSelected;

  /// Whether the icon should use its filled variant (if supported by [MyIcon]).
  /// Defaults to false.
  final bool filled;

  /// Optional tooltip text to display on hover/long press.
  final String? tooltip;

  /// Whether the button should be disabled.
  final bool disabled;

  /// Whether to automatically show a loading indicator while an async [onPressed] callback executes.
  /// Defaults to `true`.
  final bool autoLoading;

  const MyIconButton._({
    super.key,
    required this.icon,
    required this.onPressed,
    required _MyIconButtonType type,
    this.buttonSize,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.isSelected = false,
    this.filled = false,
    this.tooltip,
    this.disabled = false,
    this.autoLoading = true,
  }) : _type = type;

  /// Creates a circular button with a solid background.
  ///
  /// * [backgroundColor] defaults to [context.colorScheme.surfaceContainer].
  factory MyIconButton.solid({
    Key? key,
    required IconData icon,
    Function()? onPressed,
    Color? iconColor,
    double? buttonSize,
    double? iconSize,
    Color? backgroundColor,
    Color? borderColor,
    bool filled = false,
    String? tooltip,
    bool disabled = false,
    bool autoLoading = true,
  }) {
    return MyIconButton._(
      key: key,
      icon: icon,
      onPressed: onPressed,
      type: _MyIconButtonType.solid,
      buttonSize: buttonSize,
      iconSize: iconSize,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      borderColor: borderColor,
      filled: filled,
      tooltip: tooltip,
      disabled: disabled,
      autoLoading: autoLoading,
    );
  }

  /// Creates a circular button with a transparent background and an outline border.
  ///
  /// * [borderColor] defaults to [context.colorScheme.outlineVariant].
  factory MyIconButton.outlined({
    Key? key,
    required IconData icon,
    Function()? onPressed,
    Color? iconColor,
    double? buttonSize,
    double? iconSize,
    Color? borderColor,
    bool filled = false,
    String? tooltip,
    bool disabled = false,
    bool autoLoading = true,
  }) {
    return MyIconButton._(
      key: key,
      icon: icon,
      onPressed: onPressed,
      type: _MyIconButtonType.outlined,
      buttonSize: buttonSize,
      iconSize: iconSize,
      borderColor: borderColor,
      iconColor: iconColor,
      filled: filled,
      tooltip: tooltip,
      disabled: disabled,
      autoLoading: autoLoading,
    );
  }

  /// Creates a completely flat circular button with no background and no border.
  factory MyIconButton.ghost({
    Key? key,
    required IconData icon,
    Function()? onPressed,
    Color? iconColor,
    double? buttonSize,
    double? iconSize,
    bool filled = false,
    String? tooltip,
    bool disabled = false,
    bool autoLoading = true,
  }) {
    return MyIconButton._(
      key: key,
      icon: icon,
      onPressed: onPressed,
      type: _MyIconButtonType.ghost,
      buttonSize: buttonSize,
      iconSize: iconSize,
      iconColor: iconColor,
      filled: filled,
      tooltip: tooltip,
      disabled: disabled,
      autoLoading: autoLoading,
    );
  }

  /// Creates a solid circular button with a border that can highlight when selected.
  ///
  /// * [backgroundColor] defaults to [context.colorScheme.surfaceContainer].
  /// * [borderColor] defaults to [context.colorScheme.outlineVariant].
  /// * When [isSelected] is true, the border and icon color switch to [context.colorScheme.primary].
  factory MyIconButton.bordered({
    Key? key,
    required IconData icon,
    Function()? onPressed,
    Color? iconColor,
    double? buttonSize,
    double? iconSize,
    Color? backgroundColor,
    Color? borderColor,
    bool isSelected = false,
    bool filled = false,
    String? tooltip,
    bool disabled = false,
    bool autoLoading = true,
  }) {
    return MyIconButton._(
      key: key,
      icon: icon,
      onPressed: onPressed,
      type: _MyIconButtonType.bordered,
      buttonSize: buttonSize,
      iconSize: iconSize,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      iconColor: iconColor,
      isSelected: isSelected,
      filled: filled,
      tooltip: tooltip,
      disabled: disabled,
      autoLoading: autoLoading,
    );
  }

  @override
  State<MyIconButton> createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (widget.onPressed != null) {
      final result = widget.onPressed!();
      if (result is Future && widget.autoLoading) {
        setState(() {
          _isLoading = true;
        });
        try {
          await result;
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    // Resolve responsive fallback sizes
    final double finalSize = widget.buttonSize ?? context.setSize(38);
    final double defaultIconSize = widget.iconSize ?? context.iconM;

    // Resolve visual styles based on type
    Color baseBg = Colors.transparent;
    BorderSide baseBorder = BorderSide.none;
    Color baseIconColor =
        widget.iconColor ?? colors.onSurface; // fallback to colors.onSurface

    switch (widget._type) {
      case _MyIconButtonType.solid:
        baseBg = widget.backgroundColor ?? colors.surfaceContainer;
        if (widget.borderColor != null) {
          baseBorder = BorderSide(color: widget.borderColor!, width: 1);
        }
        break;

      case _MyIconButtonType.outlined:
        baseBg = widget.backgroundColor ?? Colors.transparent;
        baseBorder = BorderSide(
          color: widget.borderColor ?? colors.outlineVariant,
          width: 1,
        );
        break;

      case _MyIconButtonType.ghost:
        baseBg = Colors.transparent;
        break;

      case _MyIconButtonType.bordered:
        baseBg = widget.backgroundColor ?? colors.surfaceContainer;
        baseBorder = BorderSide(
          color: widget.isSelected
              ? context.colorScheme.primary
              : (widget.borderColor ?? colors.outlineVariant),
          width: 1,
        );
        if (widget.isSelected) {
          baseIconColor = widget.iconColor ?? context.colorScheme.primary;
        }
        break;
    }

    final bool isEffectivelyDisabled =
        _isLoading || widget.onPressed == null || widget.disabled;

    final Color finalBg = isEffectivelyDisabled
        ? (baseBg == Colors.transparent
              ? Colors.transparent
              : baseBg.withValues(alpha: baseBg.a * 0.5))
        : baseBg;

    final Color finalIconColor = isEffectivelyDisabled
        ? baseIconColor.withValues(alpha: baseIconColor.a * 0.5)
        : baseIconColor;

    final BorderSide finalBorder =
        (baseBorder.style != BorderStyle.none && isEffectivelyDisabled)
        ? baseBorder.copyWith(
            color: baseBorder.color.withValues(alpha: baseBorder.color.a * 0.5),
          )
        : baseBorder;

    // Build single unified container
    Widget button = Container(
      width: finalSize,
      height: finalSize,
      decoration: BoxDecoration(
        color: finalBg,
        borderRadius: BorderRadius.circular(context.radiusM),
        border: finalBorder.style != BorderStyle.none
            ? Border.fromBorderSide(finalBorder)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Disable interaction dynamically if loading or if no callback was provided
          onTap: isEffectivelyDisabled ? null : _handlePressed,
          borderRadius: BorderRadius.circular(context.radiusM),
          splashColor:
              (widget.iconColor ??
                      (widget.isSelected ? colors.primary : null) ??
                      widget.borderColor ??
                      widget.backgroundColor ??
                      colors.primary)
                  .withValues(alpha: .15),
          highlightColor:
              (widget.iconColor ??
                      (widget.isSelected ? colors.primary : null) ??
                      widget.borderColor ??
                      widget.backgroundColor ??
                      colors.primary)
                  .withValues(alpha: .12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Icon fades out when loading
              MyAnimatedVisibility(
                visible: !_isLoading,
                child: MyIcon(
                  icon: widget.icon,
                  size: defaultIconSize,
                  filled: widget.filled,
                  color: finalIconColor,
                ),
              ),

              // Spinner fades in when loading
              MyAnimatedVisibility(
                visible: _isLoading,
                child: MyProgressIndicator(
                  size: defaultIconSize,
                  color: finalIconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
