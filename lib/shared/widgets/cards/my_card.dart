import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';

enum _MyCardType { elevated, outlined, filled, bordered }

class MyCard extends StatelessWidget {
  /// The widget content to display inside the card.
  final Widget child;

  final _MyCardType _type;

  /// Fixed width of the card.
  /// Defaults to [null] (wraps the child's width).
  final double? width;

  /// Fixed height of the card.
  /// Defaults to [null] (wraps the child's height).
  final double? height;

  /// Additional sizing constraints to apply to the card.
  /// Defaults to [null].
  final BoxConstraints? constraints;

  /// Custom background color.
  /// Defaults to [context.colorScheme.surfaceContainer] for elevated/filled/bordered variants,
  /// and [Colors.transparent] for outlined.
  final Color? color;

  /// Optional background gradient.
  /// Supports all Flutter gradient types such as [LinearGradient], [RadialGradient], and [SweepGradient].
  /// When provided, takes precedence over the solid [color].
  final Gradient? gradient;

  /// The size of the drop shadow. Only applies to [AppCard.elevated].
  /// Defaults to [context.elevationL] (scaled 8.0).
  final double? elevation;

  /// Internal padding for the card contents.
  /// Defaults to [context.insetsAllM] (scaled 12.0 on all sides).
  final EdgeInsets? padding;

  /// External margin around the card.
  /// Defaults to [null] (no margin).
  final EdgeInsets? margin;

  /// Custom border radius for the card corners.
  /// Supports custom shapes like [BorderRadius.only(...)].
  /// Defaults to [context.brM] (scaled 12.0 on all corners).
  final BorderRadius? borderRadius;

  /// Custom border color. Applies to outlined and bordered variants, or filled if specified.
  /// Defaults to [context.colorScheme.outlineVariant].
  final Color? borderColor;

  /// Thickness of the border.
  /// Defaults to 1.0 for outlined/bordered variants, and 0.0 for filled unless specified.
  final double? borderWidth;

  /// A custom list of shadows.
  /// If provided, completely overrides the default [elevation].
  final List<BoxShadow>? customShadow;

  /// Callback when the card is tapped. Adds an interactive Material ink splash.
  /// Defaults to [null] (no interaction).
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed. Adds an interactive Material ink splash.
  /// Defaults to [null] (no interaction).
  final VoidCallback? onLongPress;

  const MyCard._({
    super.key,
    required this.child,
    required _MyCardType type,
    this.width,
    this.height,
    this.constraints,
    this.color,
    this.gradient,
    this.elevation,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.customShadow,
    this.onTap,
    this.onLongPress,
  }) : _type = type;

  /// Creates a card lifted with a drop shadow.
  ///
  /// * [elevation] defaults to [context.elevationL].
  /// * [padding] defaults to [context.insetsAllM].
  /// * [borderRadius] defaults to [context.brM].
  /// * [gradient] optional background gradient taking precedence over [color].
  factory MyCard.elevated({
    Key? key,
    required Widget child,
    double? width,
    double? height,
    BoxConstraints? constraints,
    double? elevation,
    Color? color,
    Gradient? gradient,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? customShadow,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return MyCard._(
      key: key,
      type: _MyCardType.elevated,
      width: width,
      height: height,
      constraints: constraints,
      elevation: elevation,
      color: color,
      gradient: gradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      customShadow: customShadow,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Creates a card styled with a clear border outline and a transparent background.
  ///
  /// * [borderColor] defaults to [context.colorScheme.outlineVariant].
  /// * [borderWidth] defaults to 1.0.
  /// * [padding] defaults to [context.insetsAllM].
  /// * [borderRadius] defaults to [context.brM].
  /// * [gradient] optional background gradient taking precedence over [color].
  factory MyCard.outlined({
    Key? key,
    required Widget child,
    double? width,
    double? height,
    BoxConstraints? constraints,
    Color? color,
    Gradient? gradient,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? borderWidth,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return MyCard._(
      key: key,
      type: _MyCardType.outlined,
      width: width,
      height: height,
      constraints: constraints,
      color: color,
      gradient: gradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Creates a flat card with a solid background color and no border by default.
  ///
  /// * [color] defaults to [context.colorScheme.surfaceContainer].
  /// * [padding] defaults to [context.insetsAllM].
  /// * [borderRadius] defaults to [context.brM].
  /// * [gradient] optional background gradient taking precedence over [color].
  factory MyCard.filled({
    Key? key,
    required Widget child,
    double? width,
    double? height,
    BoxConstraints? constraints,
    Color? color,
    Gradient? gradient,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? borderWidth,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return MyCard._(
      key: key,
      type: _MyCardType.filled,
      width: width,
      height: height,
      constraints: constraints,
      color: color,
      gradient: gradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Creates a card with a solid background color AND a border outline.
  ///
  /// * [color] defaults to [context.colorScheme.surfaceContainer].
  /// * [borderColor] defaults to [context.colorScheme.outlineVariant].
  /// * [borderWidth] defaults to 1.0.
  /// * [padding] defaults to [context.insetsAllM].
  /// * [borderRadius] defaults to [context.brM].
  /// * [gradient] optional background gradient taking precedence over [color].
  factory MyCard.bordered({
    Key? key,
    required Widget child,
    double? width,
    double? height,
    BoxConstraints? constraints,
    Color? color,
    Gradient? gradient,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? borderWidth,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return MyCard._(
      key: key,
      type: _MyCardType.bordered,
      width: width,
      height: height,
      constraints: constraints,
      color: color,
      gradient: gradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    // Fallback values strictly using the requested responsive properties
    final BorderRadius radiusValue = borderRadius ?? context.brM;
    final EdgeInsets contentPadding = padding ?? context.insetsAllM;

    // Resolve visual styles based on type
    Color? bgColor;
    BoxBorder? border;
    List<BoxShadow>? shadows;

    switch (_type) {
      case _MyCardType.elevated:
        bgColor = color ?? colors.surfaceContainer;
        final double shadowElevation = elevation ?? context.elevationL;
        shadows =
            customShadow ??
            [BoxShadow(blurRadius: shadowElevation, color: Colors.black12)];
        break;

      case _MyCardType.outlined:
        bgColor = color ?? Colors.transparent;
        border = Border.all(
          color: borderColor ?? colors.outlineVariant,
          width: borderWidth ?? 1.0,
        );
        break;

      case _MyCardType.filled:
        bgColor = color ?? colors.surfaceContainer;
        if (borderColor != null) {
          border = Border.all(color: borderColor!, width: borderWidth ?? 1.0);
        }
        break;

      case _MyCardType.bordered:
        bgColor = color ?? colors.surfaceContainer;
        border = Border.all(
          color: borderColor ?? colors.outlineVariant,
          width: borderWidth ?? 1.0,
        );
        break;
    }

    // Build single unified container
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: radiusValue,
        boxShadow: shadows,
      ),
      foregroundDecoration: border != null
          ? BoxDecoration(border: border, borderRadius: radiusValue)
          : null,
      child: _buildContent(context, radiusValue, contentPadding),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BorderRadius radiusValue,
    EdgeInsets contentPadding,
  ) {
    final hasInteraction = onTap != null || onLongPress != null;

    if (!hasInteraction) {
      return Padding(padding: contentPadding, child: child);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: context.colorScheme.primary.withValues(alpha: .2),
        highlightColor: context.colorScheme.primary.withValues(alpha: .2),
        borderRadius: radiusValue,
        child: Padding(padding: contentPadding, child: child),
      ),
    );
  }
}
