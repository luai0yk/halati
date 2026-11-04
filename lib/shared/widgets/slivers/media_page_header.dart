import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';
import 'package:status_saver/shared/widgets/buttons/whatsapp_type_switch.dart';
import 'package:status_saver/shared/widgets/chips/media_filter_bar.dart';

class MediaPageHeader extends StatelessWidget {
  final String title;
  final MediaType? selectedType;
  final ValueChanged<MediaType?> onFilterChanged;
  final WhatsAppType? currentWhatsAppType;
  final ValueChanged<WhatsAppType>? onWhatsAppTypeChanged;

  const MediaPageHeader({
    super.key,
    required this.title,
    required this.selectedType,
    required this.onFilterChanged,
    this.currentWhatsAppType,
    this.onWhatsAppTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeType =
        currentWhatsAppType ??
        (Get.isRegistered<SettingsController>()
            ? SettingsController.to.activeWhatsAppType.value
            : WhatsAppType.whatsapp);

    final onTypeChanged =
        onWhatsAppTypeChanged ??
        (Get.isRegistered<SettingsController>()
            ? SettingsController.to.setActiveWhatsAppType
            : (_) {});

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: .spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: context.spaceM,
              right: context.spaceM,
              top: context.spaceS,
              bottom: context.spaceS,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                context.horizontalSpace(context.spaceS),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.setSize(165),
                    minWidth: context.setSize(130),
                  ),
                  child: WhatsAppTypeSwitch(
                    currentType: activeType,
                    onChanged: onTypeChanged,
                  ),
                ),
              ],
            ),
          ),
          MediaFilterBar(
            selectedType: selectedType,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}
