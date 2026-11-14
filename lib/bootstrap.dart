import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:halati/app/l10n/app_locale_config.dart';
import 'package:halati/app/routes/app_pages.dart';
import 'package:halati/app/routes/app_routes.dart';
import 'package:halati/app/theme/material_theme.dart';
import 'package:halati/core/config/app_config.dart';
import 'package:halati/core/constants/app_constants.dart';
import 'package:halati/core/services/cash/cash_service.dart';
import 'package:halati/core/utils/helpers/settings_helper.dart';
import 'package:halati/core/utils/helpers/ui/app_navigator.dart';
import 'package:halati/features/settings/controller/settings_controller.dart';

final ValueNotifier<Key> _appRestartKey = ValueNotifier(UniqueKey());

/// Shared bootstrapping procedure for development and production flavors.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(config);

  await initServices();

  runApp(
    ValueListenableBuilder<Key>(
      valueListenable: _appRestartKey,
      builder: (context, key, child) {
        return KeyedSubtree(key: key, child: const MyApp());
      },
    ),
  );
}

Future<void> initServices() async {
  await Get.putAsync<CashService>(
    () async => await CashService().init(),
    permanent: true,
  );

  Get.put(SettingsController(), permanent: true);
}

Future<void> restartApp() async {
  FocusManager.instance.primaryFocus?.unfocus();

  await Get.deleteAll(force: true);
  await initServices();

  _appRestartKey.value = UniqueKey();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: AppNavigator.key,
      title: AppConfig.current.appName,
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

        Widget appContent = child ?? const SizedBox.shrink();

        if (AppConfig.isDev) {
          appContent = Directionality(
            textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
            child: Banner(
              message: 'DEV',
              location: BannerLocation.topEnd,
              color: const Color(0xFFE65100),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
              child: appContent,
            ),
          );
        }

        return Theme(
          data: theme.copyWith(textTheme: textTheme),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemOverlayStyle,
            child: appContent,
          ),
        );
      },
    );
  }
}
