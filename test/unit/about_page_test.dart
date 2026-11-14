import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:halati/core/constants/app_constants.dart';
import 'package:halati/app/l10n/app_localizations.dart';
import 'package:halati/core/services/cash/cash_service.dart';
import 'package:halati/features/settings/controller/settings_controller.dart';
import 'package:halati/features/settings/view/about_page.dart';
import 'package:halati/features/settings/view/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Open Source in AboutPage & SettingsPage Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      await Get.putAsync<CashService>(
        () async => await CashService().init(),
        permanent: true,
      );
      Get.put(SettingsController(), permanent: true);
    });

    tearDown(() {
      Get.reset();
    });

    test('AppConstants contains correct source code URL', () {
      expect(AppConstants.sourceCodeUrl, 'https://github.com/luai0yk/halati');
    });

    test('AppConstants contains correct privacy policy URL', () {
      expect(
        AppConstants.privacyPolicyUrl,
        'https://dev-luai0yk-halati.web.app/privacy-policy',
      );
    });

    testWidgets('AboutPage displays actions including privacy policy', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const AboutPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Source Code'), findsOneWidget);
      expect(find.text('Contribute on GitHub'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Contact & Feedback'), findsOneWidget);
      expect(find.text('Open-Source Licenses'), findsOneWidget);
    });

    testWidgets('SettingsPage displays about section tile', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SettingsPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('About Halati'), findsOneWidget);
    });
  });
}
