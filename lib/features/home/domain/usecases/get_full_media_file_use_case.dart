import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/home/domain/repositories/status_repository.dart';

class GetFullMediaFileUseCase {
  final StatusRepository _repository;

  GetFullMediaFileUseCase(this._repository);

  Future<Result<String, Failure>> call(
    String documentUri,
    String fileName,
  ) async {
    return await _repository.getFullMediaFile(documentUri, fileName);
  }
}
