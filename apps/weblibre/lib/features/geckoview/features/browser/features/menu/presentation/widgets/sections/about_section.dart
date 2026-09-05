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
import 'package:weblibre/core/routing/routes.dart';

import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';

/// The about screen, on its own so it can be moved or switched off like any
/// other section.
class AboutSection extends StatelessWidget {
  final List<MenuItemType> items;

  const AboutSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return buildMenuCard(
      context,
      children: [
        for (final item in items)
          if (item == MenuItemType.about)
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(item.label),
              onTap: () async {
                Navigator.pop(context);
                await AboutRoute().push(context);
              },
            ),
      ],
    );
  }
}
