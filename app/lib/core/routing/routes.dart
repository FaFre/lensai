import 'package:bang_navigator/core/routing/dialog_page.dart';
import 'package:bang_navigator/features/about/presentation/screens/about.dart';
import 'package:bang_navigator/features/search_browser/presentation/screens/browser.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/settings/presentation/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'routes.g.dart';

@TypedGoRoute<KagiRoute>(
  path: '/',
  routes: [
    TypedGoRoute<AboutRoute>(
      path: 'about',
    ),
    TypedGoRoute<SettingsRoute>(
      path: 'settings',
    ),
  ],
)
class KagiRoute extends GoRouteData {
  KagiRoute();

  @override
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final hasKagiSession = await ProviderScope.containerOf(context)
        .read(settingsRepositoryProvider.future)
        .then((value) => value.kagiSession?.isNotEmpty ?? false);

    if (!hasKagiSession) {
      return SettingsRoute().location;
    }

    return null;
  }

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
