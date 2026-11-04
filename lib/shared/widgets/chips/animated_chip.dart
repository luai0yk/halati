import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/shared/widgets/animations/my_animated_fade_switcher.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';

class AnimatedChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  /// When true, shows a checkmark icon.
  /// Defaults to `false`.
  final bool showIcon;

  /// Custom border radius.
  /// Defaults to [context.brCircular].
  final BorderRadius? borderRadius;

  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;

  const AnimatedChip({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.showIcon = false,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return MyAnimatedFadeSwitcher(
      child: MyCard.filled(
        key: ValueKey<bool>(isSelected),
        padding: EdgeInsets.symmetric(
          horizontal: context.spaceM,
          vertical: context.setSize(6),
        ),
        color: isSelected
            ? context.colorScheme.primary
            : colors.surfaceContainer,
        borderRadius: borderRadius ?? context.brCircular,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefix != null) ...[
              prefix!,
              SizedBox(width: context.setSize(6)),
            ] else if (prefixIcon != null) ...[
              MyIcon(
                icon: prefixIcon!,
                color: isSelected ? Colors.white : colors.onSurface,
                size: context.setSize(14),
              ),
              SizedBox(width: context.setSize(6)),
            ] else if (isSelected && showIcon) ...[
              MyIcon(
                icon: AppIcons.checkCircle,
                color: Colors.white,
                size: context.setSize(14),
              ),
              SizedBox(width: context.setSize(6)),
            ],
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : colors.onSurface,
                fontSize: context.setSize(13),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (suffix != null) ...[
              SizedBox(width: context.setSize(6)),
              suffix!,
            ] else if (suffixIcon != null) ...[
              SizedBox(width: context.setSize(6)),
              MyIcon(
                icon: suffixIcon!,
                color: isSelected ? Colors.white : colors.onSurface,
                size: context.setSize(14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
