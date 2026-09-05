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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';

/// The installed extensions, as one expandable row.
///
/// Offers no arrangeable items: the rows inside it are the extensions the
/// user has installed, which come and go on their own.
class ExtensionsSection extends HookConsumerWidget {
  const ExtensionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonService = ref.watch(addonServiceProvider);
    final extensionsExpanded = ref.watch(
      persistedBoolProvider(PersistedBoolKey.extensionsExpanded),
    );
    final pageExtensions = ref.watch(
      webExtensionsStateProvider(
        WebExtensionActionType.page,
      ).select((value) => value.values.toList()),
    );
    final browserExtensions = ref.watch(
      webExtensionsStateProvider(
        WebExtensionActionType.browser,
      ).select((value) => value.values.toList()),
    );
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    Future<void> openExtensionSettings(String extensionId) async {
      Navigator.pop(context);
      await AddonDetailsRoute(addonId: extensionId).push<void>(rootContext);
    }

    return buildMenuCard(
      context,
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: const Icon(MdiIcons.puzzle),
            title: const Text('Extensions'),
            initiallyExpanded: extensionsExpanded,
            onExpansionChanged: (_) => ref
                .read(
                  persistedBoolProvider(
                    PersistedBoolKey.extensionsExpanded,
                  ).notifier,
                )
                .toggle(),
            children: [
              // Page extensions
              if (pageExtensions.isNotEmpty) ...[
                ...pageExtensions.map(
                  (extension) => ListTile(
                    contentPadding: const EdgeInsets.only(left: 56, right: 16),
                    leading: ExtensionBadgeIcon(extension),
                    title: Text(
                      extension.title ?? 'Extension',
                      style: const TextStyle(fontSize: 14),
                    ),
                    dense: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VerticalDivider(indent: 4, endIndent: 4),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 20),
                          tooltip: 'Extension settings',
                          onPressed: () async {
                            await openExtensionSettings(extension.extensionId);
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await addonService.invokeAddonAction(
                        extension.extensionId,
                        WebExtensionActionType.page,
                      );
                    },
                  ),
                ),
                const Divider(indent: 56, endIndent: 16),
              ],
              // Browser extensions
              if (browserExtensions.isNotEmpty) ...[
                ...browserExtensions.map(
                  (extension) => ListTile(
                    contentPadding: const EdgeInsets.only(left: 56, right: 16),
                    leading: ExtensionBadgeIcon(extension),
                    title: Text(
                      extension.title ?? 'Extension',
                      style: const TextStyle(fontSize: 14),
                    ),
                    dense: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VerticalDivider(indent: 4, endIndent: 4),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 20),
                          tooltip: 'Extension settings',
                          onPressed: () async {
                            await openExtensionSettings(extension.extensionId);
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await addonService.invokeAddonAction(
                        extension.extensionId,
                        WebExtensionActionType.browser,
                      );
                    },
                  ),
                ),
                const Divider(indent: 56, endIndent: 16),
              ],
              // Management
              buildMenuSubTile(
                'Manage Extensions',
                icon: MdiIcons.puzzleEdit,
                onTap: () async {
                  Navigator.pop(context);
                  await const AddonManagerRoute().push<void>(rootContext);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
