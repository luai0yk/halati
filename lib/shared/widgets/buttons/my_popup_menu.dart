import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';

class MyPopupMenuItem<T> {
  final T? value;
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const MyPopupMenuItem({
    this.value,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
  });
}

class MyPopupMenu<T> extends StatelessWidget {
  final List<MyPopupMenuItem<T>> items;
  final void Function(T)? onSelected;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final Color? iconBackground;
  final BorderRadiusGeometry? iconRadius;
  final String? tooltip;
  final Offset offset;
  final ShapeBorder? shape;
  final Color? color;
  final double? elevation;

  const MyPopupMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.iconBackground,
    this.iconRadius,
    this.tooltip,
    this.offset = Offset.zero,
    this.shape,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: MyIcon(
        icon: icon ?? AppIcons.more,
        color: iconColor,
        size: iconSize ?? context.iconM,
      ),
      iconSize: iconSize,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          iconBackground ?? context.colorScheme.surfaceContainer,
        ),
        splashFactory: InkRipple.splashFactory,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: iconRadius ?? context.brM,
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),

      tooltip: tooltip,
      offset: offset,
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: context.brM,
            side: BorderSide(
              width: context.setSize(0.4),
              color: context.colorScheme.outlineVariant,
            ),
          ),
      color: color ?? context.colorScheme.surface,
      elevation: elevation ?? context.elevationS,
      onSelected: (value) {
        onSelected?.call(value);
      },
      itemBuilder: (BuildContext context) {
        return items.map((MyPopupMenuItem<T> item) {
          final itemColor = item.color ?? context.colorScheme.onSurface;
          return PopupMenuItem<T>(
            value: item.value,
            onTap: item.onTap,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  MyIcon(
                    icon: item.icon!,
                    color: itemColor,
                    size: context.iconM,
                  ),
                  SizedBox(width: context.spaceS),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: itemColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
