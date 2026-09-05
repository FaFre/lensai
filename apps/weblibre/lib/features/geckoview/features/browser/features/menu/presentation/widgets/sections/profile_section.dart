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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';
import 'package:weblibre/features/sync/domain/entities/sync_repository_state.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Profile switch, sync, settings and quit.
class ProfileSection extends HookConsumerWidget {
  final List<MenuItemType> items;

  const ProfileSection({super.key, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tiles = <MenuItemType, Widget>{};

    for (final item in items) {
      switch (item) {
        case MenuItemType.profileSwitch:
          final profile = ref.watch(selectedProfileProvider);
          tiles[item] = ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(profile.value?.name ?? item.label),
            subtitle: Text(
              'Tap to switch profile',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              await const SelectProfileRoute().push(context);
            },
          );

        case MenuItemType.syncNow:
          if (!ref.watch(syncIsAuthenticatedProvider)) continue;
          tiles[item] = const _SyncTile();

        case MenuItemType.appSettings:
          tiles[item] = ListTile(
            leading: const Icon(Icons.settings),
            title: Text(item.label),
            onTap: () async {
              Navigator.pop(context);
              await SettingsRoute().push(context);
            },
          );

        case MenuItemType.quitBrowser:
          tiles[item] = ListTile(
            leading: Icon(MdiIcons.power, color: theme.colorScheme.error),
            title: Text(
              item.label,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              final result = await showQuitBrowserDialog(context);

              if (result == true) {
                await exitApp(ref.container);
              }
            },
            onLongPress: () async {
              Navigator.pop(context);
              await exitApp(ref.container);
            },
          );

        default:
          continue;
      }
    }

    return buildMenuCard(
      context,
      children: [
        for (final item in items)
          if (tiles[item] case final tile?) tile,
      ],
    );
  }
}

class _SyncTile extends HookConsumerWidget {
  const _SyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncInfo = ref.watch(
      syncRepositoryProvider.select((value) => value.value?.account),
    );

    final syncStarted = ref.watch(
      syncEventProvider.select(
        (value) => value.isLoading || value.value?.$1 == SyncEvent.started,
      ),
    );
    final isSyncing = syncStarted || syncInfo?.syncing == true;

    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final controller = useAnimationController(
      duration: disableAnimations ? Duration.zero : const Duration(seconds: 2),
    );

    useEffect(() {
      if (isSyncing && !disableAnimations) {
        unawaited(controller.repeat());
      } else {
        controller.stop();
        controller.reset();
      }
      return null;
    }, [isSyncing, disableAnimations]);

    return ListTile(
      leading: RotationTransition(
        turns: Tween<double>(begin: 0, end: -1).animate(controller),
        child: const Icon(Icons.sync),
      ),
      title: Text(MenuItemType.syncNow.label),
      onTap: () async {
        await ref.read(syncRepositoryProvider.notifier).syncNow();

        final openedTabs = await ref
            .read(syncRepositoryProvider.notifier)
            .pollIncomingTabsAndOpen();

        if (context.mounted) {
          if (openedTabs > 0) {
            ui_helper.showOpenedTabsFromAnotherDeviceMessage(
              context,
              openedTabs,
            );
          } else {
            ui_helper.showInfoMessage(
              context,
              'Synchronization complete',
              duration: const Duration(seconds: 2),
            );
          }
        }

        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}
