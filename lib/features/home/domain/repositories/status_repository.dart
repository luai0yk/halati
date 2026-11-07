import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';

abstract class StatusRepository {
  Future<Result<bool, Failure>> checkSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]);
  Future<Result<String, Failure>> requestSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]);
  Future<Result<bool, Failure>> releaseSafAccess([
    WhatsAppType type = WhatsAppType.whatsapp,
  ]);
  Future<Result<List<StatusMedia>, Failure>> getStatuses({
    bool forceRefresh = false,
    WhatsAppType type = WhatsAppType.whatsapp,
  });
  Future<Result<String, Failure>> getThumbnail(
    String documentUri, {
    int width = 300,
    int height = 300,
  });
  Future<Result<Map<String, dynamic>, Failure>> getMediaMetadata(
    String documentUri,
  );
  Future<Result<String, Failure>> getFullMediaFile(
    String documentUri,
    String fileName,
  );
  Future<Result<Map<String, dynamic>, Failure>> saveMediaToGallery(
    StatusMedia media, {
    WhatsAppType? type,
  });
}
