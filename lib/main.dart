import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:halati/core/constants/app_constants.dart';
import 'package:halati/core/utils/helpers/ui/app_navigator.dart';

import 'core/l10n/app_locale_config.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/cash/cash_service.dart';
import 'core/theme/material_theme.dart';
import 'core/utils/helpers/settings_helper.dart';
import 'features/settings/controller/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _init();

  runApp(const MyApp());
}

Future<void> _init() async {
  await Get.putAsync<CashService>(
    () async => await CashService().init(),
    permanent: true,
  );

  Get.put(SettingsController(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: AppNavigator.key,
      title: 'Halati',
      debugShowCheckedModeBanner: false,
      theme: const MaterialTheme().light(),
      darkTheme: const MaterialTheme().dark(),
      themeMode: SettingsHelper.currentTheme,
      initialRoute: AppRoutes.appShell,
      getPages: AppPages.pages,
      supportedLocales: AppLocaleConfig.supportedLocales,
      localizationsDelegates: AppLocaleConfig.localizationsDelegates,
      localeResolutionCallback: AppLocaleConfig.resolve,
      locale: SettingsHelper.currentLocale,
      builder: (context, child) {
        final theme = Theme.of(context);

        final textTheme = MaterialTheme.responsiveTextTheme(context).apply(
          bodyColor: theme.colorScheme.onSurface,
          displayColor: theme.colorScheme.onSurface,
          fontFamily: AppConstants.fontFamily,
        );

        final systemOverlayStyle = SystemUiOverlayStyle(
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness:
              theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          statusBarBrightness: theme.brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
        );

        return Theme(
          data: theme.copyWith(textTheme: textTheme),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemOverlayStyle,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
