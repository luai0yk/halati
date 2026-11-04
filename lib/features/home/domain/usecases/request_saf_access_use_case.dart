import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';

class RequestSafAccessUseCase {
  final StatusRepository _repository;

  RequestSafAccessUseCase(this._repository);

  Future<Result<String, Failure>> call([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    return await _repository.requestSafAccess(type);
  }
}
