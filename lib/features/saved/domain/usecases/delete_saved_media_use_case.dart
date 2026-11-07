import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/saved/domain/repositories/saved_media_repository.dart';

class DeleteSavedMediaUseCase {
  final SavedMediaRepository _repository;

  DeleteSavedMediaUseCase(this._repository);

  Future<Result<bool, Failure>> call(int id, {String? mediaStoreUri}) {
    return _repository.deleteSavedMedia(id, mediaStoreUri: mediaStoreUri);
  }

  Future<Result<bool, Failure>> deleteByOriginalUri(
    String originalDocumentUri,
  ) {
    return _repository.deleteSavedMediaByOriginalUri(originalDocumentUri);
  }
}
