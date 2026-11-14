import 'package:flutter/material.dart';
import 'package:halati/app/l10n/app_localizations.dart';
import 'package:halati/app/theme/extended_colors.dart';

extension ContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ExtendedColors get extendedColors =>
      Theme.of(this).extension<ExtendedColors>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
