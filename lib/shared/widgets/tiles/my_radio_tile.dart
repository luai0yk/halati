import 'package:flutter/material.dart';
import 'package:flutter_app_template/shared/widgets/input/my_radio.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_list_tile.dart';

class MyRadioTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? innerColor;
  final double? size;
  final double? borderWidth;
  final Widget? secondary;
  final ListTileControlAffinity controlAffinity;
  final bool enabled;

  const MyRadioTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.innerColor,
    this.size,
    this.borderWidth,
    this.subtitle,
    this.secondary,
    this.controlAffinity = ListTileControlAffinity.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final control = MyRadio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      innerColor: innerColor,
      size: size,
      borderWidth: borderWidth,
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
      onTap: enabled ? () => onChanged?.call(value) : null,
    );
  }
}
