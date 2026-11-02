import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';
import 'package:status_saver/shared/widgets/misc/my_progress_indicator.dart';

import 'my_list_tile.dart';

class MyActionTile extends StatefulWidget {
  final IconData? icon;
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final Function()? onTap;
  final Color? color;

  /// Whether to automatically show a loading indicator and disable the tile while an async [onTap] callback executes.
  /// Defaults to `true`.
  final bool autoLoading;
  final Widget? leading;
  final Widget? trailing;

  const MyActionTile({
    super.key,
    this.icon,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
    this.leading,
    this.trailing,
    this.autoLoading = true,
  });

  @override
  State<MyActionTile> createState() => _MyActionTileState();
}

class _MyActionTileState extends State<MyActionTile> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (widget.onTap == null || _isLoading) {
      return;
    }

    final result = widget.onTap!();

    if (result is Future && widget.autoLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        await result;
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLoading = (widget.autoLoading && _isLoading);
    final effectiveIcon = widget.leadingIcon ?? widget.icon;

    return MyListTile(
      onTap: showLoading ? null : _handleTap,
      leading:
          widget.leading ??
          (effectiveIcon != null
              ? MyCard.filled(
                  padding: context.insetsAllM,
                  color: (widget.color ?? context.colorScheme.primary)
                      .withValues(alpha: .08),
                  child: MyIcon(
                    icon: effectiveIcon,
                    color: widget.color ?? context.colorScheme.primary,
                  ),
                )
              : null),
      title: widget.title,
      titleColor: widget.color,
      subtitle: widget.subtitle,
      borderRadius: BorderRadius.zero,
      trailing: showLoading
          ? SizedBox.square(
              dimension: context.setSize(16),
              child: MyProgressIndicator(color: widget.color),
            )
          : (widget.trailing ??
                MyIcon(
                  icon: AppIcons.arrowForward(context),
                  size: context.iconS,
                  color: widget.color ?? context.colorScheme.onSurfaceVariant,
                )),
    );
  }
}
