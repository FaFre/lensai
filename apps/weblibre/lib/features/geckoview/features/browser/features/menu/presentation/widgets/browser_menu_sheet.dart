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
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_reorder_view.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/navigation_row.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/about_section.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/connection_section.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/extensions_section.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/page_actions_section.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/profile_section.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/quick_links_section.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/quick_toggles_section.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/tab_actions_section.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

/// Shows the combined browser menu as a modal bottom sheet.
Future<void> showBrowserMenuSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _BrowserMenuSheet(),
  );
}

/// Builders rather than widgets: a section the user switched off is never
/// constructed, so it never subscribes to its providers. Building them eagerly
/// would make a hidden Connection section keep watching the proxy runtime and a
/// hidden Extensions section keep watching the installed add-ons every time the
/// menu opens.
Map<MenuSectionType, Widget Function(MenuSectionEntry section)>
_buildSectionBuilders(String? selectedTabId) {
  return {
    // The sections that act on a page only exist while one is in front. Left
    // out of the map rather than rendered empty, so their place in the user's
    // order is remembered without leaving a gap on the home screen.
    if (selectedTabId case final tabId?) ...{
      MenuSectionType.quickToggles: (section) => QuickTogglesSection(
        selectedTabId: tabId,
        items: section.visibleItemTypes,
      ),
      MenuSectionType.pageActions: (section) => PageActionsSection(
        selectedTabId: tabId,
        items: section.visibleItemTypes,
      ),
      // The only section whose rows open rows of their own, so the only one
      // handed the entries rather than just their types.
      MenuSectionType.tabActions: (section) =>
          TabActionsSection(selectedTabId: tabId, items: section.visibleItems),
    },
    MenuSectionType.extensions: (_) => const ExtensionsSection(),
    MenuSectionType.quickLinks: (section) =>
        QuickLinksSection(items: section.visibleItemTypes),
    MenuSectionType.connection: (_) =>
        ConnectionSection(selectedTabId: selectedTabId),
    MenuSectionType.profile: (section) =>
        ProfileSection(items: section.visibleItemTypes),
    MenuSectionType.about: (section) =>
        AboutSection(items: section.visibleItemTypes),
  };
}

class _BrowserMenuSheet extends ConsumerWidget {
  const _BrowserMenuSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabId = ref.watch(selectedTabProvider);
    final reorderMode = ref.watch(menuReorderModeProvider);
    final isReordering = reorderMode.active;

    // The arrangement UI is navigation inside the sheet, so the system back
    // gesture has to unwind it a level at a time — out of a section, then out
    // of arranging — before the sheet itself is allowed to close. Dragging the
    // sheet down still dismisses it outright, which keeps a way out that does
    // not depend on stepping back through the levels.
    return PopScope(
      canPop: !isReordering,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(menuReorderModeProvider.notifier).stepBack();
      },
      child: PointerScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SheetDragHandle(),

              // Pinned above the scrolling list: "Done" and the back arrow
              // are the only ways out of the arrangement UI, and a long
              // section's rows would otherwise carry them off screen.
              if (isReordering) ...[
                const MenuReorderHeader(),
                const Divider(height: 1),
              ],

              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: isReordering
                      ? const [MenuReorderView()]
                      : [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            sliver: _MenuSections(selectedTabId: selectedTabId),
                          ),
                        ],
                ),
              ),

              // Persistent navigation row at the bottom. Chrome rather than a
              // section, so it stays out of the way while the menu is being
              // arranged.
              if (selectedTabId != null && !isReordering) ...[
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                    top: 8,
                  ),
                  child: MenuNavigationRow(selectedTabId: selectedTabId),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MenuSections extends ConsumerWidget {
  final String? selectedTabId;

  const _MenuSections({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(menuLayoutProvider);
    final builders = _buildSectionBuilders(selectedTabId);

    return SliverList.list(
      children: [
        for (final section in layout)
          if (section.visible)
            if (builders[section.type] case final build?) build(section),
        const _CustomizeMenuButton(),
      ],
    );
  }
}

/// Always-present entry into the arrangement UI, so a menu whose sections are
/// all switched off is still configurable.
class _CustomizeMenuButton extends ConsumerWidget {
  const _CustomizeMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Low emphasis on purpose: this is a settings affordance sitting at the end
    // of the user's menu, not an action the menu is asking for.
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextButton.icon(
          onPressed: () =>
              ref.read(menuReorderModeProvider.notifier).activate(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          icon: const Icon(Icons.tune, size: 18),
          label: Text(
            'Customize menu',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}
