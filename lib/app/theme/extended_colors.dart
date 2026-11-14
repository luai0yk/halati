import 'package:flutter/material.dart';

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

class ExtendedColors extends ThemeExtension<ExtendedColors> {
  final ColorFamily danger;
  final ColorFamily warning;
  final ColorFamily info;
  final ColorFamily success;

  const ExtendedColors({
    required this.danger,
    required this.warning,
    required this.info,
    required this.success,
  });

  @override
  ExtendedColors copyWith({
    ColorFamily? danger,
    ColorFamily? warning,
    ColorFamily? info,
    ColorFamily? success,
  }) {
    return ExtendedColors(
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      success: success ?? this.success,
    );
  }

  @override
  ExtendedColors lerp(ThemeExtension<ExtendedColors>? other, double t) {
    if (other is! ExtendedColors) return this;
    return ExtendedColors(
      danger: _lerpFamily(danger, other.danger, t),
      warning: _lerpFamily(warning, other.warning, t),
      info: _lerpFamily(info, other.info, t),
      success: _lerpFamily(success, other.success, t),
    );
  }

  ColorFamily _lerpFamily(ColorFamily a, ColorFamily b, double t) {
    return ColorFamily(
      color: Color.lerp(a.color, b.color, t)!,
      onColor: Color.lerp(a.onColor, b.onColor, t)!,
      colorContainer: Color.lerp(a.colorContainer, b.colorContainer, t)!,
      onColorContainer: Color.lerp(a.onColorContainer, b.onColorContainer, t)!,
    );
  }

  static const ExtendedColors light = ExtendedColors(
    danger: ColorFamily(
      color: Color(0xffa42200),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd02d00),
      onColorContainer: Color(0xffffece8),
    ),
    warning: ColorFamily(
      color: Color(0xff755b00),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe3b200),
      onColorContainer: Color(0xff5b4600),
    ),
    info: ColorFamily(
      color: Color(0xff005da8),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff0076d3),
      onColorContainer: Color(0xfffdfcff),
    ),
    success: ColorFamily(
      color: Color(0xff276c00),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff4bb70d),
      onColorContainer: Color(0xff144000),
    ),
  );

  static const ExtendedColors dark = ExtendedColors(
    danger: ColorFamily(
      color: Color(0xffffb4a3),
      onColor: Color(0xff621000),
      colorContainer: Color(0xffd02d00),
      onColorContainer: Color(0xffffece8),
    ),
    warning: ColorFamily(
      color: Color(0xffffce41),
      onColor: Color(0xff3e2e00),
      colorContainer: Color(0xffe3b200),
      onColorContainer: Color(0xff5b4600),
    ),
    info: ColorFamily(
      color: Color(0xffa4c9ff),
      onColor: Color(0xff00315d),
      colorContainer: Color(0xff3093f8),
      onColorContainer: Color(0xff00152e),
    ),
    success: ColorFamily(
      color: Color(0xff71df3c),
      onColor: Color(0xff113800),
      colorContainer: Color(0xff4bb70d),
      onColorContainer: Color(0xff144000),
    ),
  );
}
