import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';

/// A customizable, reusable SliverAppBar designed to work natively within a `CustomScrollView`.
///
/// It provides two constructors:
/// - [MySliverAppBar] for a standard collapsible/pinned toolbar.
/// - [MySliverAppBar.expanded] for a toolbar with a collapsible header area.
class MySliverAppBar extends StatelessWidget {
  /// The text to display in the app bar title.
  final String? title;

  /// A custom widget to display as the title. Overrides [title] if provided.
  final Widget? titleWidget;

  /// A widget to display before the title (e.g., a back button or menu icon).
  final Widget? leading;

  /// A list of widgets to display after the title (e.g., actions/icons).
  final List<Widget>? actions;

  /// Whether the title should be centered. Defaults to true.
  final bool centerTitle;

  /// The height of the toolbar. Defaults to [kToolbarHeight].
  final double toolbarHeight;

  /// Whether the app bar should remain pinned at the top when scrolling down.
  final bool pinned;

  /// Whether the app bar should become visible as soon as the user scrolls towards it.
  final bool floating;

  /// Whether the app bar should snap into view when the user stops scrolling.
  /// Only effective if [floating] is true.
  final bool snap;

  /// The background color of the app bar.
  final Color? backgroundColor;

  /// The elevation of the app bar.
  final double? elevation;

  /// The system overlay style (status bar color/icons brightness).
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// The height of the app bar when fully expanded.
  /// Only applicable when using the [MySliverAppBar.expanded] constructor.
  final double? expandedHeight;

  /// The background color of the expanded area.
  /// Only applicable when using the [MySliverAppBar.expanded] constructor.
  final Color? expandedBackgroundColor;

  /// A custom [FlexibleSpaceBar] or equivalent widget.
  /// If provided, this fully overrides [expandedContent] and [background].
  final Widget? flexibleSpace;

  /// Content to display inside the expanded area's foreground.
  /// Automatically wrapped in a [FlexibleSpaceBar].
  final Widget? expandedContent;

  /// Background widget, image, or color for the expanded area.
  /// Displays behind [expandedContent] and transitions as the app bar collapses.
  final Widget? background;

  /// Determines how the [expandedContent] and [background] collapse.
  /// Defaults to [CollapseMode.parallax].
  final CollapseMode collapseMode;

  /// If true, the [titleWidget] or [title] will fade in only as the app bar collapses.
  /// This allows you to have completely different content when expanded ([expandedContent]),
  /// and a standard title when collapsed.
  final bool hideTitleWhenExpanded;

  /// If true, the [actions] will fade in only as the app bar collapses.
  final bool hideActionsWhenExpanded;

  /// Whether to show elevation (shadow) or not. Matches MyAppBar.
  final bool isElevated;

  /// Whether this app bar was created using the expanded constructor.
  final bool _isExpanded;

  /// Creates a standard, collapsible or pinned `MySliverAppBar`.
  const MySliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.toolbarHeight = kToolbarHeight,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
    this.isElevated = true,
    this.backgroundColor,
    this.elevation,
    this.systemOverlayStyle,
  }) : _isExpanded = false,
       expandedHeight = null,
       expandedBackgroundColor = null,
       flexibleSpace = null,
       expandedContent = null,
       background = null,
       hideTitleWhenExpanded = false,
       hideActionsWhenExpanded = false,
       collapseMode = CollapseMode.parallax;

  /// Creates an expanded `MySliverAppBar` with a collapsible header.
  ///
  /// Requires an [expandedHeight].
  /// You can provide [expandedContent] and [background] to automatically
  /// construct a [FlexibleSpaceBar], or provide a custom [flexibleSpace] for full control.
  const MySliverAppBar.expanded({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.toolbarHeight = kToolbarHeight,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.isElevated = true,
    this.backgroundColor,
    this.elevation,
    this.systemOverlayStyle,
    required this.expandedHeight,
    this.expandedBackgroundColor,
    this.flexibleSpace,
    this.expandedContent,
    this.background,
    this.hideTitleWhenExpanded = false,
    this.hideActionsWhenExpanded = false,
    this.collapseMode = CollapseMode.parallax,
  }) : _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return _buildSliverAppBar(context, 1.0);
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final double maxExtent = expandedHeight ?? toolbarHeight;
        final double topPadding = MediaQuery.paddingOf(context).top;
        final double minExtent = toolbarHeight + topPadding;

        final double currentExtent = maxExtent - constraints.scrollOffset;
        double expandRatio =
            (currentExtent - minExtent) / (maxExtent - minExtent);
        expandRatio = expandRatio.clamp(0.0, 1.0);

        return _buildSliverAppBar(context, expandRatio);
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, double expandRatio) {
    // Fine-tuned animation curves for a premium transition effect
    final double titleOpacity = const Interval(
      0.0,
      0.4,
      curve: Curves.easeIn,
    ).transform(1.0 - expandRatio);
    final double actionsOpacity = const Interval(
      0.0,
      0.5,
      curve: Curves.easeIn,
    ).transform(1.0 - expandRatio);
    final double contentOpacity = const Interval(
      0.3,
      1.0,
      curve: Curves.easeOut,
    ).transform(expandRatio);

    Widget? builtFlexibleSpace = flexibleSpace;
    Widget? baseTitle =
        titleWidget ??
        (title != null
            ? Text(
                title!,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              )
            : null);
    Widget? builtTitle = baseTitle;

    if (_isExpanded &&
        builtFlexibleSpace == null &&
        (expandedContent != null ||
            background != null ||
            baseTitle != null ||
            expandedBackgroundColor != null)) {
      builtFlexibleSpace = FlexibleSpaceBar(
        title: hideTitleWhenExpanded ? null : baseTitle,
        background:
            (expandedContent != null ||
                background != null ||
                expandedBackgroundColor != null)
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (expandedBackgroundColor != null)
                    Container(color: expandedBackgroundColor),
                  ?background,
                  if (expandedContent != null)
                    AnimatedOpacity(
                      duration: Duration.zero,
                      opacity: contentOpacity,
                      child: SafeArea(bottom: false, child: expandedContent!),
                    ),
                ],
              )
            : null,
        collapseMode: collapseMode,
        centerTitle: centerTitle,
        titlePadding: hideTitleWhenExpanded ? EdgeInsets.zero : null,
      );

      if (hideTitleWhenExpanded && baseTitle != null) {
        builtTitle = AnimatedOpacity(
          duration: Duration.zero,
          opacity: titleOpacity,
          child: baseTitle,
        );
      } else {
        builtTitle = null;
      }
    }

    List<Widget>? builtActions;
    if (actions != null && actions!.isNotEmpty) {
      builtActions = [];
      for (int i = 0; i < actions!.length; i++) {
        Widget action = actions![i];

        // Apply fading logic if needed
        if (_isExpanded && hideActionsWhenExpanded) {
          action = IgnorePointer(
            ignoring: actionsOpacity < 0.5,
            child: AnimatedOpacity(
              duration: Duration.zero,
              opacity: actionsOpacity,
              child: action,
            ),
          );
        }

        builtActions.add(action);

        // Add spacing between actions, but not after the last one (we add trailing padding instead)
        if (i < actions!.length - 1) {
          builtActions.add(SizedBox(width: context.spaceS));
        }
      }

      // Add padding at the end so it doesn't stick to the edge of the screen
      builtActions.add(SizedBox(width: context.spaceM));
    }

    return SliverAppBar(
      title: builtTitle,
      leading: leading,
      actions: builtActions,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      forceElevated: isElevated,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
      surfaceTintColor: backgroundColor ?? context.colorScheme.surface,
      shadowColor: Colors.black.withValues(alpha: isElevated ? .2 : 0),
      elevation: elevation,
      systemOverlayStyle: systemOverlayStyle,
      expandedHeight: _isExpanded ? expandedHeight : null,
      flexibleSpace: _isExpanded ? builtFlexibleSpace : null,
    );
  }
}
