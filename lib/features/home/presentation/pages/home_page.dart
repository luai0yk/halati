import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/core/utils/helpers/misc/share_helper.dart';
import 'package:halati/core/utils/helpers/ui/toast_helper.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/features/home/presentation/controllers/home_controller.dart';
import 'package:halati/features/home/presentation/widgets/status_grid_item.dart';
import 'package:halati/features/viewer/presentation/pages/media_viewer_page.dart';
import 'package:halati/shared/widgets/misc/my_empty_state.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';
import 'package:halati/shared/widgets/slivers/media_page_header.dart';
import 'package:halati/shared/widgets/slivers/sliver_filter_delegate.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  void _openViewer(BuildContext context, int initialIndex) {
    final items = controller.filteredStatuses
        .map(
          (m) => MediaViewerItem(
            id: m.id,
            uri: m.documentUri,
            fileName: m.fileName,
            mediaType: m.mediaType,
            thumbnailPath:
                controller.thumbnails[m.documentUri] ?? m.thumbnailPath,
            durationMs: m.durationMs,
            isSaved: controller.savedDocumentUris.contains(m.documentUri),
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
      onSave: (item) async {
        final media = item.originalObject as StatusMedia;
        return await controller.saveStatus(
          media,
          type: media.whatsAppType,
          onSuccess: () =>
              ToastHelper.show(msg: context.l10n.savedSuccessfully),
          onError: (msg) =>
              ToastHelper.show(msg: '${context.l10n.saveFailed}: $msg'),
        );
      },
      onShare: (item) async {
        final path = await controller.getFullMediaFile(item.uri, item.fileName);
        if (path != null) {
          await ShareHelper.shareFile(File(path), text: item.fileName);
        }
      },
      onDelete: (item) async {
        return await controller.deleteStatus(
          item.originalObject as StatusMedia,
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
        final items = controller.filteredStatuses;
        final hasPerm = controller.hasPermission.value;
        final isLoading =
            controller.isLoading.value && controller.statuses.isEmpty;
        final error = controller.errorMessage.value;
        final isBusiness = controller.currentWhatsAppType.isBusiness;

        Widget bodyContent;
        if (isLoading) {
          bodyContent = const Center(child: MyProgressIndicator());
        } else if (!hasPerm) {
          bodyContent = Center(
            child: MyEmptyState(
              icon: AppIcons.folder,
              title: isBusiness
                  ? context.l10n.safPermissionTitleBusiness
                  : context.l10n.safPermissionTitle,
              subtitle: isBusiness
                  ? context.l10n.safPermissionExplanationBusiness
                  : context.l10n.safPermissionExplanation,
              onAction: controller.requestPermission,
              actionText: context.l10n.selectFolder,
            ),
          );
        } else if (error != null && controller.statuses.isEmpty) {
          bodyContent = Center(
            child: MyEmptyState(
              icon: AppIcons.error,
              title: context.l10n.noResultsFound,
              subtitle: error,
              actionText: context.l10n.refresh,
              onAction: () => controller.loadStatuses(forceRefresh: true),
            ),
          );
        } else if (items.isEmpty) {
          bodyContent = Center(
            child: MyEmptyState(
              icon: AppIcons.status,
              title: context.l10n.noStatusesFound,
              subtitle: context.l10n.noStatusesSubtitle,
              actionText: context.l10n.refresh,
              onAction: () => controller.loadStatuses(forceRefresh: true),
            ),
          );
        } else {
          bodyContent = const SizedBox.shrink();
        }

        final showGrid =
            !isLoading &&
            hasPerm &&
            (error == null || controller.statuses.isNotEmpty) &&
            items.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => controller.loadStatuses(forceRefresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            cacheExtent: 500,
            clipBehavior: Clip.none,
            slivers: [
              SliverPersistentHeader(
                floating: true,
                delegate: SliverFilterDelegate(
                  height:
                      MediaQuery.paddingOf(context).top + context.setSize(90),
                  child: MediaPageHeader(
                    title: context.l10n.statuses,
                    selectedType: controller.filterType.value,
                    onFilterChanged: controller.setFilter,
                    currentWhatsAppType: controller.currentWhatsAppType,
                    onWhatsAppTypeChanged: controller.switchWhatsAppType,
                  ),
                ),
              ),
              if (!showGrid)
                SliverFillRemaining(hasScrollBody: false, child: bodyContent)
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
                      return StatusGridItem(
                        media: media,
                        onTap: () => _openViewer(context, index),
                      );
                    }, childCount: items.length),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
