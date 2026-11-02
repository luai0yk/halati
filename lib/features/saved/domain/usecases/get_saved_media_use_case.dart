import 'package:status_saver/features/saved/domain/entities/saved_media.dart';
import 'package:status_saver/features/saved/domain/repositories/saved_media_repository.dart';

class GetSavedMediaUseCase {
  final SavedMediaRepository _repository;

  GetSavedMediaUseCase(this._repository);

  Stream<List<SavedMedia>> watch() {
    return _repository.watchSavedMedia();
  }
}
