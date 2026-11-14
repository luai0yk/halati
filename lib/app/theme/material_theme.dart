import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:halati/core/constants/app_constants.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'dark_theme.dart';
import 'extended_colors.dart';
import 'light_theme.dart';

class MaterialTheme {
  final TextTheme? textTheme;

  const MaterialTheme([this.textTheme]);

  ThemeData light() {
    return _theme(
      colorScheme: lightColorScheme,
      extendedColors: ExtendedColors.light,
    );
  }

  ThemeData dark() {
    return _theme(
      colorScheme: darkColorScheme,
      extendedColors: ExtendedColors.dark,
    );
  }

  ThemeData _theme({
    required ColorScheme colorScheme,
    required ExtendedColors extendedColors,
  }) {
    final base = textTheme ?? _baseTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      fontFamily: AppConstants.fontFamily,

      textTheme: base.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
        fontFamily: AppConstants.fontFamily,
      ),

      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,

      extensions: [
        extendedColors,
        SkeletonizerConfigData(
          containersColor: colorScheme.surfaceContainerLow,
          effect: ShimmerEffect(
            baseColor: colorScheme.outline.withValues(alpha: 0.1),
            highlightColor: colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
      ],

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),

      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: colorScheme.surface,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: colorScheme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          statusBarBrightness: colorScheme.brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
    );
  }

  TextTheme _baseTextTheme(ColorScheme colorScheme) {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    );
  }

  static TextTheme responsiveTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: context.setSize(32),
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontSize: context.setSize(28),
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        fontSize: context.setSize(24),
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        fontSize: context.setSize(22),
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontSize: context.setSize(20),
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: context.setSize(18),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: context.setSize(18),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: context.setSize(16),
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontSize: context.setSize(14),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: context.setSize(16),
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontSize: context.setSize(14),
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontSize: context.setSize(12),
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontSize: context.setSize(14),
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: context.setSize(12),
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: context.setSize(10),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
