import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/helpers/misc/share_helper.dart';
import 'package:status_saver/core/utils/helpers/ui/status_delete_helper.dart';
import 'package:status_saver/core/utils/helpers/ui/toast_helper.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';
import 'package:status_saver/features/saved/presentation/controllers/saved_controller.dart';
import 'package:status_saver/shared/widgets/buttons/my_popup_menu.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';

class SavedGridItem extends StatelessWidget {
  final SavedMedia media;
  final VoidCallback? onTap;

  const SavedGridItem({super.key, required this.media, this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SavedController>();

    return MyCard.filled(
      padding: EdgeInsets.zero,
      color: context.colorScheme.surfaceContainerHigh,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media preview
          if (media.mediaType == MediaType.audio)
            _buildAudioVisual(context)
          else
            _buildThumbnail(context, controller),

          // Video overlay
          if (media.mediaType == MediaType.video)
            Center(
              child: MyCard.filled(
                padding: context.insetsAllS,
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: context.brCircular,
                child: MyIcon(icon: AppIcons.play, color: Colors.white),
              ),
            ),

          // Top-end Menu button (using MyPopupMenu)
          PositionedDirectional(
            top: context.spaceS,
            end: context.spaceS,
            child: _buildActionMenu(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, SavedController controller) {
    return SizedBox.square(
      dimension: context.setSize(22),
      child: MyPopupMenu<String>(
        iconSize: context.setSize(16),
        iconColor: Colors.white,
        iconBackground: Colors.black.withValues(alpha: 0.55),
        items: [
          MyPopupMenuItem<String>(
            value: 'share',
            label: context.l10n.share,
            icon: AppIcons.share,
          ),
          MyPopupMenuItem<String>(
            value: 'delete',
            label: context.l10n.delete,
            icon: AppIcons.delete,
            color: context.colorScheme.error,
          ),
        ],
        onSelected: (value) async {
          if (value == 'share') {
            final path = await controller.getFullMediaFile(
              media.mediaStoreUri,
              media.fileName,
            );
            if (path != null) {
              await ShareHelper.shareFile(File(path), text: media.fileName);
            }
          } else if (value == 'delete') {
            _confirmDelete(context, controller);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, SavedController controller) {
    StatusDeleteHelper.confirmAndDelete(
      context,
      onDelete: () => controller.deleteMedia(
        media,
        onError: (msg) => ToastHelper.show(msg: '${context.l10n.error}: $msg'),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, SavedController controller) {
    return Obx(() {
      final cachedPath = controller.thumbnails[media.mediaStoreUri];

      if (cachedPath != null && cachedPath.isNotEmpty) {
        return Image.file(
          File(cachedPath),
          fit: BoxFit.cover,
          cacheWidth: 400,
          errorBuilder: (ctx, err, stack) => _buildFallback(context),
        );
      }

      return FutureBuilder<String?>(
        future: controller.loadThumbnail(media.mediaStoreUri),
        builder: (context, snapshot) {
          final path =
              snapshot.data ?? controller.thumbnails[media.mediaStoreUri];
          if (path != null && path.isNotEmpty) {
            return Image.file(
              File(path),
              fit: BoxFit.cover,
              cacheWidth: 400,
              errorBuilder: (ctx, err, stack) => _buildFallback(context),
            );
          }
          return _buildFallback(context);
        },
      );
    });
  }

  Widget _buildAudioVisual(BuildContext context) {
    return MyCard.filled(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          context.colorScheme.primaryContainer.withValues(alpha: 0.8),
          context.colorScheme.secondaryContainer.withValues(alpha: 0.9),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyCard.filled(
            padding: context.insetsAllS,
            color: context.colorScheme.surface.withValues(alpha: 0.2),
            borderRadius: context.brCircular,
            child: MyIcon(
              icon: AppIcons.waveform,
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: context.spaceXs),
          Padding(
            padding: context.insetsHorizontalS,
            child: Text(
              media.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: context.colorScheme.surfaceContainerHighest,
      child: Center(
        child: MyIcon(
          icon: media.mediaType == MediaType.video
              ? AppIcons.video
              : AppIcons.image,
          size: context.setSize(28),
          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
