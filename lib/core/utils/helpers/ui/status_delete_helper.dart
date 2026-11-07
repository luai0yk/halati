import 'package:flutter/material.dart';
import 'package:halati/core/constants/app_icons.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';
import 'package:halati/core/utils/helpers/ui/dialog_helper.dart';
import 'package:halati/core/utils/helpers/ui/toast_helper.dart';
import 'package:halati/shared/widgets/dialogs/my_dialog.dart';

class StatusDeleteHelper {
  StatusDeleteHelper._();

  /// Shows the shared confirmation dialog and executes the deletion callback upon confirmation.
  static Future<void> confirmAndDelete(
    BuildContext context, {
    required Future<bool> Function() onDelete,
    VoidCallback? onDeleted,
  }) async {
    final successMsg = context.l10n.deletedSuccessfully;
    await DialogHelper.show(
      child: MyDialog(
        title: context.l10n.deleteSavedMedia,
        content: context.l10n.confirmDeleteMessage,
        status: DialogStatus.danger,
        statusIcon: AppIcons.delete,
        primaryButton: DialogButton(
          text: context.l10n.delete,
          onPressed: () async {
            final success = await onDelete();
            if (success) {
              ToastHelper.show(msg: successMsg);
              onDeleted?.call();
            }
          },
        ),
        secondaryButton: DialogButton(text: context.l10n.cancel),
      ),
    );
  }
}
