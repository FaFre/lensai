// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $kagiRoute,
      $settingsRoute,
      $chatArchiveListRoute,
    ];

RouteBase get $kagiRoute => GoRouteData.$route(
      path: '/',
      name: 'KagiRoute',
      factory: $KagiRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'about',
          name: 'AboutRoute',
          factory: $AboutRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'bangs',
          name: 'BangRoute',
          factory: $BangRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'search',
              name: 'BangSearchRoute',
              factory: $BangSearchRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $KagiRouteExtension on KagiRoute {
  static KagiRoute _fromState(GoRouterState state) => KagiRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AboutRouteExtension on AboutRoute {
  static AboutRoute _fromState(GoRouterState state) => AboutRoute();

  String get location => GoRouteData.$location(
        '/about',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangRouteExtension on BangRoute {
  static BangRoute _fromState(GoRouterState state) => BangRoute();

  String get location => GoRouteData.$location(
        '/bangs',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangSearchRouteExtension on BangSearchRoute {
  static BangSearchRoute _fromState(GoRouterState state) => BangSearchRoute();

  String get location => GoRouteData.$location(
        '/bangs/search',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
      path: '/settings',
      name: 'SettingsRoute',
      factory: $SettingsRouteExtension._fromState,
    );

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute();

  String get location => GoRouteData.$location(
        '/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatArchiveListRoute => GoRouteData.$route(
      path: '/chat_archive',
      name: 'ChatArchiveListRoute',
      factory: $ChatArchiveListRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'detail/:fileName',
          name: 'ChatArchiveDetailRoute',
          factory: $ChatArchiveDetailRouteExtension._fromState,
        ),
      ],
    );

extension $ChatArchiveListRouteExtension on ChatArchiveListRoute {
  static ChatArchiveListRoute _fromState(GoRouterState state) =>
      ChatArchiveListRoute();

  String get location => GoRouteData.$location(
        '/chat_archive',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChatArchiveDetailRouteExtension on ChatArchiveDetailRoute {
  static ChatArchiveDetailRoute _fromState(GoRouterState state) =>
      ChatArchiveDetailRoute(
        fileName: state.pathParameters['fileName']!,
      );

  String get location => GoRouteData.$location(
        '/chat_archive/detail/${Uri.encodeComponent(fileName)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
