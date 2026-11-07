import 'package:drift/drift.dart';
import 'package:halati/core/database/app_database.dart';
import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/core/errors/failures.dart';
import 'package:halati/core/utils/result.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/features/home/domain/repositories/status_repository.dart';
import 'package:halati/features/saved/data/datasources/saved_media_local_data_source.dart';

class SaveMediaUseCase {
  final StatusRepository _statusRepository;
  final SavedMediaLocalDataSource _savedMediaDataSource;

  SaveMediaUseCase(this._statusRepository, this._savedMediaDataSource);

  Future<Result<String, Failure>> call(
    StatusMedia media, {
    WhatsAppType? type,
  }) async {
    final targetType = type ?? media.whatsAppType;
    final saveResult = await _statusRepository.saveMediaToGallery(
      media,
      type: targetType,
    );

    return saveResult.when(
      success: (data) async {
        final savedUri = data['savedUri'] as String? ?? '';
        final relativePath = data['relativePath'] as String? ?? '';
        final fileName = data['fileName'] as String? ?? media.fileName;

        try {
          await _savedMediaDataSource.insertSavedMedia(
            SavedMediaTableCompanion.insert(
              originalDocumentUri: media.documentUri,
              mediaStoreUri: savedUri,
              relativePath: relativePath,
              fileName: fileName,
              mediaType: media.mediaType.name,
              mimeType: media.mimeType,
              fileSize: media.size,
              durationMs: Value(media.durationMs),
              savedAt: DateTime.now(),
              sourceCreatedAt: DateTime.fromMillisecondsSinceEpoch(
                media.lastModified > 0
                    ? media.lastModified
                    : DateTime.now().millisecondsSinceEpoch,
              ),
              whatsAppType: Value(targetType.name),
            ),
          );
        } catch (_) {
          // Failure to write to SQLite does not invalidate the gallery write
        }

        return Success(savedUri);
      },
      failure: (f) => FailureResult(f),
    );
  }
}
