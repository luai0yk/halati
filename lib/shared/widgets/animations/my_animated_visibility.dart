import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';

/// Animates the visibility of a widget by fading it in and out,
/// while still occupying layout space.
class MyAnimatedVisibility extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration duration;

  const MyAnimatedVisibility({
    super.key,
    required this.child,
    required this.visible,
    this.duration = AppDurations.veryFast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      opacity: visible ? 1.0 : 0.0,
      child: child,
    );
  }
}
