import 'package:flutter/material.dart';
import 'package:halati/core/utils/extensions/context_extension.dart';

enum LangCode {
  system('system'),
  en('en'),
  ar('ar');

  final String value;

  const LangCode(this.value);

  String localizedName(BuildContext context) {
    switch (this) {
      case LangCode.system:
        return context.l10n.system;
      case LangCode.en:
        return context.l10n.english;
      case LangCode.ar:
        return context.l10n.arabic;
    }
  }
}

abstract final class AppLocales {
  static Locale english = Locale(LangCode.en.name);
  static Locale arabic = Locale(LangCode.ar.name);

  static List<Locale> supported = [english, arabic];
}
