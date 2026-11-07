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
import 'package:status_saver/core/utils/helpers/ui/toast_helper.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/cards/my_section_card.dart';
import 'package:status_saver/shared/widgets/input/my_switch.dart';
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
                // 1. General Section
                MySectionCard(
                  title: context.l10n.general,
                  children: [
                    GetBuilder<SettingsController>(
                      id: SettingsController.themeId,
                      builder: (ctrl) {
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
                          onTap: () => _showThemeBottomSheet(context, ctrl),
                        );
                      },
                    ),
                    GetBuilder<SettingsController>(
                      builder: (ctrl) {
                        return MyListTile(
                          leading: _buildIconContainer(
                            context,
                            AppIcons.translate,
                            context.colorScheme.secondary,
                          ),
                          borderRadius: BorderRadius.zero,
                          title: context.l10n.language,
                          subtitle: ctrl.selectLang.localizedName(context),
                          trailingIcon: AppIcons.arrowForward(context),
                          onTap: () => _showLanguageBottomSheet(context, ctrl),
                        );
                      },
                    ),
                    GetBuilder<SettingsController>(
                      id: SettingsController.whatsappSettingId,
                      builder: (ctrl) {
                        final defaultType = ctrl.defaultWhatsAppType;
                        return MyListTile(
                          leading: _buildIconContainer(
                            context,
                            AppIcons.whatsapp,
                            context.colorScheme.tertiary,
                          ),
                          borderRadius: BorderRadius.zero,
                          title: context.l10n.defaultWhatsApp,
                          subtitle: defaultType.isBusiness
                              ? context.l10n.whatsappBusiness
                              : context.l10n.whatsapp,
                          trailingIcon: AppIcons.arrowForward(context),
                          onTap: () =>
                              _showDefaultWhatsAppBottomSheet(context, ctrl),
                        );
                      },
                    ),
                  ],
                ),
                context.verticalSpace(20),

                // 2. Storage & Downloads Section
                GetBuilder<SettingsController>(
                  id: SettingsController.storageSettingId,
                  builder: (ctrl) {
                    return MySectionCard(
                      title: context.l10n.storageAndDownloads,
                      children: [
                        Obx(() {
                          final path = ctrl.getSaveFolderPath(
                            WhatsAppType.whatsapp,
                          );
                          return MyListTile(
                            leading: _buildIconContainer(
                              context,
                              AppIcons.folder,
                              context.colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.zero,
                            title: context.l10n.whatsappSaveFolder,
                            subtitle: path,
                            subtitleDirection: TextDirection.ltr,
                            trailingIcon: AppIcons.arrowForward(context),
                            onTap: () => _showFolderManagementBottomSheet(
                              context,
                              ctrl,
                              WhatsAppType.whatsapp,
                            ),
                          );
                        }),
                        Obx(() {
                          final path = ctrl.getSaveFolderPath(
                            WhatsAppType.business,
                          );
                          return MyListTile(
                            leading: _buildIconContainer(
                              context,
                              AppIcons.folder,
                              context.colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.zero,
                            title: context.l10n.whatsappBusinessSaveFolder,
                            subtitle: path,
                            subtitleDirection: TextDirection.ltr,
                            trailingIcon: AppIcons.arrowForward(context),
                            onTap: () => _showFolderManagementBottomSheet(
                              context,
                              ctrl,
                              WhatsAppType.business,
                            ),
                          );
                        }),
                        Obx(() {
                          final isAuto = ctrl.autoSaveOpenedStatuses.value;
                          return MyListTile(
                            leading: _buildIconContainer(
                              context,
                              AppIcons.download,
                              context.colorScheme.secondary,
                            ),
                            borderRadius: BorderRadius.zero,
                            title: context.l10n.autoSaveOpenedStatuses,
                            subtitle:
                                context.l10n.autoSaveOpenedStatusesDescription,
                            trailing: MySwitch(
                              value: isAuto,
                              onChanged: (val) =>
                                  ctrl.setAutoSaveOpenedStatuses(val),
                            ),
                            onTap: () =>
                                ctrl.setAutoSaveOpenedStatuses(!isAuto),
                          );
                        }),
                      ],
                    );
                  },
                ),
                context.verticalSpace(20),

                // 3. About Section
                MySectionCard(
                  title: context.l10n.about,
                  children: [
                    GetBuilder<SettingsController>(
                      id: SettingsController.aboutInfoId,
                      builder: (ctrl) {
                        return MyListTile(
                          leading: _buildIconContainer(
                            context,
                            AppIcons.info,
                            context.colorScheme.tertiary,
                          ),
                          borderRadius: BorderRadius.zero,
                          title: context.l10n.appVersionTitle,
                          subtitle: ctrl.appVersionWithBuild,
                        );
                      },
                    ),
                    MyListTile(
                      leading: _buildIconContainer(
                        context,
                        AppIcons.status,
                        context.colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.zero,
                      title: context.l10n.aboutHalati,
                      subtitle: context.l10n.aboutHalatiSubtitle,
                      trailingIcon: AppIcons.arrowForward(context),
                      onTap: () => Get.toNamed(AppRoutes.about),
                    ),
                  ],
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

  void _showFolderManagementBottomSheet(
    BuildContext context,
    SettingsController ctrl,
    WhatsAppType type,
  ) {
    final title = type.isBusiness
        ? context.l10n.whatsappBusinessSaveFolder
        : context.l10n.whatsappSaveFolder;
    final isCustom = ctrl.isCustomFolder(type);
    final currentPath = ctrl.getSaveFolderPath(type);

    BottomSheetHelper.show(
      child: MyBottomSheet(
        title: title,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: context.insetsAllM,
              child: MyCard.filled(
                padding: context.insetsAllM,
                color: context.colorScheme.surfaceContainerHigh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.currentPath,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.setSize(8),
                            vertical: context.setSize(2),
                          ),
                          decoration: BoxDecoration(
                            color: isCustom
                                ? context.colorScheme.primaryContainer
                                : context.colorScheme.surfaceContainerHighest,
                            borderRadius: context.brCircular,
                          ),
                          child: Text(
                            isCustom
                                ? context.l10n.customLocation
                                : context.l10n.defaultLocation,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: isCustom
                                  ? context.colorScheme.onPrimaryContainer
                                  : context.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spaceS),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        currentPath,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            MyListTile(
              leading: _buildIconContainer(
                context,
                AppIcons.folder,
                context.colorScheme.primary,
              ),
              title: context.l10n.changeFolder,
              trailingIcon: AppIcons.arrowForward(context),
              onTap: () async {
                final updatedMsg = context.l10n.folderUpdatedSuccessfully;
                Navigator.pop(context);
                final success = await ctrl.pickCustomSaveFolder(type);
                if (success) {
                  ToastHelper.show(msg: updatedMsg);
                }
              },
            ),
            if (isCustom)
              MyListTile(
                leading: _buildIconContainer(
                  context,
                  AppIcons.refresh,
                  context.colorScheme.secondary,
                ),
                title: context.l10n.restoreDefaultFolder,
                trailingIcon: AppIcons.arrowForward(context),
                onTap: () async {
                  final restoredMsg = context.l10n.folderRestoredSuccessfully;
                  Navigator.pop(context);
                  await ctrl.restoreDefaultSaveFolder(type);
                  ToastHelper.show(msg: restoredMsg);
                },
              ),
            SizedBox(height: context.spaceM),
          ],
        ),
      ),
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
