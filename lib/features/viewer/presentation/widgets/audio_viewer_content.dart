import 'dart:io';

import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/shared/widgets/buttons/my_icon_button.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';
import 'package:video_player/video_player.dart';

class AudioViewerContent extends StatefulWidget {
  final String filePath;
  final String fileName;
  final bool isActive;

  const AudioViewerContent({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.isActive,
  });

  @override
  State<AudioViewerContent> createState() => _AudioViewerContentState();
}

class _AudioViewerContentState extends State<AudioViewerContent> {
  VideoPlayerController? _audioController;

  @override
  void initState() {
    super.initState();
    _initAudioController();
  }

  @override
  void didUpdateWidget(covariant AudioViewerContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filePath != oldWidget.filePath) {
      _initAudioController();
    } else {
      if (!widget.isActive && oldWidget.isActive) {
        _audioController?.pause();
      } else if (widget.isActive && !oldWidget.isActive) {
        if (_audioController != null && _audioController!.value.isInitialized) {
          if (_audioController!.value.position >=
              _audioController!.value.duration) {
            _audioController!.seekTo(Duration.zero);
          }
          _audioController!.play();
        }
      }
    }
  }

  Future<void> _initAudioController() async {
    _audioController?.dispose();
    _audioController = null;

    final controller = VideoPlayerController.file(File(widget.filePath));
    _audioController = controller;

    controller.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await controller.initialize();
      controller.setLooping(false);
      if (mounted) {
        // Auto-play when active upon initialization
        if (widget.isActive) {
          await controller.play();
        }
        setState(() {});
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _audioController?.pause();
    _audioController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _audioController;
    final isPlaying = controller?.value.isPlaying ?? false;
    final position = controller?.value.position ?? Duration.zero;
    final duration = controller?.value.duration ?? Duration.zero;

    return Center(
      child: SingleChildScrollView(
        padding: context.insetsAllXl,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.setSize(300),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero Artwork matching the item in the grid with gradient & waveform
              AspectRatio(
                aspectRatio: 1.0,
                child: MyCard.filled(
                  padding: context.insetsAllM,
                  borderRadius: BorderRadius.circular(context.radiusXl),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorScheme.primaryContainer
                          .withValues(alpha: 0.8),
                      context.colorScheme.secondaryContainer
                          .withValues(alpha: 0.9),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyCard.filled(
                        padding: context.insetsAllM,
                        color:
                            context.colorScheme.surface.withValues(alpha: 0.2),
                        borderRadius: context.brCircular,
                        child: MyIcon(
                          icon: AppIcons.waveform,
                          size: context.setSize(48),
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(height: context.spaceS),
                      Padding(
                        padding: context.insetsHorizontalS,
                        child: Text(
                          widget.fileName,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.spaceL),

              // Seek slider and duration indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDuration(position),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: context.setSize(4),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: context.setSize(6),
                        ),
                        activeTrackColor: context.colorScheme.primary,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: context.colorScheme.primary,
                        overlayColor:
                            context.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: duration.inMilliseconds > 0
                            ? (position.inMilliseconds /
                                    duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                        onChanged: (val) {
                          if (controller != null &&
                              duration.inMilliseconds > 0) {
                            controller.seekTo(
                              Duration(
                                milliseconds:
                                    (val * duration.inMilliseconds).toInt(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spaceM),

              // Play / Pause Button
              MyIconButton.solid(
                icon: isPlaying ? AppIcons.pause : AppIcons.play,
                backgroundColor: context.colorScheme.primary,
                iconColor: context.colorScheme.onPrimary,
                buttonSize: context.setSize(58),
                iconSize: context.setSize(28),
                onPressed: () {
                  if (controller == null) return;
                  if (isPlaying) {
                    controller.pause();
                  } else {
                    if (position >= duration && duration > Duration.zero) {
                      controller.seekTo(Duration.zero);
                    }
                    controller.play();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
