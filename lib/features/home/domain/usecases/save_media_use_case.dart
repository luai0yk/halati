import 'package:drift/drift.dart';
import 'package:status_saver/core/database/app_database.dart';
import 'package:status_saver/core/errors/failures.dart';
import 'package:status_saver/core/utils/result.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/home/domain/repositories/status_repository.dart';
import 'package:status_saver/features/saved/data/datasources/saved_media_local_data_source.dart';

class SaveMediaUseCase {
  final StatusRepository _statusRepository;
  final SavedMediaLocalDataSource _savedMediaDataSource;

  SaveMediaUseCase(this._statusRepository, this._savedMediaDataSource);

  Future<Result<String, Failure>> call(StatusMedia media) async {
    final saveResult = await _statusRepository.saveMediaToGallery(media);

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
                media.lastModified > 0 ? media.lastModified : DateTime.now().millisecondsSinceEpoch,
              ),
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
