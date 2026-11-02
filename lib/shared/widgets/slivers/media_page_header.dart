import 'package:flutter/material.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/features/home/domain/entities/status_media.dart';
import 'package:status_saver/shared/widgets/chips/media_filter_bar.dart';

class MediaPageHeader extends StatelessWidget {
  final String title;
  final MediaType? selectedType;
  final ValueChanged<MediaType?> onFilterChanged;

  const MediaPageHeader({
    super.key,
    required this.title,
    required this.selectedType,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: context.spaceM,
              right: context.spaceM,
              top: context.spaceS,
              bottom: context.spaceS,
            ),
            child: Text(
              title,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          MediaFilterBar(
            selectedType: selectedType,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}
