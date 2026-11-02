import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/constants/app_icons.dart';
import 'package:flutter_app_template/core/l10n/app_locales.dart';
import 'package:flutter_app_template/core/utils/extensions/context_extension.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_values.dart';
import 'package:flutter_app_template/core/utils/helpers/settings_helper.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:flutter_app_template/features/settings/controller/settings_controller.dart';
import 'package:flutter_app_template/shared/widgets/appbars/my_app_bar.dart';
import 'package:flutter_app_template/shared/widgets/cards/my_card.dart';
import 'package:flutter_app_template/shared/widgets/cards/my_section_card.dart';
import 'package:flutter_app_template/shared/widgets/lists/selectable_list.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_icon.dart';
import 'package:flutter_app_template/shared/widgets/sheets/my_bottom_sheet.dart';
import 'package:flutter_app_template/shared/widgets/tiles/my_list_tile.dart';
import 'package:get/get.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: MyAppBar(title: context.l10n.settings),
      body: ListView(
        padding: context.insetsAllM,
        children: [
          MySectionCard(
            title: context.l10n.generalSettings,
            children: [
              GetBuilder<SettingsController>(
                id: SettingsController.themeId,
                builder: (controller) {
                  return MyListTile(
                    leading: _buildIconContainer(
                      context,
                      AppIcons.brightness,
                      Colors.orangeAccent,
                    ),
                    borderRadius: BorderRadius.zero,
                    title: context.l10n.theme,
                    subtitle: SettingsHelper.getThemeName(
                      context,
                      SettingsHelper.currentTheme,
                    ),
                    trailingIcon: AppIcons.arrowForward(context),
                    onTap: () => _showThemeBottomSheet(context, controller),
                  );
                },
              ),
              GetBuilder<SettingsController>(
                builder: (controller) {
                  return MyListTile(
                    leading: _buildIconContainer(
                      context,
                      AppIcons.translate,
                      Colors.blueAccent,
                    ),
                    borderRadius: BorderRadius.zero,
                    title: context.l10n.language,
                    subtitle: controller.selectLang.localizedName(context),
                    trailingIcon: AppIcons.arrowForward(context),
                    onTap: () => _showLanguageBottomSheet(context, controller),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon, Color color) {
    return MyCard.filled(
      padding: EdgeInsets.all(context.spaceS),
      color: color.withValues(alpha: 0.15),
      child: MyIcon(icon: icon, color: color),
    );
  }

  void _showThemeBottomSheet(
    BuildContext context,
    SettingsController controller,
  ) {
    BottomSheetHelper.show(
      child: MyBottomSheet(
        padding: EdgeInsets.zero,
        title: context.l10n.selectTheme,
        child: SelectableList<ThemeMode>.single(
          items: [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
          initialSelected: SettingsHelper.currentTheme,
          itemLabel: (label) => SettingsHelper.getThemeName(context, label),
          onChanged: (value) {
            controller.changeTheme(value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    SettingsController controller,
  ) {
    BottomSheetHelper.show(
      child: MyBottomSheet(
        title: context.l10n.selectLanguage,
        padding: EdgeInsets.zero,
        child: SelectableList<LangCode>.single(
          items: [LangCode.system, LangCode.en, LangCode.ar],
          initialSelected: controller.selectLang,
          itemLabel: (label) => label.localizedName(context),
          onChanged: (value) {
            controller.changeLocale(value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
