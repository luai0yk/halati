import 'package:halati/core/l10n/app_localizations.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

abstract class PhoneValidator {
  PhoneValidator._();

  static String? validate(
    AppLocalizations l10n,
    String? value, {
    required String countryCode,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n.required;
    }

    try {
      final phone = PhoneNumber.parse(
        value,
        destinationCountry: IsoCode.values.firstWhere(
          (e) => e.name == countryCode,
          orElse: () => IsoCode.YE,
        ),
      );

      if (!phone.isValid()) {
        return l10n.invalidPhoneNumber;
      }

      return null;
    } catch (_) {
      return l10n.invalidPhoneNumber;
    }
  }
}
