import 'package:status_saver/core/database/app_database.dart';
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/features/saved/domain/entities/saved_media.dart';

class SavedMediaModel extends SavedMedia {
  const SavedMediaModel({
    required super.id,
    required super.originalDocumentUri,
    required super.mediaStoreUri,
    required super.relativePath,
    required super.fileName,
    required super.mediaType,
    required super.mimeType,
    required super.fileSize,
    super.durationMs,
    required super.savedAt,
    required super.sourceCreatedAt,
    super.whatsAppType,
  });

  factory SavedMediaModel.fromData(SavedMediaTableData data) {
    final mediaType = switch (data.mediaType.toLowerCase()) {
      'video' => MediaType.video,
      'audio' => MediaType.audio,
      _ => MediaType.image,
    };

    final decodedUri = Uri.decodeFull(data.originalDocumentUri).toLowerCase();
    final decodedRel = data.relativePath.toLowerCase();

    final isBusiness = data.whatsAppType == WhatsAppType.business.name ||
        decodedRel.contains('whatsapp business') ||
        decodedUri.contains('com.whatsapp.w4b') ||
        decodedUri.contains('whatsapp business') ||
        decodedUri.contains('w4b');

    final whatsAppType =
        isBusiness ? WhatsAppType.business : WhatsAppType.whatsapp;

    return SavedMediaModel(
      id: data.id,
      originalDocumentUri: data.originalDocumentUri,
      mediaStoreUri: data.mediaStoreUri,
      relativePath: data.relativePath,
      fileName: data.fileName,
      mediaType: mediaType,
      mimeType: data.mimeType,
      fileSize: data.fileSize,
      durationMs: data.durationMs,
      savedAt: data.savedAt,
      sourceCreatedAt: data.sourceCreatedAt,
      whatsAppType: whatsAppType,
    );
  }
}
