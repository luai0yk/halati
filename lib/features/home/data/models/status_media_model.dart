import 'package:halati/core/enums/whatsapp_type.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';

class StatusMediaModel extends StatusMedia {
  const StatusMediaModel({
    required super.id,
    required super.documentUri,
    required super.fileName,
    required super.mediaType,
    required super.mimeType,
    required super.size,
    required super.lastModified,
    super.thumbnailPath,
    super.durationMs,
    super.whatsAppType,
  });

  factory StatusMediaModel.fromMap(
    Map<dynamic, dynamic> map, {
    WhatsAppType whatsAppType = WhatsAppType.whatsapp,
  }) {
    final mediaTypeString =
        (map['mediaType'] as String?)?.toLowerCase() ?? 'image';
    final mediaType = switch (mediaTypeString) {
      'video' => MediaType.video,
      'audio' => MediaType.audio,
      _ => MediaType.image,
    };

    final rawType = (map['whatsAppType'] as String?)?.toLowerCase();
    final resolvedType = rawType != null
        ? (rawType == 'business'
              ? WhatsAppType.business
              : WhatsAppType.whatsapp)
        : whatsAppType;

    return StatusMediaModel(
      id: (map['id'] ?? map['documentId'] ?? '') as String,
      documentUri: (map['documentUri'] ?? '') as String,
      fileName: (map['fileName'] ?? '') as String,
      mediaType: mediaType,
      mimeType: (map['mimeType'] ?? '') as String,
      size: (map['size'] as num?)?.toInt() ?? 0,
      lastModified: (map['lastModified'] as num?)?.toInt() ?? 0,
      thumbnailPath: map['thumbnailPath'] as String?,
      durationMs: (map['durationMs'] as num?)?.toInt(),
      whatsAppType: resolvedType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentUri': documentUri,
      'fileName': fileName,
      'mediaType': mediaType.name,
      'mimeType': mimeType,
      'size': size,
      'lastModified': lastModified,
      'thumbnailPath': thumbnailPath,
      'durationMs': durationMs,
      'whatsAppType': whatsAppType.name,
    };
  }
}
