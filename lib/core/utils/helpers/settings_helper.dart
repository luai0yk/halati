import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/services/cash/cash_keys.dart';
import 'package:flutter_app_template/core/services/cash/cash_service.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:get/get.dart';

class SettingsHelper {
  SettingsHelper._();

  static final CashService _cash = Get.find<CashService>();

  static ThemeMode get currentTheme {
    final String? storedTheme = _cash.getString(CashKeys.themeMode);
    return ThemeMode.values.byName(storedTheme ?? ThemeMode.system.name);
  }

  static String getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return context.l10n.system;
      case ThemeMode.light:
        return context.l10n.light;
      case ThemeMode.dark:
        return context.l10n.dark;
    }
  }

  static Locale get currentLocale {
    final String? storedLang = _cash.getString(CashKeys.languageCode);

    return Locale(
      storedLang ?? PlatformDispatcher.instance.locale.languageCode,
    );
  }

  static String get currentLangCode => currentLocale.languageCode;

  static bool get isArabic => currentLangCode == 'ar';
}
