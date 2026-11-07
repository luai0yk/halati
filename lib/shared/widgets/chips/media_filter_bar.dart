import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/extensions/responsive_values.dart';
import 'package:halati/features/home/domain/entities/status_media.dart';
import 'package:halati/shared/widgets/chips/animated_chip.dart';

class MediaFilterBar extends StatelessWidget {
  final MediaType? selectedType;
  final ValueChanged<MediaType?> onFilterChanged;
  final EdgeInsetsGeometry? padding;

  const MediaFilterBar({
    super.key,
    required this.selectedType,
    required this.onFilterChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: context.spaceM,
            vertical: context.spaceXs,
          ),
      child: Row(
        children: [
          AnimatedChip(
            text: context.l10n.viewAll,
            isSelected: selectedType == null,
            onTap: () => onFilterChanged(null),
          ),
          SizedBox(width: context.spaceS),
          AnimatedChip(
            text: context.l10n.images,
            isSelected: selectedType == MediaType.image,
            onTap: () => onFilterChanged(MediaType.image),
          ),
          SizedBox(width: context.spaceS),
          AnimatedChip(
            text: context.l10n.videos,
            isSelected: selectedType == MediaType.video,
            onTap: () => onFilterChanged(MediaType.video),
          ),
          SizedBox(width: context.spaceS),
          AnimatedChip(
            text: context.l10n.audio,
            isSelected: selectedType == MediaType.audio,
            onTap: () => onFilterChanged(MediaType.audio),
          ),
        ],
      ),
    );
  }
}
