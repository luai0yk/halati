import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/l10n/app_locales.dart';
import 'package:flutter_app_template/core/services/cash/cash_keys.dart';
import 'package:flutter_app_template/core/services/cash/cash_service.dart';
import 'package:flutter_app_template/core/utils/helpers/settings_helper.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final CashService _cash = Get.find<CashService>();

  static const String themeId = 'theme';

  Future<void> changeTheme(ThemeMode theme) async {
    await _cash.setString(CashKeys.themeMode, theme.name);
    update([themeId]);
    Get.changeThemeMode(theme);
  }

  Future<void> changeLocale(LangCode langCode) async {
    if (langCode == LangCode.system) {
      await _cash.remove(CashKeys.languageCode);
      Get.updateLocale(SettingsHelper.currentLocale);
      update();
      return;
    }

    await _cash.setString(CashKeys.languageCode, langCode.name);
    Get.updateLocale(Locale(langCode.name));
    update();
  }

  LangCode get selectLang {
    final String? storedLang = _cash.getString(CashKeys.languageCode);
    return LangCode.values.byName(storedLang ?? LangCode.system.name);
  }
}
