import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/home/domain/usecases/check_saf_access_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_full_media_file_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_statuses_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_thumbnail_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/request_saf_access_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/save_media_use_case.dart';
import 'package:status_saver/features/saved/domain/usecases/get_saved_media_use_case.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';

class HomeController extends GetxController {
  final CheckSafAccessUseCase _checkSafAccessUseCase;
  final RequestSafAccessUseCase _requestSafAccessUseCase;
  final GetStatusesUseCase _getStatusesUseCase;
  final GetThumbnailUseCase _getThumbnailUseCase;
  final GetFullMediaFileUseCase _getFullMediaFileUseCase;
  final SaveMediaUseCase _saveMediaUseCase;
  final GetSavedMediaUseCase _getSavedMediaUseCase;

  HomeController({
    required CheckSafAccessUseCase checkSafAccessUseCase,
    required RequestSafAccessUseCase requestSafAccessUseCase,
    required GetStatusesUseCase getStatusesUseCase,
    required GetThumbnailUseCase getThumbnailUseCase,
    required GetFullMediaFileUseCase getFullMediaFileUseCase,
    required SaveMediaUseCase saveMediaUseCase,
    required GetSavedMediaUseCase getSavedMediaUseCase,
  })  : _checkSafAccessUseCase = checkSafAccessUseCase,
        _requestSafAccessUseCase = requestSafAccessUseCase,
        _getStatusesUseCase = getStatusesUseCase,
        _getThumbnailUseCase = getThumbnailUseCase,
        _getFullMediaFileUseCase = getFullMediaFileUseCase,
        _saveMediaUseCase = saveMediaUseCase,
        _getSavedMediaUseCase = getSavedMediaUseCase;

  final RxList<StatusMedia> statuses = <StatusMedia>[].obs;
  final Rx<MediaType?> filterType = Rx<MediaType?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();
  final RxMap<String, String> thumbnails = <String, String>{}.obs;
  final RxSet<String> savedDocumentUris = <String>{}.obs;
  final RxSet<String> savingDocumentUris = <String>{}.obs;

  StreamSubscription? _savedSubscription;

  List<StatusMedia> get filteredStatuses {
    if (filterType.value == null) {
      return statuses;
    }
    return statuses
        .where((item) => item.mediaType == filterType.value)
        .toList();
  }

  void setFilter(MediaType? type) {
    filterType.value = type;
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

  @override
  void onInit() {
    super.onInit();
    _subscribeSavedMedia();
    if (Get.isRegistered<SettingsController>()) {
      ever(SettingsController.to.activeWhatsAppType, (type) {
        checkAccessAndLoadStatuses(type);
      });
    }
    initSafStatus();
  }

  void _subscribeSavedMedia() {
    _savedSubscription = _getSavedMediaUseCase.watch().listen((items) {
      savedDocumentUris.assignAll(items.map((e) => e.originalDocumentUri));
    });
  }

  @override
  void onClose() {
    _savedSubscription?.cancel();
    super.onClose();
  }

  Future<void> initSafStatus() async {
    await checkAccessAndLoadStatuses(currentWhatsAppType);
  }

  Future<void> checkAccessAndLoadStatuses([WhatsAppType? type]) async {
    final targetType = type ?? currentWhatsAppType;
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _checkSafAccessUseCase(targetType);
    result.when(
      success: (granted) {
        hasPermission.value = granted;
        if (granted) {
          loadStatuses(type: targetType);
        } else {
          statuses.clear();
          isLoading.value = false;
        }
      },
      failure: (f) {
        hasPermission.value = false;
        statuses.clear();
        errorMessage.value = f.message;
        isLoading.value = false;
      },
    );
  }

  Future<void> requestPermission([WhatsAppType? type]) async {
    final targetType = type ?? currentWhatsAppType;
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _requestSafAccessUseCase(targetType);
    result.when(
      success: (treeUri) {
        hasPermission.value = true;
        loadStatuses(forceRefresh: true, type: targetType);
      },
      failure: (f) {
        hasPermission.value = false;
        errorMessage.value = f.message;
        isLoading.value = false;
      },
    );
  }

  Future<void> loadStatuses({
    bool forceRefresh = false,
    WhatsAppType? type,
  }) async {
    final targetType = type ?? currentWhatsAppType;
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getStatusesUseCase(
      forceRefresh: forceRefresh,
      type: targetType,
    );
    result.when(
      success: (items) {
        statuses.assignAll(items);
        isLoading.value = false;
      },
      failure: (f) {
        errorMessage.value = f.message;
        isLoading.value = false;
      },
    );
  }

  final Map<String, Future<String?>> _inFlightThumbnails = {};

  Future<String?> loadThumbnail(String documentUri) {
    if (thumbnails.containsKey(documentUri) &&
        thumbnails[documentUri] != null &&
        thumbnails[documentUri]!.isNotEmpty) {
      return Future.value(thumbnails[documentUri]);
    }

    if (_inFlightThumbnails.containsKey(documentUri)) {
      return _inFlightThumbnails[documentUri]!;
    }

    final future = _loadThumbnailInternal(documentUri);
    _inFlightThumbnails[documentUri] = future;
    return future;
  }

  Future<String?> _loadThumbnailInternal(String documentUri) async {
    try {
      final result = await _getThumbnailUseCase(documentUri);
      return result.when(
        success: (path) {
          thumbnails[documentUri] = path;
          return path;
        },
        failure: (_) => null,
      );
    } finally {
      _inFlightThumbnails.remove(documentUri);
    }
  }

  Future<String?> getFullMediaFile(String documentUri, String fileName) async {
    final result = await _getFullMediaFileUseCase(documentUri, fileName);
    return result.when(
      success: (path) => path,
      failure: (_) => null,
    );
  }

  Future<bool> saveStatus(
    StatusMedia media, {
    VoidCallback? onSuccess,
    void Function(String message)? onError,
  }) async {
    if (savedDocumentUris.contains(media.documentUri) ||
        savingDocumentUris.contains(media.documentUri)) {
      return false;
    }

    savingDocumentUris.add(media.documentUri);

    final result = await _saveMediaUseCase(media);

    savingDocumentUris.remove(media.documentUri);

    return result.when(
      success: (_) {
        savedDocumentUris.add(media.documentUri);
        onSuccess?.call();
        return true;
      },
      failure: (f) {
        onError?.call(f.message);
        return false;
      },
    );
  }
}
