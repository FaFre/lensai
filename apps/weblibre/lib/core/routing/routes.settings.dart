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
part of 'routes.dart';

@TypedGoRoute<SettingsRoute>(
  name: 'SettingsRoute',
  path: '/settings',
  routes: [
    TypedGoRoute<GeneralSettingsRoute>(
      name: 'GeneralSettingsRoute',
      path: 'general',
    ),
    TypedGoRoute<SettingsTransferRoute>(
      name: 'SettingsTransferRoute',
      path: 'transfer',
    ),
    TypedGoRoute<BrowsingSettingsRoute>(
      name: 'BrowsingSettingsRoute',
      path: 'browsing',
    ),
    TypedGoRoute<GestureSettingsRoute>(
      name: 'GestureSettingsRoute',
      path: 'gestures',
    ),
    TypedGoRoute<PrivacySecuritySettingsRoute>(
      name: 'PrivacySecuritySettingsRoute',
      path: 'privacy_security',
    ),
    TypedGoRoute<ToolbarLayoutSettingsRoute>(
      name: 'ToolbarLayoutSettingsRoute',
      path: 'toolbar_layout',
    ),
    TypedGoRoute<WebContentSettingsRoute>(
      name: 'WebContentSettingsRoute',
      path: 'web_content',
    ),
    TypedGoRoute<SearchSettingsRoute>(
      name: 'SearchSettingsRoute',
      path: 'search',
    ),
    TypedGoRoute<ExtensionsSettingsRoute>(
      name: 'ExtensionsSettingsRoute',
      path: 'extensions',
    ),
    TypedGoRoute<AdvancedSettingsRoute>(
      name: 'AdvancedSettingsRoute',
      path: 'advanced',
    ),
    TypedGoRoute<ExperimentalSettingsRoute>(
      name: 'ExperimentalSettingsRoute',
      path: 'experimental',
    ),
    TypedGoRoute<WebPushSettingsRoute>(
      name: 'WebPushSettingsRoute',
      path: 'push',
    ),
    TypedGoRoute<BangSettingsRoute>(name: 'BangSettingsRoute', path: 'bang'),
    TypedGoRoute<WebEngineHardeningRoute>(
      name: 'WebEngineHardeningRoute',
      path: 'hardening',
      routes: [
        TypedGoRoute<WebEngineHardeningGroupRoute>(
          name: 'WebEngineHardeningGroupRoute',
          path: 'group/:group',
        ),
      ],
    ),
    TypedGoRoute<DohSettingsRoute>(name: 'DohSettingsRoute', path: 'doh'),
    TypedGoRoute<FingerprintSettingsRoute>(
      name: 'FingerprintSettingsRoute',
      path: 'fingerprint',
    ),
    TypedGoRoute<LocaleSettingsRoute>(
      name: 'LocaleSettingsRoute',
      path: 'locales',
    ),
    TypedGoRoute<AddonCollectionRoute>(
      name: 'AddonCollectionRoute',
      path: 'addon_collection',
    ),
    TypedGoRoute<UBlockFilterListsRoute>(
      name: 'UBlockFilterListsRoute',
      path: 'ublock_filter_lists',
    ),
    TypedGoRoute<TrackingProtectionExceptionsRoute>(
      name: 'TrackingProtectionExceptionsRoute',
      path: 'tracking_protection_exceptions',
    ),
    TypedGoRoute<CustomTrackingProtectionRoute>(
      name: 'CustomTrackingProtectionRoute',
      path: 'custom_tracking_protection',
    ),
    TypedGoRoute<ErrorLogsRoute>(name: 'ErrorLogsRoute', path: 'error_logs'),
    TypedGoRoute<AccountSettingsRoute>(
      name: 'AccountSettingsRoute',
      path: 'account',
    ),
    TypedGoRoute<SyncSettingsRoute>(name: 'SyncSettingsRoute', path: 'sync'),
    TypedGoRoute<UrlCleanerSettingsRoute>(
      name: 'UrlCleanerSettingsRoute',
      path: 'url_cleaner',
    ),
    TypedGoRoute<UnshortenerSettingsRoute>(
      name: 'UnshortenerSettingsRoute',
      path: 'unshortener',
    ),
    TypedGoRoute<HomeSettingsRoute>(name: 'HomeSettingsRoute', path: 'home'),
    TypedGoRoute<HomeModulesSettingsRoute>(
      name: 'HomeModulesSettingsRoute',
      path: 'home_modules',
    ),
    TypedGoRoute<NewTabModulesSettingsRoute>(
      name: 'NewTabModulesSettingsRoute',
      path: 'new_tab_modules',
    ),
    TypedGoRoute<WallpaperSettingsRoute>(
      name: 'WallpaperSettingsRoute',
      path: 'wallpaper',
    ),
    TypedGoRoute<ContextualToolbarSettingsRoute>(
      name: 'ContextualToolbarSettingsRoute',
      path: 'contextual_toolbar',
    ),
    TypedGoRoute<QuickSwitcherToolbarSettingsRoute>(
      name: 'QuickSwitcherToolbarSettingsRoute',
      path: 'quick_switcher_toolbar',
    ),
    TypedGoRoute<DesktopModeSitesRoute>(
      name: 'DesktopModeSitesRoute',
      path: 'desktop_mode_sites',
    ),
    TypedGoRoute<SingboxProxyProfilesRoute>(
      name: 'SingboxProxyProfilesRoute',
      path: 'singbox_proxy_profiles',
      routes: [
        TypedGoRoute<SingboxProxyProfileEditorRoute>(
          name: 'SingboxProxyProfileEditorRoute',
          path: 'editor',
        ),
        TypedGoRoute<SingboxProxyLogsRoute>(
          name: 'SingboxProxyLogsRoute',
          path: 'logs',
        ),
        TypedGoRoute<SubscriptionImportRoute>(
          name: 'SubscriptionImportRoute',
          path: 'subscription',
        ),
      ],
    ),
    TypedGoRoute<ProxyRoutingSettingsRoute>(
      name: 'ProxyRoutingSettingsRoute',
      path: 'proxy_routing',
    ),
    TypedGoRoute<ProxySettingsRoute>(name: 'ProxySettingsRoute', path: 'proxy'),
  ],
)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

class GeneralSettingsRoute extends GoRouteData with $GeneralSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const GeneralSettingsScreen();
  }
}

class SettingsTransferRoute extends GoRouteData with $SettingsTransferRoute {
  const SettingsTransferRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsTransferScreen();
  }
}

class BrowsingSettingsRoute extends GoRouteData with $BrowsingSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BrowsingSettingsScreen();
  }
}

class GestureSettingsRoute extends GoRouteData with $GestureSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const GestureSettingsScreen();
  }
}

class PrivacySecuritySettingsRoute extends GoRouteData
    with $PrivacySecuritySettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PrivacySecuritySettingsScreen();
  }
}

class ToolbarLayoutSettingsRoute extends GoRouteData
    with $ToolbarLayoutSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ToolbarLayoutSettingsScreen();
  }
}

class WebContentSettingsRoute extends GoRouteData
    with $WebContentSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebContentSettingsScreen();
  }
}

class SearchSettingsRoute extends GoRouteData with $SearchSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SearchSettingsScreen();
  }
}

class ExtensionsSettingsRoute extends GoRouteData
    with $ExtensionsSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExtensionsSettingsScreen();
  }
}

class AdvancedSettingsRoute extends GoRouteData with $AdvancedSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdvancedSettingsScreen();
  }
}

class ExperimentalSettingsRoute extends GoRouteData
    with $ExperimentalSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExperimentalSettingsScreen();
  }
}

class WebPushSettingsRoute extends GoRouteData with $WebPushSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebPushSettingsScreen();
  }
}

class BangSettingsRoute extends GoRouteData with $BangSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangSettingsScreen();
  }
}

class DohSettingsRoute extends GoRouteData with $DohSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DohSettingsScreen();
  }
}

class FingerprintSettingsRoute extends GoRouteData
    with $FingerprintSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FingerprintSettingsScreen();
  }
}

class LocaleSettingsRoute extends GoRouteData with $LocaleSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LocaleSettingsScreen();
  }
}

class AddonCollectionRoute extends GoRouteData with $AddonCollectionRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddonCollectionScreen();
  }
}

class UBlockFilterListsRoute extends GoRouteData with $UBlockFilterListsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UBlockFilterListsScreen();
  }
}

class WebEngineHardeningRoute extends GoRouteData
    with $WebEngineHardeningRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebEngineHardeningScreen();
  }
}

class WebEngineHardeningGroupRoute extends GoRouteData
    with $WebEngineHardeningGroupRoute {
  final String group;

  const WebEngineHardeningGroupRoute({required this.group});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WebEngineHardeningGroupScreen(groupName: group);
  }
}

class TrackingProtectionExceptionsRoute extends GoRouteData
    with $TrackingProtectionExceptionsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TrackingProtectionExceptionsScreen();
  }
}

class ErrorLogsRoute extends GoRouteData with $ErrorLogsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ErrorLogsScreen();
  }
}

class CustomTrackingProtectionRoute extends GoRouteData
    with $CustomTrackingProtectionRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CustomTrackingProtectionScreen();
  }
}

class AccountSettingsRoute extends GoRouteData with $AccountSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AccountSettingsScreen();
  }
}

class SyncSettingsRoute extends GoRouteData with $SyncSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SyncSettingsScreen();
  }
}

class UrlCleanerSettingsRoute extends GoRouteData
    with $UrlCleanerSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UrlCleanerSettingsScreen();
  }
}

class UnshortenerSettingsRoute extends GoRouteData
    with $UnshortenerSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UnshortenerSettingsScreen();
  }
}

class HomeSettingsRoute extends GoRouteData with $HomeSettingsRoute {
  const HomeSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeSettingsScreen();
  }
}

class HomeModulesSettingsRoute extends GoRouteData
    with $HomeModulesSettingsRoute {
  const HomeModulesSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ModuleSurfaceSettingsScreen();
  }
}

class WallpaperSettingsRoute extends GoRouteData with $WallpaperSettingsRoute {
  const WallpaperSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WallpaperSettingsScreen();
  }
}

class NewTabModulesSettingsRoute extends GoRouteData
    with $NewTabModulesSettingsRoute {
  const NewTabModulesSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ModuleSurfaceSettingsScreen(
      surface: ModuleSurface.newTab,
      title: 'Customize New Tab',
    );
  }
}

class ContextualToolbarSettingsRoute extends GoRouteData
    with $ContextualToolbarSettingsRoute {
  const ContextualToolbarSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContextualToolbarSettingsScreen();
  }
}

class QuickSwitcherToolbarSettingsRoute extends GoRouteData
    with $QuickSwitcherToolbarSettingsRoute {
  const QuickSwitcherToolbarSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContextualToolbarSettingsScreen(
      location: ToolbarConfigLocation.quickSwitcher,
      title: 'Customize Switcher Buttons',
    );
  }
}

class DesktopModeSitesRoute extends GoRouteData with $DesktopModeSitesRoute {
  const DesktopModeSitesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DesktopModeSitesScreen();
  }
}

class SingboxProxyProfilesRoute extends GoRouteData
    with $SingboxProxyProfilesRoute {
  const SingboxProxyProfilesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SingboxProxyProfilesScreen();
  }
}

class SingboxProxyProfileEditorRoute extends GoRouteData
    with $SingboxProxyProfileEditorRoute {
  final String? profileId;
  final ProxyProfileSeed? $extra;

  const SingboxProxyProfileEditorRoute({this.profileId, this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SingboxProxyProfileEditorScreen(profileId: profileId, seed: $extra);
  }
}

class SingboxProxyLogsRoute extends GoRouteData with $SingboxProxyLogsRoute {
  const SingboxProxyLogsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SingboxProxyLogsScreen();
  }
}

class SubscriptionImportRoute extends GoRouteData
    with $SubscriptionImportRoute {
  const SubscriptionImportRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SubscriptionImportScreen();
  }
}

class ProxyRoutingSettingsRoute extends GoRouteData
    with $ProxyRoutingSettingsRoute {
  const ProxyRoutingSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProxyRoutingSettingsScreen();
  }
}

class ProxySettingsRoute extends GoRouteData with $ProxySettingsRoute {
  const ProxySettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProxySettingsScreen();
  }
}
