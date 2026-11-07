import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/features/viewer/data/models/media_viewer_item.dart';
import 'package:halati/features/viewer/presentation/widgets/audio_viewer_content.dart';
import 'package:halati/features/viewer/presentation/widgets/image_viewer_content.dart';
import 'package:halati/features/viewer/presentation/widgets/video_viewer_content.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';

class MediaViewerContent extends StatelessWidget {
  final MediaViewerItem item;
  final String? filePath;
  final String? thumbnailPath;
  final bool isActive;

  const MediaViewerContent({
    super.key,
    required this.item,
    required this.filePath,
    this.thumbnailPath,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    switch (item.mediaType) {
      case MediaType.image:
        return ImageViewerContent(
          filePath: filePath,
          thumbnailPath: thumbnailPath,
        );

      case MediaType.video:
        if (filePath != null && filePath!.isNotEmpty) {
          return VideoViewerContent(
            filePath: filePath!,
            thumbnailPath: thumbnailPath,
            isActive: isActive,
          );
        } else if (thumbnailPath != null && thumbnailPath!.isNotEmpty) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Image.file(File(thumbnailPath!), fit: BoxFit.contain),
              ),
              const Center(child: MyProgressIndicator()),
            ],
          );
        } else {
          return const Center(child: MyProgressIndicator());
        }

      case MediaType.audio:
        if (filePath != null && filePath!.isNotEmpty) {
          return AudioViewerContent(
            filePath: filePath!,
            fileName: item.fileName,
            isActive: isActive,
          );
        } else {
          return const Center(child: MyProgressIndicator());
        }
    }
  }
}
