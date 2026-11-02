import 'package:flutter/material.dart';
import 'package:status_saver/core/utils/helpers/ui/app_navigator.dart';
import 'package:status_saver/shared/widgets/misc/my_toast.dart';

class ToastHelper {
  ToastHelper._();

  static OverlayEntry? _currentEntry;
  static GlobalKey<MyToastState>? _currentToastKey;
  static String? _currentMsg;

  static void show({
    required String msg,
    int longSec = 2,
    ToastStatus status = ToastStatus.standard,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
    bool preventDuplication = false,
  }) {
    if (preventDuplication && _currentMsg == msg && _currentEntry != null) {
      return;
    }

    final navigator = AppNavigator.currentState;
    if (navigator == null) return;

    final overlay = navigator.overlay;
    if (overlay == null) return;

    if (_currentEntry != null) {
      _currentToastKey?.currentState?.dismiss();
      _currentEntry = null;
      _currentToastKey = null;
    }

    final toastKey = GlobalKey<MyToastState>();
    _currentToastKey = toastKey;
    _currentMsg = msg;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => MyToast(
        key: toastKey,
        message: msg,
        duration: Duration(seconds: longSec),
        status: status,
        icon: icon,
        actionText: actionText,
        onAction: onAction,
        onDismiss: () {
          if (_currentEntry == entry) {
            _currentEntry = null;
            _currentToastKey = null;
            _currentMsg = null;
          }
          entry.remove();
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}
