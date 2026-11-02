import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';

class GetFullMediaFileUseCase {
  final StatusRepository _repository;

  GetFullMediaFileUseCase(this._repository);

  Future<Result<String, Failure>> call(String documentUri, String fileName) async {
    return await _repository.getFullMediaFile(documentUri, fileName);
  }
}
