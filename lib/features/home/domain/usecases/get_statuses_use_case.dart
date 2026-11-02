import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';

class GetStatusesUseCase {
  final StatusRepository _repository;

  GetStatusesUseCase(this._repository);

  Future<Result<List<StatusMedia>, Failure>> call({bool forceRefresh = false}) async {
    return await _repository.getStatuses(forceRefresh: forceRefresh);
  }
}
