import 'package:halati/core/config/app_config.dart';
import 'package:halati/core/config/app_environment.dart';

import 'bootstrap.dart';

export 'bootstrap.dart' show MyApp, initServices, restartApp;

/// Development entry point.
Future<void> main() async {
  await bootstrap(
    const AppConfig(
      environment: AppEnvironment.dev,
      appName: 'Halati Dev',
    ),
  );
}
