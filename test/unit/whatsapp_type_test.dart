import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/core/enums/whatsapp_type.dart';
import 'package:status_saver/core/l10n/app_localizations.dart';
import 'package:status_saver/core/services/cash/cash_keys.dart';
import 'package:status_saver/core/services/cash/cash_service.dart';
import 'package:status_saver/features/settings/controller/settings_controller.dart';
import 'package:status_saver/shared/widgets/buttons/whatsapp_type_switch.dart';

void main() {
  group('WhatsAppType & SettingsController Tests', () {
    late CashService cashService;
    late SettingsController settingsController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      cashService = await Get.putAsync<CashService>(
        () async => await CashService().init(),
        permanent: true,
      );
      settingsController = Get.put(SettingsController(), permanent: true);
    });

    tearDown(() {
      Get.reset();
    });

    test('defaultWhatsAppType defaults to whatsapp', () {
      expect(settingsController.defaultWhatsAppType, WhatsAppType.whatsapp);
      expect(settingsController.activeWhatsAppType.value, WhatsAppType.whatsapp);
    });

    test('setDefaultWhatsAppType updates preferences and active type', () async {
      await settingsController.setDefaultWhatsAppType(WhatsAppType.business);

      expect(settingsController.defaultWhatsAppType, WhatsAppType.business);
      expect(settingsController.activeWhatsAppType.value, WhatsAppType.business);
      expect(cashService.getString(CashKeys.defaultWhatsAppType), WhatsAppType.business.name);
    });

    test('setActiveWhatsAppType changes active WhatsApp type', () {
      expect(settingsController.activeWhatsAppType.value, WhatsAppType.whatsapp);
      settingsController.setActiveWhatsAppType(WhatsAppType.business);
      expect(settingsController.activeWhatsAppType.value, WhatsAppType.business);
    });
  });

  group('WhatsAppTypeSwitch Widget Test', () {
    testWidgets('renders switch and triggers callback on tap', (tester) async {
      WhatsAppType selected = WhatsAppType.whatsapp;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: SizedBox(
                    width: 160,
                    child: WhatsAppTypeSwitch(
                      currentType: selected,
                      onChanged: (newType) {
                        setState(() {
                          selected = newType;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the business segment and tap it
      final businessFinder = find.text('Business');
      expect(businessFinder, findsOneWidget);

      await tester.tap(businessFinder);
      await tester.pumpAndSettle();

      expect(selected, WhatsAppType.business);

      // Now tap WhatsApp segment
      final whatsappFinder = find.text('WhatsApp');
      expect(whatsappFinder, findsOneWidget);

      await tester.tap(whatsappFinder);
      await tester.pumpAndSettle();

      expect(selected, WhatsAppType.whatsapp);
    });

    testWidgets('supports swiping to switch between WhatsApp and Business', (tester) async {
      WhatsAppType selected = WhatsAppType.whatsapp;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: SizedBox(
                    width: 160,
                    child: WhatsAppTypeSwitch(
                      currentType: selected,
                      onChanged: (newType) {
                        setState(() {
                          selected = newType;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Swipe right from the switch center
      final switchFinder = find.byType(WhatsAppTypeSwitch);
      expect(switchFinder, findsOneWidget);

      await tester.drag(switchFinder, const Offset(60, 0));
      await tester.pumpAndSettle();

      expect(selected, WhatsAppType.business);

      // Swipe left back to WhatsApp
      await tester.drag(switchFinder, const Offset(-60, 0));
      await tester.pumpAndSettle();

      expect(selected, WhatsAppType.whatsapp);
    });
  });
}

