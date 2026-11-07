import 'package:flutter/material.dart';
import 'package:halati/shared/widgets/input/my_checkbox.dart';
import 'package:halati/shared/widgets/tiles/my_list_tile.dart';

class MyCheckboxTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? checkColor;
  final double? size;
  final double? borderWidth;
  final BorderRadiusGeometry? borderRadius;
  final Widget? secondary;
  final ListTileControlAffinity controlAffinity;
  final bool enabled;

  const MyCheckboxTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.checkColor,
    this.size,
    this.borderWidth,
    this.borderRadius,
    this.subtitle,
    this.secondary,
    this.controlAffinity = ListTileControlAffinity.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final control = MyCheckbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      checkColor: checkColor,
      size: size,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      enabled: enabled,
    );

    return MyListTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
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
