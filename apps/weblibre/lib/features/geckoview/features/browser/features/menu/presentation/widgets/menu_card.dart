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

/// Vertical gap below a menu section.
///
/// Carried by the section rather than by the list that holds it, so a section
/// whose rows are all hidden or unavailable leaves no gap behind.
const double menuSectionSpacing = 16.0;

/// Wraps a section's rows in the sheet's card surface, separating them with
/// dividers.
///
/// Dividers are interleaved here rather than baked into the rows, because the
/// rows are ordered by the user and drop out when they do not apply — a row
/// that draws its own leading divider ends up drawing it at the top of the card
/// as soon as it is moved or the row above it disappears.
Widget buildMenuCard(BuildContext context, {required List<Widget> children}) {
  if (children.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(bottom: menuSectionSpacing),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) menuCardDivider,
            children[i],
          ],
        ],
      ),
    ),
  );
}

const menuCardDivider = Divider(
  height: 1,
  thickness: 1,
  indent: 16,
  endIndent: 16,
);

/// A row nested under an expandable menu row, indented to clear its icon.
Widget buildMenuSubTile(
  String title, {
  IconData? icon,
  Color? iconColor,
  Widget? trailing,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.only(left: 56, right: 16),
    leading: icon != null ? Icon(icon, color: iconColor, size: 20) : null,
    title: Text(title, style: const TextStyle(fontSize: 14)),
    trailing: trailing,
    dense: true,
    onTap: onTap,
  );
}

/// Strips the divider an [ExpansionTile] draws above and below itself, so the
/// card's own dividers are the only ones in play.
Widget menuExpansionTheme({
  required BuildContext context,
  required Widget child,
}) {
  return Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: child,
  );
}
