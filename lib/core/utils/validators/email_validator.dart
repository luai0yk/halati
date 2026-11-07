import 'package:halati/core/l10n/app_localizations.dart';

abstract class EmailValidator {
  static String? validate(AppLocalizations l10n, {required String? value}) {
    if (value == null || value.trim().isEmpty) {
      return l10n.required;
    }

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) {
      return l10n.invalidEmail;
    }

    return null;
  }
}
