import 'package:flutter/foundation.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';

@immutable
class MediaViewerItem {
  final String id;
  final String uri;
  final String fileName;
  final MediaType mediaType;
  final String? thumbnailPath;
  final int? durationMs;
  final bool isSaved;
  final dynamic originalObject;

  const MediaViewerItem({
    required this.id,
    required this.uri,
    required this.fileName,
    required this.mediaType,
    this.thumbnailPath,
    this.durationMs,
    this.isSaved = false,
    this.originalObject,
  });

  MediaViewerItem copyWith({
    String? id,
    String? uri,
    String? fileName,
    MediaType? mediaType,
    String? thumbnailPath,
    int? durationMs,
    bool? isSaved,
    dynamic originalObject,
  }) {
    return MediaViewerItem(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      fileName: fileName ?? this.fileName,
      mediaType: mediaType ?? this.mediaType,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationMs: durationMs ?? this.durationMs,
      isSaved: isSaved ?? this.isSaved,
      originalObject: originalObject ?? this.originalObject,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaViewerItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
