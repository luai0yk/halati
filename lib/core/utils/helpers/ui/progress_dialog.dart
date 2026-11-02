import 'package:flutter_app_template/shared/widgets/dialogs/my_progress_dialog.dart';

import 'dialog_helper.dart';

class ProgressDialog {
  ProgressDialog._();

  static void show({String? message}) {
    DialogHelper.show(
      isDismissible: false,
      child: MyProgressDialog(message: message),
    );
  }

  static void dismiss() {
    DialogHelper.dismiss();
  }
}
