import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/home/domain/usecases/get_full_media_file_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_thumbnail_use_case.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';
import 'package:status_saver/features/saved/domain/usecases/delete_saved_media_use_case.dart';
import 'package:status_saver/features/saved/domain/usecases/get_saved_media_use_case.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';

class SavedController extends GetxController {
  final GetSavedMediaUseCase _getSavedMediaUseCase;
  final DeleteSavedMediaUseCase _deleteSavedMediaUseCase;
  final GetFullMediaFileUseCase _getFullMediaFileUseCase;
  final GetThumbnailUseCase _getThumbnailUseCase;

  SavedController({
    required GetSavedMediaUseCase getSavedMediaUseCase,
    required DeleteSavedMediaUseCase deleteSavedMediaUseCase,
    required GetFullMediaFileUseCase getFullMediaFileUseCase,
    required GetThumbnailUseCase getThumbnailUseCase,
  })  : _getSavedMediaUseCase = getSavedMediaUseCase,
        _deleteSavedMediaUseCase = deleteSavedMediaUseCase,
        _getFullMediaFileUseCase = getFullMediaFileUseCase,
        _getThumbnailUseCase = getThumbnailUseCase;

  final RxList<SavedMedia> allSavedItems = <SavedMedia>[].obs;
  final Rx<MediaType?> filterType = Rx<MediaType?>(null);
  final RxBool isLoading = true.obs;
  final RxMap<String, String> thumbnails = <String, String>{}.obs;

  StreamSubscription<List<SavedMedia>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToSavedMedia();
  }

  void _subscribeToSavedMedia() {
    isLoading.value = true;
    _subscription = _getSavedMediaUseCase.watch().listen((items) {
      allSavedItems.assignAll(items);
      isLoading.value = false;
    });
  }

  WhatsAppType get currentWhatsAppType =>
      Get.isRegistered<SettingsController>()
          ? SettingsController.to.activeWhatsAppType.value
          : WhatsAppType.whatsapp;

  void switchWhatsAppType(WhatsAppType type) {
    if (Get.isRegistered<SettingsController>()) {
      SettingsController.to.setActiveWhatsAppType(type);
    }
  }

  List<SavedMedia> get filteredItems {
    final activeType = currentWhatsAppType;
    return allSavedItems.where((item) {
      final uri = item.originalDocumentUri.toLowerCase();
      final isItemBusiness = uri.contains('com.whatsapp.w4b') ||
          uri.contains('whatsapp%20business') ||
          uri.contains('whatsapp business');

      final matchesApp =
          activeType.isBusiness ? isItemBusiness : !isItemBusiness;
      if (!matchesApp) return false;

      if (filterType.value != null && item.mediaType != filterType.value) {
        return false;
      }
      return true;
    }).toList();
  }

  void setFilter(MediaType? type) {
    filterType.value = type;
  }

  final Map<String, Future<String?>> _inFlightThumbnails = {};

  Future<String?> loadThumbnail(String mediaStoreUri) {
    if (thumbnails.containsKey(mediaStoreUri) &&
        thumbnails[mediaStoreUri] != null &&
        thumbnails[mediaStoreUri]!.isNotEmpty) {
      return Future.value(thumbnails[mediaStoreUri]);
    }

    if (_inFlightThumbnails.containsKey(mediaStoreUri)) {
      return _inFlightThumbnails[mediaStoreUri]!;
    }

    final future = _loadThumbnailInternal(mediaStoreUri);
    _inFlightThumbnails[mediaStoreUri] = future;
    return future;
  }

  Future<String?> _loadThumbnailInternal(String mediaStoreUri) async {
    try {
      final result = await _getThumbnailUseCase(mediaStoreUri);
      return result.when(
        success: (path) {
          thumbnails[mediaStoreUri] = path;
          return path;
        },
        failure: (_) => null,
      );
    } finally {
      _inFlightThumbnails.remove(mediaStoreUri);
    }
  }

  Future<String?> getFullMediaFile(String mediaStoreUri, String fileName) async {
    final result = await _getFullMediaFileUseCase(mediaStoreUri, fileName);
    return result.when(
      success: (path) => path,
      failure: (_) => null,
    );
  }

  Future<bool> deleteMedia(
    SavedMedia media, {
    VoidCallback? onSuccess,
    void Function(String message)? onError,
  }) async {
    final result = await _deleteSavedMediaUseCase(
      media.id,
      mediaStoreUri: media.mediaStoreUri,
    );

    return result.when(
      success: (_) {
        onSuccess?.call();
        return true;
      },
      failure: (f) {
        onError?.call(f.message);
        return false;
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
