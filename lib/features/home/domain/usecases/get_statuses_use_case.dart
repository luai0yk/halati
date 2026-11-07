import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/features/home/domain/repositories/status_repository.dart';

class GetStatusesUseCase {
  final StatusRepository _repository;

  GetStatusesUseCase(this._repository);

  Future<Result<List<StatusMedia>, Failure>> call({
    bool forceRefresh = false,
    WhatsAppType type = WhatsAppType.whatsapp,
  }) async {
    return await _repository.getStatuses(
      forceRefresh: forceRefresh,
      type: type,
    );
  }
}
