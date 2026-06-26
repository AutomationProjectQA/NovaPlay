/// Build flavors for NovaPlay. Each flavor has its own entrypoint
/// (`lib/main_<flavor>.dart`) and, in production, its own Firebase project and
/// AdMob unit IDs. See docs/ARCHITECTURE.md §13.
enum Flavor { dev, staging, prod }

/// Immutable, compile-time-selected environment configuration.
///
/// The active instance is set once in `bootstrap()` and read everywhere via
/// [AppEnvironment.instance].
class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.appName,
    required this.useFirebaseEmulators,
    required this.adsEnabled,
    required this.useTestAds,
    required this.analyticsEnabled,
  });

  /// Configuration for the local development flavor.
  factory AppEnvironment.dev() => const AppEnvironment(
    flavor: Flavor.dev,
    appName: 'NovaPlay Dev',
    useFirebaseEmulators: false,
    adsEnabled: true,
    useTestAds: true,
    analyticsEnabled: false,
  );

  /// Configuration for the pre-release / QA flavor.
  factory AppEnvironment.staging() => const AppEnvironment(
    flavor: Flavor.staging,
    appName: 'NovaPlay Staging',
    useFirebaseEmulators: false,
    adsEnabled: true,
    useTestAds: true,
    analyticsEnabled: true,
  );

  /// Configuration for the production (store) flavor.
  factory AppEnvironment.prod() => const AppEnvironment(
    flavor: Flavor.prod,
    appName: 'NovaPlay',
    useFirebaseEmulators: false,
    adsEnabled: true,
    useTestAds: false,
    analyticsEnabled: true,
  );

  final Flavor flavor;
  final String appName;
  final bool useFirebaseEmulators;
  final bool adsEnabled;

  /// When true, AdMob test ad unit IDs are used instead of production IDs.
  final bool useTestAds;
  final bool analyticsEnabled;

  bool get isProd => flavor == Flavor.prod;
  bool get isDev => flavor == Flavor.dev;

  static late AppEnvironment _instance;

  /// The active environment. Throws if accessed before [init].
  static AppEnvironment get instance => _instance;

  /// Records the active environment. Called once from `bootstrap()`.
  // ignore: use_setters_to_change_properties
  static void init(AppEnvironment env) => _instance = env;
}
