import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:status_saver/core/constants/app_assets.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/routes/app_routes.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:status_saver/core/utils/helpers/ui/toast_helper.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';
import 'package:status_saver/shared/widgets/appbars/my_app_bar.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/cards/my_section_card.dart';
import 'package:status_saver/shared/widgets/images/my_image.dart';
import 'package:status_saver/shared/widgets/input/my_text_field.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';
import 'package:status_saver/shared/widgets/misc/my_toast.dart';
import 'package:status_saver/shared/widgets/sheets/my_bottom_sheet.dart';
import 'package:status_saver/shared/widgets/tiles/my_list_tile.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: MyAppBar(title: context.l10n.aboutHalati),
      body: ListView(
        padding: context.insetsAllM,
        children: [
          _buildHeader(context),
          context.verticalSpace(16),
          MySectionCard(
            title: '',
            children: [
              MyListTile(
                leading: _buildIconContainer(
                  context,
                  AppIcons.file,
                  context.colorScheme.primary,
                ),
                borderRadius: BorderRadius.zero,
                title: context.l10n.privacyPolicy,
                trailingIcon: AppIcons.arrowForward(context),
                onTap: () async {
                  final success = await controller.openPrivacyPolicy();
                  if (!success && context.mounted) {
                    ToastHelper.show(msg: context.l10n.couldNotOpenLink);
                  }
                },
              ),
              MyListTile(
                leading: _buildIconContainer(
                  context,
                  AppIcons.message,
                  context.colorScheme.secondary,
                ),
                borderRadius: BorderRadius.zero,
                title: context.l10n.contactAndFeedback,
                trailingIcon: AppIcons.arrowForward(context),
                onTap: () {
                  BottomSheetHelper.show(
                    child: _FeedbackBottomSheet(controller: controller),
                  );
                },
              ),
              MyListTile(
                leading: _buildIconContainer(
                  context,
                  AppIcons.receipt,
                  context.colorScheme.tertiary,
                ),
                borderRadius: BorderRadius.zero,
                title: context.l10n.openSourceLicenses,
                trailingIcon: AppIcons.arrowForward(context),
                onTap: () => Get.toNamed(AppRoutes.licenses),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        context.verticalSpace(16),
        MyImage.asset(
          asset: AppAssets.appIcon,
          width: context.setSize(80),
          height: context.setSize(80),
          borderRadius: BorderRadius.circular(context.radiusL),
        ),
        context.verticalSpace(12),
        Text(
          context.l10n.appName,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        context.verticalSpace(4),
        GetBuilder<SettingsController>(
          id: SettingsController.aboutInfoId,
          builder: (ctrl) {
            final version = ctrl.appVersion;
            final build = ctrl.buildNumber;
            if (version.isEmpty) {
              return const SizedBox.shrink();
            }
            return Text(
              context.l10n.appVersion(version, build),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        context.verticalSpace(8),
      ],
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon, Color color) {
    return MyCard.filled(
      padding: EdgeInsets.all(context.spaceS),
      color: color.withValues(alpha: 0.15),
      child: MyIcon(icon: icon, color: color),
    );
  }
}

class _FeedbackBottomSheet extends StatefulWidget {
  final SettingsController controller;

  const _FeedbackBottomSheet({required this.controller});

  @override
  State<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<_FeedbackBottomSheet> {
  late final TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyBottomSheet(
      title: context.l10n.contactAndFeedback,
      statusIcon: AppIcons.message,
      buttonsCanPopAutomatically: false,
      primaryButton: SheetButton(
        text: context.l10n.sendEmail,
        onPressed: () async {
          final feedbackText = _feedbackController.text.trim();
          final success = await widget.controller.sendFeedbackEmail(
            subject:
                '${context.l10n.appName} - ${context.l10n.contactAndFeedback}',
            body: feedbackText.isNotEmpty ? feedbackText : null,
          );

          if (!success && context.mounted) {
            ToastHelper.show(
              msg: context.l10n.couldNotOpenEmail,
              status: ToastStatus.danger,
            );
          }
        },
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.contactFeedbackNotice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          context.verticalSpace(24),
          MyTextField(
            controller: _feedbackController,
            maxLines: 4,
            autofocus: true,
            labelText: context.l10n.feedbackMessage,
            hintText: context.l10n.feedbackHint,
          ),
        ],
      ),
    );
  }
}
