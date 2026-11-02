import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';

class GetThumbnailUseCase {
  final StatusRepository _repository;

  GetThumbnailUseCase(this._repository);

  Future<Result<String, Failure>> call(String documentUri, {int width = 300, int height = 300}) async {
    return await _repository.getThumbnail(documentUri, width: width, height: height);
  }
}
