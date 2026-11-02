import 'package:flutter/material.dart';
import 'package:status_saver/core/constants/app_durations.dart';

/// An [AnimatedSwitcher] that automatically applies a scale transition.
class MyAnimatedScaleSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const MyAnimatedScaleSwitcher({
    super.key,
    required this.child,
    this.duration = AppDurations.veryFast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: child,
    );
  }
}
