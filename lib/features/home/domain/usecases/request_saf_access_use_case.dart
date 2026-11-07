import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/home/domain/repositories/status_repository.dart';

class RequestSafAccessUseCase {
  final StatusRepository _repository;

  RequestSafAccessUseCase(this._repository);

  Future<Result<String, Failure>> call([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]) async {
    return await _repository.requestSafAccess(type);
  }
}
