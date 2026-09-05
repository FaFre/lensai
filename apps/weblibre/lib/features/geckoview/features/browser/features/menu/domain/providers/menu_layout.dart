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

import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'menu_layout.g.dart';

/// The user's arrangement of the browser menu sheet: which sections appear, in
/// what order, and how the top-level rows inside each one are ordered.
///
/// One persisted list rather than one per section, so a reorder and the
/// visibility toggle next to it are a single atomic write, and so the whole
/// layout can be reconciled against the shipped defaults in one pass on read.
@Riverpod(keepAlive: true)
class MenuLayout extends _$MenuLayout {
  void reorderSections(int oldIndex, int newIndex) {
    final sections = [...state];
    final section = sections.removeAt(oldIndex);
    sections.insert(newIndex, section);
    state = sections;
  }

  void toggleSectionVisibility(MenuSectionType type) {
    state = [
      for (final section in state)
        if (section.type == type)
          section.copyWith(visible: !section.visible)
        else
          section,
    ];
  }

  void reorderItems(MenuSectionType section, int oldIndex, int newIndex) {
    state = _mapSection(section, (entry) {
      final items = [...entry.items];
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      return entry.copyWith(items: items);
    });
  }

  void toggleItemVisibility(MenuSectionType section, MenuItemType item) {
    state = _mapSection(
      section,
      (entry) => entry.copyWith(
        items: [
          for (final candidate in entry.items)
            if (candidate.type == item) candidate.toggled() else candidate,
        ],
      ),
    );
  }

  /// Discards the user's arrangement and returns to the shipped menu.
  void resetToDefaults() {
    state = mergeMenuLayoutWithDefaults(null);
  }

  List<MenuSectionEntry> _mapSection(
    MenuSectionType type,
    MenuSectionEntry Function(MenuSectionEntry entry) update,
  ) => [
    for (final section in state)
      if (section.type == type) update(section) else section,
  ];

  @override
  List<MenuSectionEntry> build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'BrowserMenuLayout',
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: (state) => jsonEncode(state.map((e) => e.toJson()).toList()),
      decode: (encoded) {
        final decoded = (jsonDecode(encoded) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((section) {
              try {
                return MenuSectionEntry.fromJson(section);
              } catch (_) {
                return null;
              }
            })
            .whereType<MenuSectionEntry>()
            .toList();

        // Merge with defaults to pick up newly added or removed sections/items.
        return mergeMenuLayoutWithDefaults(decoded);
      },
    );

    return stateOrNull ?? mergeMenuLayoutWithDefaults(null);
  }
}

/// Whether the sheet is currently showing its arrangement UI instead of the
/// menu.
///
/// Auto-disposed and therefore scoped to one presentation of the sheet: leaving
/// the menu while arranging and opening it again returns to the menu, which is
/// what a modal that is dismissed by tapping outside has to do.
@Riverpod()
class MenuReorderMode extends _$MenuReorderMode {
  void activate() => state = true;
  void deactivate() => state = false;

  @override
  bool build() => false;
}
