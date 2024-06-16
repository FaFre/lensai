import 'package:bang_navigator/core/routing/dialog_page.dart';
import 'package:bang_navigator/features/about/presentation/screens/about.dart';
import 'package:bang_navigator/features/bangs/presentation/screens/categories.dart';
import 'package:bang_navigator/features/bangs/presentation/screens/list.dart';
import 'package:bang_navigator/features/bangs/presentation/screens/search.dart';
import 'package:bang_navigator/features/chat_archive/presentation/screens/detail.dart';
import 'package:bang_navigator/features/chat_archive/presentation/screens/list.dart';
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
    TypedGoRoute<BangCategoriesRoute>(
      name: 'BangRoute',
      path: 'bangs',
      routes: [
        TypedGoRoute<BangCategoryRoute>(
          name: 'BangCategoryRoute',
          path: ':category',
          routes: [
            TypedGoRoute<BangSubCategoryRoute>(
              name: 'BangSubCategoryRoute',
              path: ':subCategory',
            ),
          ],
        ),
      ],
    ),
    TypedGoRoute<BangSearchRoute>(
      name: 'BangSearchRoute',
      path: 'bang_search',
    ),
  ],
)
class KagiRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const KagiScreen();
  }
}

class AboutRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const AboutDialogScreen());
  }
}

class BangCategoriesRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangCategoriesScreen();
  }
}

class BangCategoryRoute extends GoRouteData {
  final String category;

  const BangCategoryRoute({required this.category});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangListScreen(category: category);
  }
}

class BangSubCategoryRoute extends GoRouteData {
  final String category;
  final String subCategory;

  const BangSubCategoryRoute({
    required this.category,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangListScreen(category: category, subCategory: subCategory);
  }
}

class BangSearchRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangSearchScreen();
  }
}

@TypedGoRoute<SettingsRoute>(
  name: 'SettingsRoute',
  path: '/settings',
)
class SettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

@TypedGoRoute<ChatArchiveListRoute>(
  name: 'ChatArchiveListRoute',
  path: '/chat_archive',
  routes: [
    TypedGoRoute<ChatArchiveDetailRoute>(
      name: 'ChatArchiveDetailRoute',
      path: 'detail/:fileName',
    ),
  ],
)
class ChatArchiveListRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChatArchiveListScreen();
  }
}

class ChatArchiveDetailRoute extends GoRouteData {
  final String fileName;

  const ChatArchiveDetailRoute({required this.fileName});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatArchiveDetailScreen(fileName);
  }
}
