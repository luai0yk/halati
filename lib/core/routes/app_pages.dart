import 'package:get/get.dart';
import 'package:halati/core/routes/app_routes.dart';
import 'package:halati/features/app_shell/bindings/app_shell_binding.dart';
import 'package:halati/features/app_shell/view/app_shell_page.dart';
import 'package:halati/features/settings/controller/licenses_controller.dart';
import 'package:halati/features/settings/view/about_page.dart';
import 'package:halati/features/settings/view/licenses_page.dart';
import 'package:halati/features/settings/view/settings_page.dart';

class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.appShell,
      page: () => const AppShellPage(),
      binding: AppShellBinding(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),
    GetPage(name: AppRoutes.about, page: () => const AboutPage()),
    GetPage(
      name: AppRoutes.licenses,
      page: () => const LicensesPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LicensesController>(() => LicensesController());
      }),
    ),
  ];
}
