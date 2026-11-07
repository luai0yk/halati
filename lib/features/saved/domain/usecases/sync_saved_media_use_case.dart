import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/saved/domain/repositories/saved_media_repository.dart';

class SyncSavedMediaUseCase {
  final SavedMediaRepository _repository;

  SyncSavedMediaUseCase(this._repository);

  Future<Result<List<int>, Failure>> call() {
    return _repository.syncSavedMedia();
  }
}
