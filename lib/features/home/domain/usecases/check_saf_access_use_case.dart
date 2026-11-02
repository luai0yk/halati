import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';

class CheckSafAccessUseCase {
  final StatusRepository _repository;

  CheckSafAccessUseCase(this._repository);

  Future<Result<bool, Failure>> call() async {
    return await _repository.checkSafAccess();
  }
}
