import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halati/core/constants/app_constants.dart';
import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/l10n/app_locales.dart';
import 'package:halati/core/services/cash/cash_keys.dart';
import 'package:halati/core/services/cash/cash_service.dart';
import 'package:halati/core/utils/helpers/misc/url_helper.dart';
import 'package:halati/core/utils/helpers/settings_helper.dart';
import 'package:halati/features/home/data/datasources/saf_native_data_source.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find<SettingsController>();

  final CashService _cash = Get.find<CashService>();
  SafNativeDataSource? get _safDataSource =>
      Get.isRegistered<SafNativeDataSource>()
      ? Get.find<SafNativeDataSource>()
      : null;

  static const String themeId = 'theme';
  static const String aboutInfoId = 'aboutInfo';
  static const String whatsappSettingId = 'whatsappSetting';
  static const String storageSettingId = 'storageSetting';

  static const String defaultWhatsAppSavePath = 'Download/Halati/WhatsApp';
  static const String defaultBusinessSavePath =
      'Download/Halati/WhatsApp Business';

  late final Rx<WhatsAppType> activeWhatsAppType;

  final RxString saveFolderWhatsApp = defaultWhatsAppSavePath.obs;
  final RxString saveFolderBusiness = defaultBusinessSavePath.obs;
  final RxBool isCustomFolderWhatsApp = false.obs;
  final RxBool isCustomFolderBusiness = false.obs;
  final RxBool autoSaveOpenedStatuses = false.obs;

  String _appVersion = '';
  String get appVersion => _appVersion;

  String _buildNumber = '';
  String get buildNumber => _buildNumber;

  String get appVersionWithBuild => _appVersion.isNotEmpty
      ? '$_appVersion (${_buildNumber.isNotEmpty ? _buildNumber : "1"})'
      : '1.0.0 (1)';

  @override
  void onInit() {
    super.onInit();
    activeWhatsAppType = defaultWhatsAppType.obs;
    autoSaveOpenedStatuses.value = _cash.getBool(
      CashKeys.autoSaveOpenedStatuses,
    );
    _initStorageSettings();
    loadAppInfo();
  }

  void _initStorageSettings() {
    final waPath = _cash.getString(CashKeys.saveFolderCustomPath);
    final waUri = _cash.getString(CashKeys.saveFolderCustomUri);
    if (waUri != null &&
        waUri.isNotEmpty &&
        waPath != null &&
        waPath.isNotEmpty) {
      saveFolderWhatsApp.value = waPath;
      isCustomFolderWhatsApp.value = true;
      _validateFolderAccess(waUri, WhatsAppType.whatsapp);
    } else {
      saveFolderWhatsApp.value = defaultWhatsAppSavePath;
      isCustomFolderWhatsApp.value = false;
    }

    final bizPath = _cash.getString(CashKeys.saveFolderCustomPathBusiness);
    final bizUri = _cash.getString(CashKeys.saveFolderCustomUriBusiness);
    if (bizUri != null &&
        bizUri.isNotEmpty &&
        bizPath != null &&
        bizPath.isNotEmpty) {
      saveFolderBusiness.value = bizPath;
      isCustomFolderBusiness.value = true;
      _validateFolderAccess(bizUri, WhatsAppType.business);
    } else {
      saveFolderBusiness.value = defaultBusinessSavePath;
      isCustomFolderBusiness.value = false;
    }
  }

  Future<void> _validateFolderAccess(String uri, WhatsAppType type) async {
    try {
      final ds = _safDataSource;
      if (ds == null) return;
      final result = await ds.checkSaveFolderAccess(uri);
      final accessible = result['accessible'] == true;
      if (!accessible) {
        // If directory became inaccessible, revert to default gracefully
        await restoreDefaultSaveFolder(type, notify: false);
      }
    } catch (_) {}
  }

  String getSaveFolderPath(WhatsAppType type) {
    if (type.isBusiness) {
      return isCustomFolderBusiness.value
          ? saveFolderBusiness.value
          : defaultBusinessSavePath;
    }
    return isCustomFolderWhatsApp.value
        ? saveFolderWhatsApp.value
        : defaultWhatsAppSavePath;
  }

  bool isCustomFolder(WhatsAppType type) {
    return type.isBusiness
        ? isCustomFolderBusiness.value
        : isCustomFolderWhatsApp.value;
  }

  Future<bool> pickCustomSaveFolder(WhatsAppType type) async {
    try {
      final ds = _safDataSource;
      if (ds == null) return false;
      final result = await ds.requestCustomSaveFolder();
      if (result == null) return false;

      final uri = result['uri'] as String? ?? '';
      final displayPath = result['displayPath'] as String? ?? 'Custom Folder';
      if (uri.isEmpty) return false;

      if (type.isBusiness) {
        await _cash.setString(CashKeys.saveFolderCustomUriBusiness, uri);
        await _cash.setString(
          CashKeys.saveFolderCustomPathBusiness,
          displayPath,
        );
        saveFolderBusiness.value = displayPath;
        isCustomFolderBusiness.value = true;
      } else {
        await _cash.setString(CashKeys.saveFolderCustomUri, uri);
        await _cash.setString(CashKeys.saveFolderCustomPath, displayPath);
        saveFolderWhatsApp.value = displayPath;
        isCustomFolderWhatsApp.value = true;
      }
      update([storageSettingId]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> restoreDefaultSaveFolder(
    WhatsAppType type, {
    bool notify = true,
  }) async {
    try {
      final ds = _safDataSource;
      final uriKey = type.isBusiness
          ? CashKeys.saveFolderCustomUriBusiness
          : CashKeys.saveFolderCustomUri;
      final pathKey = type.isBusiness
          ? CashKeys.saveFolderCustomPathBusiness
          : CashKeys.saveFolderCustomPath;

      final storedUri = _cash.getString(uriKey);
      if (storedUri != null && storedUri.isNotEmpty && ds != null) {
        try {
          await ds.releaseDirectoryAccess(storedUri);
        } catch (_) {}
      }

      await _cash.remove(uriKey);
      await _cash.remove(pathKey);

      if (type.isBusiness) {
        saveFolderBusiness.value = defaultBusinessSavePath;
        isCustomFolderBusiness.value = false;
      } else {
        saveFolderWhatsApp.value = defaultWhatsAppSavePath;
        isCustomFolderWhatsApp.value = false;
      }

      if (notify) {
        update([storageSettingId]);
      }
    } catch (_) {}
  }

  Future<void> setAutoSaveOpenedStatuses(bool enabled) async {
    autoSaveOpenedStatuses.value = enabled;
    await _cash.setBool(CashKeys.autoSaveOpenedStatuses, enabled);
    update([storageSettingId]);
  }

  WhatsAppType get defaultWhatsAppType {
    final String? stored = _cash.getString(CashKeys.defaultWhatsAppType);
    if (stored == WhatsAppType.business.name) {
      return WhatsAppType.business;
    }
    return WhatsAppType.whatsapp;
  }

  Future<void> setDefaultWhatsAppType(WhatsAppType type) async {
    await _cash.setString(CashKeys.defaultWhatsAppType, type.name);
    activeWhatsAppType.value = type;
    update([whatsappSettingId]);
  }

  void setActiveWhatsAppType(WhatsAppType type) {
    if (activeWhatsAppType.value != type) {
      activeWhatsAppType.value = type;
    }
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
