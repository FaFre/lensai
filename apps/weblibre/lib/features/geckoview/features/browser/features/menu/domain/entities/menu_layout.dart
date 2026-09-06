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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/utils/ordered_layout.dart';

part 'menu_layout.g.dart';

/// One card (or bar) of the browser menu sheet.
///
/// Sections are the coarse unit the user arranges: they can be reordered
/// against each other and switched off entirely. What lives *inside* a section
/// is a [MenuItemType], and items never move between sections — the grouping is
/// part of the design, only the order within it is the user's.
enum MenuSectionType {
  /// Segmented Desktop / Reader / Gestures bar at the top of the sheet.
  quickToggles,

  /// Actions on the page in front: bookmark, find, translate, install.
  pageActions,

  /// The installed extensions list.
  extensions,

  /// Actions on the tab itself: containers, share, clone, export.
  tabActions,

  /// Icon grid of the browser's other screens (history, bookmarks, …).
  quickLinks,

  /// Routing for this tab plus the proxy backends it names.
  connection,

  /// Profile switch, sync, settings and quit.
  profile,

  /// The about screen.
  about;

  String get label => switch (this) {
    quickToggles => 'Quick Toggles',
    pageActions => 'Page Actions',
    extensions => 'Extensions',
    tabActions => 'Tab Actions',
    quickLinks => 'Quick Links',
    connection => 'Connection',
    profile => 'Profile & App',
    about => 'About',
  };
}

/// A row inside a [MenuSectionType], or inside a row that expands.
///
/// The rows a section lays out itself are arrangeable at both levels: Share can
/// be moved within Tab Actions, and the destinations under Share can be moved
/// within Share. What stays fixed is anything built from live data — the
/// installed extensions, the proxies a route names, the devices under Send To
/// Device — because pinning an order onto a list that comes and go leaves
/// configuration behind for things that no longer exist.
enum MenuItemType {
  // Quick toggles
  desktopMode,
  readerMode,
  gestures,

  // Page actions
  addBookmark,
  findInPage,
  translatePage,
  addToHomeScreen,
  openInApp,

  // Tab actions
  containers,
  manageContainers,
  assignContainer,
  assignUrlToContainer,
  unassignUrlFromContainer,
  unassignContainer,

  share,
  copyAddress,
  shareScreenshot,
  shareLink,
  sendToDevice,
  showQrCode,

  /// Not a row of its own: the point in Tab Actions where the rest folds away
  /// behind a "More" row. Switch it off to show the whole section flat, or
  /// drag it to choose how much stays visible.
  moreDisclosure,

  cloneTab,
  cloneRegularTab,
  clonePrivateTab,
  cloneIsolatedTab,

  export,
  copyAsMarkdown,
  exportAsMarkdown,
  exportAsPdf,
  exportAsPng,
  printPage,

  pinTopSite,
  fetchFeeds,

  // Quick links
  history,
  bookmarks,
  downloads,
  bangs,
  feeds,
  smallWeb,

  // Profile & App
  profileSwitch,
  syncNow,
  appSettings,
  quitBrowser,

  // About
  about;

  String get label => switch (this) {
    desktopMode => 'Desktop',
    readerMode => 'Reader',
    gestures => 'Gestures',
    addBookmark => 'Add Bookmark',
    findInPage => 'Find in Page',
    translatePage => 'Translate Page',
    addToHomeScreen => 'Add to Home Screen',
    openInApp => 'Open in App',
    containers => 'Containers',
    manageContainers => 'Manage Containers',
    assignContainer => 'Assign Container',
    assignUrlToContainer => 'Assign URL to Container',
    unassignUrlFromContainer => 'Unassign URL from Container',
    unassignContainer => 'Unassign Container',
    share => 'Share',
    copyAddress => 'Copy Address',
    shareScreenshot => 'Share Screenshot',
    shareLink => 'Share Link',
    sendToDevice => 'Send To Device',
    showQrCode => 'Show QR Code',
    moreDisclosure => 'More',
    cloneTab => 'Clone Tab',
    cloneRegularTab => 'Regular',
    clonePrivateTab => 'Private',
    cloneIsolatedTab => 'Isolated',
    export => 'Export',
    copyAsMarkdown => 'Copy as Markdown',
    exportAsMarkdown => 'Export as Markdown',
    exportAsPdf => 'Export as PDF',
    exportAsPng => 'Export as PNG',
    printPage => 'Print',
    pinTopSite => 'Pin to Shortcuts',
    fetchFeeds => 'Fetch Feeds',
    history => 'History',
    bookmarks => 'Bookmarks',
    downloads => 'Downloads',
    bangs => 'Bangs',
    feeds => 'Feeds',
    smallWeb => 'Small Web',
    profileSwitch => 'Profile',
    syncNow => 'Sync Now',
    appSettings => 'Settings',
    quitBrowser => 'Quit Browser',
    about => 'About',
  };

  /// Shown under the label while arranging, for rows whose behaviour is not
  /// obvious from the name alone.
  String? get description => switch (this) {
    moreDisclosure => 'Folds everything below it behind a "More" row',
    sendToDevice => 'The devices themselves come from your account',
    _ => null,
  };
}

/// One row slot in the defaults: which row, whether it starts on, and the rows
/// it reveals when it expands.
///
/// A class rather than a record because it nests inside itself, which a
/// record typedef cannot express.
class MenuItemDefault {
  final MenuItemType type;
  final bool visible;
  final List<MenuItemDefault> items;

  const MenuItemDefault(
    this.type, {
    this.visible = true,
    this.items = const [],
  });
}

/// One section slot in the defaults.
class MenuSectionDefault {
  final MenuSectionType type;
  final bool visible;
  final List<MenuItemDefault> items;

  const MenuSectionDefault(
    this.type, {
    this.visible = true,
    this.items = const [],
  });
}

/// The shipped menu, in shipped order.
///
/// This is the layout every profile starts from and the one "Reset" returns to,
/// so it has to keep matching what the sheet renders when nothing is persisted.
/// A section or row that lays its own contents out from live data (Extensions,
/// Connection, Send To Device) offers nothing to arrange beneath it.
const List<MenuSectionDefault> menuLayoutDefaults = [
  MenuSectionDefault(
    MenuSectionType.quickToggles,
    items: [
      MenuItemDefault(MenuItemType.desktopMode),
      MenuItemDefault(MenuItemType.readerMode),
      MenuItemDefault(MenuItemType.gestures),
    ],
  ),
  MenuSectionDefault(
    MenuSectionType.pageActions,
    items: [
      MenuItemDefault(MenuItemType.addBookmark),
      MenuItemDefault(MenuItemType.findInPage),
      MenuItemDefault(MenuItemType.translatePage),
      MenuItemDefault(MenuItemType.addToHomeScreen),
      MenuItemDefault(MenuItemType.openInApp),
    ],
  ),
  MenuSectionDefault(MenuSectionType.extensions),
  MenuSectionDefault(
    MenuSectionType.tabActions,
    items: [
      MenuItemDefault(
        MenuItemType.containers,
        items: [
          MenuItemDefault(MenuItemType.manageContainers),
          MenuItemDefault(MenuItemType.assignContainer),
          MenuItemDefault(MenuItemType.assignUrlToContainer),
          MenuItemDefault(MenuItemType.unassignUrlFromContainer),
          MenuItemDefault(MenuItemType.unassignContainer),
        ],
      ),
      MenuItemDefault(
        MenuItemType.share,
        items: [
          MenuItemDefault(MenuItemType.copyAddress),
          MenuItemDefault(MenuItemType.shareScreenshot),
          MenuItemDefault(MenuItemType.shareLink),
          MenuItemDefault(MenuItemType.sendToDevice),
          MenuItemDefault(MenuItemType.showQrCode),
        ],
      ),
      MenuItemDefault(MenuItemType.moreDisclosure),
      MenuItemDefault(
        MenuItemType.cloneTab,
        items: [
          MenuItemDefault(MenuItemType.cloneRegularTab),
          MenuItemDefault(MenuItemType.clonePrivateTab),
          MenuItemDefault(MenuItemType.cloneIsolatedTab),
        ],
      ),
      MenuItemDefault(
        MenuItemType.export,
        items: [
          MenuItemDefault(MenuItemType.copyAsMarkdown),
          MenuItemDefault(MenuItemType.exportAsMarkdown),
          MenuItemDefault(MenuItemType.exportAsPdf),
          MenuItemDefault(MenuItemType.exportAsPng),
          MenuItemDefault(MenuItemType.printPage),
        ],
      ),
      MenuItemDefault(MenuItemType.pinTopSite),
      MenuItemDefault(MenuItemType.fetchFeeds),
    ],
  ),
  MenuSectionDefault(
    MenuSectionType.quickLinks,
    items: [
      MenuItemDefault(MenuItemType.history),
      MenuItemDefault(MenuItemType.bookmarks),
      MenuItemDefault(MenuItemType.downloads),
      MenuItemDefault(MenuItemType.bangs),
      MenuItemDefault(MenuItemType.feeds),
      MenuItemDefault(MenuItemType.smallWeb),
    ],
  ),
  MenuSectionDefault(MenuSectionType.connection),
  MenuSectionDefault(
    MenuSectionType.profile,
    items: [
      MenuItemDefault(MenuItemType.profileSwitch),
      MenuItemDefault(MenuItemType.syncNow),
      MenuItemDefault(MenuItemType.appSettings),
      MenuItemDefault(MenuItemType.quitBrowser),
    ],
  ),
  MenuSectionDefault(
    MenuSectionType.about,
    items: [MenuItemDefault(MenuItemType.about)],
  ),
];

@JsonSerializable()
class MenuItemEntry with FastEquatable {
  final MenuItemType type;
  final bool visible;

  /// The arrangement of the rows this one reveals when it expands. Empty for a
  /// row that expands into nothing, or into live data.
  @JsonKey(fromJson: menuItemEntriesFromJson)
  final List<MenuItemEntry> items;

  MenuItemEntry({
    required this.type,
    required this.visible,
    this.items = const [],
  });

  factory MenuItemEntry.fromJson(Map<String, dynamic> json) =>
      _$MenuItemEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemEntryToJson(this);

  MenuItemEntry copyWith({bool? visible, List<MenuItemEntry>? items}) =>
      MenuItemEntry(
        type: type,
        visible: visible ?? this.visible,
        items: items ?? this.items,
      );

  /// The rows under this one that the user kept, in their order.
  List<MenuItemEntry> get visibleItems => [
    for (final item in items)
      if (item.visible) item,
  ];

  @override
  List<Object?> get hashParameters => [type, visible, items];
}

@JsonSerializable()
class MenuSectionEntry with FastEquatable {
  final MenuSectionType type;
  final bool visible;

  /// The section's own arrangement. Empty for sections that offer no rows.
  @JsonKey(fromJson: menuItemEntriesFromJson)
  final List<MenuItemEntry> items;

  MenuSectionEntry({
    required this.type,
    required this.visible,
    this.items = const [],
  });

  factory MenuSectionEntry.fromJson(Map<String, dynamic> json) =>
      _$MenuSectionEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MenuSectionEntryToJson(this);

  MenuSectionEntry copyWith({bool? visible, List<MenuItemEntry>? items}) =>
      MenuSectionEntry(
        type: type,
        visible: visible ?? this.visible,
        items: items ?? this.items,
      );

  /// The rows the user kept, in their order.
  List<MenuItemEntry> get visibleItems => [
    for (final item in items)
      if (item.visible) item,
  ];

  /// The rows the user kept, for a section whose rows never expand.
  List<MenuItemType> get visibleItemTypes => [
    for (final item in visibleItems) item.type,
  ];

  @override
  List<Object?> get hashParameters => [type, visible, items];
}

/// Drops item entries that no longer decode instead of failing the section or
/// row they sit in — one retired [MenuItemType] must not cost the user the rest
/// of their arrangement.
List<MenuItemEntry> menuItemEntriesFromJson(Object? json) {
  if (json is! List) return const [];

  return json
      .whereType<Map<String, dynamic>>()
      .map((item) {
        try {
          return MenuItemEntry.fromJson(item);
        } catch (_) {
          return null;
        }
      })
      .whereType<MenuItemEntry>()
      .toList();
}

/// Reconciles a persisted menu layout with what the app currently offers, at
/// every level: sections against [defaults], each surviving section's rows
/// against that section's own defaults, and each surviving row's rows against
/// its own.
///
/// Pure and exported so the reconciliation can be tested directly — it runs on
/// every read of the persisted layout, and a regression here silently rewrites
/// user configuration.
List<MenuSectionEntry> mergeMenuLayoutWithDefaults(
  List<MenuSectionEntry>? persisted, [
  List<MenuSectionDefault> defaults = menuLayoutDefaults,
]) {
  return mergeOrderedLayout(
    persisted: persisted,
    defaults: defaults,
    entryKey: (entry) => entry.type,
    defaultKey: (definition) => definition.type,
    fromDefault: (definition) => MenuSectionEntry(
      type: definition.type,
      visible: definition.visible,
      items: _mergeItems(null, definition.items),
    ),
    reconcile: (entry, definition) =>
        entry.copyWith(items: _mergeItems(entry.items, definition.items)),
  );
}

List<MenuItemEntry> _mergeItems(
  List<MenuItemEntry>? persisted,
  List<MenuItemDefault> defaults,
) {
  return mergeOrderedLayout(
    persisted: persisted,
    defaults: defaults,
    entryKey: (entry) => entry.type,
    defaultKey: (definition) => definition.type,
    fromDefault: (definition) => MenuItemEntry(
      type: definition.type,
      visible: definition.visible,
      items: _mergeItems(null, definition.items),
    ),
    reconcile: (entry, definition) =>
        entry.copyWith(items: _mergeItems(entry.items, definition.items)),
  );
}
