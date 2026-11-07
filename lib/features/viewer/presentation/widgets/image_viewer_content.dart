import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerContent extends StatefulWidget {
  final String? filePath;
  final String? thumbnailPath;

  const ImageViewerContent({super.key, this.filePath, this.thumbnailPath});

  @override
  State<ImageViewerContent> createState() => _ImageViewerContentState();
}

class _ImageViewerContentState extends State<ImageViewerContent> {
  ImageStream? _imageStream;
  ImageStreamListener? _streamListener;
  bool _isFullLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkFullImage();
  }

  @override
  void didUpdateWidget(covariant ImageViewerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath) {
      _checkFullImage();
    }
  }

  void _checkFullImage() {
    if (widget.filePath == null || widget.filePath!.isEmpty) {
      _isFullLoaded = false;
      return;
    }

    _stopListening();

    final provider = FileImage(File(widget.filePath!));
    final stream = provider.resolve(ImageConfiguration.empty);
    _imageStream = stream;

    _streamListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!mounted) return;
        if (synchronousCall) {
          _isFullLoaded = true;
        } else {
          setState(() {
            _isFullLoaded = true;
          });
        }
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        if (!mounted) return;
        setState(() {
          _isFullLoaded = false;
        });
      },
    );

    stream.addListener(_streamListener!);
  }

  void _stopListening() {
    if (_imageStream != null && _streamListener != null) {
      _imageStream!.removeListener(_streamListener!);
    }
    _imageStream = null;
    _streamListener = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasThumbnail =
        widget.thumbnailPath != null && widget.thumbnailPath!.isNotEmpty;
    final hasFilePath = widget.filePath != null && widget.filePath!.isNotEmpty;

    if (!hasThumbnail && !hasFilePath) {
      return const Center(child: MyProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Instant low-res thumbnail layer (frame 0)
        if (hasThumbnail)
          Center(
            child: Image.file(
              File(widget.thumbnailPath!),
              fit: BoxFit.contain,
              cacheWidth: 400,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),

        // 2. Full-resolution PhotoView with smooth cross-fade once decoded
        if (hasFilePath)
          IgnorePointer(
            ignoring: !_isFullLoaded,
            child: AnimatedOpacity(
              opacity: _isFullLoaded ? 1.0 : 0.0,
              duration: AppDurations.fast,
              curve: Curves.easeOutCubic,
              child: PhotoView(
                imageProvider: FileImage(File(widget.filePath!)),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
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
              ),
            ),
          ),

        // 3. Fallback spinner only if no thumbnail and full image is still loading
        if (!hasThumbnail && !_isFullLoaded)
          const Center(child: MyProgressIndicator()),
      ],
    );
  }
}
