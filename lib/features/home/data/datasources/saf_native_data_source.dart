import 'package:flutter/services.dart';
import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/platform/saf_channel.dart';
import 'package:status_saver/features/home/data/models/status_media_model.dart';

abstract class SafNativeDataSource {
  Future<Map<String, dynamic>> checkDirectoryAccess(String? uri);
  Future<Map<String, dynamic>> checkSaveFolderAccess(String? uri);
  Future<String?> requestDirectorySelection({String? initialUriHint, bool isBusiness = false});
  Future<Map<String, dynamic>?> requestCustomSaveFolder({String? initialUriHint});
  Future<bool> releaseDirectoryAccess(String uri);
  Future<List<StatusMediaModel>> discoverStatuses(String treeUri);
  Future<String?> getThumbnail(String documentUri, {int width = 300, int height = 300});
  Future<Map<String, dynamic>> getMediaMetadata(String documentUri);
  Future<String?> getFullMediaFile(String documentUri, String fileName);
  Future<Map<String, dynamic>> saveToMediaStore(
    String documentUri,
    String mediaType,
    String fileName, {
    bool isBusiness = false,
    String? customTreeUri,
  });
  Future<bool> deleteFromMediaStore(String mediaStoreUri);
  Future<List<String>> checkMissingFiles(List<Map<String, String>> items);
}

class SafNativeDataSourceImpl implements SafNativeDataSource {
  final MethodChannel _channel;

  SafNativeDataSourceImpl([MethodChannel? channel])
      : _channel = channel ?? const MethodChannel(SafChannel.channelName);

  @override
  Future<Map<String, dynamic>> checkDirectoryAccess(String? uri) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        SafChannel.checkDirectoryAccess,
        {'uri': uri},
      );
      if (result == null) {
        return {'granted': false, 'accessible': false};
      }
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw SafAccessRevokedFailure(e.message ?? 'Failed to check directory access', e.code);
    }
  }

  @override
  Future<Map<String, dynamic>> checkSaveFolderAccess(String? uri) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        SafChannel.checkSaveFolderAccess,
        {'uri': uri},
      );
      if (result == null) {
        return {'granted': false, 'accessible': false};
      }
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw SafAccessRevokedFailure(e.message ?? 'Failed to check save folder access', e.code);
    }
  }

  @override
  Future<String?> requestDirectorySelection({String? initialUriHint, bool isBusiness = false}) async {
    try {
      final result = await _channel.invokeMethod<String>(
        SafChannel.requestDirectorySelection,
        {
          'initialUriHint': initialUriHint,
          'isBusiness': isBusiness,
        },
      );
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'USER_CANCELLED') {
        throw SafPermissionDeniedFailure(e.message ?? 'User cancelled selection', e.code);
      }
      throw SafFolderInvalidFailure(e.message ?? 'Folder selection failed', e.code);
    }
  }

  @override
  Future<Map<String, dynamic>?> requestCustomSaveFolder({String? initialUriHint}) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        SafChannel.requestCustomSaveFolder,
        {'initialUriHint': initialUriHint},
      );
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      if (e.code == 'USER_CANCELLED') {
        throw SafPermissionDeniedFailure(e.message ?? 'User cancelled selection', e.code);
      }
      throw SafFolderInvalidFailure(e.message ?? 'Save folder selection failed', e.code);
    }
  }

  @override
  Future<bool> releaseDirectoryAccess(String uri) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        SafChannel.releaseDirectoryAccess,
        {'uri': uri},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<List<StatusMediaModel>> discoverStatuses(String treeUri) async {
    try {
      final result = await _channel.invokeListMethod<dynamic>(
        SafChannel.discoverStatuses,
        {'treeUri': treeUri},
      );

      if (result == null) {
        return [];
      }

      return result
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => StatusMediaModel.fromMap(item))
          .toList();
    } on PlatformException catch (e) {
      throw MediaReadFailure(e.message ?? 'Failed to discover statuses', e.code);
    }
  }

  @override
  Future<String?> getThumbnail(String documentUri, {int width = 300, int height = 300}) async {
    try {
      final result = await _channel.invokeMethod<String>(
        SafChannel.getThumbnail,
        {
          'documentUri': documentUri,
          'width': width,
          'height': height,
        },
      );
      return result;
    } on PlatformException catch (e) {
      throw ThumbnailGenerationFailure(e.message ?? 'Failed to get thumbnail', e.code);
    }
  }

  @override
  Future<Map<String, dynamic>> getMediaMetadata(String documentUri) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        SafChannel.getMediaMetadata,
        {'documentUri': documentUri},
      );
      if (result == null) {
        return {};
      }
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw MediaReadFailure(e.message ?? 'Failed to retrieve media metadata', e.code);
    }
  }

  @override
  Future<String?> getFullMediaFile(String documentUri, String fileName) async {
    try {
      final result = await _channel.invokeMethod<String>(
        SafChannel.getFullMediaFile,
        {
          'documentUri': documentUri,
          'fileName': fileName,
        },
      );
      return result;
    } on PlatformException catch (e) {
      throw MediaReadFailure(e.message ?? 'Failed to get full media file', e.code);
    }
  }

  @override
  Future<Map<String, dynamic>> saveToMediaStore(
    String documentUri,
    String mediaType,
    String fileName, {
    bool isBusiness = false,
    String? customTreeUri,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        SafChannel.saveToMediaStore,
        {
          'documentUri': documentUri,
          'mediaType': mediaType,
          'fileName': fileName,
          'isBusiness': isBusiness,
          'customTreeUri': customTreeUri,
        },
      );
      if (result == null) {
        throw const MediaStoreSaveFailure('Native save returned null');
      }
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw MediaStoreSaveFailure(e.message ?? 'Failed to save to gallery', e.code);
    }
  }

  @override
  Future<bool> deleteFromMediaStore(String mediaStoreUri) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        SafChannel.deleteFromMediaStore,
        {'mediaStoreUri': mediaStoreUri},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw MediaStoreSaveFailure(e.message ?? 'Failed to delete file', e.code);
    }
  }

  @override
  Future<List<String>> checkMissingFiles(List<Map<String, String>> items) async {
    try {
      final result = await _channel.invokeListMethod<dynamic>(
        SafChannel.checkMissingFiles,
        {'items': items},
      );
      if (result == null) return [];
      return result.map((e) => e.toString()).toList();
    } on PlatformException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }
}
