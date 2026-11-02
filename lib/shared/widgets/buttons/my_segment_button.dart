import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_constants.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/constants/app_icons.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/shared/controller/segment_button_controller.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/misc/my_icon.dart';

class MyButtonSegment<T> extends ButtonSegment<T> {
  final Color? color;

  MyButtonSegment({
    required super.value,
    String? label,
    IconData? icon,
    this.color,
  }) : assert(
         label != null || icon != null,
         'Either label or icon must be provided.',
       ),
       super(
         label: label != null ? Text(label) : null,
         icon: icon != null ? Icon(icon) : null,
       );
}

class MySegmentButton<T> extends StatefulWidget {
  /// Segments to render as selectable buttons
  final List<MyButtonSegment<T>> segments;

  /// Controller that manages the selected segment state
  final SegmentButtonController<T> controller;

  /// Callback triggered when the selected segment changes
  final ValueChanged<T>? onSelectionChanged;

  /// Whether the segment row is horizontally scrollable
  /// Default to `false`
  final bool scrollable;

  /// Background color of the segment container
  final Color? backgroundColor;

  /// Foreground color of the unselected segments
  final Color? unselectedSegmentColor;

  /// Custom border radius for the segment container and indicators
  final BorderRadius? borderRadius;

  /// Custom border width for the segment container
  final double? borderWidth;

  /// Custom border color for the segment container
  final Color? borderColor;

  /// Vertical padding for each button segment
  final double? buttonVerticalPadding;

  /// Size of the segment buttons
  /// Default to `SegmentButtonSize.medium`
  final SegmentButtonSize size;

  const MySegmentButton({
    super.key,
    required this.controller,
    required this.segments,
    this.onSelectionChanged,
    this.scrollable = false,
    this.backgroundColor,
    this.unselectedSegmentColor,
    this.buttonVerticalPadding,
    this.size = SegmentButtonSize.medium,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
  });

  @override
  State<MySegmentButton<T>> createState() => _MySegmentButtonState<T>();
}

class _MySegmentButtonState<T> extends State<MySegmentButton<T>> {
  ScrollController? _scrollController;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        int selectedIndex = widget.segments.indexWhere(
          (s) => s.value == c.selected,
        );
        if (selectedIndex == -1) selectedIndex = 0;

        return MyCard.filled(
          width: double.infinity,
          margin: EdgeInsets.zero,
          padding: context.insetsAllXs,
          color: widget.backgroundColor ?? context.colorScheme.surface,
          borderRadius: widget.borderRadius,
          borderColor: widget.borderColor,
          borderWidth: widget.borderWidth,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double estimatedSegmentWidth = context.setSize(120);
              final double gap = context.spaceXs;

              double segmentWidth;
              if (widget.scrollable) {
                segmentWidth = estimatedSegmentWidth;
              } else {
                segmentWidth =
                    (constraints.maxWidth -
                        (widget.segments.length - 1) * gap) /
                    widget.segments.length;
              }

              if (widget.scrollable && _scrollController == null) {
                double itemLeft = selectedIndex * (estimatedSegmentWidth + gap);
                double offset =
                    itemLeft -
                    (constraints.maxWidth / 2) +
                    (estimatedSegmentWidth / 2);
                if (offset < 0) offset = 0;

                _scrollController = ScrollController(
                  initialScrollOffset: offset,
                );
              }

              final BorderRadius innerRadius = widget.borderRadius != null
                  ? BorderRadius.circular(
                      (widget.borderRadius!.topLeft.x - context.spaceXs).clamp(
                        0.0,
                        999.0,
                      ),
                    )
                  : context.brS;

              final Color activeColor =
                  widget.segments[selectedIndex].color ??
                  context.colorScheme.primary;

              List<Widget> children = [];
              for (int i = 0; i < widget.segments.length; i++) {
                final segment = widget.segments[i];
                final bool isSelected = selectedIndex == i;

                Widget segmentWidget = _SegmentButtonContent<T>(
                  segment: segment,
                  isSelected: isSelected,
                  size: widget.size,
                  colors: colors,
                  borderRadius: innerRadius,
                  activeColor: segment.color ?? context.colorScheme.primary,
                  onTap: () {
                    c.updateSelection({segment.value});
                    widget.onSelectionChanged?.call(segment.value);
                  },
                );

                if (widget.scrollable) {
                  children.add(
                    SizedBox(
                      width: estimatedSegmentWidth,
                      child: segmentWidget,
                    ),
                  );
                } else {
                  children.add(Expanded(child: segmentWidget));
                }

                if (i < widget.segments.length - 1) {
                  children.add(SizedBox(width: gap));
                }
              }

              double alignmentX = 0.0;
              if (widget.segments.length > 1) {
                alignmentX =
                    -1.0 + (2.0 / (widget.segments.length - 1)) * selectedIndex;
              }

              Widget stackContent = Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedAlign(
                      duration: AppDurations.fast,
                      curve: Curves.easeInOutCubic,
                      alignment: AlignmentDirectional(alignmentX, 0),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        width: segmentWidth,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: innerRadius,
                        ),
                      ),
                    ),
                  ),
                  Row(mainAxisSize: MainAxisSize.max, children: children),
                ],
              );

              if (widget.scrollable) {
                return Row(
                  children: [
                    if (widget.segments.length > 2)
                      MyIcon(
                        icon: AppIcons.arrowBack(context),
                        color: colors.onSurface.withValues(alpha: .5),
                        size: widget.size.iconSize(context) * 0.8,
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: stackContent,
                      ),
                    ),
                    if (widget.segments.length > 2)
                      MyIcon(
                        icon: AppIcons.arrowForward(context),
                        color: colors.onSurface.withValues(alpha: .5),
                        size: widget.size.iconSize(context) * 0.8,
                      ),
                  ],
                );
              } else {
                return stackContent;
              }
            },
          ),
        );
      },
    );
  }
}

enum SegmentButtonSize {
  small,
  medium,
  large;

  double verticalPadding(BuildContext context) {
    switch (this) {
      case SegmentButtonSize.small:
        return context.spaceXs;
      case SegmentButtonSize.medium:
        return context.spaceS;
      case SegmentButtonSize.large:
        return context.spaceM;
    }
  }

  double fontSize(BuildContext context) {
    switch (this) {
      case SegmentButtonSize.small:
        return context.setSize(12);
      case SegmentButtonSize.medium:
        return context.setSize(14);
      case SegmentButtonSize.large:
        return context.setSize(16);
    }
  }

  double iconSize(BuildContext context) {
    switch (this) {
      case SegmentButtonSize.small:
        return context.iconS;
      case SegmentButtonSize.medium:
        return context.iconM;
      case SegmentButtonSize.large:
        return context.iconL;
    }
  }

  double spacing(BuildContext context) {
    switch (this) {
      case SegmentButtonSize.small:
        return context.spaceXs;
      case SegmentButtonSize.medium:
        return context.spaceXs * 1.5;
      case SegmentButtonSize.large:
        return context.spaceS;
    }
  }
}

class _SegmentButtonContent<T> extends StatelessWidget {
  final MyButtonSegment<T> segment;
  final bool isSelected;
  final ColorScheme colors;
  final VoidCallback onTap;
  final SegmentButtonSize size;
  final BorderRadius borderRadius;
  final Color activeColor;

  const _SegmentButtonContent({
    required this.segment,
    required this.isSelected,
    required this.colors,
    required this.onTap,
    required this.size,
    required this.borderRadius,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasIcon = segment.icon != null;
    final bool hasLabel = segment.label != null;

    final Color targetColor = isSelected
        ? Colors.white
        : colors.onSurfaceVariant;

    Widget content;

    if (hasIcon && hasLabel) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: targetColor),
            duration: AppDurations.fast,
            builder: (context, color, child) {
              return IconTheme(
                data: IconThemeData(color: color, size: size.iconSize(context)),
                child: segment.icon!,
              );
            },
          ),
          SizedBox(width: size.spacing(context)),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: TextStyle(
                color: targetColor,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                fontFamily: AppConstants.fontFamily,
                fontSize: size.fontSize(context),
              ),
              child: segment.label!,
            ),
          ),
        ],
      );
    } else if (hasIcon) {
      content = TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: targetColor),
        duration: AppDurations.fast,
        builder: (context, color, child) {
          return IconTheme(
            data: IconThemeData(color: color, size: size.iconSize(context)),
            child: segment.icon!,
          );
        },
      );
    } else {
      content = AnimatedDefaultTextStyle(
        duration: AppDurations.fast,
        style: TextStyle(
          color: targetColor,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontFamily: AppConstants.fontFamily,
          fontSize: size.fontSize(context),
        ),
        child: segment.label!,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: activeColor.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: size.verticalPadding(context),
            horizontal: context.spaceS,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
