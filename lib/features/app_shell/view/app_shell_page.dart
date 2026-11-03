import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/features/app_shell/controller/app_shell_controller.dart';
import 'package:status_saver/features/home/presentation/pages/home_page.dart';
import 'package:status_saver/features/saved/presentation/pages/saved_page.dart';
import 'package:status_saver/features/settings/view/settings_page.dart';
import 'package:status_saver/shared/widgets/misc/my_bottom_navigation_bar.dart';

class AppShellPage extends GetView<AppShellController> {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [HomePage(), SavedPage(), SettingsPage()];

    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      // Get.find<CashService>().remove(CashKeys.safTreeUri);

      return Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: currentIndex,
          clipBehavior: Clip.none,
          children: pages,
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          margin: context.insetsAllL,
          itemAnimation: .bounce,
          currentIndex: currentIndex,
          borderRadius: context.brCircular,
          // backgroundColor: context.colorScheme.surface.withValues(alpha: 0.90),
          itemBorderRadius: context.brCircular,
          expandItems: true,
          elevation: 5,
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: context.setSize(0.5),
          ),
          onItemSelected: controller.changeTab,
          items: [
            MyBottomNavigationBarItem(
              title: context.l10n.statuses,
              icon: const Icon(AppIcons.status),
              selectedIcon: const Icon(AppIcons.statusFilled),
            ),
            MyBottomNavigationBarItem(
              title: context.l10n.saved,
              icon: const Icon(AppIcons.download),
              selectedIcon: const Icon(AppIcons.downloadFilled),
            ),
            MyBottomNavigationBarItem(
              title: context.l10n.settings,
              icon: const Icon(AppIcons.settings),
              selectedIcon: const Icon(AppIcons.settingsFilled),
            ),
          ],
        ),
      );
    });
  }
}
