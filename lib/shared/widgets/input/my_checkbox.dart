import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/shared/widgets/animations/my_animated_scale_switcher.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';

class MyCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? checkColor;
  final double? size;
  final double? borderWidth;
  final BorderRadiusGeometry? borderRadius;
  final bool enabled;

  const MyCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.checkColor,
    this.size,
    this.borderWidth,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final actualSize = size ?? context.setSize(24);

    final active = activeColor ?? colorScheme.primary;
    final check = checkColor ?? colorScheme.onPrimary;
    final inactiveBorder = inactiveColor ?? colorScheme.outline;

    return GestureDetector(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: actualSize,
        height: actualSize,
        decoration: BoxDecoration(
          color: value
              ? (enabled
                    ? active
                    : colorScheme.onSurface.withValues(alpha: 0.38))
              : Colors.transparent,
          borderRadius:
              borderRadius ?? BorderRadius.circular(context.setSize(6)),
          border: Border.all(
            color: value
                ? (enabled
                      ? active
                      : colorScheme.onSurface.withValues(alpha: 0.1))
                : (enabled
                      ? inactiveBorder
                      : colorScheme.onSurface.withValues(alpha: 0.38)),
            width: borderWidth ?? context.setSize(2),
          ),
        ),
        child: MyAnimatedScaleSwitcher(
          child: value
              ? MyIcon(
                  key: const ValueKey('checked'),
                  icon: AppIcons.check,
                  size: actualSize * 0.7,
                  color: enabled ? check : colorScheme.surface,
                )
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}
