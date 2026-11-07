// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read texts, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:halati/core/services/cash/cash_service.dart';
import 'package:halati/features/settings/controller/settings_controller.dart';
import 'package:halati/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await Get.putAsync<CashService>(
      () async => await CashService().init(),
      permanent: true,
    );
    Get.put(SettingsController(), permanent: true);
  });

  testWidgets('App mounts and smoke test passes', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify App renders MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
