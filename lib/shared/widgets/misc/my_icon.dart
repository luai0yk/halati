import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';

class MyIcon extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon. If not provided,
  /// defaults to [context.setSize(24)].
  final double? size;

  /// The color of the icon. If not provided,
  /// defaults to [context.colorScheme.onSurface].
  final Color? color;

  final bool filled;

  const MyIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = context.colorScheme;

    return Icon(
      icon,
      size: size ?? context.iconM,
      color: color ?? colors.onSurface,
      fill: filled ? 1 : 0,
      weight: 700,
    );
  }
}
