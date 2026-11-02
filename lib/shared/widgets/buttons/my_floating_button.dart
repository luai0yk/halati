import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

class MyFloatingButton extends StatelessWidget {
  final String? label;
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const MyFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  }) : label = null;

  const MyFloatingButton.extended({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final double floatingButtonSize = context.setSize(54);
    final ColorScheme colors = context.colorScheme;

    if (label != null) {
      return SizedBox(
        height: floatingButtonSize,
        child: FloatingActionButton.extended(
          heroTag: null,
          tooltip: tooltip,
          backgroundColor: colors.primary,
          label: Text(
            label!,
            style: context.textTheme.labelLarge?.copyWith(
              color: colors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: context.elevationM,
          icon: MyIcon(icon: icon, color: colors.surface, size: context.iconL),
          onPressed: onPressed,
        ),
      );
    }

    return SizedBox(
      height: floatingButtonSize,
      width: floatingButtonSize,
      child: FloatingActionButton(
        heroTag: null,
        tooltip: tooltip,
        shape: RoundedRectangleBorder(borderRadius: context.brL),
        backgroundColor: colors.primary,
        onPressed: onPressed,
        elevation: context.elevationM,
        child: MyIcon(icon: icon, color: colors.surface, size: context.iconL),
      ),
    );
  }
}
