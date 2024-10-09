// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $browserRoute,
      $settingsRoute,
      $chatArchiveListRoute,
    ];

RouteBase get $browserRoute => GoRouteData.$route(
      path: '/',
      name: 'BrowserRoute',
      factory: $BrowserRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'about',
          name: 'AboutRoute',
          factory: $AboutRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'bangs',
          name: 'BangRoute',
          factory: $BangCategoriesRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'search',
              name: 'BangSearchRoute',
              factory: $BangSearchRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: 'category/:category',
              name: 'BangCategoryRoute',
              factory: $BangCategoryRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':subCategory',
                  name: 'BangSubCategoryRoute',
                  factory: $BangSubCategoryRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'topics',
          name: 'TopicsRoute',
          factory: $TopicListRouteExtension._fromState,
        ),
      ],
    );

extension $BrowserRouteExtension on BrowserRoute {
  static BrowserRoute _fromState(GoRouterState state) => BrowserRoute();

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

extension $BangCategoriesRouteExtension on BangCategoriesRoute {
  static BangCategoriesRoute _fromState(GoRouterState state) =>
      BangCategoriesRoute();

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

extension $BangCategoryRouteExtension on BangCategoryRoute {
  static BangCategoryRoute _fromState(GoRouterState state) => BangCategoryRoute(
        category: state.pathParameters['category']!,
      );

  String get location => GoRouteData.$location(
        '/bangs/category/${Uri.encodeComponent(category)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangSubCategoryRouteExtension on BangSubCategoryRoute {
  static BangSubCategoryRoute _fromState(GoRouterState state) =>
      BangSubCategoryRoute(
        category: state.pathParameters['category']!,
        subCategory: state.pathParameters['subCategory']!,
      );

  String get location => GoRouteData.$location(
        '/bangs/category/${Uri.encodeComponent(category)}/${Uri.encodeComponent(subCategory)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $TopicListRouteExtension on TopicListRoute {
  static TopicListRoute _fromState(GoRouterState state) => TopicListRoute();

  String get location => GoRouteData.$location(
        '/topics',
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
          path: 'search',
          name: 'ChatArchiveSearchRoute',
          factory: $ChatArchiveSearchRouteExtension._fromState,
        ),
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

extension $ChatArchiveSearchRouteExtension on ChatArchiveSearchRoute {
  static ChatArchiveSearchRoute _fromState(GoRouterState state) =>
      ChatArchiveSearchRoute();

  String get location => GoRouteData.$location(
        '/chat_archive/search',
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
