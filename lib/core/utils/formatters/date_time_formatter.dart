import 'package:flutter_app_template/core/l10n/app_localizations.dart';
import 'package:flutter_app_template/core/utils/helpers/settings_helper.dart';
import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTimeFormatter._();

  /// Formats a date from a [DateTime].
  /// Example: 01 Jan 2022
  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd(SettingsHelper.currentLangCode).format(dateTime);
  }

  /// Formats a date from [millisecondsSinceEpoch].
  /// Example: 01 Jan 2022
  static String formatDateFromEpoch(int millisecondsSinceEpoch) {
    return formatDate(
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
  }

  /// Formats a short date.
  /// Example: 01 Jan
  static String formatShortDate(DateTime dateTime) {
    return DateFormat.MMMd(SettingsHelper.currentLangCode).format(dateTime);
  }

  /// Formats a short date from [millisecondsSinceEpoch].
  /// Example: 01 Jan
  static String formatShortDateFromEpoch(int millisecondsSinceEpoch) {
    return formatShortDate(
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
  }

  /// Formats a time from a [DateTime].
  /// Example: 12:00 AM
  static String formatTime(DateTime dateTime) {
    return DateFormat.jm(SettingsHelper.currentLangCode).format(dateTime);
  }

  /// Formats a time from [millisecondsSinceEpoch].
  /// Example: 12:00 AM
  static String formatTimeFromEpoch(int millisecondsSinceEpoch) {
    return formatTime(
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
  }

  /// Formats a date and time from a [DateTime].
  /// Example: 01 Jan 2022  |  12:00 AM
  static String formatDateTime(DateTime dateTime) {
    final dateStr = DateFormat.yMMMd(
      SettingsHelper.currentLangCode,
    ).format(dateTime);
    final timeStr = DateFormat.jm(
      SettingsHelper.currentLangCode,
    ).format(dateTime);
    return '$dateStr  |  $timeStr';
  }

  /// Formats a date and time from [millisecondsSinceEpoch].
  /// Example: 01 Jan 2022  |  12:00 AM
  static String formatDateTimeFromEpoch(int millisecondsSinceEpoch) {
    return formatDateTime(
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
  }

  /// Returns a human-friendly relative time string (e.g. "Just now", "Yesterday", or formatted date).
  static String since(DateTime dateTime, AppLocalizations l10n) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.isNegative) {
      return formatDate(dateTime);
    }

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    }

    if (difference.inDays == 1) {
      return l10n.yesterday;
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return formatDate(dateTime);
  }

  /// Returns a relative time string from [millisecondsSinceEpoch].
  static String sinceEpoch(int millisecondsSinceEpoch, AppLocalizations l10n) {
    return since(
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
      l10n,
    );
  }
}
