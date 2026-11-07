import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';

/// An [AnimatedSwitcher] that automatically applies both a scale and a fade transition.
class MyAnimatedScaleFadeSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const MyAnimatedScaleFadeSwitcher({
    super.key,
    required this.child,
    this.duration = AppDurations.veryFast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: child,
    );
  }
}
