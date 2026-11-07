import 'package:flutter/material.dart';
import 'package:halati/shared/widgets/input/my_switch.dart';
import 'package:halati/shared/widgets/tiles/my_list_tile.dart';

class MySwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final bool thumbShadow;
  final double? width;
  final double? height;
  final Widget? secondary;
  final ListTileControlAffinity controlAffinity;
  final bool enabled;
  final BorderRadius? borderRadius;

  const MySwitchTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.thumbShadow = true,
    this.width,
    this.height,
    this.subtitle,
    this.secondary,
    this.controlAffinity = ListTileControlAffinity.trailing,
    this.enabled = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final control = MySwitch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      activeThumbColor: activeThumbColor,
      inactiveThumbColor: inactiveThumbColor,
      thumbShadow: thumbShadow,
      width: width,
      height: height,
      enabled: enabled,
    );

    return MyListTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      borderRadius: borderRadius,
      leading: controlAffinity == ListTileControlAffinity.leading
          ? control
          : secondary,
      trailing: controlAffinity == ListTileControlAffinity.trailing
          ? control
          : secondary,
      onTap: enabled ? () => onChanged?.call(!value) : null,
    );
  }
}
