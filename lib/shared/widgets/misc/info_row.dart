import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? iconColor;
  final Color? labelColor;
  final Color? valueColor;
  final double? labelSize;
  final double? valueSize;
  final double? iconSize;
  final FontWeight? labelWeight;
  final FontWeight? valueWeight;

  const InfoRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.iconColor,
    this.labelColor,
    this.valueColor,
    this.labelSize,
    this.valueSize,
    this.iconSize,
    this.labelWeight,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return Row(
      children: [
        if (icon != null) ...[
          MyIcon(
            icon: icon!,
            color: iconColor ?? context.colorScheme.primary,
            size: iconSize ?? context.iconS,
          ),
          SizedBox(width: context.spaceM),
        ],

        Expanded(
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: labelColor ?? colors.onSurfaceVariant,
              fontSize: labelSize,
              fontWeight: labelWeight,
            ),
          ),
        ),

        if (value != null)
          Text(
            value!,
            style: context.textTheme.labelMedium?.copyWith(
              color: valueColor ?? colors.onSurface,
              fontSize: valueSize,
              fontWeight: valueWeight ?? FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
