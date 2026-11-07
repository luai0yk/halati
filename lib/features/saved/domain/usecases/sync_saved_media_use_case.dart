import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/saved/domain/repositories/saved_media_repository.dart';

class SyncSavedMediaUseCase {
  final SavedMediaRepository _repository;

  SyncSavedMediaUseCase(this._repository);

  Future<Result<List<int>, Failure>> call() {
    return _repository.syncSavedMedia();
  }
}
