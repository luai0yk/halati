import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/core/database/app_database.dart';
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/services/cash/cash_keys.dart';
import 'package:status_saver/core/services/cash/cash_service.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/app_shell/controller/app_shell_controller.dart';
import 'package:status_saver/features/home/data/datasources/saf_native_data_source.dart';
import 'package:status_saver/features/home/data/models/status_media_model.dart';
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
import 'package:status_saver/features/saved/data/repositories/saved_media_repository_impl.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';
import 'package:status_saver/features/saved/domain/repositories/saved_media_repository.dart';
import 'package:status_saver/features/saved/domain/usecases/delete_saved_media_use_case.dart';
import 'package:status_saver/features/saved/domain/usecases/get_saved_media_use_case.dart';
import 'package:status_saver/features/saved/presentation/controllers/saved_controller.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';
import 'package:status_saver/shared/widgets/misc/my_bottom_navigation_bar.dart';

class FakeSavedMediaRepository implements SavedMediaRepository {
  final List<String> deletedOriginalUris = [];
  final List<int> deletedIds = [];

  @override
  Future<Result<bool, Failure>> deleteSavedMedia(
    int id, {
    String? mediaStoreUri,
  }) async {
    deletedIds.add(id);
    return const Success(true);
  }

  @override
  Future<Result<bool, Failure>> deleteSavedMediaByOriginalUri(
    String originalDocumentUri,
  ) async {
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

  @override
  Future<Result<List<int>, Failure>> syncSavedMedia() async {
    return const Success([]);
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

    test(
      'changeTab ignores intermediate onPageChanged events during animation',
      () {
        controller.changeTab(2);
        expect(controller.currentIndex.value, 2);

        // Simulating intermediate page event fired by PageView while scrolling past page 1
        controller.onPageChanged(1);
        expect(
          controller.currentIndex.value,
          2,
          reason: 'Intermediate page 1 should not overwrite target page 2',
        );

        // Once the target page is reached
        controller.onPageChanged(2);
        expect(controller.currentIndex.value, 2);

        // Subsequent user swipe should work normally
        controller.onPageChanged(1);
        expect(controller.currentIndex.value, 1);
      },
    );
  });

  group('Delete Saved Status (DeleteSavedMediaUseCase & HomeController)', () {
    late FakeSavedMediaRepository fakeRepo;
    late DeleteSavedMediaUseCase deleteUseCase;

    setUp(() {
      fakeRepo = FakeSavedMediaRepository();
      deleteUseCase = DeleteSavedMediaUseCase(fakeRepo);
    });

    test(
      'DeleteSavedMediaUseCase.deleteByOriginalUri calls repository',
      () async {
        const uri = 'content://documents/statuses/sample.jpg';
        final result = await deleteUseCase.deleteByOriginalUri(uri);

        expect(result.isSuccess, true);
        expect(fakeRepo.deletedOriginalUris, contains(uri));
      },
    );

    test(
      'HomeController.deleteStatus removes status and calls use case',
      () async {
        SharedPreferences.setMockInitialValues({});
        Get.reset();
        await Get.putAsync<CashService>(() async => await CashService().init());

        final homeController = HomeController(
          checkSafAccessUseCase: CheckSafAccessUseCase(_DummyStatusRepo()),
          requestSafAccessUseCase: RequestSafAccessUseCase(_DummyStatusRepo()),
          getStatusesUseCase: GetStatusesUseCase(_DummyStatusRepo()),
          getThumbnailUseCase: GetThumbnailUseCase(_DummyStatusRepo()),
          getFullMediaFileUseCase: GetFullMediaFileUseCase(_DummyStatusRepo()),
          saveMediaUseCase: SaveMediaUseCase(
            _DummyStatusRepo(),
            _DummySavedDataSource(),
          ),
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
      },
    );
  });

  group('Custom Save Folder & Auto-Save (SettingsController)', () {
    late CashService cashService;
    late SettingsController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      cashService = await Get.putAsync<CashService>(
        () async => await CashService().init(),
      );
      controller = Get.put(SettingsController());
    });

    tearDown(() {
      Get.reset();
    });

    test(
      'Default save folders are independent for WhatsApp and WhatsApp Business',
      () {
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
      },
    );

    test('Auto-save opened statuses setting is disabled by default', () {
      expect(controller.autoSaveOpenedStatuses.value, false);
    });

    test(
      'setAutoSaveOpenedStatuses toggles and persists in preferences',
      () async {
        await controller.setAutoSaveOpenedStatuses(true);

        expect(controller.autoSaveOpenedStatuses.value, true);
        expect(cashService.getBool(CashKeys.autoSaveOpenedStatuses), true);

        await controller.setAutoSaveOpenedStatuses(false);

        expect(controller.autoSaveOpenedStatuses.value, false);
        expect(cashService.getBool(CashKeys.autoSaveOpenedStatuses), false);
      },
    );

    test('Restoring default save folder restores default path', () async {
      // Simulate configured custom path for WhatsApp
      controller.saveFolderWhatsApp.value = 'MyFolder/CustomStatuses';
      controller.isCustomFolderWhatsApp.value = true;
      await cashService.setString(
        CashKeys.saveFolderCustomUri,
        'content://custom/tree',
      );
      await cashService.setString(
        CashKeys.saveFolderCustomPath,
        'MyFolder/CustomStatuses',
      );

      expect(
        controller.getSaveFolderPath(WhatsAppType.whatsapp),
        'MyFolder/CustomStatuses',
      );
      expect(controller.isCustomFolder(WhatsAppType.whatsapp), true);

      // Restore default
      await controller.restoreDefaultSaveFolder(WhatsAppType.whatsapp);

      expect(
        controller.getSaveFolderPath(WhatsAppType.whatsapp),
        'Download/Halati/WhatsApp',
      );
      expect(controller.isCustomFolder(WhatsAppType.whatsapp), false);
      expect(cashService.getString(CashKeys.saveFolderCustomUri), null);

      // Verify business remains unaffected
      expect(
        controller.getSaveFolderPath(WhatsAppType.business),
        'Download/Halati/WhatsApp Business',
      );
    });
  });

  group('MyBottomNavigationBar Directionality & Navigation', () {
    testWidgets(
      'adapts indicator position when directionality flips from LTR to RTL',
      (tester) async {
        int selectedIndex = 2; // Settings selected
        final directionNotifier = ValueNotifier<TextDirection>(
          TextDirection.ltr,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ValueListenableBuilder<TextDirection>(
              valueListenable: directionNotifier,
              builder: (context, direction, _) {
                return Directionality(
                  textDirection: direction,
                  child: Scaffold(
                    bottomNavigationBar: MyBottomNavigationBar(
                      currentIndex: selectedIndex,
                      itemAnimation: MyBottomNavigationBarAnimation.bounce,
                      expandItems: true,
                      onItemSelected: (i) => selectedIndex = i,
                      items: const [
                        MyBottomNavigationBarItem(
                          title: 'Statuses',
                          icon: Icon(Icons.circle_outlined),
                        ),
                        MyBottomNavigationBarItem(
                          title: 'Saved',
                          icon: Icon(Icons.download_outlined),
                        ),
                        MyBottomNavigationBarItem(
                          title: 'Settings',
                          icon: Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the AnimatedPositioned widget representing the indicator
        final animatedPositionedFinder = find.byType(AnimatedPositioned);
        expect(animatedPositionedFinder, findsOneWidget);
        final ltrPositioned = tester.widget<AnimatedPositioned>(
          animatedPositionedFinder,
        );
        final ltrLeft = ltrPositioned.left!;

        // In LTR, index 2 (Settings) is on the right side (left > 400 for an 800-wide test screen)
        expect(ltrLeft, greaterThan(400));

        // Now flip to RTL (Arabic), while keeping selectedIndex at 2
        directionNotifier.value = TextDirection.rtl;

        await tester.pump();
        await tester.pumpAndSettle();

        final rtlPositioned = tester.widget<AnimatedPositioned>(
          animatedPositionedFinder,
        );
        final rtlLeft = rtlPositioned.left!;

        // In RTL, index 2 (Settings) is on the left side (left < 100)
        expect(rtlLeft, lessThan(100));
        expect(rtlLeft, isNot(equals(ltrLeft)));
      },
    );
  });

  group('WhatsApp Business Storage & Saved Status Filtering', () {
    late _RecordingStatusRepo statusRepo;
    late _RecordingSavedDataSource savedDataSource;
    late SaveMediaUseCase saveMediaUseCase;

    setUp(() {
      statusRepo = _RecordingStatusRepo();
      savedDataSource = _RecordingSavedDataSource();
      saveMediaUseCase = SaveMediaUseCase(statusRepo, savedDataSource);
    });

    test(
      'SaveMediaUseCase accurately routes WhatsApp vs Business images, videos, and audios',
      () async {
        // 1. WhatsApp Image
        final waImage = const StatusMedia(
          id: 'wa_img_1',
          documentUri: 'content://wa/image_1.jpg',
          fileName: 'image_1.jpg',
          mediaType: MediaType.image,
          mimeType: 'image/jpeg',
          size: 1000,
          lastModified: 500,
          whatsAppType: WhatsAppType.whatsapp,
        );
        await saveMediaUseCase(waImage);
        expect(statusRepo.lastSavedType, WhatsAppType.whatsapp);
        expect(
          savedDataSource.lastSavedCompanion?.whatsAppType.value,
          'whatsapp',
        );

        // 2. Business Image
        final bzImage = const StatusMedia(
          id: 'bz_img_1',
          documentUri: 'content://biz/image_2.jpg',
          fileName: 'image_2.jpg',
          mediaType: MediaType.image,
          mimeType: 'image/jpeg',
          size: 1200,
          lastModified: 600,
          whatsAppType: WhatsAppType.business,
        );
        await saveMediaUseCase(bzImage);
        expect(statusRepo.lastSavedType, WhatsAppType.business);
        expect(
          savedDataSource.lastSavedCompanion?.whatsAppType.value,
          'business',
        );

        // 3. Business Video
        final bzVideo = const StatusMedia(
          id: 'bz_vid_1',
          documentUri: 'content://biz/video_1.mp4',
          fileName: 'video_1.mp4',
          mediaType: MediaType.video,
          mimeType: 'video/mp4',
          size: 50000,
          lastModified: 700,
          whatsAppType: WhatsAppType.business,
        );
        await saveMediaUseCase(bzVideo);
        expect(statusRepo.lastSavedType, WhatsAppType.business);
        expect(
          savedDataSource.lastSavedCompanion?.whatsAppType.value,
          'business',
        );

        // 4. Business Audio
        final bzAudio = const StatusMedia(
          id: 'bz_aud_1',
          documentUri: 'content://biz/audio_1.opus',
          fileName: 'audio_1.opus',
          mediaType: MediaType.audio,
          mimeType: 'audio/ogg',
          size: 3000,
          lastModified: 800,
          whatsAppType: WhatsAppType.business,
        );
        await saveMediaUseCase(bzAudio);
        expect(statusRepo.lastSavedType, WhatsAppType.business);
        expect(
          savedDataSource.lastSavedCompanion?.whatsAppType.value,
          'business',
        );
      },
    );

    test(
      'SavedController filters statuses strictly by WhatsApp vs WhatsApp Business source',
      () async {
        SharedPreferences.setMockInitialValues({});
        Get.reset();
        await Get.putAsync<CashService>(() async => await CashService().init());
        final settings = Get.put(SettingsController());

        final items = [
          SavedMedia(
            id: 1,
            originalDocumentUri: 'content://wa/1.jpg',
            mediaStoreUri: 'content://media/1',
            relativePath: 'Download/Halati/WhatsApp/Halati Images/',
            fileName: '1.jpg',
            mediaType: MediaType.image,
            mimeType: 'image/jpeg',
            fileSize: 100,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: WhatsAppType.whatsapp,
          ),
          SavedMedia(
            id: 2,
            originalDocumentUri: 'content://wa/2.mp4',
            mediaStoreUri: 'content://media/2',
            relativePath: 'Download/Halati/WhatsApp/Halati Videos/',
            fileName: '2.mp4',
            mediaType: MediaType.video,
            mimeType: 'video/mp4',
            fileSize: 200,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: WhatsAppType.whatsapp,
          ),
          SavedMedia(
            id: 3,
            originalDocumentUri: 'content://wa/3.opus',
            mediaStoreUri: 'content://media/3',
            relativePath: 'Download/Halati/WhatsApp/Halati Audios/',
            fileName: '3.opus',
            mediaType: MediaType.audio,
            mimeType: 'audio/ogg',
            fileSize: 50,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: WhatsAppType.whatsapp,
          ),
          SavedMedia(
            id: 4,
            originalDocumentUri: 'content://biz/4.jpg',
            mediaStoreUri: 'content://media/4',
            relativePath: 'Download/Halati/WhatsApp Business/Halati Images/',
            fileName: '4.jpg',
            mediaType: MediaType.image,
            mimeType: 'image/jpeg',
            fileSize: 150,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: WhatsAppType.business,
          ),
          SavedMedia(
            id: 5,
            originalDocumentUri: 'content://biz/5.mp4',
            mediaStoreUri: 'content://media/5',
            relativePath: 'Download/Halati/WhatsApp Business/Halati Videos/',
            fileName: '5.mp4',
            mediaType: MediaType.video,
            mimeType: 'video/mp4',
            fileSize: 250,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: WhatsAppType.business,
          ),
          SavedMedia(
            id: 6,
            originalDocumentUri: 'content://biz/6.opus',
            mediaStoreUri: 'content://media/6',
            relativePath: 'Download/Halati/WhatsApp Business/Halati Audios/',
            fileName: '6.opus',
            mediaType: MediaType.audio,
            mimeType: 'audio/ogg',
            fileSize: 60,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: WhatsAppType.business,
          ),
        ];

        final controller = SavedController(
          getSavedMediaUseCase: GetSavedMediaUseCase(
            FakeSavedMediaRepository(),
          ),
          deleteSavedMediaUseCase: DeleteSavedMediaUseCase(
            FakeSavedMediaRepository(),
          ),
          getFullMediaFileUseCase: GetFullMediaFileUseCase(_DummyStatusRepo()),
          getThumbnailUseCase: GetThumbnailUseCase(_DummyStatusRepo()),
        );

        controller.allSavedItems.assignAll(items);

        // Default is WhatsApp: must only show WhatsApp items
        settings.setActiveWhatsAppType(WhatsAppType.whatsapp);
        expect(controller.filteredItems.length, 3);
        expect(
          controller.filteredItems.every(
            (it) => it.whatsAppType == WhatsAppType.whatsapp,
          ),
          true,
        );
        expect(
          controller.filteredItems.map((it) => it.id),
          containsAll([1, 2, 3]),
        );

        // Filter by video on WhatsApp
        controller.setFilter(MediaType.video);
        expect(controller.filteredItems.length, 1);
        expect(controller.filteredItems.first.id, 2);

        // Switch to WhatsApp Business
        controller.setFilter(null);
        settings.setActiveWhatsAppType(WhatsAppType.business);
        expect(controller.filteredItems.length, 3);
        expect(
          controller.filteredItems.every(
            (it) => it.whatsAppType == WhatsAppType.business,
          ),
          true,
        );
        expect(
          controller.filteredItems.map((it) => it.id),
          containsAll([4, 5, 6]),
        );

        // Filter by audio on WhatsApp Business
        controller.setFilter(MediaType.audio);
        expect(controller.filteredItems.length, 1);
        expect(controller.filteredItems.first.id, 6);
      },
    );

    test(
      'syncSavedMedia detects and purges files deleted externally from gallery or files',
      () async {
        final fakeLocal = _InMemorySavedDataSource();
        final fakeSaf = _FakeSafDataSource();
        final repo = SavedMediaRepositoryImpl(fakeLocal, fakeSaf);

        // Add 2 items: 1 regular WhatsApp, 1 WhatsApp Business
        await fakeLocal.insertSavedMedia(
          SavedMediaTableCompanion.insert(
            id: const Value(10),
            originalDocumentUri: 'content://wa/10.jpg',
            mediaStoreUri: 'content://media/10',
            relativePath: 'Download/Halati/WhatsApp/Halati Images/',
            fileName: '10.jpg',
            mediaType: 'image',
            mimeType: 'image/jpeg',
            fileSize: 100,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: const Value('whatsapp'),
          ),
        );
        await fakeLocal.insertSavedMedia(
          SavedMediaTableCompanion.insert(
            id: const Value(20),
            originalDocumentUri: 'content://biz/20.mp4',
            mediaStoreUri: 'content://media/20',
            relativePath: 'Download/Halati/WhatsApp Business/Halati Videos/',
            fileName: '20.mp4',
            mediaType: 'video',
            mimeType: 'video/mp4',
            fileSize: 200,
            savedAt: DateTime.now(),
            sourceCreatedAt: DateTime.now(),
            whatsAppType: const Value('business'),
          ),
        );

        expect((await fakeLocal.getSavedMedia()).length, 2);

        // Simulate external deletion of item 20 (Business video) in Gallery or Files
        fakeSaf.missingIds = ['20'];

        final syncResult = await repo.syncSavedMedia();
        expect(syncResult.isSuccess, true);
        expect(syncResult.dataOrNull, [20]);

        // Verify item 20 was purged from SQLite and only item 10 remains
        final remaining = await fakeLocal.getSavedMedia();
        expect(remaining.length, 1);
        expect(remaining.first.id, 10);
      },
    );
  });
}

class _RecordingStatusRepo extends _DummyStatusRepo {
  WhatsAppType? lastSavedType;

  @override
  Future<Result<Map<String, dynamic>, Failure>> saveMediaToGallery(
    StatusMedia media, {
    WhatsAppType? type,
  }) async {
    lastSavedType = type;
    final isBiz = type?.isBusiness ?? false;
    final appName = isBiz ? 'WhatsApp Business' : 'WhatsApp';
    return Success({
      'savedUri': 'content://media/external/downloads/1',
      'relativePath': 'Download/Halati/$appName/Halati Images/',
      'fileName': media.fileName,
    });
  }
}

class _RecordingSavedDataSource extends _DummySavedDataSource {
  SavedMediaTableCompanion? lastSavedCompanion;

  @override
  Future<int> insertSavedMedia(dynamic companion) async {
    if (companion is SavedMediaTableCompanion) {
      lastSavedCompanion = companion;
    }
    return 1;
  }
}

class _DummyStatusRepo implements StatusRepository {
  @override
  Future<Result<bool, Failure>> checkSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async => const Success(true);

  @override
  Future<Result<String, Failure>> requestSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async => const Success('uri');

  @override
  Future<Result<bool, Failure>> releaseSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async => const Success(true);

  @override
  Future<Result<List<StatusMedia>, Failure>> getStatuses({
    bool forceRefresh = false,
    WhatsAppType type = WhatsAppType.whatsapp,
  }) async => const Success([]);

  @override
  Future<Result<String, Failure>> getThumbnail(
    String documentUri, {
    int width = 300,
    int height = 300,
  }) async => const Success('');

  @override
  Future<Result<Map<String, dynamic>, Failure>> getMediaMetadata(
    String documentUri,
  ) async => const Success({});

  @override
  Future<Result<String, Failure>> getFullMediaFile(
    String documentUri,
    String fileName,
  ) async => const Success('');

  @override
  Future<Result<Map<String, dynamic>, Failure>> saveMediaToGallery(
    StatusMedia media, {
    WhatsAppType? type,
  }) async => const Success({});
}

class _DummySavedDataSource implements SavedMediaLocalDataSource {
  @override
  Future<int> deleteSavedMedia(int id) async => 1;

  @override
  Future<int> deleteSavedMediaByOriginalUri(String originalDocumentUri) async =>
      1;

  @override
  Future<List<SavedMediaModel>> getSavedMedia() async => [];

  @override
  Future<SavedMediaModel?> getSavedMediaByOriginalUri(
    String originalDocumentUri,
  ) async => null;

  @override
  Future<int> insertSavedMedia(dynamic companion) async => 1;

  @override
  Stream<List<SavedMediaModel>> watchSavedMedia() => Stream.value([]);
}

class _InMemorySavedDataSource implements SavedMediaLocalDataSource {
  final Map<int, SavedMediaModel> _storage = {};

  @override
  Future<int> deleteSavedMedia(int id) async {
    return _storage.remove(id) != null ? 1 : 0;
  }

  @override
  Future<int> deleteSavedMediaByOriginalUri(String originalDocumentUri) async {
    final entry = _storage.entries
        .where((e) => e.value.originalDocumentUri == originalDocumentUri)
        .firstOrNull;
    if (entry != null) {
      _storage.remove(entry.key);
      return 1;
    }
    return 0;
  }

  @override
  Future<List<SavedMediaModel>> getSavedMedia() async {
    return _storage.values.toList();
  }

  @override
  Future<SavedMediaModel?> getSavedMediaByOriginalUri(
    String originalDocumentUri,
  ) async {
    return _storage.values
        .where((e) => e.originalDocumentUri == originalDocumentUri)
        .firstOrNull;
  }

  @override
  Future<int> insertSavedMedia(dynamic companion) async {
    if (companion is SavedMediaTableCompanion) {
      final id = companion.id.present
          ? companion.id.value
          : _storage.length + 1;
      final type = companion.whatsAppType.present
          ? (companion.whatsAppType.value == 'business'
                ? WhatsAppType.business
                : WhatsAppType.whatsapp)
          : WhatsAppType.whatsapp;

      final model = SavedMediaModel(
        id: id,
        originalDocumentUri: companion.originalDocumentUri.value,
        mediaStoreUri: companion.mediaStoreUri.value,
        relativePath: companion.relativePath.value,
        fileName: companion.fileName.value,
        mediaType: companion.mediaType.value == 'video'
            ? MediaType.video
            : (companion.mediaType.value == 'audio'
                  ? MediaType.audio
                  : MediaType.image),
        mimeType: companion.mimeType.value,
        fileSize: companion.fileSize.value,
        savedAt: companion.savedAt.value,
        sourceCreatedAt: companion.sourceCreatedAt.value,
        whatsAppType: type,
      );
      _storage[id] = model;
      return id;
    }
    return 1;
  }

  @override
  Stream<List<SavedMediaModel>> watchSavedMedia() {
    return Stream.value(_storage.values.toList());
  }
}

class _FakeSafDataSource implements SafNativeDataSource {
  List<String> missingIds = [];

  @override
  Future<List<String>> checkMissingFiles(
    List<Map<String, String>> items,
  ) async {
    return missingIds;
  }

  @override
  Future<Map<String, dynamic>> checkDirectoryAccess(String? uri) async => {
    'granted': true,
    'accessible': true,
  };

  @override
  Future<Map<String, dynamic>> checkSaveFolderAccess(String? uri) async => {
    'granted': true,
    'accessible': true,
  };

  @override
  Future<Map<String, dynamic>?> requestCustomSaveFolder({
    String? initialUriHint,
  }) async => null;

  @override
  Future<String?> requestDirectorySelection({
    String? initialUriHint,
    bool isBusiness = false,
  }) async => null;

  @override
  Future<bool> releaseDirectoryAccess(String treeUri) async => true;

  @override
  Future<List<StatusMediaModel>> discoverStatuses(String treeUri) async => [];

  @override
  Future<String?> getThumbnail(
    String documentUri, {
    int width = 300,
    int height = 300,
  }) async => null;

  @override
  Future<Map<String, dynamic>> getMediaMetadata(String documentUri) async => {};

  @override
  Future<String?> getFullMediaFile(String documentUri, String fileName) async =>
      null;

  @override
  Future<Map<String, dynamic>> saveToMediaStore(
    String documentUri,
    String mediaType,
    String fileName, {
    bool isBusiness = false,
    String? customTreeUri,
  }) async => {};

  @override
  Future<bool> deleteFromMediaStore(String mediaStoreUri) async => true;
}
