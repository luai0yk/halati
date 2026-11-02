import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_durations.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';

class MySwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final bool thumbShadow;
  final double? width;
  final double? height;
  final bool enabled;

  const MySwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.thumbShadow = true,
    this.width,
    this.height,
    this.enabled = true,
  });

  @override
  State<MySwitch> createState() => _MySwitchState();
}

class _MySwitchState extends State<MySwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.veryFast,
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(MySwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.enabled) return;
    widget.onChanged?.call(!widget.value);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final actualWidth = widget.width ?? context.setSize(52);
    final actualHeight = widget.height ?? context.setSize(32);
    final thumbSize = actualHeight - context.setSize(6);
    final trackWidth = actualWidth - thumbSize - context.setSize(6);

    double delta = details.primaryDelta! / trackWidth;
    if (isRtl) {
      delta = -delta;
    }
    _controller.value += delta;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    final newValue = _controller.value >= 0.5;
    if (newValue != widget.value) {
      widget.onChanged?.call(newValue);
    } else {
      // Snap back if we didn't cross the threshold
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final actualWidth = widget.width ?? context.setSize(52);
    final actualHeight = widget.height ?? context.setSize(32);
    final thumbSize = actualHeight - context.setSize(6);

    final active = widget.activeColor ?? colorScheme.primary;
    final inactive =
        widget.inactiveColor ?? colorScheme.surfaceContainerHighest;
    final activeThumb = widget.activeThumbColor ?? colorScheme.onPrimary;
    final inactiveThumb = widget.inactiveThumbColor ?? colorScheme.surface;

    return GestureDetector(
      onTap: _onTap,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          // value goes from 0.0 to 1.0.
          // Alignment x goes from -1.0 to 1.0
          // If LTR: 0.0 -> -1.0 (Left), 1.0 -> 1.0 (Right)
          // If RTL: 0.0 -> 1.0 (Right), 1.0 -> -1.0 (Left)

          final directionMultiplier = isRtl ? -1.0 : 1.0;
          final alignmentX =
              (-1.0 + (_controller.value * 2.0)) * directionMultiplier;

          final bgColor = widget.enabled
              ? Color.lerp(inactive, active, _controller.value)!
              : colorScheme.onSurface.withValues(alpha: 0.12);

          final thumbColor = widget.enabled
              ? Color.lerp(inactiveThumb, activeThumb, _controller.value)!
              : colorScheme.onSurface.withValues(alpha: 0.38);

          return Container(
            width: actualWidth,
            height: actualHeight,
            padding: EdgeInsets.all(context.setSize(3)),
            alignment: Alignment(alignmentX, 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(actualHeight / 2),
              color: bgColor,
            ),
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: thumbColor,
                boxShadow: (widget.enabled && widget.thumbShadow)
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: context.setSize(4),
                          offset: Offset(0, context.setSize(2)),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
