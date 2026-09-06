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

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/effective_tab_routing.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/connection_usage.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/proxy/presentation/widgets/proxy_connection_picker_sheet.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// How the current tab is routed, the settings that decide it, and the backends
/// those settings name.
///
/// The routing rows edit the narrowest setting that applies (the tab's own
/// container before the global route), and the backend rows below say what each
/// connection is used *for* — a proxy that is off while a route names it blocks
/// that route rather than falling back to a direct connection, which is the one
/// failure the browser cannot otherwise explain.
class ConnectionSection extends ConsumerWidget {
  final String? selectedTabId;

  const ConnectionSection({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);

    final connectionsExpanded = ref.watch(
      persistedBoolProvider(PersistedBoolKey.connectionsExpanded),
    );

    final routing = ref.watch(effectiveTabRoutingProvider(selectedTabId));
    final routingSettings = ref.watch(proxyRoutingSettingsWithDefaultsProvider);
    final proxyOptions = ref.watch(proxyConnectionOptionsProvider);
    final container = ref
        .watch(watchTabContainerDataProvider(selectedTabId))
        .value;
    final containers =
        ref.watch(watchContainersWithCountProvider).value ?? const [];

    final isTorActive = ref.watch(
      torProxyServiceProvider.select((value) => value.value?.isRunning == true),
    );
    final isTorBusy = ref.watch(startProxyControllerProvider);

    final profiles =
        ref.watch(singboxProxyProfilesRepositoryProvider).value ?? const [];
    final runtimeEndpointIds = ref
        .watch(
          singboxProxyRuntimeRepositoryProvider.select((value) {
            final endpoints = value.value?.endpoints;
            if (endpoints == null) {
              return EquatableValue(const <String>{});
            }

            return EquatableValue({
              for (final endpoint in endpoints) endpoint.profileId,
            });
          }),
        )
        .value;

    final routeRows = <Widget>[
      // The global route, which every container without its own route inherits.
      _RouteRow(
        icon: MdiIcons.tab,
        label: 'Regular tabs',
        value:
            routingSettings.regularTabsMode == ProxyRegularTabRoutingMode.all &&
                routingSettings.regularTabsProxyConnectionId != null
            ? 'All through ${proxyConnectionTitle(proxyOptions, routingSettings.regularTabsProxyConnectionId!)}'
            : 'Per container',
        onTap: () async {
          // Read before the picker opens. The sheet can outlive this row —
          // the menu behind it closes on a drag or an external navigation —
          // and a `WidgetRef` throws once its widget is gone.
          final repository = ref.read(
            proxyRoutingSettingsRepositoryProvider.notifier,
          );

          final outcome = await showProxyConnectionPicker(
            context,
            title: 'Regular tabs',
            selectedProxyConnectionId:
                routingSettings.regularTabsMode ==
                    ProxyRegularTabRoutingMode.all
                ? routingSettings.regularTabsProxyConnectionId
                : null,
            noneTitle: 'Per container',
            noneSubtitle: 'Only containers with a proxy assigned are routed',
          );

          switch (outcome) {
            case null:
              break;
            case ProxyPickerCleared() || ProxyPickerDirect():
              await repository.updateSettings(
                (current) => current.copyWith(
                  regularTabsMode: ProxyRegularTabRoutingMode.container,
                ),
              );
            case ProxyPickerSelected(:final id):
              await repository.updateSettings(
                (current) => current.copyWith(
                  regularTabsMode: ProxyRegularTabRoutingMode.all,
                  regularTabsProxyConnectionId: id,
                ),
              );
              if (context.mounted) {
                await ensureProxyStartedForConnection(context, ref, id);
              }
          }
        },
      ),
      // Private tabs have their own route and never inherit the global one, so
      // it is only worth a row while a private tab is in front.
      if (routing.contextId == privateContextId)
        _RouteRow(
          icon: MdiIcons.dominoMask,
          iconColor: appColors.privateTabPurple,
          label: 'Private tabs',
          value: switch (routingSettings.privateTabsProxyConnectionId) {
            final id? => proxyConnectionTitle(proxyOptions, id),
            null => 'Direct',
          },
          onTap: () async {
            final repository = ref.read(
              proxyRoutingSettingsRepositoryProvider.notifier,
            );

            final outcome = await showProxyConnectionPicker(
              context,
              title: 'Private tabs',
              selectedProxyConnectionId:
                  routingSettings.privateTabsProxyConnectionId,
              noneTitle: 'Direct',
              noneSubtitle: 'Private tabs never inherit the global route',
            );

            final proxyConnectionId = switch (outcome) {
              null => null,
              ProxyPickerSelected(:final id) => id,
              ProxyPickerCleared() || ProxyPickerDirect() => null,
            };
            if (outcome == null) return;

            await repository.updateSettings(
              (current) => current.copyWith(
                privateTabsProxyConnectionId: proxyConnectionId,
              ),
            );

            if (context.mounted) {
              await ensureProxyStartedForConnection(
                context,
                ref,
                proxyConnectionId,
              );
            }
          },
        ),
      // An isolated tab has a cookie store of its own, so it can be routed
      // independently of the container it sits in.
      if (routing.contextId case final isolationContextId?
          when isIsolatedContextId(isolationContextId))
        _RouteRow(
          icon: MdiIcons.snowflake,
          iconColor: appColors.isolatedTabTeal,
          label: 'This isolated tab',
          value: switch (routingSettings
              .isolationContextRoutes[isolationContextId]) {
            final id? => proxyConnectionTitle(proxyOptions, id),
            null =>
              routingSettings.isolationContextRoutes.containsKey(
                    isolationContextId,
                  )
                  ? 'Direct'
                  : 'Follows its container',
          },
          onTap: () async {
            final routes = routingSettings.isolationContextRoutes;
            final repository = ref.read(
              proxyRoutingSettingsRepositoryProvider.notifier,
            );

            final outcome = await showProxyConnectionPicker(
              context,
              title: 'This isolated tab',
              selectedProxyConnectionId: routes[isolationContextId],
              isDirectSelected:
                  routes.containsKey(isolationContextId) &&
                  routes[isolationContextId] == null,
              noneTitle: 'Follow its container',
              noneSubtitle: 'Use whatever routes the container it sits in',
              directTitle: 'Direct',
              directSubtitle: 'Bypass the route its container would apply',
            );
            if (outcome == null) return;

            switch (outcome) {
              case ProxyPickerCleared():
                await repository.clearIsolationContextRoute(isolationContextId);
              case ProxyPickerDirect():
                await repository.setIsolationContextRoute(
                  isolationContextId,
                  null,
                );
              case ProxyPickerSelected(:final id):
                await repository.setIsolationContextRoute(
                  isolationContextId,
                  id,
                );
                if (context.mounted) {
                  await ensureProxyStartedForConnection(context, ref, id);
                }
            }
          },
        ),
      // Only a container with a cookie-store context of its own can carry a
      // route; the others share the general context.
      if (container != null && container.metadata.contextualIdentity != null)
        _RouteRow(
          icon: resolveContainerIcon(container.metadata.iconData),
          label: container.name ?? 'This container',
          value: switch (container.metadata.proxyConnectionId) {
            final id? => proxyConnectionTitle(proxyOptions, id),
            null when container.metadata.bypassGlobalProxy => 'Direct',
            null => 'Follows global routing',
          },
          onTap: () async {
            final containerRepository = ref.read(
              containerRepositoryProvider.notifier,
            );

            final outcome = await showProxyConnectionPicker(
              context,
              title: container.name ?? 'Container',
              selectedProxyConnectionId: container.metadata.proxyConnectionId,
              isDirectSelected: container.metadata.bypassGlobalProxy,
              noneTitle: 'Follow global routing',
              noneSubtitle: 'Use whatever routes regular tabs',
              directTitle: 'Direct',
              directSubtitle: 'Bypass the global proxy for this container',
            );
            if (outcome == null) return;

            final proxyConnectionId = switch (outcome) {
              ProxyPickerSelected(:final id) => id,
              ProxyPickerCleared() || ProxyPickerDirect() => null,
            };

            try {
              await containerRepository.replaceContainer(
                container.copyWith.metadata(
                  container.metadata
                      .copyWith(
                        proxyConnectionId: proxyConnectionId,
                        // Bypass only applies while no proxy is assigned;
                        // the snapshot reads the two in that order.
                        bypassGlobalProxy:
                            proxyConnectionId == null &&
                            outcome is ProxyPickerDirect,
                      )
                      .sanitized(),
                ),
              );
            } catch (error, stackTrace) {
              logger.e(
                'Failed to change container route from the browser menu',
                error: error,
                stackTrace: stackTrace,
              );
              if (context.mounted) {
                ui_helper.showErrorMessage(
                  context,
                  'Failed to change route: $error',
                );
              }
              return;
            }

            if (context.mounted) {
              await ensureProxyStartedForConnection(
                context,
                ref,
                proxyConnectionId,
              );
            }
          },
        ),
    ];

    // A subscription import can leave dozens of profiles behind, so the menu
    // lists only the ones this browser is actually using — plus anything
    // running, which has to stay stoppable from here.
    final relevantProfiles =
        [
          for (final profile in profiles)
            (
              profile,
              proxyConnectionUsage(
                id: profile.proxyConnection,
                routingSettings: routingSettings,
                containers: containers,
              ),
            ),
        ].where((entry) {
          final (profile, usage) = entry;
          return !usage.isUnused ||
              runtimeEndpointIds.contains(profile.proxyConnectionId);
        }).toList();

    final connectionRows = <Widget>[
      _ConnectionRow(
        icon: TorIcons.onionAlt,
        label: torProxyLabel,
        active: isTorActive,
        enabled: !isTorBusy,
        usage: proxyConnectionUsage(
          id: const TorProxyConnectionId(),
          routingSettings: routingSettings,
          containers: containers,
        ),
        onToggle: () async {
          if (isTorBusy) return;
          if (isTorActive) {
            await ref.read(torProxyServiceProvider.notifier).disconnect();
          } else {
            await ref.read(startProxyControllerProvider.notifier).startProxy();
          }
        },
        onEdit: () async {
          Navigator.pop(context);
          await const TorProxyRoute().push(context);
        },
      ),
      for (final (profile, usage) in relevantProfiles)
        _ConnectionRow(
          icon: MdiIcons.lanConnect,
          label: profile.name,
          active: runtimeEndpointIds.contains(profile.proxyConnectionId),
          usage: usage,
          onToggle: () async {
            final runtime = ref.read(
              singboxProxyRuntimeRepositoryProvider.notifier,
            );
            final isRunning = runtimeEndpointIds.contains(
              profile.proxyConnectionId,
            );

            try {
              if (isRunning) {
                await runtime.stopProfiles([profile.id]);
              } else {
                await runtime.startProfile(profile.id);
              }
            } catch (error, stackTrace) {
              logger.e(
                'Failed to toggle proxy profile ${profile.id} from menu',
                error: error,
                stackTrace: stackTrace,
              );
              if (context.mounted) {
                ui_helper.showErrorMessage(context, 'Proxy error: $error');
              }
            }
          },
          onEdit: () async {
            Navigator.pop(context);
            await SingboxProxyProfileEditorRoute(
              profileId: profile.id,
            ).push(context);
          },
        ),
    ];

    // A container that names a proxy while its own tab connects directly is a
    // misconfiguration nothing else in the browser reports.
    final isContextMismatch = routing.isContextMismatch;

    final (IconData headerIcon, Color? headerColor) = switch (routing.status) {
      _ when isContextMismatch => (
        MdiIcons.shieldAlertOutline,
        colorScheme.error,
      ),
      TabRoutingStatus.active => (
        MdiIcons.shieldCheck,
        appColors.torActiveGreen,
      ),
      TabRoutingStatus.blocked => (MdiIcons.shieldOff, colorScheme.error),
      TabRoutingStatus.pending => (MdiIcons.shieldSync, null),
      TabRoutingStatus.unknown => (MdiIcons.shieldOutline, null),
      // Shares the site sheet's icon for the same state, and keeps the header
      // clear of glyphs that read as arrows next to the text.
      TabRoutingStatus.direct => (Icons.public, null),
    };

    return buildMenuCard(
      context,
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(headerIcon, color: headerColor),
            title: const Text('Connection'),
            subtitle: Text(
              _routingSummary(routing),
              style:
                  routing.status == TabRoutingStatus.blocked ||
                      isContextMismatch
                  ? TextStyle(color: colorScheme.error)
                  : null,
            ),
            initiallyExpanded: connectionsExpanded,
            onExpansionChanged: (_) => ref
                .read(
                  persistedBoolProvider(
                    PersistedBoolKey.connectionsExpanded,
                  ).notifier,
                )
                .toggle(),
            children: [
              // The fix for a blocked route is always to start the backend it
              // names, so offer that before the routing rows.
              if (routing.status == TabRoutingStatus.blocked &&
                  routing.proxyConnectionId != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 4, 16, 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton.tonalIcon(
                      onPressed: () => ensureProxyStartedForConnection(
                        context,
                        ref,
                        routing.proxyConnectionId,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: Text('Start ${routing.proxyTitle}'),
                    ),
                  ),
                ),
              for (final row in routeRows) row,
              const Divider(indent: 56, endIndent: 16),
              for (final row in connectionRows) row,
              const Divider(indent: 56, endIndent: 16),
              // One way out of the menu: the proxy settings screen forks into
              // routing and connection management itself, so offering both
              // here only asks the user to pick before they know which they
              // want.
              buildMenuSubTile(
                'Proxy Settings',
                icon: Icons.settings_outlined,
                onTap: () async {
                  Navigator.pop(context);
                  await const ProxySettingsRoute().push<void>(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One-line answer to "where is this tab's traffic going".
String _routingSummary(TabRouting routing) {
  if (routing.isContextMismatch) {
    return switch (routing.containerName) {
      final container? => 'Not routed by container "$container"',
      null => "Not routed by this tab's container",
    };
  }

  return switch (routing.status) {
    TabRoutingStatus.unknown => 'Checking routing…',
    TabRoutingStatus.pending => 'Starting routing…',
    TabRoutingStatus.blocked =>
      'Blocked — ${routing.proxyTitle} is not running',
    TabRoutingStatus.active => 'This tab: ${routing.proxyTitle}',
    TabRoutingStatus.direct => 'This tab: direct connection',
  };
}

/// A routing *decision* — which connection carries a class of tabs — as opposed
/// to a [_ConnectionRow], which starts and stops a backend.
class _RouteRow extends StatelessWidget {
  final IconData icon;

  /// Tab types carry their own colour throughout the app (private purple,
  /// isolated teal); null keeps the neutral list-tile tint.
  final Color? iconColor;

  final String label;
  final String value;
  final Future<void> Function() onTap;

  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 56, right: 16),
      leading: Icon(
        icon,
        size: 20,
        color: iconColor ?? colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      dense: true,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => onTap(),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool enabled;

  /// What routes name this connection, if any. A used connection that is off
  /// blocks those routes, which the row says outright.
  final ProxyConnectionUsage usage;

  final Future<void> Function() onToggle;
  final Future<void> Function() onEdit;

  const _ConnectionRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.usage,
    required this.onToggle,
    required this.onEdit,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = AppColors.of(context).torActiveGreen;

    final isBlocking = !usage.isUnused && !active;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 56, right: 16),
      leading: Icon(
        icon,
        size: 20,
        color: active
            ? activeColor
            : isBlocking
            ? colorScheme.error
            : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: _ConnectionUsageLine(usage: usage, isBlocking: isBlocking),
      onTap: enabled ? () => onToggle() : null,
      dense: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.circle : Icons.circle_outlined,
            size: 12,
            color: active
                ? activeColor
                : isBlocking
                ? colorScheme.error
                : colorScheme.outline,
          ),
          const SizedBox(width: 16),
          const VerticalDivider(indent: 4, endIndent: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Edit',
            onPressed: () => onEdit(),
          ),
        ],
      ),
    );
  }
}

/// The routes a connection carries, on one line of a dense tile.
///
/// The counted kinds are drawn as their icon with the number beside it rather
/// than spelled out — "2 containers · 1 isolated tab" is 29 characters where
/// the row has room for about thirty in total. The icons are the same ones the
/// routing rows above use for those scopes, so the line can be read off the
/// card it sits in; tooltips carry the words for anyone who needs them, and
/// give the screen reader something to say.
///
/// Built as spans rather than a `Row` so the whole line still truncates with an
/// ellipsis instead of overflowing when even this does not fit.
class _ConnectionUsageLine extends StatelessWidget {
  final ProxyConnectionUsage usage;

  /// The connection is off while routes still name it: they are not falling
  /// back to a direct connection, they are stopped.
  final bool isBlocking;

  const _ConnectionUsageLine({required this.usage, required this.isBlocking});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isBlocking ? colorScheme.error : colorScheme.onSurfaceVariant;

    if (usage.isUnused) {
      return Text(
        'Not used by any route',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isBlocking ? TextStyle(color: colorScheme.error) : null,
      );
    }

    InlineSpan countSpan(IconData icon, int count, String singular) {
      return TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Tooltip(
              message: count == 1 ? '1 $singular' : '$count ${singular}s',
              child: Icon(icon, size: 14, color: color),
            ),
          ),
          TextSpan(text: ' $count'),
        ],
      );
    }

    final parts = <InlineSpan>[
      // Leads rather than trails: it is the one word that must survive the
      // ellipsis, and the icons say nothing about it.
      if (isBlocking) const TextSpan(text: 'Blocked'),
      if (usage.routesRegularTabs) const TextSpan(text: 'Regular tabs'),
      if (usage.routesPrivateTabs) const TextSpan(text: 'Private tabs'),
      if (usage.containerCount > 0)
        countSpan(defaultContainerIcon, usage.containerCount, 'container'),
      if (usage.isolatedGroupCount > 0)
        countSpan(MdiIcons.snowflake, usage.isolatedGroupCount, 'isolated tab'),
    ];

    return Text.rich(
      TextSpan(
        children: [
          for (final (index, part) in parts.indexed) ...[
            if (index > 0) const TextSpan(text: ' · '),
            part,
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: isBlocking ? TextStyle(color: colorScheme.error) : null,
    );
  }
}
