import 'app_environment.dart';

/// Centralized application configuration holding environment information.
class AppConfig {
  final AppEnvironment environment;
  final String appName;

  const AppConfig({
    required this.environment,
    required this.appName,
  });

  static late final AppConfig current;

  /// Initializes the global application configuration.
  static void initialize(AppConfig config) {
    current = config;
  }

  /// Convenience getters for active environment checks.
  static AppEnvironment get currentEnvironment => current.environment;
  static bool get isDev => current.environment.isDev;
  static bool get isProd => current.environment.isProd;
}
