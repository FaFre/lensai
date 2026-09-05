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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_mode_controller.dart';

/// Icon grid of the browser's other screens.
///
/// Laid out at a fixed four per row: the width each tile gets is derived from
/// the space available, so the grid already adapts without the row count being
/// something the user has to decide.
class QuickLinksSection extends ConsumerWidget {
  final List<MenuItemType> items;

  static const _spacing = 8.0;
  static const _itemsPerRow = 4;

  const QuickLinksSection({super.key, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = [
      for (final item in items)
        if (_iconFor(item) case final icon?) (item: item, icon: icon),
    ];

    if (links.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: menuSectionSpacing),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              (constraints.maxWidth - _spacing * (_itemsPerRow - 1)) /
              _itemsPerRow;

          return Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: [
              for (final link in links)
                SizedBox(
                  width: width,
                  child: _QuickLinkTile(
                    icon: link.icon,
                    label: link.item.label,
                    onTap: () => _open(context, ref, link.item),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static IconData? _iconFor(MenuItemType item) => switch (item) {
    MenuItemType.history => Icons.history,
    MenuItemType.bookmarks => MdiIcons.bookmarkMultiple,
    MenuItemType.downloads => MdiIcons.fileDownload,
    MenuItemType.bangs => MdiIcons.exclamationThick,
    MenuItemType.feeds => Icons.rss_feed,
    MenuItemType.smallWeb => Icons.explore,
    _ => null,
  };

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    MenuItemType item,
  ) async {
    switch (item) {
      case MenuItemType.history:
        Navigator.pop(context);
        await const HistoryRoute().push(context);
      case MenuItemType.bookmarks:
        Navigator.pop(context);
        await BookmarkListRoute(entryGuid: BookmarkRoot.root.id).push(context);
      case MenuItemType.downloads:
        Navigator.pop(context);
        await const HistoryDownloadsRoute().push(context);
      case MenuItemType.bangs:
        Navigator.pop(context);
        await const BangMenuRoute().push(context);
      case MenuItemType.feeds:
        Navigator.pop(context);
        await context.push(FeedListRoute().location);
      case MenuItemType.smallWeb:
        Navigator.pop(context);
        await ref.read(smallWebModeControllerProvider.notifier).enter();
      default:
        break;
    }
  }
}

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.onSurface),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
