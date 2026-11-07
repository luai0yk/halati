import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/core/utils/helpers/ui/status_delete_helper.dart';
import 'package:halati/core/utils/helpers/ui/toast_helper.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/features/home/presentation/controllers/home_controller.dart';
import 'package:halati/shared/widgets/cards/my_card.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';

class StatusGridItem extends StatelessWidget {
  final StatusMedia media;
  final VoidCallback? onTap;

  const StatusGridItem({super.key, required this.media, this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return MyCard.filled(
      padding: EdgeInsets.zero,
      color: context.colorScheme.surfaceContainerHigh,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail or audio card background
          if (media.mediaType == MediaType.audio)
            _buildAudioVisual(context)
          else
            _buildMediaThumbnail(context, controller),

          // Video overlay (play icon)
          if (media.mediaType == MediaType.video)
            Center(
              child: MyCard.filled(
                padding: context.insetsAllS,
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: context.brCircular,
                child: MyIcon(icon: AppIcons.play, color: Colors.white),
              ),
            ),

          // Top-end Save button
          PositionedDirectional(
            top: context.spaceS,
            end: context.spaceS,
            child: _buildSaveButton(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, HomeController controller) {
    return Obx(() {
      final isSaved = controller.savedDocumentUris.contains(media.documentUri);
      final isSaving = controller.savingDocumentUris.contains(
        media.documentUri,
      );

      return MyCard.filled(
        padding: context.insetsAllXs,
        color: isSaved
            ? context.colorScheme.primary.withValues(alpha: 0.85)
            : Colors.black.withValues(alpha: 0.55),
        onTap: () async {
          if (isSaving) return;
          if (isSaved) {
            StatusDeleteHelper.confirmAndDelete(
              context,
              onDelete: () => controller.deleteStatus(
                media,
                onError: (msg) {
                  ToastHelper.show(msg: '${context.l10n.error}: $msg');
                },
              ),
            );
            return;
          }
          await controller.saveStatus(
            media,
            onSuccess: () {
              ToastHelper.show(msg: context.l10n.savedSuccessfully);
            },
            onError: (msg) {
              ToastHelper.show(msg: '${context.l10n.saveFailed}: $msg');
            },
          );
        },
        child: isSaving
            ? SizedBox(
                width: context.setSize(16),
                height: context.setSize(16),
                child: const MyProgressIndicator(strokeWidth: 2),
              )
            : MyIcon(
                icon: isSaved ? AppIcons.check : AppIcons.download,
                color: Colors.white,
                size: context.setSize(14),
              ),
      );
    });
  }

  Widget _buildMediaThumbnail(BuildContext context, HomeController controller) {
    return Obx(() {
      final cachedPath =
          controller.thumbnails[media.documentUri] ?? media.thumbnailPath;

      if (cachedPath != null && cachedPath.isNotEmpty) {
        return Image.file(
          File(cachedPath),
          fit: BoxFit.cover,
          cacheWidth: 400,
          errorBuilder: (ctx, err, stack) => _buildPlaceholder(context),
        );
      }

      return FutureBuilder<String?>(
        future: controller.loadThumbnail(media.documentUri),
        builder: (context, snapshot) {
          final path =
              snapshot.data ??
              controller.thumbnails[media.documentUri] ??
              media.thumbnailPath;
          if (path != null && path.isNotEmpty) {
            return Image.file(
              File(path),
              fit: BoxFit.cover,
              cacheWidth: 400,
              errorBuilder: (ctx, err, stack) => _buildPlaceholder(context),
            );
          }
          return _buildPlaceholder(context);
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

  Widget _buildPlaceholder(BuildContext context) {
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
