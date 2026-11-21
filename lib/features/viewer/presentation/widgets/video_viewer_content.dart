import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';
import 'package:halati/shared/widgets/misc/my_progress_indicator.dart';
import 'package:video_player/video_player.dart';

class VideoViewerContent extends StatefulWidget {
  final String filePath;
  final String? thumbnailPath;
  final bool isActive;

  const VideoViewerContent({
    super.key,
    required this.filePath,
    this.thumbnailPath,
    required this.isActive,
  });

  @override
  State<VideoViewerContent> createState() => _VideoViewerContentState();
}

class _VideoViewerContentState extends State<VideoViewerContent> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initVideoController();
    }
  }

  @override
  void didUpdateWidget(covariant VideoViewerContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filePath != oldWidget.filePath) {
      _disposeController();
      if (widget.isActive) {
        _initVideoController();
      }
    } else if (widget.isActive && !oldWidget.isActive) {
      if (_videoController == null) {
        _initVideoController();
      } else if (_isInitialized) {
        _videoController?.play();
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposeController();
    }
  }

  Future<void> _initVideoController() async {
    _disposeController();

    final controller = VideoPlayerController.file(File(widget.filePath));
    _videoController = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      if (mounted && widget.isActive) {
        setState(() {
          _isInitialized = true;
        });
        controller.play();
      } else {
        // If no longer active while initializing, release decoder immediately
        controller.dispose();
        if (identical(_videoController, controller)) {
          _videoController = null;
          _isInitialized = false;
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _disposeController() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || !_isInitialized || _videoController == null) {
      if (widget.thumbnailPath != null && widget.thumbnailPath!.isNotEmpty) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Image.file(
                File(widget.thumbnailPath!),
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
            if (widget.isActive)
              const Center(child: MyProgressIndicator())
            else
              Center(
                child: Container(
                  padding: EdgeInsets.all(context.spaceL),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: MyIcon(
                    icon: AppIcons.play,
                    color: Colors.white,
                    size: context.setSize(36),
                  ),
                ),
              ),
          ],
        );
      }
      return const Center(child: MyProgressIndicator());
    }

    final controller = _videoController!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),

        // Center Play/Pause tap button with fine-grained reactivity
        Center(
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final isPlaying = value.isPlaying;
              return AnimatedOpacity(
                opacity: isPlaying ? 0.0 : 1.0,
                duration: AppDurations.fast,
                child: GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(context.spaceL),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: MyIcon(
                      icon: isPlaying ? AppIcons.pause : AppIcons.play,
                      color: Colors.white,
                      size: context.setSize(36),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Video duration pill with fine-grained reactivity
        PositionedDirectional(
          bottom: context.setSize(95),
          start: context.spaceL,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spaceS,
                  vertical: context.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(context.radiusS),
                ),
                child: Text(
                  '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
