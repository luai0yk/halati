/// Defines the supported application environments (flavors).
enum AppEnvironment {
  dev,
  prod;

  bool get isDev => this == AppEnvironment.dev;
  bool get isProd => this == AppEnvironment.prod;

  String get name => switch (this) {
        AppEnvironment.dev => 'dev',
        AppEnvironment.prod => 'prod',
      };

  String get displayName => switch (this) {
        AppEnvironment.dev => 'Halati Dev',
        AppEnvironment.prod => 'Halati',
      };
}
