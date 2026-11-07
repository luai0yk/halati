import 'dart:async';

import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/widgets/animations/my_animated_visibility.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';

enum AppButtonTextStyle { bold, medium, regular }

enum _MyButtonType { primary, outlined, outlinedNeutral, text }

class MyButton extends StatefulWidget {
  /// The text to display inside the button.
  final String text;

  /// Callback when the button is tapped. If null, the button is disabled.
  final Function()? onPressed;

  /// The internal type of the button.
  final _MyButtonType _type;

  /// When true, disables the button visually and functionally.
  final bool isDisabled;

  /// Optional widget to display before the text.
  final Widget? prefix;

  /// Optional widget to display after the text.
  final Widget? suffix;

  /// Optional icon data to display before the text.
  final IconData? prefixIcon;

  /// Optional icon data to display after the text.
  final IconData? suffixIcon;

  /// The main color of the button.
  /// - Primary: Sets the background color.
  /// - Outlined: Sets both the border and text color.
  /// - Text: Sets the text color.
  /// Defaults to [context.colorScheme.primary].
  final Color? color;

  /// Custom text and icon color.
  /// Primarily used in [MyButton.primary] to override the default text color.
  final Color? foregroundColor;

  /// Fixed width of the button.
  /// Primary/Outlined default to full width ([double.infinity]).
  /// Text buttons default to wrap content.
  final double? width;

  /// Fixed height of the button. Defaults to [context.setSize(54)].
  final double? height;

  /// Border radius of the button.
  final BorderRadiusGeometry? borderRadius;

  /// Internal padding. Defaults to symmetric horizontal padding.
  final EdgeInsets? padding;

  /// Font weight style. Defaults to [AppButtonTextStyle.bold].
  final AppButtonTextStyle textStyleType;

  /// Custom font size. Defaults to scaled 16.0.
  final double? fontSize;

  /// If provided, disables the button and displays a countdown timer for this many seconds.
  final int? timerSeconds;

  /// Whether to automatically show a loading indicator and disable the button while an async [onPressed] callback executes.
  /// Defaults to `true`.
  final bool autoLoading;

  const MyButton._({
    super.key,
    required this.text,
    this.onPressed,
    required _MyButtonType type,
    this.isDisabled = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.color,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.textStyleType = AppButtonTextStyle.bold,
    this.fontSize,
    this.timerSeconds,
    this.autoLoading = true,
  }) : _type = type;

  factory MyButton.primary({
    Key? key,
    required String text,
    Function()? onPressed,
    bool isDisabled = false,
    Widget? prefix,
    Widget? suffix,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? color,
    Color? foregroundColor,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    EdgeInsets? padding,
    AppButtonTextStyle textStyleType = AppButtonTextStyle.bold,
    double? fontSize,
    int? timerSeconds,
    bool autoLoading = true,
  }) {
    return MyButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      type: _MyButtonType.primary,
      isDisabled: isDisabled,
      prefix: prefix,
      suffix: suffix,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      color: color,
      foregroundColor: foregroundColor,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      textStyleType: textStyleType,
      fontSize: fontSize,
      timerSeconds: timerSeconds,
      autoLoading: autoLoading,
    );
  }

  factory MyButton.outlined({
    Key? key,
    required String text,
    Function()? onPressed,
    bool isDisabled = false,
    Widget? prefix,
    Widget? suffix,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? color,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    EdgeInsets? padding,
    AppButtonTextStyle textStyleType = AppButtonTextStyle.bold,
    double? fontSize,
    int? timerSeconds,
    bool autoLoading = true,
  }) {
    return MyButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      type: _MyButtonType.outlined,
      isDisabled: isDisabled,
      prefix: prefix,
      suffix: suffix,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      color: color,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      textStyleType: textStyleType,
      fontSize: fontSize,
      timerSeconds: timerSeconds,
      autoLoading: autoLoading,
    );
  }

  factory MyButton.outlinedNeutral({
    Key? key,
    required String text,
    Function()? onPressed,
    bool isDisabled = false,
    Widget? prefix,
    Widget? suffix,
    IconData? prefixIcon,
    IconData? suffixIcon,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    EdgeInsets? padding,
    AppButtonTextStyle textStyleType = AppButtonTextStyle.bold,
    double? fontSize,
    int? timerSeconds,
    bool autoLoading = true,
  }) {
    return MyButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      type: _MyButtonType.outlinedNeutral,
      isDisabled: isDisabled,
      prefix: prefix,
      suffix: suffix,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      textStyleType: textStyleType,
      fontSize: fontSize,
      timerSeconds: timerSeconds,
      autoLoading: autoLoading,
    );
  }

  factory MyButton.text({
    Key? key,
    required String text,
    Function()? onPressed,
    bool isDisabled = false,
    Widget? prefix,
    Widget? suffix,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? color,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    EdgeInsets? padding,
    AppButtonTextStyle textStyleType = AppButtonTextStyle.bold,
    double? fontSize,
    int? timerSeconds,
    bool autoLoading = true,
  }) {
    return MyButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      type: _MyButtonType.text,
      isDisabled: isDisabled,
      prefix: prefix,
      suffix: suffix,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      color: color,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      textStyleType: textStyleType,
      fontSize: fontSize,
      timerSeconds: timerSeconds,
      autoLoading: autoLoading,
    );
  }

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isLoading = false;
  Timer? _countdownTimer;
  int? _currentTimerSeconds;

  @override
  void initState() {
    super.initState();
    if (widget.timerSeconds != null && widget.timerSeconds! > 0) {
      _currentTimerSeconds = widget.timerSeconds;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentTimerSeconds != null && _currentTimerSeconds! > 0) {
          setState(() {
            _currentTimerSeconds = _currentTimerSeconds! - 1;
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

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

    final bool isTimerActive =
        _currentTimerSeconds != null && _currentTimerSeconds! > 0;
    final bool isEffectivelyDisabled =
        _isLoading || widget.isDisabled || isTimerActive;

    // Resolve visual styles based on button type
    Color baseBg;
    Color baseFg;
    BorderSide baseBorder = BorderSide.none;

    // Default width logic: Text buttons wrap content, others are full width.
    double defaultWidth =
        widget.width ??
        (widget._type == _MyButtonType.text ? 0 : double.infinity);

    switch (widget._type) {
      case _MyButtonType.primary:
        baseBg = widget.color ?? colors.primary;
        baseFg = widget.foregroundColor ?? colors.onPrimary;
        break;
      case _MyButtonType.outlined:
        baseBg = Colors.transparent;
        baseFg = widget.color ?? colors.primary;
        baseBorder = BorderSide(
          color: widget.color ?? colors.primary,
          width: context.setSize(1),
        );
        break;
      case _MyButtonType.outlinedNeutral:
        baseBg = Colors.transparent;
        baseFg = colors.onSurface;
        baseBorder = BorderSide(
          color: colors.outlineVariant,
          width: context.setSize(1),
        );
        break;
      case _MyButtonType.text:
        baseBg = Colors.transparent;
        baseFg = widget.color ?? colors.primary;
        break;
    }

    final Color finalBg = isEffectivelyDisabled
        ? (baseBg == Colors.transparent
              ? Colors.transparent
              : baseBg.withValues(alpha: 0.5))
        : baseBg;

    final Color finalFg = isEffectivelyDisabled
        ? baseFg.withValues(alpha: 0.5)
        : baseFg;

    final BorderSide finalBorder =
        (baseBorder.style != BorderStyle.none && isEffectivelyDisabled)
        ? baseBorder.copyWith(color: baseBorder.color.withValues(alpha: 0.5))
        : baseBorder;

    // Build Single Button Implementation
    return TextButton(
      onPressed: isEffectivelyDisabled ? null : _handlePressed,
      style: TextButton.styleFrom(
        backgroundColor: finalBg,
        foregroundColor: finalFg,
        disabledBackgroundColor: finalBg,
        disabledForegroundColor: finalFg,
        minimumSize: Size(defaultWidth, widget.height ?? context.setSize(54)),
        padding:
            widget.padding ?? EdgeInsets.symmetric(horizontal: context.spaceL),
        shape: RoundedRectangleBorder(
          borderRadius:
              widget.borderRadius ?? BorderRadius.circular(context.radiusM),
          side: finalBorder,
        ),
      ),
      child: _buildChild(context, finalFg),
    );
  }

  Widget _buildChild(BuildContext context, Color fgColor) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefix != null) ...[
          widget.prefix!,
          SizedBox(width: context.spaceS),
        ] else if (widget.prefixIcon != null) ...[
          MyIcon(icon: widget.prefixIcon!, size: context.iconM, color: fgColor),
          SizedBox(width: context.spaceS),
        ],
        Flexible(
          child: Text(
            (_currentTimerSeconds != null && _currentTimerSeconds! > 0)
                ? '${widget.text} ($_currentTimerSeconds)'
                : widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              color: fgColor,
              fontSize: widget.fontSize,
              fontWeight: _getFontWeight(),
            ),
          ),
        ),
        if (widget.suffix != null) ...[
          SizedBox(width: context.spaceS),
          widget.suffix!,
        ] else if (widget.suffixIcon != null) ...[
          SizedBox(width: context.spaceS),
          MyIcon(icon: widget.suffixIcon!, size: context.iconM, color: fgColor),
        ],
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Content hides when loading
        MyAnimatedVisibility(visible: !_isLoading, child: content),

        // Spinner shows when loading (matching foreground color)
        MyAnimatedVisibility(
          visible: _isLoading,
          child: MyProgressIndicator(size: context.iconM, color: fgColor),
        ),
      ],
    );
  }

  FontWeight _getFontWeight() {
    switch (widget.textStyleType) {
      case AppButtonTextStyle.bold:
        return FontWeight.bold;
      case AppButtonTextStyle.medium:
        return FontWeight.w500;
      case AppButtonTextStyle.regular:
        return FontWeight.w400;
    }
  }
}
