import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  static final _formatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d{0,2}$'),
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _formatter.formatEditUpdate(oldValue, newValue);
  }
}
