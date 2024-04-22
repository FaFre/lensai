import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kagi_bang_bang/features/search_browser/presentation/screens/browser.dart';
import 'package:kagi_bang_bang/features/settings/data/repositories/settings_repository.dart';
import 'package:kagi_bang_bang/features/settings/presentation/screens/settings.dart';

part 'routes.g.dart';

@TypedGoRoute<KagiRoute>(
  path: '/',
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

@TypedGoRoute<SettingsRoute>(
  path: '/settings',
)
class SettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}
