import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_size.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/features/viewer/data/models/media_viewer_item.dart';
import 'package:halati/shared/widgets/images/my_image.dart';
import 'package:halati/shared/widgets/misc/my_icon.dart';

class MediaViewerFilmstrip extends StatelessWidget {
  final List<MediaViewerItem> items;
  final int currentIndex;
  final ScrollController scrollController;
  final Map<String, String> thumbnails;
  final bool isVisible;
  final void Function(int index) onSelectIndex;

  const MediaViewerFilmstrip({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.scrollController,
    required this.thumbnails,
    required this.isVisible,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (items.length <= 1) {
      return const SizedBox.shrink();
    }

    final stripHeight = context.setSize(76);
    final itemWidth = context.setSize(48);
    final itemHeight = context.setSize(62);

    return PositionedDirectional(
      start: 0,
      end: 0,
      bottom: context.spaceL + MediaQuery.paddingOf(context).bottom,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: AppDurations.fast,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: SizedBox(
            height: stripHeight,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              padding: EdgeInsets.symmetric(horizontal: context.spaceM),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == currentIndex;
                final thumb = thumbnails[item.uri];

                return GestureDetector(
                  onTap: () => onSelectIndex(index),
                  child: Center(
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 0.94,
                      duration: AppDurations.fast,
                      curve: Curves.easeOutCubic,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: context.spaceXxs,
                        ),
                        width: itemWidth,
                        height: itemHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(context.radiusS),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Thumbnail, Audio card, or Placeholder
                              if (item.mediaType == MediaType.audio)
                                _buildAudioThumb(context)
                              else if (thumb != null && thumb.isNotEmpty)
                                MyImage.file(
                                  file: File(thumb),
                                  borderRadius: BorderRadius.zero,
                                  fit: BoxFit.cover,
                                  cacheWidth: 160,
                                  errorWidget: _buildThumbPlaceholder(
                                    context,
                                    item,
                                  ),
                                )
                              else
                                _buildThumbPlaceholder(context, item),

                              // Inactive subtle dimming overlay to focus on active item
                              if (!isSelected)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.25),
                                ),

                              // Video overlay indicator
                              if (item.mediaType == MediaType.video)
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.all(context.setSize(3)),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.65,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: context.setSize(0.5),
                                      ),
                                    ),
                                    child: MyIcon(
                                      icon: AppIcons.play,
                                      color: Colors.white,
                                      size: context.setSize(10),
                                    ),
                                  ),
                                ),

                              // Flush Border Overlay on top of thumbnail
                              IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      context.radiusS,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? context.colorScheme.primary
                                          : Colors.white.withValues(
                                              alpha: 0.22,
                                            ),
                                      width: isSelected
                                          ? context.setSize(2.5)
                                          : context.setSize(1.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioThumb(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primaryContainer,
            context.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: MyIcon(
          icon: AppIcons.waveform,
          color: context.colorScheme.onPrimaryContainer,
          size: context.setSize(16),
        ),
      ),
    );
  }

  Widget _buildThumbPlaceholder(BuildContext context, MediaViewerItem item) {
    return Container(
      color: Colors.white.withValues(alpha: 0.08),
      child: Center(
        child: MyIcon(
          icon: item.mediaType == MediaType.video
              ? AppIcons.video
              : item.mediaType == MediaType.audio
              ? AppIcons.waveform
              : AppIcons.image,
          size: context.setSize(16),
          color: Colors.white54,
        ),
      ),
    );
  }
}
