import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerContent extends StatelessWidget {
  final String? filePath;
  final String? thumbnailPath;

  const ImageViewerContent({super.key, this.filePath, this.thumbnailPath});

  @override
  Widget build(BuildContext context) {
    final hasThumbnail = thumbnailPath != null && thumbnailPath!.isNotEmpty;
    final hasFilePath = filePath != null && filePath!.isNotEmpty;

    if (!hasThumbnail && !hasFilePath) {
      return const Center(child: MyProgressIndicator());
    }

    if (hasFilePath) {
      return PhotoView(
        imageProvider: FileImage(File(filePath!)),
        loadingBuilder: (context, event) {
          if (hasThumbnail) {
            return Center(
              child: Image.file(
                File(thumbnailPath!),
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            );
          }
          return const Center(child: MyProgressIndicator());
        },
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        gaplessPlayback: true,
        errorBuilder: (ctx, err, stack) => Center(
          child: MyIcon(
            icon: AppIcons.imageNotSupported,
            size: context.setSize(40),
            color: Colors.white54,
          ),
        ),
      );
    }

    // Frame-0 instant rendering: display the thumbnail with zero delay while full file resolves
    return Center(
      child: Image.file(
        File(thumbnailPath!),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: MyProgressIndicator()),
      ),
    );
  }
}
