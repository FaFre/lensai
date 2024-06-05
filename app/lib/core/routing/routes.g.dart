// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $kagiRoute,
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
          path: 'settings',
          name: 'SettingsRoute',
          factory: $SettingsRouteExtension._fromState,
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
