import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/helpers/ui/status_delete_helper.dart';
import 'package:status_saver/core/utils/helpers/ui/toast_helper.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';
import 'package:status_saver/features/viewer/data/models/media_viewer_item.dart';
import 'package:status_saver/features/viewer/presentation/controllers/media_viewer_controller.dart';
import 'package:status_saver/features/viewer/presentation/widgets/media_viewer_app_bar.dart';
import 'package:status_saver/features/viewer/presentation/widgets/media_viewer_content.dart';
import 'package:status_saver/features/viewer/presentation/widgets/media_viewer_filmstrip.dart';
import 'package:status_saver/shared/widgets/appbars/my_app_bar.dart';

export 'package:status_saver/features/viewer/data/models/media_viewer_item.dart';
export 'package:status_saver/features/viewer/presentation/controllers/media_viewer_controller.dart';

class MediaViewerPage extends StatefulWidget {
  final List<MediaViewerItem> items;
  final int initialIndex;
  final Future<String?> Function(MediaViewerItem item)? onLoadThumbnail;
  final Future<String?> Function(MediaViewerItem item)? onResolveFullFile;
  final Future<bool> Function(MediaViewerItem item)? onSave;
  final Future<void> Function(MediaViewerItem item)? onShare;
  final Future<bool> Function(MediaViewerItem item)? onDelete;
  final bool closeOnDelete;

  const MediaViewerPage({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onLoadThumbnail,
    this.onResolveFullFile,
    this.onSave,
    this.onShare,
    this.onDelete,
    this.closeOnDelete = false,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required List<MediaViewerItem> items,
    int initialIndex = 0,
    Future<String?> Function(MediaViewerItem item)? onLoadThumbnail,
    Future<String?> Function(MediaViewerItem item)? onResolveFullFile,
    Future<bool> Function(MediaViewerItem item)? onSave,
    Future<void> Function(MediaViewerItem item)? onShare,
    Future<bool> Function(MediaViewerItem item)? onDelete,
    bool closeOnDelete = false,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: AppDurations.fast,
        reverseTransitionDuration: AppDurations.fast,
        pageBuilder: (context, animation, secondaryAnimation) {
          return MediaViewerPage(
            items: items,
            initialIndex: initialIndex,
            onLoadThumbnail: onLoadThumbnail,
            onResolveFullFile: onResolveFullFile,
            onSave: onSave,
            onShare: onShare,
            onDelete: onDelete,
            closeOnDelete: closeOnDelete,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final MediaViewerController controller;
  final Set<String> _autoSavingIds = <String>{};

  @override
  void initState() {
    super.initState();
    controller = MediaViewerController(
      items: widget.items,
      initialIndex: widget.initialIndex,
      onLoadThumbnailCallback: widget.onLoadThumbnail,
      onResolveFullFileCallback: widget.onResolveFullFile,
      onSaveItem: widget.onSave,
      onShareItem: widget.onShare,
      onDeleteItem: widget.onDelete,
    );
    controller.onInit();
    _checkAutoSave(widget.initialIndex);
  }

  @override
  void dispose() {
    controller.onClose();
    super.dispose();
  }

  void _checkAutoSave(int index) {
    if (!Get.isRegistered<SettingsController>()) return;
    final settings = SettingsController.to;
    if (!settings.autoSaveOpenedStatuses.value) return;
    if (index < 0 || index >= controller.items.length) return;

    final item = controller.items[index];
    if (item.isSaved || _autoSavingIds.contains(item.id) || widget.onSave == null) return;

    _autoSavingIds.add(item.id);

    // Run unawaited in background without blocking media viewing
    Future.microtask(() async {
      try {
        final success = await widget.onSave!(item);
        if (success && mounted) {
          final idx = controller.items.indexWhere((it) => it.id == item.id);
          if (idx != -1) {
            controller.items[idx] = controller.items[idx].copyWith(isSaved: true);
          }
          ToastHelper.show(msg: context.l10n.savedSuccessfully);
        }
      } catch (_) {
        // Softly handle failed saves without interrupting media viewing
      } finally {
        _autoSavingIds.remove(item.id);
      }
    });
  }

  Future<void> _handleSave() async {
    await controller.saveCurrentItem(
      onSuccess: () => ToastHelper.show(msg: context.l10n.savedSuccessfully),
      onError: (msg) =>
          ToastHelper.show(msg: '${context.l10n.saveFailed}: $msg'),
    );
  }

  void _confirmDelete() {
    final currentItem = controller.currentItem;
    if (currentItem == null) return;

    StatusDeleteHelper.confirmAndDelete(
      context,
      onDelete: () async {
        return await controller.deleteCurrentItem(
          onCloseViewer: () {
            if (mounted) Navigator.of(context).pop();
          },
          forceClose: widget.closeOnDelete,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && controller.filmstripController.hasClients) {
        final itemWidth = context.setSize(48) + (context.spaceXxs * 2);
        controller.scrollToThumbnail(
          controller.currentIndex.value,
          screenWidth: MediaQuery.of(context).size.width,
          itemWidth: itemWidth,
          animate: false,
        );
      }
    });

    return Obx(() {
      if (controller.items.isEmpty) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: MyAppBar(
            color: Colors.transparent,
            isElevated: false,
            leadingIconColor: Colors.white,
            title: '',
          ),
          body: Center(
            child: Text(
              context.l10n.noData,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }

      final currentItem = controller.currentItem;
      if (currentItem == null) {
        return const Scaffold(backgroundColor: Colors.black);
      }

      const overlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      );

      final titleText =
          '${controller.currentIndex.value + 1} ${context.l10n.counterOf} ${controller.items.length}';
      final itemWidth = context.setSize(48) + (context.spaceXxs * 2);

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: controller.toggleControls,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Main Media Carousel
                PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.items.length,
                  onPageChanged: (index) {
                    controller.onPageChanged(index);
                    controller.scrollToThumbnail(
                      index,
                      screenWidth: MediaQuery.of(context).size.width,
                      itemWidth: itemWidth,
                    );
                    _checkAutoSave(index);
                  },
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    final resolvedPath =
                        controller.resolvedPaths[item.uri];
                    final thumbPath =
                        controller.thumbnails[item.uri] ?? item.thumbnailPath;

                    return MediaViewerContent(
                      item: item,
                      filePath: resolvedPath,
                      thumbnailPath: thumbPath,
                      isActive: index == controller.currentIndex.value,
                    );
                  },
                ),

                // Top AppBar Overlay
                MediaViewerAppBar(
                  title: titleText,
                  currentItem: currentItem,
                  isVisible: controller.showControls.value,
                  onSave: controller.onSaveItem != null && !currentItem.isSaved
                      ? _handleSave
                      : null,
                  onShare: controller.onShareItem != null
                      ? controller.shareCurrentItem
                      : null,
                  onDelete:
                      controller.onDeleteItem != null && currentItem.isSaved
                          ? _confirmDelete
                          : null,
                ),

                // Floating Bottom Gallery Filmstrip
                MediaViewerFilmstrip(
                  items: controller.items.toList(),
                  currentIndex: controller.currentIndex.value,
                  scrollController: controller.filmstripController,
                  thumbnails: Map<String, String>.from(controller.thumbnails),
                  isVisible: controller.showControls.value,
                  onSelectIndex: controller.selectItemFromStrip,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
