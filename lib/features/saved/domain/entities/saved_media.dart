import 'package:flutter/foundation.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';

@immutable
class SavedMedia {
  final int id;
  final String originalDocumentUri;
  final String mediaStoreUri;
  final String relativePath;
  final String fileName;
  final MediaType mediaType;
  final String mimeType;
  final int fileSize;
  final int? durationMs;
  final DateTime savedAt;
  final DateTime sourceCreatedAt;

  const SavedMedia({
    required this.id,
    required this.originalDocumentUri,
    required this.mediaStoreUri,
    required this.relativePath,
    required this.fileName,
    required this.mediaType,
    required this.mimeType,
    required this.fileSize,
    this.durationMs,
    required this.savedAt,
    required this.sourceCreatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMedia &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
