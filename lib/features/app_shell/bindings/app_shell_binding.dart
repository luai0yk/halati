import 'package:get/get.dart';
import 'package:status_saver/core/database/app_database.dart';
import 'package:status_saver/core/services/cash/cash_service.dart';
import 'package:status_saver/features/app_shell/controller/app_shell_controller.dart';
import 'package:status_saver/features/home/data/datasources/saf_native_data_source.dart';
import 'package:status_saver/features/home/data/repositories/status_repository_impl.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';
import 'package:status_saver/features/home/domain/usecases/check_saf_access_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_full_media_file_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_statuses_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/get_thumbnail_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/request_saf_access_use_case.dart';
import 'package:status_saver/features/home/domain/usecases/save_media_use_case.dart';
import 'package:status_saver/features/home/presentation/controllers/home_controller.dart';
import 'package:status_saver/features/saved/data/datasources/saved_media_local_data_source.dart';
import 'package:status_saver/features/saved/data/repositories/saved_media_repository_impl.dart';
import 'package:status_saver/features/saved/domain/repositories/saved_media_repository.dart';
import 'package:status_saver/features/saved/domain/usecases/delete_saved_media_use_case.dart';
import 'package:status_saver/features/saved/domain/usecases/get_saved_media_use_case.dart';
import 'package:status_saver/features/saved/domain/usecases/sync_saved_media_use_case.dart';
import 'package:status_saver/features/saved/presentation/controllers/saved_controller.dart';

class AppShellBinding extends Bindings {
  @override
  void dependencies() {
    // Database
    if (!Get.isRegistered<AppDatabase>()) {
      Get.lazyPut<AppDatabase>(() => AppDatabase(), fenix: true);
    }

    // Native Data Source
    Get.lazyPut<SafNativeDataSource>(
      () => SafNativeDataSourceImpl(),
      fenix: true,
    );

    // Saved Data Source & Repo
    Get.lazyPut<SavedMediaLocalDataSource>(
      () => SavedMediaLocalDataSourceImpl(Get.find<AppDatabase>()),
      fenix: true,
    );
    Get.lazyPut<SavedMediaRepository>(
      () => SavedMediaRepositoryImpl(
        Get.find<SavedMediaLocalDataSource>(),
        Get.find<SafNativeDataSource>(),
      ),
      fenix: true,
    );

    // Status Repository
    Get.lazyPut<StatusRepository>(
      () => StatusRepositoryImpl(
        safDataSource: Get.find<SafNativeDataSource>(),
        cashService: Get.find<CashService>(),
      ),
      fenix: true,
    );

    // Use cases
    Get.lazyPut<CheckSafAccessUseCase>(
      () => CheckSafAccessUseCase(Get.find<StatusRepository>()),
      fenix: true,
    );
    Get.lazyPut<RequestSafAccessUseCase>(
      () => RequestSafAccessUseCase(Get.find<StatusRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetStatusesUseCase>(
      () => GetStatusesUseCase(Get.find<StatusRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetThumbnailUseCase>(
      () => GetThumbnailUseCase(Get.find<StatusRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetFullMediaFileUseCase>(
      () => GetFullMediaFileUseCase(Get.find<StatusRepository>()),
      fenix: true,
    );
    Get.lazyPut<SaveMediaUseCase>(
      () => SaveMediaUseCase(
        Get.find<StatusRepository>(),
        Get.find<SavedMediaLocalDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<GetSavedMediaUseCase>(
      () => GetSavedMediaUseCase(Get.find<SavedMediaRepository>()),
      fenix: true,
    );
    Get.lazyPut<DeleteSavedMediaUseCase>(
      () => DeleteSavedMediaUseCase(Get.find<SavedMediaRepository>()),
      fenix: true,
    );
    Get.lazyPut<SyncSavedMediaUseCase>(
      () => SyncSavedMediaUseCase(Get.find<SavedMediaRepository>()),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<HomeController>(
      () => HomeController(
        checkSafAccessUseCase: Get.find<CheckSafAccessUseCase>(),
        requestSafAccessUseCase: Get.find<RequestSafAccessUseCase>(),
        getStatusesUseCase: Get.find<GetStatusesUseCase>(),
        getThumbnailUseCase: Get.find<GetThumbnailUseCase>(),
        getFullMediaFileUseCase: Get.find<GetFullMediaFileUseCase>(),
        saveMediaUseCase: Get.find<SaveMediaUseCase>(),
        getSavedMediaUseCase: Get.find<GetSavedMediaUseCase>(),
        deleteSavedMediaUseCase: Get.find<DeleteSavedMediaUseCase>(),
        syncSavedMediaUseCase: Get.find<SyncSavedMediaUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SavedController>(
      () => SavedController(
        getSavedMediaUseCase: Get.find<GetSavedMediaUseCase>(),
        deleteSavedMediaUseCase: Get.find<DeleteSavedMediaUseCase>(),
        getFullMediaFileUseCase: Get.find<GetFullMediaFileUseCase>(),
        getThumbnailUseCase: Get.find<GetThumbnailUseCase>(),
        syncSavedMediaUseCase: Get.find<SyncSavedMediaUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AppShellController>(
      () => AppShellController(),
      fenix: true,
    );
  }
}
