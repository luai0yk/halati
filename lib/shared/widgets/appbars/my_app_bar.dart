import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/shared/widgets/buttons/my_icon_button.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar.
  final String? title;

  final Widget? titleWidget;

  /// A list of widgets to display in a row after the title widget.
  final List<Widget>? actions;

  /// Whether the leading icon should be displayed or not
  /// Default to [true]
  final bool withLeading;

  /// The background color of the app bar.
  /// Default to [context.colorScheme.surface]
  final Color? color;

  /// The color of the title texts.
  /// Default to [context.colorScheme.onSurface]
  final Color? titleColor;

  /// The color of the leading icon.
  final Color? leadingIconColor;

  /// The background color of the leading icon button.
  final Color? leadingBackgroundColor;

  /// Whether to show elevation (shadow) or not
  /// Default to [true]
  final bool isElevated;

  /// Whether the title should be centered.
  /// Default to [true]
  final bool isTitleCenter;

  /// The bottom widget to display at the bottom of the app bar.
  /// Default to [null]
  final PreferredSizeWidget? bottom;

  /// The system overlay style for the app bar.
  final SystemUiOverlayStyle? systemOverlayStyle;

  const MyAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.withLeading = true,
    this.actions,
    this.color,
    this.titleColor,
    this.leadingIconColor,
    this.leadingBackgroundColor,
    this.isElevated = true,
    this.isTitleCenter = true,
    this.bottom,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return AppBar(
      title:
          titleWidget ??
          Text(
            title ?? '',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: titleColor ?? colors.onSurface,
            ),
          ),
      automaticallyImplyLeading: false,
      backgroundColor: color ?? colors.surface,
      surfaceTintColor: color ?? colors.surface,
      shadowColor: Colors.black.withValues(alpha: isElevated ? .2 : 0),
      centerTitle: isTitleCenter,
      actionsPadding: EdgeInsets.symmetric(horizontal: context.setSize(12)),
      systemOverlayStyle: systemOverlayStyle,
      actions: actions,
      bottom: bottom,
      leading: withLeading
          ? Center(
              child: MyIconButton.solid(
                icon: AppIcons.arrowBack(context),
                iconColor: leadingIconColor,
                tooltip: context.l10n.back,
                backgroundColor: leadingBackgroundColor,
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
    );
  }
}
