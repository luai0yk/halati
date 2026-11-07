import 'package:flutter_test/flutter_test.dart';
import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/features/home/domain/repositories/status_repository.dart';
import 'package:halati/features/home/domain/usecases/check_saf_access_use_case.dart';
import 'package:halati/features/home/domain/usecases/get_statuses_use_case.dart';
import 'package:halati/features/home/domain/usecases/request_saf_access_use_case.dart';

class FakeStatusRepository implements StatusRepository {
  bool hasAccess = false;
  String? requestResultUri =
      'content://tree/primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
  List<StatusMedia> statuses = [];
  Failure? failure;
  WhatsAppType? lastRequestedType;

  @override
  Future<Result<bool, Failure>> checkSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    lastRequestedType = type;
    if (failure != null) return FailureResult(failure!);
    return Success(hasAccess);
  }

  @override
  Future<Result<String, Failure>> requestSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    lastRequestedType = type;
    if (failure != null) return FailureResult(failure!);
    if (requestResultUri == null) {
      return const FailureResult(SafPermissionDeniedFailure());
    }
    hasAccess = true;
    return Success(requestResultUri!);
  }

  @override
  Future<Result<bool, Failure>> releaseSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    lastRequestedType = type;
    hasAccess = false;
    return const Success(true);
  }

  @override
  Future<Result<List<StatusMedia>, Failure>> getStatuses({
    bool forceRefresh = false,
    WhatsAppType type = WhatsAppType.whatsapp,
  }) async {
    lastRequestedType = type;
    if (failure != null) return FailureResult(failure!);
    return Success(statuses);
  }

  @override
  Future<Result<String, Failure>> getThumbnail(
    String documentUri, {
    int width = 300,
    int height = 300,
  }) async {
    return const Success('/cache/thumb.jpg');
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> getMediaMetadata(
    String documentUri,
  ) async {
    return const Success({'durationMs': 10000});
  }

  @override
  Future<Result<String, Failure>> getFullMediaFile(
    String documentUri,
    String fileName,
  ) async {
    return const Success('/cache/full_media.jpg');
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> saveMediaToGallery(
    StatusMedia media, {
    WhatsAppType? type,
  }) async {
    return const Success({
      'savedUri': 'content://media/1',
      'relativePath': 'Pictures/Halati',
    });
  }
}

void main() {
  late FakeStatusRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeStatusRepository();
  });

  group('CheckSafAccessUseCase', () {
    test('returns true when SAF access is granted', () async {
      fakeRepo.hasAccess = true;
      final useCase = CheckSafAccessUseCase(fakeRepo);

      final result = await useCase();

      expect(result.isSuccess, true);
      expect(result.dataOrNull, true);
    });

    test('returns false when SAF access is not granted', () async {
      fakeRepo.hasAccess = false;
      final useCase = CheckSafAccessUseCase(fakeRepo);

      final result = await useCase();

      expect(result.isSuccess, true);
      expect(result.dataOrNull, false);
    });

    test('passes WhatsAppType to repository', () async {
      fakeRepo.hasAccess = true;
      final useCase = CheckSafAccessUseCase(fakeRepo);

      await useCase(WhatsAppType.business);

      expect(fakeRepo.lastRequestedType, WhatsAppType.business);
    });
  });

  group('RequestSafAccessUseCase', () {
    test('returns selected URI string on successful folder grant', () async {
      final useCase = RequestSafAccessUseCase(fakeRepo);

      final result = await useCase();

      expect(result.isSuccess, true);
      expect(result.dataOrNull, contains('com.whatsapp'));
    });

    test('returns failure when user cancels folder selection', () async {
      fakeRepo.requestResultUri = null;
      final useCase = RequestSafAccessUseCase(fakeRepo);

      final result = await useCase();

      expect(result.isFailure, true);
      expect(result.failureOrNull, isA<SafPermissionDeniedFailure>());
    });
  });

  group('GetStatusesUseCase', () {
    test('returns list of discovered statuses', () async {
      fakeRepo.statuses = [
        const StatusMedia(
          id: '1',
          documentUri: 'content://1',
          fileName: 'img.jpg',
          mediaType: MediaType.image,
          mimeType: 'image/jpeg',
          size: 1000,
          lastModified: 2000,
        ),
      ];

      final useCase = GetStatusesUseCase(fakeRepo);
      final result = await useCase();

      expect(result.isSuccess, true);
      expect(result.dataOrNull?.length, 1);
      expect(result.dataOrNull?.first.mediaType, MediaType.image);
    });
  });
}
