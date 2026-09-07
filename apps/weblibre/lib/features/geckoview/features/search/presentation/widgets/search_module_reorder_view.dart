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
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';

class SearchModuleReorderView extends ConsumerWidget {
  final ModuleSurface surface;

  const SearchModuleReorderView({super.key, required this.surface});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(searchModuleOrderProvider(surface));
    final colorScheme = Theme.of(context).colorScheme;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Customize Sections',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                // The only way back to the shipped layout for a surface with
                // no settings screen of its own — the search results page is
                // reachable from here and nowhere else.
                MenuAnchor(
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.restore),
                      onPressed: ref
                          .read(searchModuleOrderProvider(surface).notifier)
                          .resetToDefaults,
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
                TextButton(
                  onPressed: () => ref
                      .read(searchReorderModeProvider(surface).notifier)
                      .deactivate(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
        SliverReorderableList(
          itemCount: entries.length,
          onReorderItem: (oldIndex, newIndex) {
            ref
                .read(searchModuleOrderProvider(surface).notifier)
                .reorder(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Material(
              key: ValueKey(entry.type),
              color: Colors.transparent,
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    entry.visible ? Icons.visibility : Icons.visibility_off,
                    color: entry.visible
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => ref
                      .read(searchModuleOrderProvider(surface).notifier)
                      .toggleVisibility(entry.type),
                ),
                title: Text(
                  entry.type.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: entry.visible
                        ? null
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
