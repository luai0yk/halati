import 'dart:math';

import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_durations.dart';
import 'package:halati/core/utils/helpers/ui/app_navigator.dart';

class DialogHelper {
  DialogHelper._();

  static int _dialogCount = 0;
  static bool get _isDialogOpen => _dialogCount > 0;

  static Future<void> show({
    required Widget child,
    bool isDismissible = true,
  }) async {
    final context = AppNavigator.key.currentContext;
    if (context == null) return;

    _dialogCount++;
    try {
      await showGeneralDialog(
        context: context,
        barrierLabel: '${Random().nextInt(100)}',
        transitionDuration: AppDurations.fast,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        barrierDismissible: isDismissible,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic, // show
              reverseCurve: Curves.easeInCubic, // dismiss
            ),
          );

          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: const Interval(
              0.0,
              0.8, // fade out slightly faster than scale
              curve: Curves.easeIn,
            ),
          );

          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: PopScope(canPop: isDismissible, child: child),
            ),
          );
        },
      );
    } finally {
      _dialogCount = max(0, _dialogCount - 1);
    }
  }

  static void dismiss() {
    if (_isDialogOpen) {
      final context = AppNavigator.key.currentContext;
      if (context != null) {
        Navigator.of(context).pop();
      }
    }
  }
}
