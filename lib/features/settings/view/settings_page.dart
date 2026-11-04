import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/core/l10n/app_locales.dart';
import 'package:status_saver/core/routes/app_routes.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/helpers/settings_helper.dart';
import 'package:status_saver/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:status_saver/features/home/presentation/controllers/home_controller.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/cards/my_section_card.dart';
import 'package:status_saver/shared/widgets/lists/selectable_list.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';
import 'package:status_saver/shared/widgets/sheets/my_bottom_sheet.dart';
import 'package:status_saver/shared/widgets/slivers/sliver_filter_delegate.dart';
import 'package:status_saver/shared/widgets/tiles/my_list_tile.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        slivers: [
          SliverPersistentHeader(
            floating: true,
            delegate: SliverFilterDelegate(
              height: MediaQuery.paddingOf(context).top + context.setSize(64),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spaceM,
                    vertical: context.spaceS,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.l10n.settings,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: context.spaceM,
              right: context.spaceM,
              top: context.spaceS,
              bottom:
                  context.setSize(95) + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
                            context.colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.zero,
                          title: context.l10n.theme,
                          subtitle: SettingsHelper.getThemeName(
                            context,
                            SettingsHelper.currentTheme,
                          ),
                          trailingIcon: AppIcons.arrowForward(context),
                          onTap: () =>
                              _showThemeBottomSheet(context, controller),
                        );
                      },
                    ),
                    GetBuilder<SettingsController>(
                      builder: (controller) {
                        return MyListTile(
                          leading: _buildIconContainer(
                            context,
                            AppIcons.translate,
                            context.colorScheme.tertiary,
                          ),
                          borderRadius: BorderRadius.zero,
                          title: context.l10n.language,
                          subtitle: controller.selectLang.localizedName(
                            context,
                          ),
                          trailingIcon: AppIcons.arrowForward(context),
                          onTap: () =>
                              _showLanguageBottomSheet(context, controller),
                        );
                      },
                    ),
                    GetBuilder<SettingsController>(
                      id: SettingsController.whatsappSettingId,
                      builder: (controller) {
                        final defaultType = controller.defaultWhatsAppType;
                        return MyListTile(
                          leading: _buildIconContainer(
                            context,
                            defaultType.isBusiness
                                ? AppIcons.store
                                : AppIcons.message,
                            context.colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.zero,
                          title: context.l10n.defaultWhatsApp,
                          subtitle: defaultType.isBusiness
                              ? context.l10n.whatsappBusiness
                              : context.l10n.whatsapp,
                          trailingIcon: AppIcons.arrowForward(context),
                          onTap: () => _showDefaultWhatsAppBottomSheet(
                            context,
                            controller,
                          ),
                        );
                      },
                    ),
                    if (Get.isRegistered<HomeController>())
                      MyListTile(
                        leading: _buildIconContainer(
                          context,
                          AppIcons.folder,
                          context.colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.zero,
                        title: context.l10n.selectFolder,
                        subtitle:
                            Get.find<HomeController>()
                                .currentWhatsAppType
                                .isBusiness
                            ? context.l10n.safPermissionTitleBusiness
                            : context.l10n.safPermissionTitle,
                        trailingIcon: AppIcons.arrowForward(context),
                        onTap: () =>
                            Get.find<HomeController>().requestPermission(),
                      ),
                  ],
                ),
                context.verticalSpace(12),
                MyListTile(
                  leading: _buildIconContainer(
                    context,
                    AppIcons.info,
                    context.colorScheme.primary,
                  ),
                  tileColor: context.colorScheme.surfaceContainer,
                  title: context.l10n.aboutStatusSaver,
                  trailingIcon: AppIcons.arrowForward(context),
                  onTap: () => Get.toNamed(AppRoutes.about),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon, Color color) {
    return MyCard.filled(
      padding: EdgeInsets.all(context.spaceS),
      color: color.withValues(alpha: 0.12),
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
          items: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
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
          items: const [LangCode.system, LangCode.en, LangCode.ar],
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

  void _showDefaultWhatsAppBottomSheet(
    BuildContext context,
    SettingsController controller,
  ) {
    BottomSheetHelper.show(
      child: MyBottomSheet(
        title: context.l10n.selectDefaultWhatsApp,
        padding: EdgeInsets.zero,
        child: SelectableList<WhatsAppType>.single(
          items: const [WhatsAppType.whatsapp, WhatsAppType.business],
          initialSelected: controller.defaultWhatsAppType,
          itemLabel: (type) => type.isBusiness
              ? context.l10n.whatsappBusiness
              : context.l10n.whatsapp,
          onChanged: (value) {
            controller.setDefaultWhatsAppType(value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
