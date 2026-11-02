import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:status_saver/core/l10n/app_localizations.dart';
import 'package:status_saver/core/utils/extensions/context_extension.dart';
import 'package:status_saver/core/utils/extensions/responsive_size.dart';
import 'package:status_saver/core/utils/extensions/responsive_values.dart';
import 'package:status_saver/core/utils/helpers/ui/bottom_sheet_helper.dart';
import 'package:status_saver/shared/widgets/cards/my_card.dart';
import 'package:status_saver/shared/widgets/sheets/my_bottom_sheet.dart';

class MyDateRangePicker {
  MyDateRangePicker._();

  static void show({
    required BuildContext context,
    required Function(DateTimeRange value) onDateRangeChanged,
    String? title,
    DateTimeRange? initialDateRange,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    BottomSheetHelper.show(
      child: _MyDateRangePickerSheet(
        title: title,
        initialDateRange: initialDateRange,
        minDate: minDate,
        maxDate: maxDate,
        onDateRangeChanged: onDateRangeChanged,
      ),
    );
  }
}

class _MyDateRangePickerSheet extends StatefulWidget {
  final String? title;
  final DateTimeRange? initialDateRange;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Function(DateTimeRange value) onDateRangeChanged;

  const _MyDateRangePickerSheet({
    this.title,
    this.initialDateRange,
    this.minDate,
    this.maxDate,
    required this.onDateRangeChanged,
  });

  @override
  State<_MyDateRangePickerSheet> createState() =>
      _MyDateRangePickerSheetState();
}

class _MyDateRangePickerSheetState extends State<_MyDateRangePickerSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _minDate;
  late DateTime _maxDate;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _minDate = widget.minDate ?? DateTime(1900);
    _maxDate = widget.maxDate ?? DateTime(now.year + 100);

    _startDate = widget.initialDateRange?.start ?? now;
    _endDate = widget.initialDateRange?.end ?? now.add(const Duration(days: 7));

    if (_startDate.isBefore(_minDate)) _startDate = _minDate;
    if (_endDate.isAfter(_maxDate)) _endDate = _maxDate;
  }

  Widget _buildPickerSection({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.setSize(16),
              fontWeight: FontWeight.w600,
              color: context.colorScheme.primary,
            ),
          ),
          SizedBox(height: context.spaceS),
          Expanded(
            child: MyCard.bordered(
              margin: EdgeInsets.symmetric(horizontal: context.spaceM),
              padding: EdgeInsets.zero,
              color: context.colorScheme.surfaceContainer.withValues(
                alpha: 0.5,
              ),
              borderColor: context.colorScheme.outlineVariant.withValues(
                alpha: 0.5,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MyBottomSheet(
      title: widget.title ?? l10n.selectDateRange,
      sheetHeight: context.setSize(640),
      primaryButton: SheetButton(
        text: l10n.ok,
        onPressed: () {
          widget.onDateRangeChanged(
            DateTimeRange(start: _startDate, end: _endDate),
          );
        },
      ),
      child: Column(
        children: [
          _buildPickerSection(
            context: context,
            title: l10n.startDate,
            child: CupertinoDatePicker(
              initialDateTime: _startDate,
              minimumDate: _minDate,
              maximumDate: _maxDate,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (date) {
                setState(() {
                  _startDate = date;
                  if (_startDate.isAfter(_endDate)) {
                    _endDate = _startDate;
                  }
                });
              },
            ),
          ),
          SizedBox(height: context.spaceXl),
          _buildPickerSection(
            context: context,
            title: l10n.endDate,
            child: CupertinoDatePicker(
              key: ValueKey(_endDate.millisecondsSinceEpoch),
              initialDateTime: _endDate,
              minimumDate: _startDate,
              maximumDate: _maxDate,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (date) {
                _endDate = date;
              },
            ),
          ),
          SizedBox(height: context.spaceL),
        ],
      ),
    );
  }
}
