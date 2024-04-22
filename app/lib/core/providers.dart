import 'package:go_router/go_router.dart';
import 'package:kagi_bang_bang/core/routing/routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) => GoRouter(
      debugLogDiagnostics: true,
      routes: $appRoutes,
    );
