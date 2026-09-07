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
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_layout_slivers.dart';

/// Replaces the menu's scrolling content while the user is arranging it.
///
/// The level in front is held in [menuReorderModeProvider] rather than in local
/// state, so the sheet above can answer the system back gesture by unwinding it
/// one step at a time — and so [MenuReorderHeader], which the sheet pins
/// outside this scroll view, can title itself from the same place.
class MenuReorderView extends ConsumerWidget {
  const MenuReorderView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reorderMode = ref.watch(menuReorderModeProvider);
    final reorderNotifier = ref.read(menuReorderModeProvider.notifier);

    final (:section, :item) = resolveMenuLayoutFocus(
      ref.watch(menuLayoutProvider),
      focusedSection: reorderMode.focusedSection,
      focusedItem: reorderMode.focusedItem,
    );

    return SliverMainAxisGroup(
      slivers: [
        MenuLayoutSlivers(
          focusedSection: section?.type,
          focusedItem: item?.type,
          onFocusSection: reorderNotifier.focusSection,
          onFocusItem: reorderNotifier.focusItem,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

/// The arrangement UI's title, and the controls that leave it.
///
/// Pinned by the sheet above the scrolling list rather than scrolled with it:
/// "Done" and the back arrow are the only ways out of this mode, and a long
/// section's rows would otherwise push them off screen.
class MenuReorderHeader extends ConsumerWidget {
  const MenuReorderHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reorderMode = ref.watch(menuReorderModeProvider);
    final reorderNotifier = ref.read(menuReorderModeProvider.notifier);

    final (:section, :item) = resolveMenuLayoutFocus(
      ref.watch(menuLayoutProvider),
      focusedSection: reorderMode.focusedSection,
      focusedItem: reorderMode.focusedItem,
    );

    return _Header(
      title: item?.type.label ?? section?.type.label ?? 'Customize Menu',
      subtitle: switch ((section, item)) {
        (null, _) =>
          'Drag to reorder. Switch a section off to hide it from the menu.',
        (_, null) => 'Drag to reorder the rows in this section.',
        _ => 'Drag to reorder the rows this one opens.',
      },
      onBack: section == null ? null : reorderNotifier.stepBack,
      onDone: reorderNotifier.deactivate,
      onReset: section == null
          ? ref.read(menuLayoutProvider.notifier).resetToDefaults
          : null,
    );
  }
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

  /// Horizontal inset of the whole header.
  static const _margin = 8.0;

  /// What an [IconButton] occupies once Material pads it to the 48dp touch
  /// target. The title sits after it, and the subtitle is indented to match, so
  /// the two stay aligned with each other whether or not the back arrow is
  /// there.
  static const _leadingSlot = 48.0;

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
    final leadingWidth = onBack == null ? _margin : _leadingSlot;

    return Padding(
      padding: const EdgeInsets.fromLTRB(_margin, 4, _margin, 4),
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
                const SizedBox(width: _margin),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              if (onReset case final onReset?)
                MenuAnchor(
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.restore),
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
            padding: EdgeInsets.fromLTRB(leadingWidth, 0, _margin, 12),
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
