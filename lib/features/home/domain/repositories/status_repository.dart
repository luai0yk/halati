import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';

abstract class StatusRepository {
  Future<Result<bool, Failure>> checkSafAccess();
  Future<Result<String, Failure>> requestSafAccess();
  Future<Result<bool, Failure>> releaseSafAccess();
  Future<Result<List<StatusMedia>, Failure>> getStatuses({bool forceRefresh = false});
  Future<Result<String, Failure>> getThumbnail(String documentUri, {int width = 300, int height = 300});
  Future<Result<Map<String, dynamic>, Failure>> getMediaMetadata(String documentUri);
  Future<Result<String, Failure>> getFullMediaFile(String documentUri, String fileName);
  Future<Result<Map<String, dynamic>, Failure>> saveMediaToGallery(StatusMedia media);
}
