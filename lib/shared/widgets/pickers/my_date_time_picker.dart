import 'package:flutter/cupertino.dart';
import 'package:flutter_app_template/core/l10n/app_localizations.dart';
import 'package:flutter_app_template/core/utils/extensions/responsive_size.dart';
import 'package:flutter_app_template/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:flutter_app_template/shared/widgets/sheets/my_bottom_sheet.dart';

enum MyDateBottomPickerMode { date, dateTime, time }

class MyDateTimePicker {
  MyDateTimePicker._();

  static void show({
    required BuildContext context,
    required Function(DateTime value) onDateChanged,
    String? title,
    MyDateBottomPickerMode mode = MyDateBottomPickerMode.date,

    /// Date configuration
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    final l10n = AppLocalizations.of(context)!;

    final DateTime now = DateTime.now();

    final DateTime resolvedMinDate = minDate ?? DateTime(1900);
    final DateTime resolvedMaxDate = maxDate ?? DateTime(now.year + 100);

    DateTime resolvedInitialDate = initialDate ?? now;

    if (resolvedInitialDate.isBefore(resolvedMinDate)) {
      resolvedInitialDate = resolvedMinDate;
    } else if (resolvedInitialDate.isAfter(resolvedMaxDate)) {
      resolvedInitialDate = resolvedMaxDate;
    }

    DateTime currentSelectedDate = resolvedInitialDate;

    String getHeaderTitle() {
      if (title != null) return title;
      switch (mode) {
        case MyDateBottomPickerMode.dateTime:
          return l10n.dateTime;
        case MyDateBottomPickerMode.time:
          return l10n.time;
        case MyDateBottomPickerMode.date:
          return l10n.date;
      }
    }

    void handleDateChanged(DateTime date) {
      if (mode == MyDateBottomPickerMode.time) {
        currentSelectedDate = DateTime(
          resolvedInitialDate.year,
          resolvedInitialDate.month,
          resolvedInitialDate.day,
          date.hour,
          date.minute,
        );
      } else if (mode == MyDateBottomPickerMode.date) {
        currentSelectedDate = DateTime(
          date.year,
          date.month,
          date.day,
          resolvedInitialDate.hour,
          resolvedInitialDate.minute,
        );
      } else {
        currentSelectedDate = date;
      }
    }

    BottomSheetHelper.show(
      child: MyBottomSheet(
        title: getHeaderTitle(),
        sheetHeight: context.setSize(300),
        primaryButton: SheetButton(
          text: l10n.ok,
          onPressed: () {
            onDateChanged(currentSelectedDate);
          },
        ),
        child: CupertinoDatePicker(
          changeReportingBehavior: .onScrollEnd,
          showTimeSeparator:
              mode == MyDateBottomPickerMode.dateTime ||
              mode == MyDateBottomPickerMode.time,
          initialDateTime: resolvedInitialDate,
          minimumDate: resolvedMinDate,
          maximumDate: resolvedMaxDate,
          mode: mode == MyDateBottomPickerMode.dateTime
              ? CupertinoDatePickerMode.dateAndTime
              : (mode == MyDateBottomPickerMode.time
                    ? CupertinoDatePickerMode.time
                    : CupertinoDatePickerMode.date),
          onDateTimeChanged: handleDateChanged,
        ),
      ),
    );
  }
}
