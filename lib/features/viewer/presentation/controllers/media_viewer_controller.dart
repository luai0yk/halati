import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/features/viewer/data/models/media_viewer_item.dart';

class MediaViewerController extends GetxController {
  final Future<String?> Function(MediaViewerItem item)? onLoadThumbnailCallback;
  final Future<String?> Function(MediaViewerItem item)?
  onResolveFullFileCallback;
  final Future<bool> Function(MediaViewerItem item)? onSaveItem;
  final Future<void> Function(MediaViewerItem item)? onShareItem;
  final Future<bool> Function(MediaViewerItem item)? onDeleteItem;

  final RxList<MediaViewerItem> items = <MediaViewerItem>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool showControls = true.obs;
  final RxMap<String, String> resolvedPaths = <String, String>{}.obs;
  final RxMap<String, String> thumbnails = <String, String>{}.obs;

  final Map<String, Future<String?>> _inFlightResolutions = {};
  final Map<String, Future<String?>> _inFlightThumbnails = {};

  late final PageController pageController;
  late final ScrollController filmstripController;
  Timer? _controlsTimer;

  MediaViewerController({
    required List<MediaViewerItem> items,
    int initialIndex = 0,
    this.onLoadThumbnailCallback,
    this.onResolveFullFileCallback,
    this.onSaveItem,
    this.onShareItem,
    this.onDeleteItem,
  }) {
    this.items.assignAll(items);
    final clampedIndex = initialIndex.clamp(
      0,
      this.items.isEmpty ? 0 : this.items.length - 1,
    );
    currentIndex.value = clampedIndex;
    pageController = PageController(initialPage: clampedIndex);
    filmstripController = ScrollController();

    for (final item in this.items) {
      if (item.thumbnailPath != null && item.thumbnailPath!.isNotEmpty) {
        thumbnails[item.uri] = item.thumbnailPath!;
      }
    }
  }

  MediaViewerItem? get currentItem =>
      items.isNotEmpty && currentIndex.value < items.length
          ? items[currentIndex.value]
          : null;

  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    loadThumbnailForIndex(currentIndex.value);
    resolveFileForIndex(currentIndex.value);
    _prefetchAdjacent(currentIndex.value);
    startHideControlsTimer();
  }

  @override
  void onClose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _controlsTimer?.cancel();
    pageController.dispose();
    filmstripController.dispose();
    super.onClose();
  }

  void startHideControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (showControls.value) {
        showControls.value = false;
      }
    });
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) {
      startHideControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    loadThumbnailForIndex(index);
    resolveFileForIndex(index);
    _prefetchAdjacent(index);
    startHideControlsTimer();
  }

  void _prefetchAdjacent(int index) {
    if (index + 1 < items.length) {
      loadThumbnailForIndex(index + 1);
      resolveFileForIndex(index + 1);
    }
    if (index - 1 >= 0) {
      loadThumbnailForIndex(index - 1);
      resolveFileForIndex(index - 1);
    }
  }

  Future<void> loadThumbnailForIndex(int index) async {
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    if (thumbnails.containsKey(item.uri)) return;
    if (_inFlightThumbnails.containsKey(item.uri)) {
      await _inFlightThumbnails[item.uri];
      return;
    }

    if (onLoadThumbnailCallback != null) {
      final future = onLoadThumbnailCallback!(item);
      _inFlightThumbnails[item.uri] = future;
      try {
        final path = await future;
        if (path != null) {
          thumbnails[item.uri] = path;
        }
      } finally {
        _inFlightThumbnails.remove(item.uri);
      }
    }
  }

  Future<void> resolveFileForIndex(int index) async {
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    if (resolvedPaths.containsKey(item.uri)) return;
    if (_inFlightResolutions.containsKey(item.uri)) {
      await _inFlightResolutions[item.uri];
      return;
    }

    if (onResolveFullFileCallback != null) {
      final future = onResolveFullFileCallback!(item);
      _inFlightResolutions[item.uri] = future;
      try {
        final fullPath = await future;
        if (fullPath != null) {
          resolvedPaths[item.uri] = fullPath;
        }
      } finally {
        _inFlightResolutions.remove(item.uri);
      }
    }
  }

  void scrollToThumbnail(
    int index, {
    required double screenWidth,
    required double itemWidth,
    bool animate = true,
  }) {
    if (!filmstripController.hasClients) return;
    final targetOffset =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    final clampedOffset = targetOffset.clamp(
      0.0,
      filmstripController.position.maxScrollExtent,
    );

    if (animate) {
      filmstripController.animateTo(
        clampedOffset,
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    } else {
      filmstripController.jumpTo(clampedOffset);
    }
  }

  void selectItemFromStrip(int index) {
    if (index == currentIndex.value) return;
    pageController.animateToPage(
      index,
      duration: AppDurations.medium,
      curve: Curves.easeInOut,
    );
  }

  Future<void> saveCurrentItem({
    VoidCallback? onSuccess,
    void Function(String msg)? onError,
  }) async {
    final item = currentItem;
    if (item == null || item.isSaved || onSaveItem == null) return;
    try {
      final success = await onSaveItem!(item);
      if (success) {
        final idx = items.indexWhere((it) => it.id == item.id);
        if (idx != -1) {
          items[idx] = items[idx].copyWith(isSaved: true);
        }
        onSuccess?.call();
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<void> shareCurrentItem() async {
    final item = currentItem;
    if (item == null || onShareItem == null) return;
    await onShareItem!(item);
  }

  Future<bool> deleteCurrentItem({
    VoidCallback? onCloseViewer,
    bool forceClose = false,
  }) async {
    final item = currentItem;
    if (item == null || onDeleteItem == null) return false;

    final success = await onDeleteItem!(item);
    if (success) {
      items.removeWhere((it) => it.id == item.id);
      if (forceClose || items.isEmpty) {
        onCloseViewer?.call();
      } else {
        if (currentIndex.value >= items.length) {
          currentIndex.value = items.length - 1;
        }
        pageController.jumpToPage(currentIndex.value);
      }
      return true;
    }
    return false;
  }
}
