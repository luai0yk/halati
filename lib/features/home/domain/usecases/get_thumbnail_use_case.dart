import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/home/domain/repositories/status_repository.dart';

class GetThumbnailUseCase {
  final StatusRepository _repository;

  GetThumbnailUseCase(this._repository);

  Future<Result<String, Failure>> call(
    String documentUri, {
    int width = 300,
    int height = 300,
  }) async {
    return await _repository.getThumbnail(
      documentUri,
      width: width,
      height: height,
    );
  }
}
