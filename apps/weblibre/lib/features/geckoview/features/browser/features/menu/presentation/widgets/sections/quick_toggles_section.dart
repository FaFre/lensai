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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// The segmented Desktop / Reader / Gestures bar at the top of the sheet.
///
/// Only the toggles the user kept are built, so a hidden toggle costs nothing:
/// the reader and desktop state it would otherwise watch is never subscribed
/// to. Renders nothing at all when none of its toggles apply, so the sheet is
/// not left with a gap where the bar would have been.
class QuickTogglesSection extends ConsumerWidget {
  final String selectedTabId;
  final List<MenuItemType> items;

  const QuickTogglesSection({
    super.key,
    required this.selectedTabId,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggles = <MenuItemType, _QuickToggle>{};

    if (items.contains(MenuItemType.desktopMode)) {
      final desktopEnabled = ref.watch(desktopModeProvider(selectedTabId));
      toggles[MenuItemType.desktopMode] = _QuickToggle(
        icon: MdiIcons.monitor,
        label: MenuItemType.desktopMode.label,
        active: desktopEnabled,
        onTap: () {
          ref
              .read(desktopModeProvider(selectedTabId).notifier)
              .enabled(!desktopEnabled);
        },
      );
    }

    if (items.contains(MenuItemType.readerMode)) {
      final isReaderLoading = ref
          .watch(readerableScreenControllerProvider)
          .isLoading;
      final readerabilityState = ref.watch(
        selectedTabStateProvider.select(
          (state) => state?.readerableState ?? ReaderableState.$default(),
        ),
      );
      final isReaderActive = readerabilityState.active;
      final enableReadability = ref.watch(
        generalSettingsWithDefaultsProvider.select(
          (value) => value.enableReadability,
        ),
      );
      final enforceReadability = ref.watch(
        generalSettingsWithDefaultsProvider.select(
          (value) => value.enforceReadability,
        ),
      );
      final readerVisible =
          (readerabilityState.readerable &&
              (enableReadability || readerabilityState.active)) ||
          (enforceReadability && enableReadability);

      toggles[MenuItemType.readerMode] = _QuickToggle(
        icon: (readerVisible && isReaderActive)
            ? MdiIcons.bookOpen
            : MdiIcons.bookOpenOutline,
        label: MenuItemType.readerMode.label,
        active: readerVisible && isReaderActive,
        enabled: readerVisible && !isReaderLoading,
        onTap: () async {
          await ref
              .read(readerableScreenControllerProvider.notifier)
              .toggleReaderView(!isReaderActive);
        },
      );
    }

    if (items.contains(MenuItemType.gestures)) {
      final gestureSettings = ref.watch(gestureSettingsWithDefaultsProvider);

      if (gestureSettings.enabled) {
        toggles[MenuItemType.gestures] = _QuickToggle(
          icon: MdiIcons.gestureSwipe,
          label: MenuItemType.gestures.label,
          active: gestureSettings.active,
          onTap: () async {
            await ref
                .read(gestureSettingsRepositoryProvider.notifier)
                .updateSettings(
                  (s) => s.copyWith(active: !gestureSettings.active),
                );
          },
          onLongPress: () {
            Navigator.pop(context);
            unawaited(GestureSettingsRoute().push(context));
          },
        );
      }
    }

    final ordered = [
      for (final item in items)
        if (toggles[item] case final toggle?) toggle,
    ];

    if (ordered.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: menuSectionSpacing),
      child: _QuickToggleBar(toggles: ordered),
    );
  }
}

/// A single quick toggle's display + behavior, rendered as one segment of a
/// [_QuickToggleBar].
class _QuickToggle {
  final IconData icon;
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _QuickToggle({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.enabled = true,
    this.onLongPress,
  });
}

/// Connected, equal-width segmented bar (icon over label) for the quick
/// toggles. Segments are split across rows of at most [_maxPerRow] so the bar
/// stays compact and resizes to however many toggles are present.
class _QuickToggleBar extends StatelessWidget {
  final List<_QuickToggle> toggles;

  static const int _maxPerRow = 4;

  const _QuickToggleBar({required this.toggles});

  @override
  Widget build(BuildContext context) {
    final rows = <List<_QuickToggle>>[];
    for (var i = 0; i < toggles.length; i += _maxPerRow) {
      final end = i + _maxPerRow <= toggles.length
          ? i + _maxPerRow
          : toggles.length;
      rows.add(toggles.sublist(i, end));
    }

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 8),
          _buildRow(context, rows[r]),
        ],
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<_QuickToggle> items) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant,
                ),
              Expanded(child: _QuickToggleSegment(toggle: items[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickToggleSegment extends StatelessWidget {
  final _QuickToggle toggle;

  const _QuickToggleSegment({required this.toggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final foregroundColor = !toggle.enabled
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : toggle.active
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: toggle.active
          ? colorScheme.secondaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: toggle.enabled ? toggle.onTap : null,
        onLongPress: toggle.enabled ? toggle.onLongPress : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(toggle.icon, color: foregroundColor, size: 22),
              const SizedBox(height: 6),
              Text(
                toggle.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
