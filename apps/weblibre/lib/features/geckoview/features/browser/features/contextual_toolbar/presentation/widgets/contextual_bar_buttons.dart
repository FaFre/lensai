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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/browser_menu_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/share_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_creation_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart'
    as tab_data;
import 'package:weblibre/features/geckoview/features/tabs/utils/background_tab_open.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';

class ShareMenuButton extends StatelessWidget {
  final String? selectedTabId;

  const ShareMenuButton({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context) {
    return ShareMenuButtonView(
      onPressed: selectedTabId == null
          ? null
          : () async {
              await showShareBottomSheet(
                context,
                selectedTabId: selectedTabId!,
              );
            },
    );
  }
}

class ShareMenuButtonView extends StatelessWidget {
  const ShareMenuButtonView({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: const Icon(Icons.share));
  }
}

class NavigationMenuButton extends StatelessWidget {
  final String? selectedTabId;

  const NavigationMenuButton({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context) {
    return NavigationMenuButtonView(
      onTap: () async {
        await showBrowserMenuSheet(context);
      },
      onLongPress: () async {
        await SettingsRoute().push(context);
      },
    );
  }
}

class NavigationMenuButtonView extends StatelessWidget {
  const NavigationMenuButtonView({super.key, this.onTap, this.onLongPress});

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ToolbarButton(
      onTap: onTap,
      onLongPress: onLongPress,
      child: const Icon(Icons.more_vert),
    );
  }
}

class AddTabButton extends HookConsumerWidget {
  const AddTabButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabMenuController = useMenuController();

    return TabCreationMenu(
      controller: tabMenuController,
      child: AddTabButtonView(
        onPressed: () async {
          final settings = ref.read(generalSettingsWithDefaultsProvider);

          await SearchRoute(
            tabType:
                ref.read(selectedTabTypeProvider) ??
                settings.effectiveDefaultCreateTabType,
          ).push(context);

          if (context.mounted) {
            const BrowserRoute().go(context);
          }
        },
        onLongPress: () {
          if (tabMenuController.isOpen) {
            tabMenuController.close();
          } else {
            tabMenuController.open();
          }
        },
      ),
    );
  }
}

class AddTabButtonView extends StatelessWidget {
  const AddTabButtonView({super.key, this.onPressed, this.onLongPress});

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(MdiIcons.tabPlus),
      onLongPress: onLongPress,
    );
  }
}

class CloneTabButton extends HookConsumerWidget {
  const CloneTabButton({super.key, required this.selectedTabId});

  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabMenuController = useMenuController();

    return CloneTabMenu(
      controller: tabMenuController,
      selectedTabId: selectedTabId,
      child: CloneTabButtonView(
        onPressed: selectedTabId == null
            ? null
            : () => _cloneCurrentTabMode(context, ref, selectedTabId!),
        onLongPress: selectedTabId == null
            ? null
            : () {
                if (tabMenuController.isOpen) {
                  tabMenuController.close();
                } else {
                  tabMenuController.open();
                }
              },
      ),
    );
  }
}

class CloneTabButtonView extends StatelessWidget {
  const CloneTabButtonView({super.key, this.onPressed, this.onLongPress});

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      icon: const Icon(MdiIcons.contentDuplicate),
    );
  }
}

class CloneTabMenu extends HookConsumerWidget {
  const CloneTabMenu({
    super.key,
    required this.child,
    required this.controller,
    required this.selectedTabId,
  });

  final Widget child;
  final MenuController controller;
  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showIsolatedTabUi = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.showIsolatedTabUi,
      ),
    );

    return MenuAnchor(
      controller: controller,
      builder: (context, controller, child) {
        return child!;
      },
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(MdiIcons.tab),
          onPressed: selectedTabId == null
              ? null
              : () => _cloneTabAsRegular(context, ref, selectedTabId!),
          child: const Text('Clone as Regular'),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            MdiIcons.dominoMask,
            color: AppColors.of(context).privateTabPurple,
          ),
          onPressed: selectedTabId == null
              ? null
              : () => _cloneTabAsPrivate(context, ref, selectedTabId!),
          child: const Text('Clone as Private'),
        ),
        if (showIsolatedTabUi)
          MenuItemButton(
            leadingIcon: Icon(
              MdiIcons.snowflake,
              color: AppColors.of(context).isolatedTabTeal,
            ),
            onPressed: selectedTabId == null
                ? null
                : () => _cloneTabAsIsolated(context, ref, selectedTabId!),
            child: const Text('Clone as Isolated'),
          ),
      ],
      child: child,
    );
  }
}

class TabsCountButtonView extends StatelessWidget {
  const TabsCountButtonView({
    super.key,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
    this.buttonBuilder,
  });

  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget Function(
    bool isActive,
    VoidCallback onTap,
    VoidCallback? onLongPress,
  )?
  buttonBuilder;

  @override
  Widget build(BuildContext context) {
    return (buttonBuilder != null)
        ? buttonBuilder!(isActive, onTap, onLongPress)
        : TabsActionButton(
            isActive: isActive,
            onTap: onTap,
            onLongPress: onLongPress,
          );
  }
}

Future<void> _cloneCurrentTabMode(
  BuildContext context,
  WidgetRef ref,
  String selectedTabId,
) async {
  final containerData = await ref
      .read(tab_data.tabDataRepositoryProvider.notifier)
      .getTabContainerData(selectedTabId);

  final tabId = await ref
      .read(tabRepositoryProvider.notifier)
      .duplicateTab(
        selectTabId: selectedTabId,
        containerData: containerData,
        selectTab: false,
      );

  if (context.mounted) {
    handleBackgroundTabOpened(context, ref, tabId);
  }
}

Future<void> _cloneTabAsRegular(
  BuildContext context,
  WidgetRef ref,
  String selectedTabId,
) {
  return _cloneTabAsMode(context, ref, selectedTabId, mode: TabMode.regular);
}

Future<void> _cloneTabAsPrivate(
  BuildContext context,
  WidgetRef ref,
  String selectedTabId,
) {
  return _cloneTabAsMode(context, ref, selectedTabId, mode: TabMode.private);
}

Future<void> _cloneTabAsIsolated(
  BuildContext context,
  WidgetRef ref,
  String selectedTabId,
) {
  return _cloneTabAsMode(
    context,
    ref,
    selectedTabId,
    mode: TabMode.newIsolated(),
  );
}

Future<void> _cloneTabAsMode(
  BuildContext context,
  WidgetRef ref,
  String selectedTabId, {
  required TabMode mode,
}) async {
  final tabState = ref.read(tabStateProvider(selectedTabId));
  if (tabState == null) return;

  // Sandbox-captured tab: clone the canonical source URL so the new tab
  // either re-captures or loads the real site — never the loopback loader.
  final cloneUrl =
      ref.read(sandboxSourceUriForTabProvider(tabId: tabState.id)) ??
      tabState.url;

  final containerData = await ref
      .read(tab_data.tabDataRepositoryProvider.notifier)
      .getTabContainerData(selectedTabId);
  final repo = ref.read(tabRepositoryProvider.notifier);

  final tabId = switch (mode) {
    RegularTabMode() =>
      tabState.tabMode is RegularTabMode
          ? await repo.duplicateTab(
              selectTabId: selectedTabId,
              containerData: containerData,
              selectTab: false,
            )
          : await repo.addTab(
              tabMode: TabMode.regular,
              url: cloneUrl,
              containerSelection: containerData == null
                  ? const TabContainerSelection.unassigned()
                  : TabContainerSelection.specific(containerData),
              selectTab: false,
            ),
    PrivateTabMode() =>
      tabState.tabMode is PrivateTabMode
          ? await repo.duplicateTab(
              selectTabId: selectedTabId,
              containerData: containerData,
              selectTab: false,
            )
          : await repo.addTab(
              tabMode: TabMode.private,
              url: cloneUrl,
              containerSelection: containerData == null
                  ? const TabContainerSelection.unassigned()
                  : TabContainerSelection.specific(containerData),
              selectTab: false,
            ),
    IsolatedTabMode() => await repo.addTab(
      tabMode: TabMode.newIsolated(),
      url: cloneUrl,
      containerSelection: containerData == null
          ? const TabContainerSelection.unassigned()
          : TabContainerSelection.specific(containerData),
      selectTab: false,
    ),
  };

  if (context.mounted) {
    handleBackgroundTabOpened(context, ref, tabId);
  }
}

class TabsCountButton extends HookConsumerWidget {
  const TabsCountButton({
    super.key,
    required this.selectedTabId,
    required this.displayedSheet,
    required this.showLongPressMenu,
  });

  final String? selectedTabId;
  final Sheet? displayedSheet;
  final bool showLongPressMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabMenuController = useMenuController();

    return TabCreationMenu(
      controller: tabMenuController,
      child: TabsCountButtonView(
        isActive: displayedSheet is ViewTabsSheet,
        onTap: () async {
          final tabViewBottomSheet = ref
              .read(generalSettingsWithDefaultsProvider)
              .tabViewBottomSheet;

          if (tabViewBottomSheet) {
            if (displayedSheet case ViewTabsSheet()) {
              ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
            } else {
              ref
                  .read(bottomSheetControllerProvider.notifier)
                  .show(ViewTabsSheet());
            }
          } else {
            await const TabViewRoute().push(context);
          }
        },
        onLongPress: showLongPressMenu
            ? () {
                if (tabMenuController.isOpen) {
                  tabMenuController.close();
                } else {
                  tabMenuController.open();
                }
              }
            : null,
      ),
    );
  }
}
