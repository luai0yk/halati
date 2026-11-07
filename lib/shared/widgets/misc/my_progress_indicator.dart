import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';

class MyProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? color;
  final double? size;
  final double? strokeWidth;
  final Color? backgroundColor;

  const MyProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.size,
    this.strokeWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      value: value,
      color: color ?? context.colorScheme.primary,
      backgroundColor: backgroundColor,
      strokeWidth: strokeWidth ?? context.setSize(3),
      strokeCap: StrokeCap.round,
    );

    if (size != null) {
      return SizedBox(width: size, height: size, child: indicator);
    }

    return indicator;
  }
}
