import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/l10n/app_locales.dart';
import 'package:halati/core/routes/app_routes.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/core/utils/helpers/settings_helper.dart';
import 'package:halati/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:halati/core/utils/helpers/ui/toast_helper.dart';
import 'package:halati/features/settings/controller/settings_controller.dart';
import 'package:halati/shared/widgets/cards/my_card.dart';
import 'package:halati/shared/widgets/cards/my_section_card.dart';
import 'package:halati/shared/widgets/input/my_switch.dart';
import 'package:halati/shared/widgets/lists/selectable_list.dart';
import 'package:halati/shared/widgets/sheets/my_bottom_sheet.dart';
import 'package:halati/shared/widgets/slivers/sliver_filter_delegate.dart';
import 'package:halati/shared/widgets/tiles/my_list_tile.dart';

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
                _buildPreferencesSection(context),
                context.verticalSpace(20),
                _buildStorageSection(context),
                context.verticalSpace(20),
                _buildAboutSection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sections ---
  Widget _buildPreferencesSection(BuildContext context) {
    return MySectionCard(
      title: context.l10n.preferences,
      showDividers: false,
      children: [
        GetBuilder<SettingsController>(
          id: SettingsController.themeId,
          builder: (ctrl) {
            return _buildTile(
              context,
              leadingIcon: AppIcons.brightness,
              title: context.l10n.theme,
              trailing: _buildValueTrailing(
                context,
                SettingsHelper.getThemeName(
                  context,
                  SettingsHelper.currentTheme,
                ),
              ),
              onTap: () {
                _showSelectionBottomSheet<ThemeMode>(
                  context: context,
                  title: context.l10n.selectTheme,
                  items: const [
                    ThemeMode.system,
                    ThemeMode.light,
                    ThemeMode.dark,
                  ],
                  initialSelected: SettingsHelper.currentTheme,
                  itemLabel: (label) =>
                      SettingsHelper.getThemeName(context, label),
                  onSelected: controller.changeTheme,
                );
              },
            );
          },
        ),
        GetBuilder<SettingsController>(
          builder: (ctrl) {
            return _buildTile(
              context,
              leadingIcon: AppIcons.translate,
              title: context.l10n.language,
              trailing: _buildValueTrailing(
                context,
                ctrl.selectLang.localizedName(context),
              ),
              onTap: () {
                _showSelectionBottomSheet<LangCode>(
                  context: context,
                  title: context.l10n.selectLanguage,
                  items: const [LangCode.system, LangCode.en, LangCode.ar],
                  initialSelected: controller.selectLang,
                  itemLabel: (label) => label.localizedName(context),
                  onSelected: controller.changeLocale,
                );
              },
            );
          },
        ),
        GetBuilder<SettingsController>(
          id: SettingsController.whatsappSettingId,
          builder: (ctrl) {
            final defaultType = ctrl.defaultWhatsAppType;
            return _buildTile(
              context,
              leadingIcon: AppIcons.whatsapp,
              title: context.l10n.defaultWhatsApp,
              trailing: _buildValueTrailing(
                context,
                defaultType.isBusiness
                    ? context.l10n.whatsappBusiness
                    : context.l10n.whatsapp,
              ),
              onTap: () {
                _showSelectionBottomSheet<WhatsAppType>(
                  context: context,
                  title: context.l10n.selectDefaultWhatsApp,
                  items: const [WhatsAppType.whatsapp, WhatsAppType.business],
                  initialSelected: controller.defaultWhatsAppType,
                  itemLabel: (type) => type.isBusiness
                      ? context.l10n.whatsappBusiness
                      : context.l10n.whatsapp,
                  onSelected: controller.setDefaultWhatsAppType,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    return GetBuilder<SettingsController>(
      id: SettingsController.storageSettingId,
      builder: (ctrl) {
        return MySectionCard(
          title: context.l10n.storageAndDownloads,
          children: [
            _buildFolderTile(context, ctrl, WhatsAppType.whatsapp),
            _buildFolderTile(context, ctrl, WhatsAppType.business),
            _buildAutoSaveTile(context, ctrl),
          ],
        );
      },
    );
  }

  Widget _buildFolderTile(
    BuildContext context,
    SettingsController ctrl,
    WhatsAppType type,
  ) {
    return Obx(() {
      final title = type.isBusiness
          ? context.l10n.whatsappBusinessSaveFolder
          : context.l10n.whatsappSaveFolder;
      final path = ctrl.getSaveFolderPath(type);

      return _buildTile(
        context,
        leadingIcon: AppIcons.folder,
        title: title,
        subtitle: path,
        subtitleDirection: TextDirection.ltr,
        showArrow: true,
        onTap: () => _showFolderManagementBottomSheet(context, ctrl, type),
      );
    });
  }

  Widget _buildAutoSaveTile(BuildContext context, SettingsController ctrl) {
    return Obx(() {
      final isAuto = ctrl.autoSaveOpenedStatuses.value;
      return _buildTile(
        context,
        leadingIcon: AppIcons.download,
        title: context.l10n.autoSaveOpenedStatuses,
        trailing: MySwitch(
          value: isAuto,
          onChanged: ctrl.setAutoSaveOpenedStatuses,
        ),
        onTap: () => ctrl.setAutoSaveOpenedStatuses(!isAuto),
      );
    });
  }

  Widget _buildAboutSection(BuildContext context) {
    return MySectionCard(
      title: context.l10n.about,
      children: [
        _buildTile(
          context,
          leadingIcon: AppIcons.info,
          title: context.l10n.aboutHalati,
          showArrow: true,
          onTap: () => Get.toNamed(AppRoutes.about),
        ),
      ],
    );
  }

  // Reusable UI Helpers
  Widget _buildTile(
    BuildContext context, {
    required String title,
    IconData? leadingIcon,
    String? subtitle,
    TextDirection? subtitleDirection,
    Widget? trailing,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return MyListTile(
      leadingIcon: leadingIcon,
      title: title,
      subtitle: subtitle,
      subtitleDirection: subtitleDirection,
      trailing: trailing,
      trailingIcon: showArrow ? AppIcons.arrowForward(context) : null,
      subtitleColor: context.colorScheme.primary,
      borderRadius: BorderRadius.zero,
      onTap: onTap,
    );
  }

  Widget _buildValueTrailing(BuildContext context, String value) {
    return Text(
      value,
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.primary,
      ),
    );
  }

  // Selection Bottom Sheets
  void _showSelectionBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required T initialSelected,
    required String Function(T) itemLabel,
    required ValueChanged<T> onSelected,
  }) {
    BottomSheetHelper.show(
      child: MyBottomSheet(
        title: title,
        padding: EdgeInsets.zero,
        child: SelectableList<T>.single(
          items: items,
          initialSelected: initialSelected,
          itemLabel: itemLabel,
          onChanged: (value) {
            onSelected(value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // Folder Management
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
            _buildPathInfoCard(
              context,
              currentPath: currentPath,
              isCustom: isCustom,
            ),
            Divider(
              height: 1,
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            _buildTile(
              context,
              title: context.l10n.changeFolder,
              leadingIcon: AppIcons.folder,
              showArrow: true,
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
              _buildTile(
                context,
                title: context.l10n.restoreDefaultFolder,
                leadingIcon: AppIcons.undo,
                showArrow: false,
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

  Widget _buildPathInfoCard(
    BuildContext context, {
    required String currentPath,
    required bool isCustom,
  }) {
    return MyCard.filled(
      margin: context.insetsAllM,
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
              MyCard.filled(
                padding: EdgeInsets.symmetric(
                  horizontal: context.setSize(8),
                  vertical: context.setSize(2),
                ),
                color: isCustom
                    ? context.colorScheme.primaryContainer
                    : context.colorScheme.surfaceContainerHighest,
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
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
