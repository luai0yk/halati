import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/saved/domain/entities/saved_media.dart';

abstract class SavedMediaRepository {
  Stream<List<SavedMedia>> watchSavedMedia();
  Future<Result<List<SavedMedia>, Failure>> getSavedMedia();
  Future<Result<bool, Failure>> deleteSavedMedia(
    int id, {
    String? mediaStoreUri,
  });
  Future<Result<bool, Failure>> deleteSavedMediaByOriginalUri(
    String originalDocumentUri,
  );
  Future<Result<List<int>, Failure>> syncSavedMedia();
}
