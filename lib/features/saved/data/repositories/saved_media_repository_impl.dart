import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/data/datasources/saf_native_data_source.dart';
import 'package:status_saver/features/saved/data/datasources/saved_media_local_data_source.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';
import 'package:status_saver/features/saved/domain/repositories/saved_media_repository.dart';

class SavedMediaRepositoryImpl implements SavedMediaRepository {
  final SavedMediaLocalDataSource _dataSource;
  final SafNativeDataSource _safDataSource;

  SavedMediaRepositoryImpl(this._dataSource, this._safDataSource);

  @override
  Stream<List<SavedMedia>> watchSavedMedia() {
    return _dataSource.watchSavedMedia();
  }

  @override
  Future<Result<List<SavedMedia>, Failure>> getSavedMedia() async {
    try {
      final items = await _dataSource.getSavedMedia();
      return Success(items);
    } catch (e) {
      return FailureResult(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool, Failure>> deleteSavedMedia(int id, {String? mediaStoreUri}) async {
    try {
      if (mediaStoreUri != null && mediaStoreUri.isNotEmpty) {
        try {
          await _safDataSource.deleteFromMediaStore(mediaStoreUri);
        } catch (_) {}
      }
      final rowsDeleted = await _dataSource.deleteSavedMedia(id);
      return Success(rowsDeleted > 0);
    } catch (e) {
      return FailureResult(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool, Failure>> deleteSavedMediaByOriginalUri(String originalDocumentUri) async {
    try {
      final savedItem = await _dataSource.getSavedMediaByOriginalUri(originalDocumentUri);
      if (savedItem != null) {
        if (savedItem.mediaStoreUri.isNotEmpty) {
          try {
            await _safDataSource.deleteFromMediaStore(savedItem.mediaStoreUri);
          } catch (_) {}
        }
        final rowsDeleted = await _dataSource.deleteSavedMedia(savedItem.id);
        return Success(rowsDeleted > 0);
      }
      return const Success(false);
    } catch (e) {
      return FailureResult(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<int>, Failure>> syncSavedMedia() async {
    try {
      final items = await _dataSource.getSavedMedia();
      if (items.isEmpty) {
        return const Success([]);
      }

      final payload = items
          .map((item) => {
                'id': item.id.toString(),
                'uri': item.mediaStoreUri,
                'relativePath': item.relativePath,
                'fileName': item.fileName,
              })
          .toList();

      final missingIdStrings = await _safDataSource.checkMissingFiles(payload);
      final prunedIds = <int>[];

      for (final idStr in missingIdStrings) {
        final id = int.tryParse(idStr);
        if (id != null) {
          await _dataSource.deleteSavedMedia(id);
          prunedIds.add(id);
        }
      }

      return Success(prunedIds);
    } catch (e) {
      return FailureResult(DatabaseFailure(e.toString()));
    }
  }
}
