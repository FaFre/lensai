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

import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/utils/ordered_layout.dart';

part 'search_module_order.g.dart';

@JsonSerializable()
class ModuleOrderEntry with FastEquatable {
  final SearchModuleType type;
  final bool visible;

  ModuleOrderEntry({required this.type, required this.visible});

  factory ModuleOrderEntry.fromJson(Map<String, dynamic> json) =>
      _$ModuleOrderEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleOrderEntryToJson(this);

  @override
  List<Object?> get hashParameters => [type, visible];
}

/// Reconciles a persisted module order with the surface's current defaults.
///
/// Thin wrapper over [mergeOrderedLayout], which carries the reconciliation
/// rules (drop modules that no longer exist, insert newly shipped ones at their
/// designed position rather than the bottom) shared with the browser menu's
/// layout. Kept as a named function because it is the tested entry point for
/// this surface.
List<ModuleOrderEntry> mergeModuleOrderWithDefaults(
  List<ModuleOrderEntry>? persisted,
  List<ModuleSurfaceDefault> defaults,
) {
  return mergeOrderedLayout(
    persisted: persisted,
    defaults: defaults,
    entryKey: (entry) => entry.type,
    defaultKey: (definition) => definition.type,
    fromDefault: (definition) =>
        ModuleOrderEntry(type: definition.type, visible: definition.visible),
  );
}

@Riverpod(keepAlive: true)
class SearchModuleOrder extends _$SearchModuleOrder {
  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
  }

  void toggleVisibility(SearchModuleType type) {
    state = [
      for (final e in state)
        if (e.type == type)
          ModuleOrderEntry(type: e.type, visible: !e.visible)
        else
          e,
    ];
  }

  /// Discards the user's layout for this surface and returns to its defaults.
  void resetToDefaults() {
    state = mergeModuleOrderWithDefaults(null, surface.defaultModules);
  }

  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: surface.key,
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: (state) => jsonEncode(state.map((e) => e.toJson()).toList()),
      decode: (encoded) {
        final decoded = (jsonDecode(encoded) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((e) {
              try {
                return ModuleOrderEntry.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<ModuleOrderEntry>()
            .toList();
        // Merge with defaults to pick up newly added or remove deleted modules
        return mergeModuleOrderWithDefaults(decoded, surface.defaultModules);
      },
    );

    return stateOrNull ??
        mergeModuleOrderWithDefaults(null, surface.defaultModules);
  }
}
