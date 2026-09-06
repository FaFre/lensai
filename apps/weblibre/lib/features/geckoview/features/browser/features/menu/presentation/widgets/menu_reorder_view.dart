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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';

/// Replaces the menu's content while the user is arranging it.
///
/// One level at a time rather than one nested list: sections, then the rows of
/// one section, then the rows one of those reveals. A reorderable list inside a
/// reorderable list makes both drags ambiguous the moment they overlap, and the
/// drill-down also gives each list somewhere to explain itself.
class MenuReorderView extends ConsumerWidget {
  const MenuReorderView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(menuLayoutProvider);
    final notifier = ref.read(menuLayoutProvider.notifier);

    final reorderMode = ref.watch(menuReorderModeProvider);
    final reorderNotifier = ref.read(menuReorderModeProvider.notifier);

    final section = reorderMode.focusedSection.mapNotNull(
      (type) => sections.firstWhere((section) => section.type == type),
    );
    final item = section == null
        ? null
        : reorderMode.focusedItem.mapNotNull(
            (type) => section.items.firstWhere((entry) => entry.type == type),
          );

    // Whichever list is in front: the sections, one section's rows, or the rows
    // under one of those.
    final entries = item?.items ?? section?.items;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(
            title: item?.type.label ?? section?.type.label ?? 'Customize Menu',
            subtitle: switch ((section, item)) {
              (null, _) =>
                'Drag to reorder. Switch a section off to hide it from the menu.',
              (_, null) => 'Drag to reorder the rows in this section.',
              _ => 'Drag to reorder the rows this one opens.',
            },
            onBack: section == null ? null : reorderNotifier.stepBack,
            onDone: reorderNotifier.deactivate,
            onReset: section == null ? notifier.resetToDefaults : null,
          ),
        ),
        if (entries == null)
          SliverReorderableList(
            itemCount: sections.length,
            onReorderItem: notifier.reorderSections,
            itemBuilder: (context, index) {
              final entry = sections[index];

              return _ReorderRow(
                key: ValueKey(entry.type),
                index: index,
                label: entry.type.label,
                subtitle: _shownSummary(entry.items, 'rows'),
                visible: entry.visible,
                onToggleVisibility: () =>
                    notifier.toggleSectionVisibility(entry.type),
                onTap: entry.items.isEmpty
                    ? null
                    : () => reorderNotifier.focusSection(entry.type),
              );
            },
          )
        else
          SliverReorderableList(
            itemCount: entries.length,
            onReorderItem: (oldIndex, newIndex) => notifier.reorderItems(
              section!.type,
              item?.type,
              oldIndex,
              newIndex,
            ),
            itemBuilder: (context, index) {
              final entry = entries[index];

              return _ReorderRow(
                key: ValueKey(entry.type),
                index: index,
                label: entry.type.label,
                subtitle:
                    entry.type.description ??
                    _shownSummary(entry.items, 'rows'),
                visible: entry.visible,
                onToggleVisibility: () => notifier.toggleItemVisibility(
                  section!.type,
                  item?.type,
                  entry.type,
                ),
                // Only one level of nesting is offered, so a row reached from a
                // row never drills further even when it opens a list of its own
                // — those lists are live data (the devices under Send To
                // Device, the extensions under Extensions).
                onTap: entry.items.isEmpty || item != null
                    ? null
                    : () => reorderNotifier.focusItem(entry.type),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

String? _shownSummary(List<MenuItemEntry> items, String noun) {
  if (items.isEmpty) return null;

  final shown = items.where((item) => item.visible).length;
  return '$shown of ${items.length} $noun shown';
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final VoidCallback onDone;

  /// Only offered at the top level: resetting one section's rows and resetting
  /// the whole menu would be the same button in two places meaning different
  /// things.
  final VoidCallback? onReset;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onDone,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (onBack case final onBack?)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to sections',
                  onPressed: onBack,
                )
              else
                const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (onReset case final onReset?)
                MenuAnchor(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: onReset,
                      child: const Text('Reset to Defaults'),
                    ),
                  ],
                  builder: (context, controller, child) => IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                  ),
                ),
              TextButton(onPressed: onDone, child: const Text('Done')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderRow extends StatelessWidget {
  final int index;
  final String label;
  final String? subtitle;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onTap;

  const _ReorderRow({
    super.key,
    required this.index,
    required this.label,
    required this.subtitle,
    required this.visible,
    required this.onToggleVisibility,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          color: visible ? colorScheme.primary : colorScheme.onSurfaceVariant,
          tooltip: visible ? 'Hide' : 'Show',
          onPressed: onToggleVisibility,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: visible
                ? null
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
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
