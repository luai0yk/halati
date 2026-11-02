import 'package:status_saver/core/l10n/app_localizations.dart';

class EmptyValidator {
  EmptyValidator._();
  static String? validate(AppLocalizations l10n, String? value, {String? msg}) {
    if (value == null || value.trim().isEmpty) {
      return msg ?? l10n.required;
    }
    return null;
  }
}
