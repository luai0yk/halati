import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/shared/widgets/animations/my_animated_scale_switcher.dart';

class MyRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? innerColor;
  final double? size;
  final double? borderWidth;
  final bool enabled;

  const MyRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.innerColor,
    this.size,
    this.borderWidth,
    this.enabled = true,
  });

  bool get selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final actualSize = size ?? context.setSize(24);

    final active = activeColor ?? colorScheme.primary;
    final inactiveBorder = inactiveColor ?? colorScheme.outline;

    return GestureDetector(
      onTap: enabled ? () => onChanged?.call(value) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.veryFast,
        width: actualSize,
        height: actualSize,
        padding: EdgeInsets.all(context.setSize(4)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? (enabled
                      ? active
                      : colorScheme.onSurface.withValues(alpha: 0.38))
                : (enabled
                      ? inactiveBorder
                      : colorScheme.onSurface.withValues(alpha: 0.38)),
            width: borderWidth ?? context.setSize(2),
          ),
        ),
        child: MyAnimatedScaleSwitcher(
          child: selected
              ? Container(
                  key: const ValueKey('selected'),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled
                        ? (innerColor ?? active)
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('unselected')),
        ),
      ),
    );
  }
}
