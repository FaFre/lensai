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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show AppLinksMode;
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/home_target.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/wallpaper/domain/entities/home_wallpaper.dart';

part 'general_settings.g.dart';

const _fallbackSearchProvider = BangKey(
  group: BangGroup.general,
  trigger: 'wikipedia',
);
const _fallbackAutocompleteProvider = SearchSuggestionProviders.none;

const defaultUiScaleFactor = 1.0;
const minUiScaleFactor = 0.5;
const maxUiScaleFactor = 1.5;
const uiScaleFactorStep = 0.05;

/// Max number of inline chevron glyphs shown on a quick tab switcher chip
/// before the depth indicator collapses into a single icon + count badge.
/// A value of 0 hides the hierarchy indicator entirely.
const defaultQuickTabSwitcherHierarchyGlyphs = 2;
const minQuickTabSwitcherHierarchyGlyphs = 0;
const maxQuickTabSwitcherHierarchyGlyphs = 4;

/// Max width (logical px) of the title text on a quick tab switcher chip.
/// The default of 64 sits at the 1/3 position of the slider scale.
const defaultQuickTabSwitcherTitleWidth = 64.0;
const minQuickTabSwitcherTitleWidth = 32.0;
const maxQuickTabSwitcherTitleWidth = 128.0;
const quickTabSwitcherTitleWidthStep = 8.0;

/// Controls the Android display refresh rate the app requests at startup.
///
/// Flutter does not request a high refresh rate by default, so on many devices
/// (Samsung, OnePlus, Xiaomi, …) the app is left at 60Hz even on a 90/120Hz
/// panel. [high] asks the OS for the fastest available mode, [low] for the
/// slowest (battery saving), and [system] leaves the OS-managed default in
/// place. Android-only; ignored on other platforms.
enum RefreshRateMode { system, high, low }

enum TabBarSwipeAction { switchLastOpened, navigateOrderedTabs }

/// Row kind rendered inside the quick tab switcher bar. [TabBarStackingMode]
/// decides which row(s) are shown; this enum identifies a single row.
enum QuickTabSwitcherMode { lastUsedTabs, containerTabs }

/// Layout of the quick tab switcher bar. Merges the former
/// "show tab switcher bar" toggle and [QuickTabSwitcherMode] selection.
///
/// [accordion] renders all containers as header chips with the selected
/// container's tabs expanded inline. [twoLevel] stacks a container-tabs row
/// on top of a recently-used row. [disabled] hides the bar entirely.
enum TabBarStackingMode {
  lastUsedTabs,
  containerTabs,
  accordion,
  twoLevel,
  disabled,
}

enum TabIntentOpenSetting { regular, private, isolated, ask }

/// Determines what happens when a bookmark is tapped in the bookmark list.
/// [ask] shows the "open in..." sheet (today's behavior, and the default);
/// the other values open the bookmark directly with no intermediate prompt.
enum BookmarkOpenSetting { regular, private, isolated, customTab, ask }

/// What happens after an action opens a new tab in the background — context
/// menu "open in new tab"/"open in container", tab cloning, and the contextual
/// toolbar clone buttons.
///
/// [prompt] keeps the "New tab opened" snackbar with its `Switch` action (the
/// behavior that predates this setting); [switchImmediately] selects the new
/// tab right away and shows no snackbar. Actions the user explicitly asked to
/// happen in the background (e.g. the bookmark list's "Open in Background")
/// always stay in the background and are unaffected.
enum BackgroundTabOpenAction { prompt, switchImmediately }

enum TabDirection { newestFirst, oldestFirst }

enum TabBarPosition {
  top,
  bottom,
  left,
  right;

  /// Whether the tab bar is rendered as a vertical side rail (left/right)
  /// rather than a horizontal bar (top/bottom).
  bool get isVertical =>
      this == TabBarPosition.left || this == TabBarPosition.right;

  /// Whether the tab bar is rendered as a horizontal bar (top/bottom).
  bool get isHorizontal => !isVertical;

  /// Main axis along which the bar's content flows.
  Axis get axis => isVertical ? Axis.vertical : Axis.horizontal;
}

enum TabBarLayout { withTitle, compact }

/// Which tab chips in the quick tab switcher and the tab bar carry a close
/// button.
///
/// [activeTabOnly] is the historic behavior: the chip the user is already on
/// can be closed in place, every other chip only through its long-press menu.
/// [all] puts a button on every chip and [never] on none — the last matters
/// once the active tab is on the bar at all (container-tabs stacking), where
/// the button sits right beside the chip the user taps to go back to it.
///
/// No mode removes a way to close a tab: the chip long-press menu and the tab
/// bar swipe action are untouched throughout. The narrow vertical rail has no
/// room for a close button beside an icon-only chip and behaves as [never]
/// whatever this says.
enum TabChipCloseButtonMode {
  activeTabOnly,
  all,
  never;

  /// Whether the chip for a tab shows its close button.
  bool showsFor({required bool isActive}) => switch (this) {
    TabChipCloseButtonMode.activeTabOnly => isActive,
    TabChipCloseButtonMode.all => true,
    TabChipCloseButtonMode.never => false,
  };
}

/// Where the browser home surface offers its entry into search.
///
/// The home surface has no address field of its own, so exactly one of these
/// two has to be present: the pinned pill at the top of the home content, or
/// the tab bar's own (empty) address field — the behaviour that predates the
/// home surface. [auto] picks whichever sits on the same edge the user already
/// chose for the tab bar, so a bottom tab bar keeps the search entry within
/// thumb reach instead of moving it to the top of the screen.
enum HomeSearchBarPlacement {
  auto,
  top,
  tabBar;

  String get label => switch (this) {
    auto => 'Follow the tab bar',
    top => 'Top of the home page',
    tabBar => 'In the tab bar',
  };

  String get description => switch (this) {
    auto => 'Whichever edge the tab bar is on',
    top => 'A pinned search bar above the home sections',
    tabBar => "The tab bar's address field, with QR and voice search",
  };
}

enum DeleteBrowsingDataType {
  tabs('Open tabs'),
  history('Browsing history'),
  recentSearches('Recent searches', 'Queries shown on the search page'),
  cookies('Cookies and site data', 'You’ll be logged out of most sites'),
  cache('Cached images and files', 'Frees up storage space'),
  permissions('Site permissions'),
  downloads('Downloads');

  final String title;
  final String? description;

  const DeleteBrowsingDataType(this.title, [this.description]);
}

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class GeneralSettings with FastEquatable {
  final ThemeMode themeMode;
  final double uiScaleFactor;
  final bool disableAnimations;

  /// Android display refresh rate requested at startup. See [RefreshRateMode].
  final RefreshRateMode refreshRateMode;
  final bool showModalBarrier;
  final bool enableReadability;
  final bool enforceReadability;
  final Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit;
  final bool screenshotProtectionEnabled;

  /// Whether private tabs may be captured by the system (screenshots, screen
  /// recording, the recents preview). Private tabs mark the window secure by
  /// default; enabling this lifts that restriction. [screenshotProtectionEnabled]
  /// still wins when both are on, because it blocks capture app-wide.
  /// Defaults to false.
  final bool allowPrivateTabScreenshots;
  @BangKeyConverter()
  final BangKey? defaultSearchProvider;

  /// Bangs the user keeps in the search-provider strip regardless of how often
  /// they are used. Frequency-ranked chips churn as habits change; a pin does
  /// not. Ordered, because the order is the user's own.
  @BangKeyListConverter()
  final List<BangKey> pinnedBangs;

  final SearchSuggestionProviders defaultSearchSuggestionsProvider;
  final bool createChildTabsOption;
  final bool enableLocalAiFeatures;
  final bool showContainerUi;
  final bool showIsolatedTabUi;

  /// Whether the search / new-tab page shows a leading close button so it can
  /// be dismissed without a system back button or back gesture (e.g. on e-ink
  /// devices). Defaults to false. Only shown when the route can be popped.
  final bool showSearchCloseButton;

  /// What to land on when there is no tab to show — at cold start, and when
  /// the last tab in scope is closed if [homeTargetOnLastTabClosed] is set.
  final HomeTarget homeTarget;

  /// Address opened when [homeTarget] is [HomeTarget.customUrl]. An unset or
  /// unparseable value falls back to the home surface.
  final String? homeTargetUrl;

  /// Also apply [homeTarget] when the last tab in the current container is
  /// closed, instead of falling through to a tab from somewhere else.
  final bool homeTargetOnLastTabClosed;

  /// Where the home surface's search entry is rendered. See
  /// [HomeSearchBarPlacement] and [effectiveHomeSearchBarPlacement].
  final HomeSearchBarPlacement homeSearchBarPlacement;

  /// The wallpaper shown behind the home surface, as a file name within the
  /// profile's wallpaper directory — never a path. Null means no wallpaper, and
  /// the home surface keeps its aura backdrop.
  ///
  /// A name rather than a path because profile directories move between
  /// installs and restores, and a fresh name per import is also what evicts the
  /// previous image from Flutter's image cache when a wallpaper is replaced.
  /// See `WallpaperStore`.
  final String? homeWallpaperFile;

  /// Gaussian sigma, in logical pixels, applied to [homeWallpaperFile].
  final double homeWallpaperBlur;

  /// How far [homeWallpaperFile] is pulled toward the theme's surface colour,
  /// 0 (untouched) to [maxHomeWallpaperDim].
  ///
  /// The scrim follows the theme rather than always darkening: the home
  /// surface draws its header, container name and section headers in theme
  /// colours directly on top of the image, so in a light theme the image has to
  /// be washed *lighter* for those to stay readable.
  final double homeWallpaperDim;
  @JsonKey(name: 'defaultCreateTabType')
  final TabType storedDefaultCreateTabType;
  final TabDirection tabListDirection;
  final TabDirection tabBarDirection;
  final TabIntentOpenSetting tabIntentOpenSetting;

  /// Determines what happens when a bookmark is tapped. See
  /// [BookmarkOpenSetting] and [effectiveBookmarkOpenSetting].
  final BookmarkOpenSetting bookmarkOpenSetting;

  /// What happens after a tab is opened in the background. See
  /// [BackgroundTabOpenAction].
  final BackgroundTabOpenAction backgroundTabOpenAction;
  final bool autoHideTabBar;
  final TabBarSwipeAction tabBarSwipeAction;

  /// Whether sequential tab navigation (the tab bar swipe and the
  /// next/previous tab gestures) walks past the current container into the
  /// neighbouring one, instead of stopping at the container's own edge.
  final bool sequentialTabNavigationCrossContainers;

  /// Whether sequential tab navigation wraps around: stepping past the last
  /// visible tab continues at the first one and vice versa, instead of the
  /// step doing nothing.
  final bool sequentialTabNavigationLoop;
  final Duration historyAutoCleanInterval;
  final bool tabViewBottomSheet;
  final bool tabBarShowContextualBar;
  final TabBarPosition tabBarPosition;
  final TabBarLayout tabBarLayout;
  final TabBarStackingMode tabBarStackingMode;
  final bool pullToRefreshEnabled;
  final bool useExternalDownloadManager;
  final bool doubleBackCloseTab;
  final Duration unassignedTabsAutoCleanInterval;
  final int maxSearchHistoryEntries;
  final bool allowClipboardAccess;
  final bool tabListShowFavicons;
  final bool quickTabSwitcherShowTitles;
  final int quickTabSwitcherHierarchyGlyphs;
  final bool quickTabSwitcherShowHistorySuggestions;

  /// Max width (logical px) for chip titles in the quick tab switcher.
  final double quickTabSwitcherTitleWidth;

  /// Which tab chips show a close button in the quick tab switcher and the
  /// tab bar.
  final TabChipCloseButtonMode quickTabSwitcherCloseButtonMode;
  final String syncServerOverride;
  final String syncTokenServerOverride;
  final bool urlCleanerEnabled;
  final bool urlCleanerAutoApply;
  final bool urlCleanerAllowReferralMarketing;
  final String urlCleanerCatalogUrl;
  final String urlCleanerHashUrl;
  final bool urlCleanerAutoUpdate;
  final int? urlCleanerLastCheckEpochMs;
  final bool urlCleanerLastUpdateWasAuto;
  final TabType smallWebTabType;
  final bool tabBarLongPressUrlCopy;
  final bool unshortenerEnabled;
  final String unshortenerToken;
  final bool allowNonManifestPwaInstall;
  final bool blockExternalAppsEnabled;
  final Map<String, IntentSourcePolicy> externalAppIntentPolicies;

  /// Whether external Custom Tab intents (and URLs shared into WebLibre) open
  /// in a lightweight custom-tab activity. When false, they open as normal
  /// tabs in the main browser instead. Read natively by `IntentReceiverActivity`
  /// via the intent gatekeeper prefs bridge. Defaults to true.
  final bool customTabsEnabled;

  /// Global app-links behaviour: always open in native apps, ask each time, or
  /// never leave the browser. Defaults to [AppLinksMode.ask]. Per-site rules in
  /// [appLinkRules] and container/proxy protection can override this per-target.
  final AppLinksMode appLinksMode;

  /// Remembered per-scope app-link rules, keyed by canonical scope
  /// (`host:youtube.com` | `pkg:...`). One rule per scope, last write wins.
  /// Malformed entries are dropped on read (see [parseAppLinkRules]).
  @JsonKey(fromJson: parseAppLinkRules)
  final Map<String, PersistedAppLinkRule> appLinkRules;

  /// Per-container app-link overrides for containers with "isolated app link
  /// settings" enabled, keyed by the container's Gecko contextId. Each entry
  /// fully *replaces* the global mode + [appLinkRules] for navigations in that
  /// container (replace semantics). Containers without isolation have no entry
  /// and fall back to the global policy. Malformed entries dropped on read.
  @JsonKey(fromJson: parseAppLinkContextOverrides)
  final Map<String, ContextAppLinkPolicy> appLinkContextOverrides;

  /// Whether an install-app (marketplace) intent is offered when an app link
  /// resolves to no installed app and has no validated http(s) fallback.
  /// Defaults to false — the wrong default for a de-Googled browser.
  final bool appLinkMarketplaceFallback;

  /// Whether app-link "never" rules allow a same-caller Custom Tab / ActionView
  /// login callback to return to the app that opened the browser. Defaults to
  /// true to keep OAuth-style sign-in flows working while normal app links still
  /// obey [appLinksMode].
  final bool appLinkAuthExceptionsEnabled;

  /// Whether an http(s) app-link prompt holds its navigation instead of letting
  /// the page load behind the banner (§2.2). Defaults to false, which keeps the
  /// non-blocking behaviour: the page loads while the banner is up, so the site
  /// sees one request even when the user picks the app. With this on, the tab
  /// stays on its previous page until the prompt is answered, and declining
  /// loads the page then. Only meaningful under [AppLinksMode.ask]; prompts for
  /// unsupported schemes always hold their navigation regardless.
  final bool appLinkBlockWhilePrompting;

  /// Whether the local search index (`history` table populated via tab→
  /// history triggers) is active. When false, the SQL trigger guard returns
  /// without writing; existing rows stay until the user clears them.
  final bool enableLocalSearchIndex;

  /// Whether private tabs feed the local search index. Defaults to false.
  final bool indexPrivateTabs;

  /// Whether pressing the keyboard submit/enter button should automatically
  /// accept and complete an inline search suggestion. Defaults to false.
  final bool acceptSuggestionOnSubmit;

  /// Whether the bundled Tranco-derived popular-domain list may supply the
  /// omnibar's inline ghost-text completion when the engine's own autocomplete
  /// (history/top domains) has no match. Defaults to true.
  final bool popularSitesAutocompleteEnabled;

  /// Whether dark mode should use pure-black ("OLED"/high-contrast) surfaces.
  /// Only takes effect when the effective brightness is dark. Defaults to false.
  final bool pureBlack;

  /// Browser-wide default desktop mode. When true, newly opened tabs request
  /// the desktop version of sites by default. The per-tab desktop-mode toggle
  /// still overrides this for an individual tab. Defaults to false.
  final bool globalDesktopMode;

  /// Hosts that should always load in desktop mode. A tab navigating to a
  /// matching host (or any of its subdomains) is switched to desktop mode,
  /// overriding [globalDesktopMode] for that visit. See `hostMatchesRule`.
  final List<String> desktopModeSites;

  /// Developer setting: when true, the GeckoView is unmounted whenever a
  /// full-cover route (settings, tab tray, search, …) is on top, freeing the
  /// engine's resources while it is occluded. On Android 12 and lower (API
  /// <= 31) this behavior is always applied to work around a native
  /// visibility bug; on Android 13+ the engine normally stays mounted to
  /// avoid reload/flicker, and this flag opts into the off-route unmounting
  /// there too. Defaults to false.
  ///
  /// It is not the answer to a stale engine surface left on top of an overlay:
  /// unmounting only hid that by destroying the platform view, and never
  /// covered the home surface, which does not unmount at all. `GeckoView`
  /// handles that wherever it happens now — see `GeckoView.isPainted` — so what
  /// is left here is the memory trade this describes.
  final bool unmountGeckoViewOffRoute;

  GeneralSettings({
    required this.themeMode,
    required this.uiScaleFactor,
    required this.disableAnimations,
    required this.refreshRateMode,
    required this.showModalBarrier,
    required this.enableReadability,
    required this.enforceReadability,
    required this.deleteBrowsingDataOnQuit,
    required this.screenshotProtectionEnabled,
    required this.allowPrivateTabScreenshots,
    required this.defaultSearchProvider,
    required this.pinnedBangs,
    required this.defaultSearchSuggestionsProvider,
    required this.createChildTabsOption,
    required this.enableLocalAiFeatures,
    required this.showContainerUi,
    required this.showIsolatedTabUi,
    required this.showSearchCloseButton,
    required this.homeTarget,
    required this.homeTargetUrl,
    required this.homeTargetOnLastTabClosed,
    required this.homeSearchBarPlacement,
    required this.homeWallpaperFile,
    required this.homeWallpaperBlur,
    required this.homeWallpaperDim,
    required this.storedDefaultCreateTabType,
    required this.tabListDirection,
    required this.tabBarDirection,
    required this.tabIntentOpenSetting,
    required this.bookmarkOpenSetting,
    required this.backgroundTabOpenAction,
    required this.autoHideTabBar,
    required this.tabBarSwipeAction,
    required this.sequentialTabNavigationCrossContainers,
    required this.sequentialTabNavigationLoop,
    required this.historyAutoCleanInterval,
    required this.tabViewBottomSheet,
    required this.tabBarShowContextualBar,
    required this.tabBarPosition,
    required this.tabBarLayout,
    required this.tabBarStackingMode,
    required this.pullToRefreshEnabled,
    required this.useExternalDownloadManager,
    required this.doubleBackCloseTab,
    required this.unassignedTabsAutoCleanInterval,
    required this.maxSearchHistoryEntries,
    required this.allowClipboardAccess,
    required this.tabListShowFavicons,
    required this.quickTabSwitcherShowTitles,
    required this.quickTabSwitcherHierarchyGlyphs,
    required this.quickTabSwitcherShowHistorySuggestions,
    required this.quickTabSwitcherTitleWidth,
    required this.quickTabSwitcherCloseButtonMode,
    required this.syncServerOverride,
    required this.syncTokenServerOverride,
    required this.urlCleanerEnabled,
    required this.urlCleanerAutoApply,
    required this.urlCleanerAllowReferralMarketing,
    required this.urlCleanerCatalogUrl,
    required this.urlCleanerHashUrl,
    required this.urlCleanerAutoUpdate,
    required this.urlCleanerLastCheckEpochMs,
    required this.urlCleanerLastUpdateWasAuto,
    required this.smallWebTabType,
    required this.tabBarLongPressUrlCopy,
    required this.unshortenerEnabled,
    required this.unshortenerToken,
    required this.allowNonManifestPwaInstall,
    required this.blockExternalAppsEnabled,
    required this.externalAppIntentPolicies,
    required this.customTabsEnabled,
    required this.appLinksMode,
    required this.appLinkRules,
    required this.appLinkContextOverrides,
    required this.appLinkMarketplaceFallback,
    required this.appLinkAuthExceptionsEnabled,
    required this.appLinkBlockWhilePrompting,
    required this.enableLocalSearchIndex,
    required this.indexPrivateTabs,
    required this.acceptSuggestionOnSubmit,
    required this.popularSitesAutocompleteEnabled,
    required this.pureBlack,
    required this.globalDesktopMode,
    required this.desktopModeSites,
    required this.unmountGeckoViewOffRoute,
  });

  GeneralSettings.withDefaults({
    ThemeMode? themeMode,
    double? uiScaleFactor,
    bool? disableAnimations,
    RefreshRateMode? refreshRateMode,
    bool? showModalBarrier,
    bool? enableReadability,
    bool? enforceReadability,
    this.deleteBrowsingDataOnQuit,
    bool? screenshotProtectionEnabled,
    bool? allowPrivateTabScreenshots,
    BangKey? defaultSearchProvider,
    List<BangKey>? pinnedBangs,
    SearchSuggestionProviders? defaultSearchSuggestionsProvider,
    bool? createChildTabsOption,
    bool? enableLocalAiFeatures,
    bool? showContainerUi,
    bool? showIsolatedTabUi,
    bool? showSearchCloseButton,
    HomeTarget? homeTarget,
    this.homeTargetUrl,
    bool? homeTargetOnLastTabClosed,
    HomeSearchBarPlacement? homeSearchBarPlacement,
    this.homeWallpaperFile,
    double? homeWallpaperBlur,
    double? homeWallpaperDim,
    TabType? storedDefaultCreateTabType,
    TabDirection? tabListDirection,
    TabDirection? tabBarDirection,
    TabIntentOpenSetting? tabIntentOpenSetting,
    BookmarkOpenSetting? bookmarkOpenSetting,
    BackgroundTabOpenAction? backgroundTabOpenAction,
    bool? autoHideTabBar,
    TabBarSwipeAction? tabBarSwipeAction,
    bool? sequentialTabNavigationCrossContainers,
    bool? sequentialTabNavigationLoop,
    Duration? historyAutoCleanInterval,
    bool? tabViewBottomSheet,
    bool? tabBarShowContextualBar,
    TabBarPosition? tabBarPosition,
    TabBarLayout? tabBarLayout,
    TabBarStackingMode? tabBarStackingMode,
    bool? pullToRefreshEnabled,
    bool? useExternalDownloadManager,
    bool? doubleBackCloseTab,
    Duration? unassignedTabsAutoCleanInterval,
    int? maxSearchHistoryEntries,
    bool? allowClipboardAccess,
    bool? tabListShowFavicons,
    bool? quickTabSwitcherShowTitles,
    int? quickTabSwitcherHierarchyGlyphs,
    bool? quickTabSwitcherShowHistorySuggestions,
    double? quickTabSwitcherTitleWidth,
    TabChipCloseButtonMode? quickTabSwitcherCloseButtonMode,
    String? syncServerOverride,
    String? syncTokenServerOverride,
    bool? urlCleanerEnabled,
    bool? urlCleanerAutoApply,
    bool? urlCleanerAllowReferralMarketing,
    String? urlCleanerCatalogUrl,
    String? urlCleanerHashUrl,
    bool? urlCleanerAutoUpdate,
    this.urlCleanerLastCheckEpochMs,
    bool? urlCleanerLastUpdateWasAuto,
    TabType? smallWebTabType,
    bool? tabBarLongPressUrlCopy,
    bool? unshortenerEnabled,
    String? unshortenerToken,
    bool? allowNonManifestPwaInstall,
    bool? blockExternalAppsEnabled,
    Map<String, IntentSourcePolicy>? externalAppIntentPolicies,
    bool? customTabsEnabled,
    AppLinksMode? appLinksMode,
    Map<String, PersistedAppLinkRule>? appLinkRules,
    Map<String, ContextAppLinkPolicy>? appLinkContextOverrides,
    bool? appLinkMarketplaceFallback,
    bool? appLinkAuthExceptionsEnabled,
    bool? appLinkBlockWhilePrompting,
    bool? enableLocalSearchIndex,
    bool? indexPrivateTabs,
    bool? acceptSuggestionOnSubmit,
    bool? popularSitesAutocompleteEnabled,
    bool? pureBlack,
    bool? globalDesktopMode,
    List<String>? desktopModeSites,
    bool? unmountGeckoViewOffRoute,
  }) : themeMode = themeMode ?? ThemeMode.dark,
       uiScaleFactor = uiScaleFactor ?? defaultUiScaleFactor,
       disableAnimations = disableAnimations ?? false,
       refreshRateMode = refreshRateMode ?? RefreshRateMode.high,
       showModalBarrier = showModalBarrier ?? true,
       enableReadability = enableReadability ?? true,
       enforceReadability = enforceReadability ?? false,
       screenshotProtectionEnabled = screenshotProtectionEnabled ?? false,
       allowPrivateTabScreenshots = allowPrivateTabScreenshots ?? false,
       defaultSearchProvider = defaultSearchProvider ?? _fallbackSearchProvider,
       pinnedBangs = pinnedBangs ?? const [],
       defaultSearchSuggestionsProvider =
           defaultSearchSuggestionsProvider ?? _fallbackAutocompleteProvider,
       createChildTabsOption = createChildTabsOption ?? false,
       enableLocalAiFeatures = enableLocalAiFeatures ?? true,
       showContainerUi = showContainerUi ?? true,
       showIsolatedTabUi = showIsolatedTabUi ?? true,
       showSearchCloseButton = showSearchCloseButton ?? false,
       // Defaults to `home`, which is exactly what the browser did before this
       // setting existed. Anything else would change startup for every user.
       homeTarget = homeTarget ?? HomeTarget.home,
       homeTargetOnLastTabClosed = homeTargetOnLastTabClosed ?? false,
       // Deliberately not a fixed edge: the placement that matches the user's
       // tab bar position is the one they can reach.
       homeSearchBarPlacement =
           homeSearchBarPlacement ?? HomeSearchBarPlacement.auto,
       // Clamped on the way in: these reach the widget tree as an ImageFilter
       // sigma and a colour alpha, and a value read back from a hand-edited
       // database must not be able to hand either one something invalid.
       homeWallpaperBlur = (homeWallpaperBlur ?? 0).clamp(
         0,
         maxHomeWallpaperBlur,
       ),
       homeWallpaperDim = (homeWallpaperDim ?? defaultHomeWallpaperDim).clamp(
         0,
         maxHomeWallpaperDim,
       ),
       storedDefaultCreateTabType =
           storedDefaultCreateTabType ?? TabType.regular,
       tabListDirection = tabListDirection ?? TabDirection.newestFirst,
       tabBarDirection = tabBarDirection ?? TabDirection.newestFirst,
       tabIntentOpenSetting = tabIntentOpenSetting ?? TabIntentOpenSetting.ask,
       bookmarkOpenSetting = bookmarkOpenSetting ?? BookmarkOpenSetting.ask,
       backgroundTabOpenAction =
           backgroundTabOpenAction ?? BackgroundTabOpenAction.prompt,
       autoHideTabBar = autoHideTabBar ?? true,
       tabBarSwipeAction =
           tabBarSwipeAction ?? TabBarSwipeAction.switchLastOpened,
       // Defaults to the behavior sequential navigation shipped with: stepping
       // off a container's edge continues in the next one.
       sequentialTabNavigationCrossContainers =
           sequentialTabNavigationCrossContainers ?? true,
       sequentialTabNavigationLoop = sequentialTabNavigationLoop ?? false,
       historyAutoCleanInterval =
           historyAutoCleanInterval ?? const Duration(days: 90),
       tabViewBottomSheet = tabViewBottomSheet ?? false,
       tabBarShowContextualBar = tabBarShowContextualBar ?? true,
       tabBarPosition = tabBarPosition ?? TabBarPosition.bottom,
       tabBarLayout = tabBarLayout ?? TabBarLayout.compact,
       tabBarStackingMode = tabBarStackingMode ?? TabBarStackingMode.accordion,
       pullToRefreshEnabled = pullToRefreshEnabled ?? true,
       useExternalDownloadManager = useExternalDownloadManager ?? false,
       doubleBackCloseTab = doubleBackCloseTab ?? true,
       unassignedTabsAutoCleanInterval =
           unassignedTabsAutoCleanInterval ?? Duration.zero,
       maxSearchHistoryEntries = maxSearchHistoryEntries ?? 5,
       allowClipboardAccess = allowClipboardAccess ?? true,
       tabListShowFavicons = tabListShowFavicons ?? false,
       quickTabSwitcherShowTitles = quickTabSwitcherShowTitles ?? true,
       quickTabSwitcherHierarchyGlyphs =
           quickTabSwitcherHierarchyGlyphs ??
           defaultQuickTabSwitcherHierarchyGlyphs,
       quickTabSwitcherShowHistorySuggestions =
           quickTabSwitcherShowHistorySuggestions ?? true,
       quickTabSwitcherTitleWidth =
           quickTabSwitcherTitleWidth ?? defaultQuickTabSwitcherTitleWidth,
       quickTabSwitcherCloseButtonMode =
           quickTabSwitcherCloseButtonMode ??
           TabChipCloseButtonMode.activeTabOnly,
       syncServerOverride = syncServerOverride ?? '',
       syncTokenServerOverride = syncTokenServerOverride ?? '',
       urlCleanerEnabled = urlCleanerEnabled ?? true,
       urlCleanerAutoApply = urlCleanerAutoApply ?? false,
       urlCleanerAllowReferralMarketing =
           urlCleanerAllowReferralMarketing ?? false,
       urlCleanerCatalogUrl =
           urlCleanerCatalogUrl ??
           'https://rules2.clearurls.xyz/data.minify.json',
       urlCleanerHashUrl =
           urlCleanerHashUrl ??
           'https://rules2.clearurls.xyz/rules.minify.hash',
       urlCleanerAutoUpdate = urlCleanerAutoUpdate ?? false,
       urlCleanerLastUpdateWasAuto = urlCleanerLastUpdateWasAuto ?? false,
       smallWebTabType = smallWebTabType ?? TabType.private,
       tabBarLongPressUrlCopy = tabBarLongPressUrlCopy ?? true,
       unshortenerEnabled = unshortenerEnabled ?? false,
       unshortenerToken = unshortenerToken ?? '',
       allowNonManifestPwaInstall = allowNonManifestPwaInstall ?? false,
       blockExternalAppsEnabled = blockExternalAppsEnabled ?? false,
       externalAppIntentPolicies = externalAppIntentPolicies ?? const {},
       customTabsEnabled = customTabsEnabled ?? true,
       appLinksMode = appLinksMode ?? AppLinksMode.ask,
       appLinkRules = appLinkRules ?? const {},
       appLinkContextOverrides = appLinkContextOverrides ?? const {},
       appLinkMarketplaceFallback = appLinkMarketplaceFallback ?? false,
       appLinkAuthExceptionsEnabled = appLinkAuthExceptionsEnabled ?? true,
       appLinkBlockWhilePrompting = appLinkBlockWhilePrompting ?? false,
       enableLocalSearchIndex = enableLocalSearchIndex ?? true,
       indexPrivateTabs = indexPrivateTabs ?? false,
       acceptSuggestionOnSubmit = acceptSuggestionOnSubmit ?? true,
       popularSitesAutocompleteEnabled =
           popularSitesAutocompleteEnabled ?? true,
       pureBlack = pureBlack ?? false,
       globalDesktopMode = globalDesktopMode ?? false,
       desktopModeSites = desktopModeSites ?? const [],
       unmountGeckoViewOffRoute = unmountGeckoViewOffRoute ?? false;

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    // Migrate legacy `newTabPosition` setting to direction settings.
    // Old `first` (new tabs at top) → newestFirst; `end` → oldestFirst.
    // TODO: Drop this fallback (and the `newTabPosition` row in the user
    // settings DB) once enough releases have shipped that rolling back to a
    // version without `tabListDirection`/`tabBarDirection` is no longer a
    // concern.
    final legacyNewTabPosition = json['newTabPosition'];
    if (legacyNewTabPosition != null) {
      final mapped = legacyNewTabPosition == 'end'
          ? 'oldestFirst'
          : 'newestFirst';
      json.putIfAbsent('tabListDirection', () => mapped);
      json.putIfAbsent('tabBarDirection', () => mapped);
    }

    // Migrate the legacy `tabBarShowQuickTabSwitcherBar` toggle and
    // `quickTabSwitcherMode` selection to the merged `tabBarStackingMode`.
    // The legacy mode names are a subset of the new enum's, so values map
    // verbatim.
    // TODO: Drop this fallback (and the legacy rows in the user settings DB)
    // once enough releases have shipped that rolling back to a version
    // without `tabBarStackingMode` is no longer a concern.
    final legacyShowSwitcherBar = json['tabBarShowQuickTabSwitcherBar'];
    final legacySwitcherMode = json['quickTabSwitcherMode'];
    if (json['tabBarStackingMode'] == null) {
      if (legacyShowSwitcherBar == false) {
        json['tabBarStackingMode'] = 'disabled';
      } else if (legacySwitcherMode != null) {
        json['tabBarStackingMode'] = legacySwitcherMode;
      }
    }

    // Migrate the legacy `quickTabSwitcherShowCloseButtonOnAllTabs` toggle to
    // the three-state `quickTabSwitcherCloseButtonMode`. The toggle could only
    // spell out `all` and `activeTabOnly`; `never` is new, so an unset mode
    // with the toggle off is just the default.
    // TODO: Drop this fallback (and the legacy row in the user settings DB)
    // once enough releases have shipped that rolling back to a version
    // without `quickTabSwitcherCloseButtonMode` is no longer a concern.
    if (json['quickTabSwitcherCloseButtonMode'] == null &&
        json['quickTabSwitcherShowCloseButtonOnAllTabs'] == true) {
      json['quickTabSwitcherCloseButtonMode'] = 'all';
    }

    return _$GeneralSettingsFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);

  TabType get effectiveDefaultCreateTabType {
    if (!showIsolatedTabUi && storedDefaultCreateTabType == TabType.isolated) {
      return TabType.regular;
    }
    return storedDefaultCreateTabType;
  }

  TabType get effectiveSmallWebTabType {
    if (!showIsolatedTabUi && smallWebTabType == TabType.isolated) {
      return TabType.private;
    }
    return smallWebTabType;
  }

  TabIntentOpenSetting get effectiveTabIntentOpenSetting {
    if (!showIsolatedTabUi &&
        tabIntentOpenSetting == TabIntentOpenSetting.isolated) {
      return TabIntentOpenSetting.ask;
    }
    return tabIntentOpenSetting;
  }

  BookmarkOpenSetting get effectiveBookmarkOpenSetting {
    if (!showIsolatedTabUi &&
        bookmarkOpenSetting == BookmarkOpenSetting.isolated) {
      return BookmarkOpenSetting.ask;
    }
    return bookmarkOpenSetting;
  }

  /// Keeping sequential navigation inside one container only means something
  /// while the user can switch containers at all: with the container UI hidden
  /// there is no selected container to stay in, so the walk spans everything.
  bool get effectiveSequentialTabNavigationCrossContainers =>
      sequentialTabNavigationCrossContainers || !showContainerUi;

  /// [homeSearchBarPlacement] with [HomeSearchBarPlacement.auto] resolved
  /// against the tab bar's position, so callers never have to. Never returns
  /// [HomeSearchBarPlacement.auto].
  ///
  /// Only a bottom tab bar resolves to [HomeSearchBarPlacement.tabBar]: a top
  /// bar puts its address field next to the pill's own position anyway, and on
  /// the vertical side rail the address field is rotated 90 degrees, which is
  /// a poor search entry to hand someone as their only one.
  HomeSearchBarPlacement effectiveHomeSearchBarPlacement() =>
      switch (homeSearchBarPlacement) {
        HomeSearchBarPlacement.auto =>
          tabBarPosition == TabBarPosition.bottom
              ? HomeSearchBarPlacement.tabBar
              : HomeSearchBarPlacement.top,
        final placement => placement,
      };

  /// Container-dependent stacking modes degrade to a single recently-used
  /// row when the container UI is disabled. Two-level stacking additionally
  /// degrades to accordion (the default mode, which has a vertical form) on the
  /// narrow vertical rail, where two stacked chip lists have no room.
  TabBarStackingMode effectiveTabBarStackingMode() {
    var mode = tabBarStackingMode;

    if (tabBarPosition.isVertical && mode == TabBarStackingMode.twoLevel) {
      mode = TabBarStackingMode.accordion;
    }

    if (!showContainerUi &&
        const {
          TabBarStackingMode.containerTabs,
          TabBarStackingMode.accordion,
          TabBarStackingMode.twoLevel,
        }.contains(mode)) {
      return TabBarStackingMode.lastUsedTabs;
    }

    return mode;
  }

  @override
  List<Object?> get hashParameters => [
    themeMode,
    uiScaleFactor,
    disableAnimations,
    refreshRateMode,
    showModalBarrier,
    enableReadability,
    enforceReadability,
    deleteBrowsingDataOnQuit,
    screenshotProtectionEnabled,
    allowPrivateTabScreenshots,
    defaultSearchProvider,
    pinnedBangs,
    defaultSearchSuggestionsProvider,
    createChildTabsOption,
    enableLocalAiFeatures,
    showContainerUi,
    showIsolatedTabUi,
    showSearchCloseButton,
    homeTarget,
    homeTargetUrl,
    homeTargetOnLastTabClosed,
    homeSearchBarPlacement,
    homeWallpaperFile,
    homeWallpaperBlur,
    homeWallpaperDim,
    storedDefaultCreateTabType,
    tabListDirection,
    tabBarDirection,
    tabIntentOpenSetting,
    bookmarkOpenSetting,
    backgroundTabOpenAction,
    autoHideTabBar,
    tabBarSwipeAction,
    sequentialTabNavigationCrossContainers,
    sequentialTabNavigationLoop,
    historyAutoCleanInterval,
    tabViewBottomSheet,
    tabBarShowContextualBar,
    tabBarPosition,
    tabBarLayout,
    tabBarStackingMode,
    pullToRefreshEnabled,
    useExternalDownloadManager,
    doubleBackCloseTab,
    unassignedTabsAutoCleanInterval,
    maxSearchHistoryEntries,
    allowClipboardAccess,
    tabListShowFavicons,
    quickTabSwitcherShowTitles,
    quickTabSwitcherHierarchyGlyphs,
    quickTabSwitcherShowHistorySuggestions,
    quickTabSwitcherTitleWidth,
    quickTabSwitcherCloseButtonMode,
    syncServerOverride,
    syncTokenServerOverride,
    urlCleanerEnabled,
    urlCleanerAutoApply,
    urlCleanerAllowReferralMarketing,
    urlCleanerCatalogUrl,
    urlCleanerHashUrl,
    urlCleanerAutoUpdate,
    urlCleanerLastCheckEpochMs,
    urlCleanerLastUpdateWasAuto,
    smallWebTabType,
    tabBarLongPressUrlCopy,
    unshortenerEnabled,
    unshortenerToken,
    allowNonManifestPwaInstall,
    blockExternalAppsEnabled,
    externalAppIntentPolicies,
    customTabsEnabled,
    appLinksMode,
    appLinkRules,
    appLinkContextOverrides,
    appLinkMarketplaceFallback,
    appLinkAuthExceptionsEnabled,
    appLinkBlockWhilePrompting,
    enableLocalSearchIndex,
    indexPrivateTabs,
    acceptSuggestionOnSubmit,
    popularSitesAutocompleteEnabled,
    pureBlack,
    globalDesktopMode,
    desktopModeSites,
    unmountGeckoViewOffRoute,
  ];
}
