import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';

abstract class SavedMediaRepository {
  Stream<List<SavedMedia>> watchSavedMedia();
  Future<Result<List<SavedMedia>, Failure>> getSavedMedia();
  Future<Result<bool, Failure>> deleteSavedMedia(int id, {String? mediaStoreUri});
  Future<Result<bool, Failure>> deleteSavedMediaByOriginalUri(String originalDocumentUri);
  Future<Result<List<int>, Failure>> syncSavedMedia();
}
