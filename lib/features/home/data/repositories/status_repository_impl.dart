import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/services/cash/cash_keys.dart';
import 'package:status_saver/core/services/cash/cash_service.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/data/datasources/saf_native_data_source.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';

class StatusRepositoryImpl implements StatusRepository {
  final SafNativeDataSource _safDataSource;
  final CashService _cashService;

  final Map<WhatsAppType, List<StatusMedia>> _cachedStatuses = {};

  StatusRepositoryImpl({
    required SafNativeDataSource safDataSource,
    required CashService cashService,
  })  : _safDataSource = safDataSource,
        _cashService = cashService;

  String _safKey(WhatsAppType type) =>
      type.isBusiness ? CashKeys.safTreeUriBusiness : CashKeys.safTreeUri;

  @override
  Future<Result<bool, Failure>> checkSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    try {
      final storedUri = _cashService.getString(_safKey(type));
      if (storedUri == null || storedUri.isEmpty) {
        return const Success(false);
      }

      final access = await _safDataSource.checkDirectoryAccess(storedUri);
      final granted = access['granted'] == true;
      final accessible = access['accessible'] == true;

      return Success(granted && accessible);
    } on Failure catch (f) {
      return FailureResult(f);
    } catch (e) {
      return FailureResult(SafAccessRevokedFailure(e.toString()));
    }
  }

  @override
  Future<Result<String, Failure>> requestSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    try {
      final selectedUri = await _safDataSource.requestDirectorySelection(
        isBusiness: type.isBusiness,
      );
      if (selectedUri == null || selectedUri.isEmpty) {
        return const FailureResult(SafPermissionDeniedFailure());
      }

      await _cashService.setString(_safKey(type), selectedUri);
      _cachedStatuses.remove(type);
      return Success(selectedUri);
    } on Failure catch (f) {
      return FailureResult(f);
    } catch (e) {
      return FailureResult(SafFolderInvalidFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool, Failure>> releaseSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    try {
      final storedUri = _cashService.getString(_safKey(type));
      if (storedUri != null && storedUri.isNotEmpty) {
        await _safDataSource.releaseDirectoryAccess(storedUri);
        await _cashService.remove(_safKey(type));
      }
      _cachedStatuses.remove(type);
      return const Success(true);
    } catch (e) {
      return FailureResult(SafAccessRevokedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<StatusMedia>, Failure>> getStatuses({
    bool forceRefresh = false,
    WhatsAppType type = WhatsAppType.whatsapp,
  }) async {
    if (!forceRefresh && _cachedStatuses.containsKey(type) && _cachedStatuses[type] != null) {
      return Success(_cachedStatuses[type]!);
    }

    try {
      final storedUri = _cashService.getString(_safKey(type));
      if (storedUri == null || storedUri.isEmpty) {
        return const FailureResult(SafPermissionDeniedFailure('No SAF folder configured'));
      }

      final models = await _safDataSource.discoverStatuses(storedUri);
      final mapped = models.map((m) => m.copyWith(whatsAppType: type)).toList();
      _cachedStatuses[type] = mapped;
      return Success(mapped);
    } on Failure catch (f) {
      return FailureResult(f);
    } catch (e) {
      return FailureResult(MediaReadFailure(e.toString()));
    }
  }

  @override
  Future<Result<String, Failure>> getThumbnail(
    String documentUri, {
    int width = 300,
    int height = 300,
  }) async {
    try {
      final path = await _safDataSource.getThumbnail(
        documentUri,
        width: width,
        height: height,
      );
      if (path == null) {
        return const FailureResult(ThumbnailGenerationFailure());
      }
      return Success(path);
    } on Failure catch (f) {
      return FailureResult(f);
    } catch (e) {
      return FailureResult(ThumbnailGenerationFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> getMediaMetadata(String documentUri) async {
    try {
      final metadata = await _safDataSource.getMediaMetadata(documentUri);
      return Success(metadata);
    } on Failure catch (f) {
      return FailureResult(f);
    } catch (e) {
      return FailureResult(MediaReadFailure(e.toString()));
    }
  }

  @override
  Future<Result<String, Failure>> getFullMediaFile(String documentUri, String fileName) async {
    try {
      final path = await _safDataSource.getFullMediaFile(documentUri, fileName);
      if (path == null) {
        return const FailureResult(MediaReadFailure('Failed to load full media file'));
      }
      return Success(path);
    } on Failure catch (f) {
      return FailureResult(f);
    } catch (e) {
      return FailureResult(MediaReadFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> saveMediaToGallery(
    StatusMedia media, {
    WhatsAppType? type,
  }) async {
    try {
      final decodedUri = Uri.decodeFull(media.documentUri).toLowerCase();
      final isBusiness = (type ?? media.whatsAppType).isBusiness ||
          decodedUri.contains('com.whatsapp.w4b') ||
          decodedUri.contains('whatsapp business') ||
          decodedUri.contains('w4b');

      final customFolderKey = isBusiness
          ? CashKeys.saveFolderCustomUriBusiness
          : CashKeys.saveFolderCustomUri;
      final customTreeUri = _cashService.getString(customFolderKey);

      final result = await _safDataSource.saveToMediaStore(
        media.documentUri,
        media.mediaType.name,
        media.fileName,
        isBusiness: isBusiness,
        customTreeUri: customTreeUri,
      );
      return Success(result);
    } on Failure catch (f) {
      return FailureResult(f);
    } catch (e) {
      return FailureResult(MediaStoreSaveFailure(e.toString()));
    }
  }
}

