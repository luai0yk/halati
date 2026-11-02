import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/features/viewer/data/models/media_viewer_item.dart';
import 'package:status_saver/shared/widgets/appbars/my_app_bar.dart';
import 'package:status_saver/shared/widgets/buttons/my_icon_button.dart';

class MediaViewerAppBar extends StatelessWidget {
  final String title;
  final MediaViewerItem currentItem;
  final bool isVisible;
  final Future<void> Function()? onSave;
  final Future<void> Function()? onShare;
  final VoidCallback? onDelete;

  const MediaViewerAppBar({
    super.key,
    required this.title,
    required this.currentItem,
    required this.isVisible,
    this.onSave,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: AppDurations.fast,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: MyAppBar(
                color: Colors.transparent,
                isElevated: false,
                isTitleCenter: false,
                leadingIconColor: Colors.white,
                leadingBackgroundColor: Colors.white.withValues(alpha: 0.1),
                title: title,
                titleColor: Colors.white,
                actions: [
                  if (onSave != null && !currentItem.isSaved)
                    MyIconButton.solid(
                      icon: AppIcons.download,
                      iconColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      tooltip: context.l10n.save,
                      onPressed: onSave,
                    ),
                  context.horizontalSpace(8),
                  if (onShare != null)
                    MyIconButton.solid(
                      icon: AppIcons.share,
                      iconColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      tooltip: context.l10n.share,
                      onPressed: onShare,
                    ),
                  if (onDelete != null) ...[
                    context.horizontalSpace(8),
                    MyIconButton.solid(
                      icon: AppIcons.delete,
                      iconColor: context.colorScheme.error,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      tooltip: context.l10n.delete,
                      onPressed: onDelete,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
