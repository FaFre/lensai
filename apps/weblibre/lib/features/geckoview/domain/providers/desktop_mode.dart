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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/host_rules.dart';

part 'desktop_mode.g.dart';

@Riverpod(keepAlive: true)
class DesktopMode extends _$DesktopMode {
  // ignore: use_setters_to_change_properties
  void enabled(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }

  /// Resolves the desktop-mode state a tab on [host] should have, honouring the
  /// per-site rule list first and falling back to the browser-wide default.
  bool _resolveForHost(Uri? url) {
    final settings = ref.read(generalSettingsWithDefaultsProvider);
    if (url != null && hostMatchesRule(url, settings.desktopModeSites)) {
      return true;
    }
    return settings.globalDesktopMode;
  }

  @override
  bool build(String tabId) {
    listenSelf((previous, next) async {
      if (previous != null) {
        await ref
            .read(tabSessionProvider(tabId: tabId).notifier)
            .requestDesktopSite(next);
      }
    });

    // Re-apply the per-site rule whenever the tab's host changes. A manual
    // toggle from the menu therefore lasts only for the current host-visit:
    // landing on a ruled host forces desktop on again, and leaving it reverts
    // to the browser-wide default. Watching only the host keeps in-page
    // navigations (path/query changes) from clobbering a manual override.
    // The keep-alive/auto-dispose pairing is the point: this notifier outlives
    // every menu and sheet so the per-site rule is still applied when the tab
    // navigates with nothing on screen watching it, and the tab-state selector
    // it holds open is a cheap projection of the keep-alive tab-state map.
    // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
    ref.listen(tabStateProvider(tabId), (previous, next) {
      // Only a real host is a page whose rule can be applied. A navigation can
      // pass through a hostless URL on its way — `about:blank` shows up as a
      // transient location change when the engine switches content process —
      // and reacting to it applies the *next* page's rule while the current one
      // is still committed. `requestDesktopSite` reloads unconditionally
      // (`toggleDesktopMode(enable, reload = true)`), so that reload lands on
      // the old entry and cancels the navigation in flight, snapping the tab
      // back to the page it was leaving.
      final nextHost = next?.url.host;
      if (nextHost == null || nextHost.isEmpty) return;
      if (previous?.url.host != nextHost) {
        state = _resolveForHost(next?.url);
      }
    });

    // Seed the initial value from the per-site rule (falling back to the
    // browser-wide default) so a newly opened tab's menu checkbox matches the
    // desktop mode it was actually created with natively (GeckoTabsApi seeds
    // new tabs from BrowserState.desktopMode). Read (not watch) so toggling the
    // global default never clobbers an existing tab's per-tab override.
    // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
    final resolved = _resolveForHost(ref.read(tabStateProvider(tabId))?.url);

    // The engine seeds a tab's desktop mode from the browser-wide default at
    // creation, and a global-default change re-applies to every tab, so at the
    // moment this notifier (re)builds the engine holds [globalDesktopMode]. When
    // a per-site rule resolves to a different value, push it now: the listenSelf
    // guard above skips the initial seed, so without this the rule would never
    // reach Gecko unless the host later changed while this notifier was alive
    // (which only happens when a menu/sheet kept it mounted across a navigation).
    final globalDesktopMode = ref
        .read(generalSettingsWithDefaultsProvider)
        .globalDesktopMode;
    if (resolved != globalDesktopMode) {
      unawaited(
        Future.microtask(() async {
          if (!ref.mounted) return;
          await ref
              .read(tabSessionProvider(tabId: tabId).notifier)
              .requestDesktopSite(resolved);
        }),
      );
    }

    return resolved;
  }
}

/// Always-mounted helper that instantiates the selected tab's [DesktopMode]
/// notifier so the per-site desktop-mode rule is applied on navigation even when
/// no tab menu or site sheet is open. Mounted by the browser view. [DesktopMode]
/// is keepAlive, so once built for a tab its navigation listener keeps running
/// for that tab's lifetime; this just guarantees it gets built when a tab
/// becomes selected (e.g. after opening a ruled site from the address bar).
@Riverpod(keepAlive: true)
void desktopModeRuleApplier(Ref ref) {
  final selectedTabId = ref.watch(selectedTabProvider);
  if (selectedTabId != null) {
    ref.watch(desktopModeProvider(selectedTabId));
  }
}
