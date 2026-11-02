import 'package:flutter/material.dart';
import 'package:flutter_app_template/core/l10n/app_localizations.dart';
import 'package:flutter_app_template/core/theme/extended_colors.dart';

extension ContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ExtendedColors get extendedColors =>
      Theme.of(this).extension<ExtendedColors>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
