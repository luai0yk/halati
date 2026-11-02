import 'package:flutter_app_template/features/app_shell/view/app_shell_page.dart';
import 'package:flutter_app_template/features/settings/view/settings_page.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.appShell, page: () => AppShellPage()),
    GetPage(name: AppRoutes.settings, page: () => SettingsPage()),
  ];
}
