import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:status_saver/core/constants/app_constants.dart';
import 'package:status_saver/core/l10n/app_locales.dart';
import 'package:status_saver/core/services/cash/cash_keys.dart';
import 'package:status_saver/core/services/cash/cash_service.dart';
import 'package:status_saver/core/utils/helpers/misc/url_helper.dart';
import 'package:status_saver/core/utils/helpers/settings_helper.dart';

class SettingsController extends GetxController {
  final CashService _cash = Get.find<CashService>();

  static const String themeId = 'theme';
  static const String aboutInfoId = 'aboutInfo';

  String _appVersion = '';
  String get appVersion => _appVersion;

  String _buildNumber = '';
  String get buildNumber => _buildNumber;

  @override
  void onInit() {
    super.onInit();
    loadAppInfo();
  }

  Future<void> loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
      update([aboutInfoId]);
    } catch (_) {}
  }

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

  Future<bool> openPrivacyPolicy() async {
    return await UrlHelper.openUrl(AppConstants.privacyPolicyUrl);
  }

  Future<bool> sendFeedbackEmail({String? subject, String? body}) async {
    return await UrlHelper.sendEmail(
      email: AppConstants.feedbackEmail,
      subject: subject,
      body: body,
    );
  }
}
