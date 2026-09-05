/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/widgets/bottom_sheet_page.dart';
import 'package:weblibre/core/routing/widgets/dialog_page.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/about/presentation/screens/about.dart';
import 'package:weblibre/features/account/presentation/screens/account_settings.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_details.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_internal_settings.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_listing_details.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_manager.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_permissions.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/presentation/screens/categories.dart';
import 'package:weblibre/features/bangs/presentation/screens/category.dart';
import 'package:weblibre/features/bangs/presentation/screens/edit.dart';
import 'package:weblibre/features/bangs/presentation/screens/menu.dart';
import 'package:weblibre/features/bangs/presentation/screens/search.dart';
import 'package:weblibre/features/bangs/presentation/screens/user.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/screens/bookmark_entry_edit.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/screens/bookmark_folder_edit.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/screens/bookmark_list.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/tab_tree.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/screens/browser.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/screens/tab_view.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/context_menu_dialog.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/screens/history.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/dialogs/open_shared_content.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/screens/unshortener_settings.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/screens/url_cleaner_settings.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/screens/search.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_draft_suggestions.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_edit.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_list.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_selection.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_settings_screen.dart';
import 'package:weblibre/features/onboarding/presentation/onboarding.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/presentation/screens/proxy_routing_settings.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_logs.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_profile_editor.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/presentation/screens/subscription_import.dart';
import 'package:weblibre/features/settings/presentation/screens/addon_collection.dart';
import 'package:weblibre/features/settings/presentation/screens/advanced_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/bang_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/browsing_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/contextual_toolbar_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/custom_tracking_protection.dart';
import 'package:weblibre/features/settings/presentation/screens/desktop_mode_sites_screen.dart';
import 'package:weblibre/features/settings/presentation/screens/doh_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/error_logs_screen.dart';
import 'package:weblibre/features/settings/presentation/screens/experimental_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/extensions_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/fingerprint_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/general_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/home_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/locale_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/module_surface_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/privacy_security_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/proxy_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/search_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/settings.dart';
import 'package:weblibre/features/settings/presentation/screens/settings_transfer.dart';
import 'package:weblibre/features/settings/presentation/screens/toolbar_layout_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/tracking_protection_exceptions.dart';
import 'package:weblibre/features/settings/presentation/screens/ublock_filter_lists.dart';
import 'package:weblibre/features/settings/presentation/screens/web_content_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/web_engine_hardening.dart';
import 'package:weblibre/features/settings/presentation/screens/web_engine_hardening_group.dart';
import 'package:weblibre/features/share_intent/domain/entities/intent_container_mode.dart';
import 'package:weblibre/features/sync/presentation/screens/sync_settings.dart';
import 'package:weblibre/features/tor/presentation/screens/country_picker.dart';
import 'package:weblibre/features/tor/presentation/screens/tor_proxy.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/select_profile.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_backup.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_backup_list.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_edit.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_list.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_restore.dart';
import 'package:weblibre/features/user/domain/presentation/widgets/auth_gate.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/wallpaper/presentation/screens/wallpaper_settings.dart';
import 'package:weblibre/features/web_feed/presentation/add_feed_dialog.dart';
import 'package:weblibre/features/web_feed/presentation/screens/feed_article.dart';
import 'package:weblibre/features/web_feed/presentation/screens/feed_article_list.dart';
import 'package:weblibre/features/web_feed/presentation/screens/feed_edit.dart';
import 'package:weblibre/features/web_feed/presentation/screens/feed_list.dart';
import 'package:weblibre/features/web_feed/presentation/select_feed_dialog.dart';
import 'package:weblibre/features/web_push/presentation/screens/web_push_settings.dart';

part 'routes.bangs.dart';
part 'routes.bookmarks.dart';
part 'routes.browser.dart';
part 'routes.addons.dart';
part 'routes.feeds.dart';
part 'routes.g.dart';
part 'routes.history.dart';
part 'routes.profiles.dart';
part 'routes.settings.dart';
part 'routes.tor.dart';

@TypedGoRoute<AboutRoute>(name: 'AboutRoute', path: '/about')
class AboutRoute extends GoRouteData with $AboutRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const AboutDialogScreen());
  }
}

@TypedGoRoute<OnboardingRoute>(
  name: OnboardingRoute.name,
  path: '${OnboardingRoute.pathPrefix}/:currentRevision/:targetRevision',
)
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  static const name = 'OnboardingRoute';
  static const pathPrefix = '/onboarding';

  final int currentRevision;
  final int targetRevision;

  const OnboardingRoute({
    required this.currentRevision,
    required this.targetRevision,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OnboardingScreen(
      currentRevision: currentRevision,
      targetRevision: targetRevision,
    );
  }
}

@TypedGoRoute<LockRoute>(name: LockRoute.name, path: LockRoute.path)
class LockRoute extends GoRouteData with $LockRoute {
  static const name = 'LockRoute';
  static const path = '/lock';

  const LockRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LockScreen();
  }
}
