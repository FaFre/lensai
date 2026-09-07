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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_layout_slivers.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Arranges the browser menu from Settings, editing the same saved layout as
/// the "Customize menu" button inside the menu itself.
///
/// The level in front is local state here rather than
/// [menuReorderModeProvider]: that provider exists to survive as long as the
/// menu sheet does, and this screen's lifetime is its own.
class MenuLayoutSettingsScreen extends HookConsumerWidget {
  const MenuLayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(menuLayoutProvider);
    final focusedSection = useState<MenuSectionType?>(null);
    final focusedItem = useState<MenuItemType?>(null);

    final (:section, :item) = resolveMenuLayoutFocus(
      sections,
      focusedSection: focusedSection.value,
      focusedItem: focusedItem.value,
    );

    void stepBack() {
      if (focusedItem.value != null) {
        focusedItem.value = null;
        return;
      }
      focusedSection.value = null;
    }

    // Drilling into a section is navigation without a route, so both the app
    // bar's back button and the system gesture have to unwind it before they
    // leave the screen.
    return PopScope(
      canPop: section == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        stepBack();
      },
      child: SettingsCustomScrollScaffold(
        title: item?.type.label ?? section?.type.label ?? 'Customize Menu',
        actions: [
          if (section == null)
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.restore),
                  onPressed: ref
                      .read(menuLayoutProvider.notifier)
                      .resetToDefaults,
                  child: const Text('Reset to Defaults'),
                ),
              ],
              builder: (context, controller, child) => IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
              ),
            ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                switch ((section, item)) {
                  (null, _) =>
                    'Drag to reorder. Switch a section off to hide it from the '
                        'menu.',
                  (_, null) => 'Drag to reorder the rows in this section.',
                  _ => 'Drag to reorder the rows this one opens.',
                },
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          MenuLayoutSlivers(
            focusedSection: section?.type,
            focusedItem: item?.type,
            onFocusSection: (type) => focusedSection.value = type,
            onFocusItem: (type) => focusedItem.value = type,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
