import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/constants/app_durations.dart';

/// An [AnimatedSwitcher] that automatically applies a fade transition.
class MyAnimatedFadeSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const MyAnimatedFadeSwitcher({
    super.key,
    required this.child,
    this.duration = AppDurations.veryFast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}
