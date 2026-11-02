import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';

enum DotIndicatorEffect { expanding, sliding, worm, jumping, scaling, fading }

class MyDotIndicator extends StatefulWidget {
  // Required properties
  final int count;
  final int activeIndex;

  // Animation
  final DotIndicatorEffect? effect;
  final Duration? duration;
  final Curve? curve;

  // Colors
  final Color? activeColor;
  final Color? inactiveColor;

  // Dimensions
  final double? activeWidth;
  final double? dotSize;
  final double? spacing;

  // Animation customization
  final double? jumpHeight;
  final double? activeScale;
  final double? inactiveOpacity;

  // Layout & Interaction
  final MainAxisAlignment? alignment;
  final ValueChanged<int>? onDotClicked;
  final BorderRadiusGeometry? borderRadius;

  const MyDotIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    this.effect,
    this.activeColor,
    this.inactiveColor,
    this.activeWidth,
    this.dotSize,
    this.spacing,
    this.duration,
    this.curve,
    this.jumpHeight,
    this.activeScale,
    this.inactiveOpacity,
    this.alignment,
    this.onDotClicked,
    this.borderRadius,
  }) : assert(count >= 0);

  @override
  State<MyDotIndicator> createState() => _MyDotIndicatorState();
}

class _MyDotIndicatorState extends State<MyDotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _wormController;
  late int _prevIndex;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.count == 0
        ? 0
        : widget.activeIndex.clamp(0, widget.count - 1);
    _prevIndex = safeIndex;
    _currentIndex = safeIndex;
    _wormController = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppDurations.fast,
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(MyDotIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final safeOldIndex = oldWidget.count == 0
        ? 0
        : oldWidget.activeIndex.clamp(0, oldWidget.count - 1);
    final safeNewIndex = widget.count == 0
        ? 0
        : widget.activeIndex.clamp(0, widget.count - 1);

    if (safeOldIndex != safeNewIndex) {
      _prevIndex = safeOldIndex;
      _currentIndex = safeNewIndex;
      if (widget.effect == DotIndicatorEffect.worm) {
        _wormController.forward(from: 0.0);
      }
    }

    if (oldWidget.duration != widget.duration) {
      _wormController.duration = widget.duration ?? AppDurations.fast;
    }
  }

  @override
  void dispose() {
    _wormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) {
      return const SizedBox.shrink();
    }

    final colors = context.colorScheme;
    final resolvedEffect = widget.effect ?? DotIndicatorEffect.expanding;

    final resolvedDotSize = widget.dotSize ?? context.setSize(8);
    final resolvedActiveWidth = widget.activeWidth ?? context.setSize(24);
    final resolvedSpacing = widget.spacing ?? context.setSize(8);

    final resolvedDuration = widget.duration ?? AppDurations.fast;
    final resolvedCurve = widget.curve ?? Curves.easeInOutCubic;

    final resolvedActiveColor = widget.activeColor ?? colors.primary;
    final resolvedInactiveColor = widget.inactiveColor ?? colors.outlineVariant;

    final resolvedJumpHeight = widget.jumpHeight ?? context.setSize(6);
    final resolvedActiveScale = (widget.activeScale ?? 1.4).clamp(0.1, 5.0);
    final resolvedInactiveOpacity = (widget.inactiveOpacity ?? 0.4).clamp(
      0.0,
      1.0,
    );

    final resolvedAlignment = widget.alignment ?? MainAxisAlignment.center;
    final resolvedBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(resolvedDotSize);

    final safeActiveIndex = widget.activeIndex.clamp(0, widget.count - 1);

    switch (resolvedEffect) {
      case DotIndicatorEffect.sliding:
      case DotIndicatorEffect.worm:
        return _buildSlidingIndicator(
          effect: resolvedEffect,
          safeActiveIndex: safeActiveIndex,
          dotSize: resolvedDotSize,
          activeWidth: resolvedActiveWidth,
          spacing: resolvedSpacing,
          duration: resolvedDuration,
          curve: resolvedCurve,
          activeColor: resolvedActiveColor,
          inactiveColor: resolvedInactiveColor,
          borderRadius: resolvedBorderRadius,
          alignment: resolvedAlignment,
        );

      default:
        return _buildDotRow(
          effect: resolvedEffect,
          safeActiveIndex: safeActiveIndex,
          dotSize: resolvedDotSize,
          activeWidth: resolvedActiveWidth,
          spacing: resolvedSpacing,
          duration: resolvedDuration,
          curve: resolvedCurve,
          activeColor: resolvedActiveColor,
          inactiveColor: resolvedInactiveColor,
          jumpHeight: resolvedJumpHeight,
          activeScale: resolvedActiveScale,
          inactiveOpacity: resolvedInactiveOpacity,
          alignment: resolvedAlignment,
          borderRadius: resolvedBorderRadius,
        );
    }
  }

  Widget _buildDotRow({
    required DotIndicatorEffect effect,
    required int safeActiveIndex,
    required double dotSize,
    required double activeWidth,
    required double spacing,
    required Duration duration,
    required Curve curve,
    required Color activeColor,
    required Color inactiveColor,
    required double jumpHeight,
    required double activeScale,
    required double inactiveOpacity,
    required MainAxisAlignment alignment,
    required BorderRadiusGeometry borderRadius,
  }) {
    // Provide vertical headroom for jumping and scaling effects to prevent clipping
    final topPadding = effect == DotIndicatorEffect.jumping ? jumpHeight : 0.0;
    final scalePadding = effect == DotIndicatorEffect.scaling
        ? (activeScale > 1.0 ? (activeScale - 1.0) * dotSize / 2 : 0.0)
        : 0.0;
    final verticalPadding = math.max(topPadding, scalePadding);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: List.generate(widget.count, (index) {
          final isActive = index == safeActiveIndex;

          final dotWidget = _buildDot(
            effect: effect,
            isActive: isActive,
            dotSize: dotSize,
            activeWidth: activeWidth,
            duration: duration,
            curve: curve,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            jumpHeight: jumpHeight,
            activeScale: activeScale,
            inactiveOpacity: inactiveOpacity,
            borderRadius: borderRadius,
          );

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: Semantics(
              label: 'Page ${index + 1} of ${widget.count}',
              selected: isActive,
              button: widget.onDotClicked != null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDotClicked != null
                    ? () => widget.onDotClicked!(index)
                    : null,
                child: MouseRegion(
                  cursor: widget.onDotClicked != null
                      ? SystemMouseCursors.click
                      : MouseCursor.defer,
                  child: dotWidget,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDot({
    required DotIndicatorEffect effect,
    required bool isActive,
    required double dotSize,
    required double activeWidth,
    required Duration duration,
    required Curve curve,
    required Color activeColor,
    required Color inactiveColor,
    required double jumpHeight,
    required double activeScale,
    required double inactiveOpacity,
    required BorderRadiusGeometry borderRadius,
  }) {
    final width = switch (effect) {
      DotIndicatorEffect.expanding => isActive ? activeWidth : dotSize,
      _ => dotSize,
    };

    Widget dot = AnimatedContainer(
      duration: duration,
      curve: curve,
      width: width,
      height: dotSize,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: borderRadius,
      ),
    );

    switch (effect) {
      case DotIndicatorEffect.scaling:
        dot = AnimatedScale(
          duration: duration,
          curve: curve,
          scale: isActive ? activeScale : 1.0,
          child: dot,
        );

      case DotIndicatorEffect.jumping:
        dot = AnimatedSlide(
          duration: duration,
          curve: curve,
          offset: isActive ? Offset(0, -jumpHeight / dotSize) : Offset.zero,
          child: dot,
        );

      case DotIndicatorEffect.fading:
        dot = AnimatedOpacity(
          duration: duration,
          curve: curve,
          opacity: isActive ? 1.0 : inactiveOpacity,
          child: dot,
        );

      default:
        break;
    }

    return dot;
  }

  Widget _buildSlidingIndicator({
    required DotIndicatorEffect effect,
    required int safeActiveIndex,
    required double dotSize,
    required double activeWidth,
    required double spacing,
    required Duration duration,
    required Curve curve,
    required Color activeColor,
    required Color inactiveColor,
    required BorderRadiusGeometry borderRadius,
    required MainAxisAlignment alignment,
  }) {
    final step = dotSize + spacing;
    final isWorm = effect == DotIndicatorEffect.worm;

    // For sliding, activeWidth can optionally be wider than dotSize (pill).
    // Center it over the dot without overflow.
    final slidingDotWidth = activeWidth > dotSize ? activeWidth : dotSize;
    final horizontalMargin = !isWorm && slidingDotWidth > dotSize
        ? (slidingDotWidth - dotSize) / 2
        : 0.0;

    final totalWidth =
        widget.count * dotSize +
        (widget.count - 1) * spacing +
        2 * horizontalMargin;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        SizedBox(
          width: totalWidth,
          height: dotSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Inactive background dots
              for (int index = 0; index < widget.count; index++)
                PositionedDirectional(
                  start: horizontalMargin + index * step,
                  top: 0,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: inactiveColor,
                      borderRadius: borderRadius,
                    ),
                  ),
                ),

              // Active animated indicator
              if (isWorm)
                AnimatedBuilder(
                  animation: _wormController,
                  builder: (context, _) {
                    final progress = _wormController.value;
                    final headCurve = Interval(0.0, 0.7, curve: curve);
                    final tailCurve = Interval(0.3, 1.0, curve: curve);

                    double start;
                    double width;

                    if (_currentIndex >= _prevIndex) {
                      // Moving forward
                      final headT = headCurve.transform(progress);
                      final tailT = tailCurve.transform(progress);

                      final headPos = _lerpDouble(
                        _prevIndex * step + dotSize,
                        _currentIndex * step + dotSize,
                        headT,
                      );
                      final tailPos = _lerpDouble(
                        _prevIndex * step,
                        _currentIndex * step,
                        tailT,
                      );

                      start = tailPos;
                      width = math.max(dotSize, headPos - tailPos);
                    } else {
                      // Moving backward
                      final headT = headCurve.transform(progress);
                      final tailT = tailCurve.transform(progress);

                      final headPos = _lerpDouble(
                        _prevIndex * step,
                        _currentIndex * step,
                        headT,
                      );
                      final tailPos = _lerpDouble(
                        _prevIndex * step + dotSize,
                        _currentIndex * step + dotSize,
                        tailT,
                      );

                      start = headPos;
                      width = math.max(dotSize, tailPos - headPos);
                    }

                    return PositionedDirectional(
                      start: start,
                      top: 0,
                      child: Container(
                        width: width,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: borderRadius,
                        ),
                      ),
                    );
                  },
                )
              else
                // Sliding effect
                AnimatedPositionedDirectional(
                  duration: duration,
                  curve: curve,
                  start: safeActiveIndex * step,
                  top: 0,
                  child: Container(
                    width: slidingDotWidth,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: borderRadius,
                    ),
                  ),
                ),

              // Interactive tap hit-targets
              for (int index = 0; index < widget.count; index++)
                PositionedDirectional(
                  start: horizontalMargin + index * step - spacing / 2,
                  top: -((kMinInteractiveDimension - dotSize) / 2).clamp(
                    0.0,
                    10.0,
                  ),
                  width: step,
                  height:
                      dotSize +
                      2 *
                          ((kMinInteractiveDimension - dotSize) / 2).clamp(
                            0.0,
                            10.0,
                          ),
                  child: Semantics(
                    label: 'Page ${index + 1} of ${widget.count}',
                    selected: index == safeActiveIndex,
                    button: widget.onDotClicked != null,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onDotClicked != null
                          ? () => widget.onDotClicked!(index)
                          : null,
                      child: MouseRegion(
                        cursor: widget.onDotClicked != null
                            ? SystemMouseCursors.click
                            : MouseCursor.defer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
