import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/services/cash/cash_keys.dart';
import 'package:status_saver/core/services/cash/cash_service.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/app_shell/controller/app_shell_controller.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';
import 'package:status_saver/features/home/domain/usecases/check_saf_access_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_full_media_file_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_statuses_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_thumbnail_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/request_saf_access_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/save_media_use_case.dart';
import 'package:status_saver/features/home/presentation/controllers/home_controller.dart';
import 'package:status_saver/features/saved/data/datasources/saved_media_local_data_source.dart';
import 'package:status_saver/features/saved/data/models/saved_media_model.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';
import 'package:status_saver/features/saved/domain/repositories/saved_media_repository.dart';
import 'package:status_saver/features/saved/domain/usecases/delete_saved_media_use_case.dart';
import 'package:status_saver/features/saved/domain/usecases/get_saved_media_use_case.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';

class FakeSavedMediaRepository implements SavedMediaRepository {
  final List<String> deletedOriginalUris = [];
  final List<int> deletedIds = [];

  @override
  Future<Result<bool, Failure>> deleteSavedMedia(int id, {String? mediaStoreUri}) async {
    deletedIds.add(id);
    return const Success(true);
  }

  @override
  Future<Result<bool, Failure>> deleteSavedMediaByOriginalUri(String originalDocumentUri) async {
    deletedOriginalUris.add(originalDocumentUri);
    return const Success(true);
  }

  @override
  Future<Result<List<SavedMedia>, Failure>> getSavedMedia() async {
    return const Success([]);
  }

  @override
  Stream<List<SavedMedia>> watchSavedMedia() {
    return Stream.value([]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tab Navigation (AppShellController)', () {
    late AppShellController controller;

    setUp(() {
      controller = AppShellController();
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test('initial tab is 0', () {
      expect(controller.currentIndex.value, 0);
      expect(controller.pageController.initialPage, 0);
    });

    test('onPageChanged updates currentIndex', () {
      controller.onPageChanged(1);
      expect(controller.currentIndex.value, 1);

      controller.onPageChanged(2);
      expect(controller.currentIndex.value, 2);
    });

    test('changeTab updates currentIndex', () {
      controller.changeTab(2);
      expect(controller.currentIndex.value, 2);
    });
  });

  group('Delete Saved Status (DeleteSavedMediaUseCase & HomeController)', () {
    late FakeSavedMediaRepository fakeRepo;
    late DeleteSavedMediaUseCase deleteUseCase;

    setUp(() {
      fakeRepo = FakeSavedMediaRepository();
      deleteUseCase = DeleteSavedMediaUseCase(fakeRepo);
    });

    test('DeleteSavedMediaUseCase.deleteByOriginalUri calls repository', () async {
      const uri = 'content://documents/statuses/sample.jpg';
      final result = await deleteUseCase.deleteByOriginalUri(uri);

      expect(result.isSuccess, true);
      expect(fakeRepo.deletedOriginalUris, contains(uri));
    });

    test('HomeController.deleteStatus removes status and calls use case', () async {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      await Get.putAsync<CashService>(() async => await CashService().init());

      final homeController = HomeController(
        checkSafAccessUseCase: CheckSafAccessUseCase(_DummyStatusRepo()),
        requestSafAccessUseCase: RequestSafAccessUseCase(_DummyStatusRepo()),
        getStatusesUseCase: GetStatusesUseCase(_DummyStatusRepo()),
        getThumbnailUseCase: GetThumbnailUseCase(_DummyStatusRepo()),
        getFullMediaFileUseCase: GetFullMediaFileUseCase(_DummyStatusRepo()),
        saveMediaUseCase: SaveMediaUseCase(_DummyStatusRepo(), _DummySavedDataSource()),
        getSavedMediaUseCase: GetSavedMediaUseCase(fakeRepo),
        deleteSavedMediaUseCase: deleteUseCase,
      );

      const testUri = 'content://documents/statuses/video1.mp4';
      homeController.savedDocumentUris.add(testUri);
      expect(homeController.savedDocumentUris.contains(testUri), true);

      const media = StatusMedia(
        id: 'video1',
        documentUri: testUri,
        fileName: 'video1.mp4',
        mediaType: MediaType.video,
        mimeType: 'video/mp4',
        size: 5000,
        lastModified: 1000,
      );

      bool callbackCalled = false;
      final success = await homeController.deleteStatus(
        media,
        onSuccess: () => callbackCalled = true,
      );

      expect(success, true);
      expect(callbackCalled, true);
      expect(homeController.savedDocumentUris.contains(testUri), false);
      expect(fakeRepo.deletedOriginalUris, contains(testUri));
    });
  });

  group('Custom Save Folder & Auto-Save (SettingsController)', () {
    late CashService cashService;
    late SettingsController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      cashService = await Get.putAsync<CashService>(() async => await CashService().init());
      controller = Get.put(SettingsController());
    });

    tearDown(() {
      Get.reset();
    });

    test('Default save folders are independent for WhatsApp and WhatsApp Business', () {
      expect(
        controller.getSaveFolderPath(WhatsAppType.whatsapp),
        'Download/Halati/WhatsApp',
      );
      expect(
        controller.getSaveFolderPath(WhatsAppType.business),
        'Download/Halati/WhatsApp Business',
      );
      expect(controller.isCustomFolder(WhatsAppType.whatsapp), false);
      expect(controller.isCustomFolder(WhatsAppType.business), false);
    });

    test('Auto-save opened statuses setting is disabled by default', () {
      expect(controller.autoSaveOpenedStatuses.value, false);
    });

    test('setAutoSaveOpenedStatuses toggles and persists in preferences', () async {
      await controller.setAutoSaveOpenedStatuses(true);

      expect(controller.autoSaveOpenedStatuses.value, true);
      expect(cashService.getBool(CashKeys.autoSaveOpenedStatuses), true);

      await controller.setAutoSaveOpenedStatuses(false);

      expect(controller.autoSaveOpenedStatuses.value, false);
      expect(cashService.getBool(CashKeys.autoSaveOpenedStatuses), false);
    });

    test('Restoring default save folder restores default path', () async {
      // Simulate configured custom path for WhatsApp
      controller.saveFolderWhatsApp.value = 'MyFolder/CustomStatuses';
      controller.isCustomFolderWhatsApp.value = true;
      await cashService.setString(CashKeys.saveFolderCustomUri, 'content://custom/tree');
      await cashService.setString(CashKeys.saveFolderCustomPath, 'MyFolder/CustomStatuses');

      expect(controller.getSaveFolderPath(WhatsAppType.whatsapp), 'MyFolder/CustomStatuses');
      expect(controller.isCustomFolder(WhatsAppType.whatsapp), true);

      // Restore default
      await controller.restoreDefaultSaveFolder(WhatsAppType.whatsapp);

      expect(controller.getSaveFolderPath(WhatsAppType.whatsapp), 'Download/Halati/WhatsApp');
      expect(controller.isCustomFolder(WhatsAppType.whatsapp), false);
      expect(cashService.getString(CashKeys.saveFolderCustomUri), null);

      // Verify business remains unaffected
      expect(controller.getSaveFolderPath(WhatsAppType.business), 'Download/Halati/WhatsApp Business');
    });
  });
}

class _DummyStatusRepo implements StatusRepository {
  @override
  Future<Result<bool, Failure>> checkSafAccess([WhatsAppType type = WhatsAppType.whatsapp]) async => const Success(true);
  @override
  Future<Result<String, Failure>> requestSafAccess([WhatsAppType type = WhatsAppType.whatsapp]) async => const Success('uri');
  @override
  Future<Result<bool, Failure>> releaseSafAccess([WhatsAppType type = WhatsAppType.whatsapp]) async => const Success(true);
  @override
  Future<Result<List<StatusMedia>, Failure>> getStatuses({bool forceRefresh = false, WhatsAppType type = WhatsAppType.whatsapp}) async => const Success([]);
  @override
  Future<Result<String, Failure>> getThumbnail(String documentUri, {int width = 300, int height = 300}) async => const Success('');
  @override
  Future<Result<Map<String, dynamic>, Failure>> getMediaMetadata(String documentUri) async => const Success({});
  @override
  Future<Result<String, Failure>> getFullMediaFile(String documentUri, String fileName) async => const Success('');
  @override
  Future<Result<Map<String, dynamic>, Failure>> saveMediaToGallery(StatusMedia media, {WhatsAppType? type}) async => const Success({});
}

class _DummySavedDataSource implements SavedMediaLocalDataSource {
  @override
  Future<int> deleteSavedMedia(int id) async => 1;
  @override
  Future<int> deleteSavedMediaByOriginalUri(String originalDocumentUri) async => 1;
  @override
  Future<List<SavedMediaModel>> getSavedMedia() async => [];
  @override
  Future<SavedMediaModel?> getSavedMediaByOriginalUri(String originalDocumentUri) async => null;
  @override
  Future<int> insertSavedMedia(dynamic companion) async => 1;
  @override
  Stream<List<SavedMediaModel>> watchSavedMedia() => Stream.value([]);
}
