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

/// A top-level entry inside a [MenuSectionType].
///
/// Only rows the sheet itself lays out are listed here. Anything a row reveals
/// once opened — the destinations under Share, the entries under Export, the
/// installed extensions — belongs to that row and is not separately arrangeable:
/// those lists are built from live data, and pinning an order onto them would
/// persist configuration for things that come and go.
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
  share,

  /// Not a row of its own: the point in Tab Actions where the rest folds away
  /// behind a "More" tile. Switch it off to show the whole section flat, or
  /// drag it to choose how much stays visible.
  moreDisclosure,
  cloneTab,
  export,
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
    share => 'Share',
    moreDisclosure => 'More',
    cloneTab => 'Clone Tab',
    export => 'Export',
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
    _ => null,
  };
}

/// One item slot in a section's defaults: which item, and whether it starts on.
typedef MenuItemDefault = ({MenuItemType type, bool visible});

/// One section slot in the menu's defaults.
typedef MenuSectionDefault = ({
  MenuSectionType type,
  bool visible,
  List<MenuItemDefault> items,
});

/// The shipped menu, in shipped order.
///
/// This is the layout every profile starts from and the one "Reset" returns to,
/// so it has to keep matching what the sheet renders when nothing is persisted.
/// A section that lays its own contents out from live data (Extensions,
/// Connection) offers no items.
const List<MenuSectionDefault> menuLayoutDefaults = [
  (
    type: MenuSectionType.quickToggles,
    visible: true,
    items: [
      (type: MenuItemType.desktopMode, visible: true),
      (type: MenuItemType.readerMode, visible: true),
      (type: MenuItemType.gestures, visible: true),
    ],
  ),
  (
    type: MenuSectionType.pageActions,
    visible: true,
    items: [
      (type: MenuItemType.addBookmark, visible: true),
      (type: MenuItemType.findInPage, visible: true),
      (type: MenuItemType.translatePage, visible: true),
      (type: MenuItemType.addToHomeScreen, visible: true),
      (type: MenuItemType.openInApp, visible: true),
    ],
  ),
  (type: MenuSectionType.extensions, visible: true, items: []),
  (
    type: MenuSectionType.tabActions,
    visible: true,
    items: [
      (type: MenuItemType.containers, visible: true),
      (type: MenuItemType.share, visible: true),
      (type: MenuItemType.moreDisclosure, visible: true),
      (type: MenuItemType.cloneTab, visible: true),
      (type: MenuItemType.export, visible: true),
      (type: MenuItemType.pinTopSite, visible: true),
      (type: MenuItemType.fetchFeeds, visible: true),
    ],
  ),
  (
    type: MenuSectionType.quickLinks,
    visible: true,
    items: [
      (type: MenuItemType.history, visible: true),
      (type: MenuItemType.bookmarks, visible: true),
      (type: MenuItemType.downloads, visible: true),
      (type: MenuItemType.bangs, visible: true),
      (type: MenuItemType.feeds, visible: true),
      (type: MenuItemType.smallWeb, visible: true),
    ],
  ),
  (type: MenuSectionType.connection, visible: true, items: []),
  (
    type: MenuSectionType.profile,
    visible: true,
    items: [
      (type: MenuItemType.profileSwitch, visible: true),
      (type: MenuItemType.syncNow, visible: true),
      (type: MenuItemType.appSettings, visible: true),
      (type: MenuItemType.quitBrowser, visible: true),
    ],
  ),
  (
    type: MenuSectionType.about,
    visible: true,
    items: [(type: MenuItemType.about, visible: true)],
  ),
];

@JsonSerializable()
class MenuItemEntry with FastEquatable {
  final MenuItemType type;
  final bool visible;

  MenuItemEntry({required this.type, required this.visible});

  factory MenuItemEntry.fromJson(Map<String, dynamic> json) =>
      _$MenuItemEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemEntryToJson(this);

  MenuItemEntry toggled() => MenuItemEntry(type: type, visible: !visible);

  @override
  List<Object?> get hashParameters => [type, visible];
}

@JsonSerializable()
class MenuSectionEntry with FastEquatable {
  final MenuSectionType type;
  final bool visible;

  /// The section's own arrangement. Empty for sections that offer no items.
  @JsonKey(fromJson: menuItemEntriesFromJson)
  final List<MenuItemEntry> items;

  MenuSectionEntry({
    required this.type,
    required this.visible,
    required this.items,
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

  /// The visible items, in the user's order. What the section renders from.
  List<MenuItemType> get visibleItems => [
    for (final item in items)
      if (item.visible) item.type,
  ];

  @override
  List<Object?> get hashParameters => [type, visible, items];
}

/// Drops item entries that no longer decode instead of failing the section they
/// sit in — one retired [MenuItemType] must not cost the user the rest of their
/// arrangement.
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
/// both levels: sections against [defaults], then each surviving section's
/// items against that section's own defaults.
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
      items: _itemsFromDefaults(definition.items),
    ),
    reconcile: (entry, definition) => entry.copyWith(
      items: mergeOrderedLayout(
        persisted: entry.items,
        defaults: definition.items,
        entryKey: (item) => item.type,
        defaultKey: (item) => item.type,
        fromDefault: (item) =>
            MenuItemEntry(type: item.type, visible: item.visible),
      ),
    ),
  );
}

List<MenuItemEntry> _itemsFromDefaults(List<MenuItemDefault> items) => [
  for (final item in items)
    MenuItemEntry(type: item.type, visible: item.visible),
];
