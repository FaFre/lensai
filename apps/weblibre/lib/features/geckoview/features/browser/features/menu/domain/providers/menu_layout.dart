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
/// what order, how the rows inside each one are ordered, and how the rows an
/// expanding row reveals are ordered.
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

  /// Reorders the rows of [section], or — when [parent] is given — the rows
  /// that [parent] reveals when it expands.
  void reorderItems(
    MenuSectionType section,
    MenuItemType? parent,
    int oldIndex,
    int newIndex,
  ) {
    state = _mapSectionItems(section, parent, (items) {
      final reordered = [...items];
      final item = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, item);
      return reordered;
    });
  }

  void toggleItemVisibility(
    MenuSectionType section,
    MenuItemType? parent,
    MenuItemType item,
  ) {
    state = _mapSectionItems(
      section,
      parent,
      (items) => [
        for (final candidate in items)
          if (candidate.type == item)
            candidate.copyWith(visible: !candidate.visible)
          else
            candidate,
      ],
    );
  }

  /// Discards the user's arrangement and returns to the shipped menu.
  void resetToDefaults() {
    state = mergeMenuLayoutWithDefaults(null);
  }

  List<MenuSectionEntry> _mapSectionItems(
    MenuSectionType section,
    MenuItemType? parent,
    List<MenuItemEntry> Function(List<MenuItemEntry> items) update,
  ) => [
    for (final entry in state)
      if (entry.type == section)
        entry.copyWith(items: _mapItems(entry.items, parent, update))
      else
        entry,
  ];

  List<MenuItemEntry> _mapItems(
    List<MenuItemEntry> items,
    MenuItemType? parent,
    List<MenuItemEntry> Function(List<MenuItemEntry> items) update,
  ) {
    if (parent == null) return update(items);

    return [
      for (final item in items)
        if (item.type == parent)
          item.copyWith(items: update(item.items))
        else
          item,
    ];
  }

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

        // Merge with defaults to pick up newly added or removed sections/rows.
        return mergeMenuLayoutWithDefaults(decoded);
      },
    );

    return stateOrNull ?? mergeMenuLayoutWithDefaults(null);
  }
}

/// Where the sheet is in its arrangement UI: not in it at all, arranging the
/// sections, arranging the rows of one section, or arranging the rows one of
/// those reveals.
///
/// One state rather than a flag plus local drill-down state, so the sheet can
/// answer the system back gesture — a back has to unwind these levels one at a
/// time before the sheet itself is allowed to close.
typedef MenuReorderState = ({
  bool active,
  MenuSectionType? focusedSection,
  MenuItemType? focusedItem,
});

/// Whether the sheet is currently showing its arrangement UI instead of the
/// menu.
///
/// Auto-disposed and therefore scoped to one presentation of the sheet: leaving
/// the menu while arranging and opening it again returns to the menu, which is
/// what a modal that is dismissed by tapping outside has to do.
@Riverpod()
class MenuReorderMode extends _$MenuReorderMode {
  void activate() =>
      state = (active: true, focusedSection: null, focusedItem: null);

  void deactivate() =>
      state = (active: false, focusedSection: null, focusedItem: null);

  void focusSection(MenuSectionType section) =>
      state = (active: true, focusedSection: section, focusedItem: null);

  void focusItem(MenuItemType item) => state = (
    active: true,
    focusedSection: state.focusedSection,
    focusedItem: item,
  );

  /// Steps back one level. Returns false once there is nothing left to step
  /// back to, which is the sheet's cue to let itself be dismissed.
  bool stepBack() {
    if (state.focusedItem != null) {
      state = (
        active: true,
        focusedSection: state.focusedSection,
        focusedItem: null,
      );
      return true;
    }

    if (state.focusedSection != null) {
      activate();
      return true;
    }

    if (state.active) {
      deactivate();
      return true;
    }

    return false;
  }

  @override
  MenuReorderState build() =>
      (active: false, focusedSection: null, focusedItem: null);
}
