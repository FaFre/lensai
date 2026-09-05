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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_close_confirmation.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/history_menu.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// The fixed row pinned below the menu's scrolling content: back,
/// forward, close and reload for the tab in front.
///
/// Not part of the arrangeable layout — it is chrome the sheet always
/// shows while a tab is selected, not one of the sections.
class MenuNavigationRow extends HookConsumerWidget {
  final String selectedTabId;

  const MenuNavigationRow({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(tabHistoryStateProvider(selectedTabId));
    final host = ref.watch(
      tabStateProvider(selectedTabId).select((value) => value?.url.host),
    );
    final isLoading = ref.watch(
      tabStateProvider(
        selectedTabId,
      ).select((state) => state?.isLoading ?? false),
    );
    final isReaderActive = ref.watch(
      tabStateProvider(
        selectedTabId,
      ).select((state) => state?.readerableState.active ?? false),
    );

    final backMenuController = useMenuController();
    final forwardMenuController = useMenuController();
    final closeMenuController = useMenuController();
    final reloadMenuController = useMenuController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        HistoryMenu(
          selectedTabId: selectedTabId,
          controller: backMenuController,
          direction: HistoryMenuDirection.back,
          child: _buildNavIcon(
            icon: isLoading ? Icons.close : Icons.arrow_back,
            label: isLoading ? 'Stop' : 'Back',
            disabled: !isLoading && !history.canGoBack,
            onTap: () async {
              final controller = ref.read(
                tabSessionProvider(tabId: selectedTabId).notifier,
              );
              if (isLoading) {
                await controller.stopLoading();
              } else if (isReaderActive) {
                await ref
                    .read(readerableScreenControllerProvider.notifier)
                    .toggleReaderView(false);
              } else {
                await controller.goBack();
              }
              if (context.mounted) Navigator.pop(context);
            },
            onLongPress: isLoading || !history.canGoBack
                ? null
                : () {
                    if (backMenuController.isOpen) {
                      backMenuController.close();
                    } else {
                      backMenuController.open();
                    }
                  },
          ),
        ),
        HistoryMenu(
          selectedTabId: selectedTabId,
          controller: forwardMenuController,
          direction: HistoryMenuDirection.forward,
          child: _buildNavIcon(
            icon: Icons.arrow_forward,
            label: 'Forward',
            disabled: !history.canGoForward,
            onTap: () async {
              await ref
                  .read(tabSessionProvider(tabId: selectedTabId).notifier)
                  .goForward();
              if (context.mounted) Navigator.pop(context);
            },
            onLongPress: !history.canGoForward
                ? null
                : () {
                    if (forwardMenuController.isOpen) {
                      forwardMenuController.close();
                    } else {
                      forwardMenuController.open();
                    }
                  },
          ),
        ),
        MenuAnchor(
          controller: closeMenuController,
          builder: (context, controller, child) => child!,
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.tab),
              onPressed: () async {
                final tabStates = ref.read(tabStatesProvider);
                final otherIds = tabStates.keys
                    .where((id) => id != selectedTabId)
                    .toList();
                if (otherIds.isNotEmpty) {
                  await closeTabsWithConfirmation(context, ref, otherIds);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Close Others'),
            ),
            if (host != null && host.isNotEmpty)
              MenuItemButton(
                leadingIcon: const Icon(Icons.language),
                onPressed: () async {
                  final tabStates = ref.read(tabStatesProvider);
                  final sameHostIds = tabStates.entries
                      .where((e) => e.value.url.host == host)
                      .map((e) => e.key)
                      .toList();
                  if (sameHostIds.isNotEmpty) {
                    await closeTabsWithConfirmation(context, ref, sameHostIds);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Close from Same Host'),
              ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.account_tree),
              onPressed: () async {
                final descendants = await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .getContainerTabDescendants(selectedTabId);
                if (!context.mounted) return;

                final subtreeIds = descendants.keys.toList();
                if (subtreeIds.isNotEmpty) {
                  await closeTabsWithConfirmation(context, ref, subtreeIds);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Close Tab and Descendants'),
            ),
          ],
          child: _buildNavIcon(
            icon: MdiIcons.tabMinus,
            label: 'Close Tab',
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId));
              if (tabState != null && tabState.tabMode is IsolatedTabMode) {
                final allStates = ref.read(tabStatesProvider);
                final groupCount = allStates.values
                    .where(
                      (s) =>
                          s.isolationContextId == tabState.isolationContextId,
                    )
                    .length;
                if (groupCount <= 1 && context.mounted) {
                  final confirmed = await ui_helper.confirmIsolatedTabClose(
                    context,
                  );
                  if (!confirmed) return;
                }
              }

              await ref
                  .read(tabRepositoryProvider.notifier)
                  .closeTab(selectedTabId);

              if (context.mounted) {
                Navigator.pop(context);
                ui_helper.showTabUndoClose(
                  context,
                  ref.read(tabRepositoryProvider.notifier).undoClose,
                );
              }
            },
            onLongPress: () {
              if (closeMenuController.isOpen) {
                closeMenuController.close();
              } else {
                closeMenuController.open();
              }
            },
          ),
        ),
        MenuAnchor(
          controller: reloadMenuController,
          builder: (context, controller, child) => child!,
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.refresh),
              onPressed: () async {
                await ref
                    .read(tabSessionProvider(tabId: selectedTabId).notifier)
                    .reload(flags: LoadUrlFlags.BYPASS_CACHE);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Hard Refresh'),
            ),
          ],
          child: _buildNavIcon(
            icon: Icons.refresh,
            label: 'Reload',
            onTap: () async {
              await ref
                  .read(tabSessionProvider(tabId: selectedTabId).notifier)
                  .reload();
              if (context.mounted) Navigator.pop(context);
            },
            onLongPress: () {
              if (reloadMenuController.isOpen) {
                reloadMenuController.close();
              } else {
                reloadMenuController.open();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required String label,
    bool disabled = false,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return InkWell(
          onTap: disabled ? null : onTap,
          onLongPress: disabled ? null : onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: disabled
                      ? colorScheme.onSurface.withValues(alpha: 0.3)
                      : colorScheme.onSurface,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: disabled
                        ? colorScheme.onSurface.withValues(alpha: 0.3)
                        : colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
