import 'package:flutter/foundation.dart';
import 'package:halati/core/enums/whatsapp_type.dart';

enum MediaType { image, video, audio }

@immutable
class StatusMedia {
  final String id;
  final String documentUri;
  final String fileName;
  final MediaType mediaType;
  final String mimeType;
  final int size;
  final int lastModified;
  final String? thumbnailPath;
  final int? durationMs;
  final WhatsAppType whatsAppType;

  const StatusMedia({
    required this.id,
    required this.documentUri,
    required this.fileName,
    required this.mediaType,
    required this.mimeType,
    required this.size,
    required this.lastModified,
    this.thumbnailPath,
    this.durationMs,
    this.whatsAppType = WhatsAppType.whatsapp,
  });

  StatusMedia copyWith({
    String? id,
    String? documentUri,
    String? fileName,
    MediaType? mediaType,
    String? mimeType,
    int? size,
    int? lastModified,
    String? thumbnailPath,
    int? durationMs,
    WhatsAppType? whatsAppType,
  }) {
    return StatusMedia(
      id: id ?? this.id,
      documentUri: documentUri ?? this.documentUri,
      fileName: fileName ?? this.fileName,
      mediaType: mediaType ?? this.mediaType,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      lastModified: lastModified ?? this.lastModified,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationMs: durationMs ?? this.durationMs,
      whatsAppType: whatsAppType ?? this.whatsAppType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusMedia &&
          runtimeType == other.runtimeType &&
          documentUri == other.documentUri;

  @override
  int get hashCode => documentUri.hashCode;
}
