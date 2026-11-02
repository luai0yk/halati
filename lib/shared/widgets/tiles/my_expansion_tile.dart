import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';

class MyExpansionTile extends StatefulWidget {
  /// The title of the expansion tile.
  final String title;

  /// The subtitle of the expansion tile.
  final String? subtitle;

  /// The children displayed when expanded.
  final List<Widget> children;

  /// Initial expansion state.
  final bool initiallyExpanded;

  const MyExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<MyExpansionTile> createState() => _MyExpansionTileState();
}

class _MyExpansionTileState extends State<MyExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return ExpansionTile(
      initiallyExpanded: widget.initiallyExpanded,
      onExpansionChanged: (value) {
        setState(() => _isExpanded = value);
      },
      backgroundColor: colors.surface,
      collapsedBackgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: context.brM,
        side: BorderSide.none,
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: context.brM,
        side: BorderSide.none,
      ),
      trailing: AnimatedRotation(
        turns: _isExpanded ? 0.5 : 0,
        duration: AppDurations.fast,
        curve: Curves.easeInOut,
        child: MyIcon(
          icon: AppIcons.arrowDown,
          color: colors.onSurfaceVariant,
          size: context.iconL,
        ),
      ),
      title: Text(
        widget.title,
        style: context.textTheme.titleMedium?.copyWith(color: colors.onSurface),
      ),
      subtitle: widget.subtitle != null
          ? Text(
              widget.subtitle!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          : null,
      children: widget.children,
    );
  }
}
