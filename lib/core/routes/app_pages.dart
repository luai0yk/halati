import 'package:get/get.dart';
import 'package:status_saver/core/routes/app_routes.dart';
import 'package:status_saver/features/app_shell/bindings/app_shell_binding.dart';
import 'package:status_saver/features/app_shell/view/app_shell_page.dart';
import 'package:status_saver/features/settings/view/settings_page.dart';

class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.appShell,
      page: () => const AppShellPage(),
      binding: AppShellBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
    ),
  ];
}
