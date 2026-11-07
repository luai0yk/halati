import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/features/app_shell/controller/app_shell_controller.dart';
import 'package:halati/features/home/presentation/pages/home_page.dart';
import 'package:halati/features/saved/presentation/pages/saved_page.dart';
import 'package:halati/features/settings/view/settings_page.dart';
import 'package:halati/shared/widgets/misc/my_bottom_navigation_bar.dart';

class AppShellPage extends GetView<AppShellController> {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      _KeepAliveTab(child: HomePage()),
      _KeepAliveTab(child: SavedPage()),
      _KeepAliveTab(child: SettingsPage()),
    ];

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: Obx(() {
        final currentIndex = controller.currentIndex.value;

        return MyBottomNavigationBar(
          margin: context.insetsAllL,
          itemAnimation: .bounce,
          currentIndex: currentIndex,
          borderRadius: context.brCircular,
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
        );
      }),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  final Widget child;

  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
