import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
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
    this.tooltip,
    this.offset = Offset.zero,
    this.shape,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: MyCard.filled(
        padding: context.insetsAllS,
        child: MyIcon(icon: icon ?? AppIcons.more, color: iconColor),
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
                    style: TextStyle(
                      color: itemColor,
                      fontSize: context.setSize(14),
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
