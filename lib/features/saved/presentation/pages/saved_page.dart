import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/helpers/misc/share_helper.dart';
import 'package:status_saver/core/utils/helpers/ui/toast_helper.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';
import 'package:status_saver/features/saved/presentation/controllers/saved_controller.dart';
import 'package:status_saver/features/saved/presentation/widgets/saved_grid_item.dart';
import 'package:status_saver/features/viewer/presentation/pages/media_viewer_page.dart';
import 'package:status_saver/shared/widgets/misc/my_empty_state.dart';
import 'package:status_saver/shared/widgets/misc/my_progress_indicator.dart';
import 'package:status_saver/shared/widgets/slivers/media_page_header.dart';
import 'package:status_saver/shared/widgets/slivers/sliver_filter_delegate.dart';

class SavedPage extends GetView<SavedController> {
  const SavedPage({super.key});

  void _openViewer(BuildContext context, int initialIndex) {
    final items = controller.filteredItems
        .map(
          (m) => MediaViewerItem(
            id: m.id.toString(),
            uri: m.mediaStoreUri,
            fileName: m.fileName,
            mediaType: m.mediaType,
            thumbnailPath: controller.thumbnails[m.mediaStoreUri],
            durationMs: m.durationMs,
            isSaved: true,
            originalObject: m,
          ),
        )
        .toList();

    MediaViewerPage.show(
      context,
      items: items,
      initialIndex: initialIndex,
      onLoadThumbnail: (item) => controller.loadThumbnail(item.uri),
      onResolveFullFile: (item) =>
          controller.getFullMediaFile(item.uri, item.fileName),
      onShare: (item) async {
        final path = await controller.getFullMediaFile(item.uri, item.fileName);
        if (path != null) {
          await ShareHelper.shareFile(File(path), text: item.fileName);
        }
      },
      onDelete: (item) async {
        return await controller.deleteMedia(
          item.originalObject as SavedMedia,
          onSuccess: () =>
              ToastHelper.show(msg: context.l10n.deletedSuccessfully),
          onError: (msg) =>
              ToastHelper.show(msg: '${context.l10n.error}: $msg'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.allSavedItems.isEmpty) {
          return const Center(child: MyProgressIndicator());
        }

        if (controller.allSavedItems.isEmpty) {
          return Center(
            child: MyEmptyState(
              icon: AppIcons.download,
              title: context.l10n.noSavedMedia,
              subtitle: context.l10n.noDataSubtitle,
            ),
          );
        }

        final items = controller.filteredItems;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: 500,
          clipBehavior: Clip.none,
          slivers: [
            SliverPersistentHeader(
              floating: true,
              delegate: SliverFilterDelegate(
                height: MediaQuery.paddingOf(context).top + context.setSize(90),
                child: MediaPageHeader(
                  title: context.l10n.saved,
                  selectedType: controller.filterType.value,
                  onFilterChanged: controller.setFilter,
                  currentWhatsAppType: controller.currentWhatsAppType,
                  onWhatsAppTypeChanged: controller.switchWhatsAppType,
                ),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: MyEmptyState(
                    icon: AppIcons.download,
                    title: context.l10n.noSavedMedia,
                    subtitle: context.l10n.noDataSubtitle,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(
                  left: context.spaceM,
                  right: context.spaceM,
                  top: context.spaceS,
                  bottom:
                      context.setSize(95) +
                      MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: context.setSize(6),
                    mainAxisSpacing: context.setSize(6),
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final media = items[index];
                    return SavedGridItem(
                      media: media,
                      onTap: () => _openViewer(context, index),
                    );
                  }, childCount: items.length),
                ),
              ),
          ],
        );
      }),
    );
  }
}
