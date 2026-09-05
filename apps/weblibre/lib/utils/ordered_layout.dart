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

/// Reconciles a persisted, user-arranged list with the list the app currently
/// offers.
///
/// Persisted entries whose element no longer exists are dropped, and elements
/// that were added since the arrangement was saved are inserted at their
/// position in [defaults] rather than appended — so a newly shipped element
/// lands where it was designed to sit instead of at the bottom of the user's
/// list. New elements keep the default's own visibility, so something can be
/// offered without being switched on for everyone who already customised the
/// list.
///
/// Pure and shared, because it runs on every read of a persisted arrangement
/// and a regression here silently rewrites user configuration. Callers supply
/// the key/creation functions rather than a common entry type: the browser menu
/// nests one arrangement inside another, and the two levels do not share a
/// type.
///
/// [reconcile] runs for every entry that survives, pairing it with the default
/// it matched. That is where a nested arrangement merges its own children.
List<E> mergeOrderedLayout<E, D>({
  required List<E>? persisted,
  required List<D> defaults,
  required Object Function(E entry) entryKey,
  required Object Function(D definition) defaultKey,
  required E Function(D definition) fromDefault,
  E Function(E entry, D definition)? reconcile,
}) {
  final offered = {
    for (final definition in defaults) defaultKey(definition): definition,
  };

  if (persisted == null) {
    return defaults.map(fromDefault).toList();
  }

  // Keep persisted entries that are still offered, reconciling each against the
  // definition it matched.
  final result = <E>[];
  for (final entry in persisted) {
    final definition = offered[entryKey(entry)];
    if (definition == null) continue;
    result.add(reconcile != null ? reconcile(entry, definition) : entry);
  }

  // Insert anything the persisted list never saw at its position in [defaults].
  final seen = result.map(entryKey).toSet();
  for (var i = 0; i < defaults.length; i++) {
    final definition = defaults[i];
    if (seen.contains(defaultKey(definition))) continue;
    result.insert(i.clamp(0, result.length), fromDefault(definition));
  }

  return result;
}
