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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';

/// The arrangement lists themselves, without any chrome around them.
///
/// One level is shown at a time — the sections, one section's rows, or the rows
/// one of those reveals — because a reorderable list inside a reorderable list
/// makes both drags ambiguous the moment they overlap. Which level is in front
/// is the host's business: the menu sheet keeps it in a provider so the back
/// gesture can unwind it, the settings screen keeps it in local state.
class MenuLayoutSlivers extends ConsumerWidget {
  final MenuSectionType? focusedSection;
  final MenuItemType? focusedItem;
  final ValueChanged<MenuSectionType> onFocusSection;
  final ValueChanged<MenuItemType> onFocusItem;

  const MenuLayoutSlivers({
    super.key,
    required this.focusedSection,
    required this.focusedItem,
    required this.onFocusSection,
    required this.onFocusItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(menuLayoutProvider);
    final notifier = ref.read(menuLayoutProvider.notifier);

    final (:section, :item) = resolveMenuLayoutFocus(
      sections,
      focusedSection: focusedSection,
      focusedItem: focusedItem,
    );

    final entries = item?.items ?? section?.items;

    if (entries == null) {
      return SliverReorderableList(
        itemCount: sections.length,
        onReorderItem: notifier.reorderSections,
        itemBuilder: (context, index) {
          final entry = sections[index];

          return _ReorderRow(
            key: ValueKey(entry.type),
            index: index,
            icon: entry.type.icon,
            label: entry.type.label,
            subtitle: _shownSummary(entry.items),
            visible: entry.visible,
            onToggleVisibility: () =>
                notifier.toggleSectionVisibility(entry.type),
            onTap: entry.items.isEmpty
                ? null
                : () => onFocusSection(entry.type),
          );
        },
      );
    }

    return SliverReorderableList(
      itemCount: entries.length,
      onReorderItem: (oldIndex, newIndex) =>
          notifier.reorderItems(section!.type, item?.type, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final entry = entries[index];

        return _ReorderRow(
          key: ValueKey(entry.type),
          index: index,
          icon: entry.type.icon,
          label: entry.type.label,
          subtitle: entry.type.description ?? _shownSummary(entry.items),
          visible: entry.visible,
          onToggleVisibility: () => notifier.toggleItemVisibility(
            section!.type,
            item?.type,
            entry.type,
          ),
          // Only one level of nesting is offered, so a row reached from a row
          // never drills further even when it opens a list of its own — those
          // lists are live data (the devices under Send To Device, the
          // extensions under Extensions).
          onTap: entry.items.isEmpty || item != null
              ? null
              : () => onFocusItem(entry.type),
        );
      },
    );
  }
}

/// Resolves a focused section and row against the current layout.
///
/// Both come back null when the layout no longer holds them, which is what a
/// reset performed while drilled in leaves behind. Shared with the hosts, which
/// need the same answer to title their headers.
({MenuSectionEntry? section, MenuItemEntry? item}) resolveMenuLayoutFocus(
  List<MenuSectionEntry> sections, {
  required MenuSectionType? focusedSection,
  required MenuItemType? focusedItem,
}) {
  final section = focusedSection.mapNotNull(
    (type) => sections.firstWhereOrNull((entry) => entry.type == type),
  );
  final item = section == null
      ? null
      : focusedItem.mapNotNull(
          (type) =>
              section.items.firstWhereOrNull((entry) => entry.type == type),
        );

  return (section: section, item: item);
}

String? _shownSummary(List<MenuItemEntry> items) {
  if (items.isEmpty) return null;

  final shown = items.where((item) => item.visible).length;
  return '$shown of ${items.length} rows shown';
}

class _ReorderRow extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onTap;

  const _ReorderRow({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.visible,
    required this.onToggleVisibility,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dimmed = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          color: visible ? colorScheme.primary : colorScheme.onSurfaceVariant,
          tooltip: visible ? 'Hide' : 'Show',
          onPressed: onToggleVisibility,
        ),
        // The row's own icon sits with its label rather than in the leading
        // slot, which the visibility control needs as a tap target.
        title: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: visible ? colorScheme.onSurfaceVariant : dimmed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: visible ? null : dimmed),
              ),
            ),
          ],
        ),
        subtitle: subtitle.mapNotNull(
          (value) => Text(value, style: Theme.of(context).textTheme.bodySmall),
        ),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onTap != null)
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
