import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final Color? tileColor;
  final bool enabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? trailing;
  final Widget? leading;
  final Function()? onTap;
  final Function()? onLongPress;
  final Color? titleColor;
  final Color? subtitleColor;
  final TextStyle? titleStyle;
  final TextStyle? selectedTitleStyle;
  final TextStyle? subtitleStyle;
  final BorderRadius? borderRadius;
  final TextDirection? subtitleDirection;

  const MyListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.tileColor,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.trailing,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.titleStyle,
    this.titleColor,
    this.subtitleColor,
    this.selectedTitleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.subtitleDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: ListTile(
          onTap: onTap,
          contentPadding: context.insetsHorizontalM,
          onLongPress: onLongPress,
          selected: selected,
          enabled: enabled,
          tileColor: tileColor,
          selectedTileColor: context.colorScheme.primary.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? context.brM,
          ),
          title: Text(
            title,
            style: selected
                ? selectedTitleStyle
                : titleStyle ??
                      context.textTheme.titleMedium?.copyWith(
                        color: titleColor,
                      ),
          ),

          subtitle: (subtitle != null)
              // Do not remove Row & Flexible
              // They help to make the subtitle support text direction better
              ? Row(
                  children: [
                    Flexible(
                      child: Text(
                        subtitle!,
                        textDirection: subtitleDirection,

                        style:
                            subtitleStyle ??
                            context.textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                            ),
                      ),
                    ),
                  ],
                )
              : null,

          leading: (leading != null)
              ? leading
              : (leadingIcon != null)
              ? MyIcon(
                  icon: leadingIcon!,
                  color: selected ? context.colorScheme.primary : null,
                )
              : null,

          trailing: (trailing != null)
              ? trailing
              : (trailingIcon != null)
              ? MyIcon(
                  icon: trailingIcon!,
                  color: context.colorScheme.onSurfaceVariant,
                  size: context.iconS,
                )
              : null,
        ),
      ),
    );
  }
}
