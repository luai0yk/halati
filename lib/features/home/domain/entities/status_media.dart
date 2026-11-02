import 'package:flutter/foundation.dart';

enum MediaType {
  image,
  video,
  audio,
}

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
