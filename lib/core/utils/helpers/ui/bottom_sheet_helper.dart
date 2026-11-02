import 'dart:math';

import 'package:flutter/material.dart';
import 'package:status_saver/core/utils/helpers/ui/app_navigator.dart';

class BottomSheetHelper {
  BottomSheetHelper._();

  static int _openCount = 0;
  static bool get isBottomSheetOpen => _openCount > 0;

  static Future<T?> show<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color barrierColor = Colors.black54,
    Color backgroundColor = Colors.transparent,
  }) async {
    final context = AppNavigator.key.currentContext;
    if (context == null) return null;

    _openCount++;
    try {
      final result = await showModalBottomSheet<T>(
        context: context,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isScrollControlled: isScrollControlled,
        barrierColor: barrierColor,
        backgroundColor: backgroundColor,
        routeSettings: RouteSettings(
          name: 'bottom_sheet_${Random().nextInt(100000)}',
        ),
        builder: (context) => child,
      );
      return result;
    } finally {
      _openCount = max(0, _openCount - 1);
    }
  }

  static void dismiss<T>({T? result}) {
    if (_openCount > 0) {
      final context = AppNavigator.key.currentContext;
      if (context != null) {
        Navigator.of(context).pop(result);
      }
    }
  }
}
