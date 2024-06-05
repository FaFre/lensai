import 'package:bang_navigator/core/routing/dialog_page.dart';
import 'package:bang_navigator/features/about/presentation/screens/about.dart';
import 'package:bang_navigator/features/search_browser/presentation/screens/browser.dart';
import 'package:bang_navigator/features/settings/presentation/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<KagiRoute>(
  name: 'KagiRoute',
  path: '/',
  routes: [
    TypedGoRoute<AboutRoute>(
      name: 'AboutRoute',
      path: 'about',
    ),
    TypedGoRoute<SettingsRoute>(
      name: 'SettingsRoute',
      path: 'settings',
    ),
  ],
)
class KagiRoute extends GoRouteData {
  KagiRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const KagiScreen();
  }
}

class SettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

class AboutRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const AboutDialogScreen());
  }
}
