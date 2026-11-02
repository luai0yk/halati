import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/app_navigator.dart';
import 'package:flutter_app_template/shared/widgets/misc/my_snackbar.dart';

class SnackBarHelper {
  SnackBarHelper._();

  static void show({
    required String msg,
    int longSec = 3,
    SnackBarStatus status = SnackBarStatus.standard,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    final context = AppNavigator.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      MySnackBar(
        context: context,
        message: msg,
        duration: Duration(seconds: longSec),
        status: status,
        icon: icon,
        actionText: actionText,
        onAction: onAction,
      ),
    );
  }
}
