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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/home_target.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

part 'home_target_controller.g.dart';

/// A custom-URL target reopened within this window of the last one is treated
/// as a loop and suppressed.
const _customUrlLoopWindow = Duration(seconds: 2);

/// How long the startup check waits for the restored selection to arrive before
/// concluding that there is none. Covers the native selected-tab debounce (50ms)
/// plus the channel hop, with room to spare.
const _restoredSelectionWindow = Duration(milliseconds: 300);

/// What [HomeTargetController] should actually do, given the configuration and
/// the current state.
///
/// Pure so the fallbacks and the loop guards can be tested without a browser.
HomeTarget resolveHomeTarget({
  required HomeTarget target,
  required String? customUrl,
  DateTime? lastCustomUrlOpenedAt,
  DateTime? now,
  Uri? closingTabUrl,
}) {
  switch (target) {
    case HomeTarget.home:
      return HomeTarget.home;

    case HomeTarget.resumeLastTab:
      // Whether there is anything to resume is only known once the repository
      // has looked; the caller falls back to home when it reports none.
      return HomeTarget.resumeLastTab;

    case HomeTarget.customUrl:
      final parsed = uri_parser.tryParseUrl(customUrl ?? '');
      if (parsed == null) {
        return HomeTarget.home;
      }

      // Closing the custom-URL tab must not immediately reopen it. Two guards,
      // because either alone is escapable: the URL check misses redirects away
      // from the configured address, and the time check misses a slow user.
      if (closingTabUrl != null && _sameTarget(closingTabUrl, parsed)) {
        return HomeTarget.home;
      }

      if (lastCustomUrlOpenedAt != null) {
        final elapsed = (now ?? DateTime.now()).difference(
          lastCustomUrlOpenedAt,
        );
        if (elapsed < _customUrlLoopWindow) {
          return HomeTarget.home;
        }
      }

      return HomeTarget.customUrl;
  }
}

/// Which container a home target opens its tab in.
///
/// Pure because this is exactly where the scope distinction is easy to get
/// wrong: under [scopeToContainer] a null [scopedContainer] means the
/// *unassigned* container and must stay unassigned, rather than silently
/// falling back to whichever container happens to be selected.
TabContainerSelection resolveHomeTargetContainer({
  required bool scopeToContainer,
  required ContainerData? scopedContainer,
  required ContainerData? selectedContainer,
}) {
  final container = scopeToContainer ? scopedContainer : selectedContainer;

  return container == null
      ? const TabContainerSelection.unassigned()
      : TabContainerSelection.specific(container);
}

bool _sameTarget(Uri a, Uri b) =>
    a.host.toLowerCase() == b.host.toLowerCase() && a.path == b.path;

/// Applies the configured [HomeTarget] when the browser has nothing to show.
@Riverpod(keepAlive: true)
class HomeTargetController extends _$HomeTargetController {
  DateTime? _lastCustomUrlOpenedAt;
  var _startupHandled = false;

  /// Runs the configured target.
  ///
  /// With [scopeToContainer] the target is confined to [containerId], so
  /// closing the last tab in a container keeps the user there. A null
  /// [containerId] under that flag means the *unassigned* container, which is a
  /// real scope — not the absence of one. Without the flag (cold start) the
  /// target is unscoped and follows the selected container.
  ///
  /// [closingTabUrl] is the tab that triggered this, used to break the
  /// custom-URL reopen loop. [excludedTabIds] are tabs that are being closed
  /// but not yet deleted, which a resume must not select.
  Future<void> applyTarget({
    bool scopeToContainer = false,
    String? containerId,
    Uri? closingTabUrl,
    Set<String> excludedTabIds = const {},
  }) async {
    final settings = ref.read(generalSettingsWithDefaultsProvider);
    final tabs = ref.read(tabRepositoryProvider.notifier);

    final resolved = resolveHomeTarget(
      target: settings.homeTarget,
      customUrl: settings.homeTargetUrl,
      lastCustomUrlOpenedAt: _lastCustomUrlOpenedAt,
      closingTabUrl: closingTabUrl,
    );

    switch (resolved) {
      case HomeTarget.home:
        ref.read(forceBrowserHomeProvider.notifier).request();

      case HomeTarget.resumeLastTab:
        // Scoped resume goes through the container query even for a null
        // container: that selects the newest *unassigned* tab, where the
        // unscoped call would happily jump into some other container.
        final resumed = scopeToContainer
            ? await tabs.resumeLatestContainerTab(
                containerId,
                excludedTabIds: excludedTabIds,
              )
            : await tabs.resumeLatestTab(excludedTabIds: excludedTabIds);

        // Nothing to resume: home beats leaving a blank viewport.
        if (!resumed && ref.mounted) {
          ref.read(forceBrowserHomeProvider.notifier).request();
        }

      case HomeTarget.customUrl:
        final url = uri_parser.tryParseUrl(settings.homeTargetUrl ?? '');
        if (url == null) {
          ref.read(forceBrowserHomeProvider.notifier).request();
          return;
        }

        _lastCustomUrlOpenedAt = DateTime.now();

        final scopedContainer = (scopeToContainer && containerId != null)
            ? await ref
                  .read(containerRepositoryProvider.notifier)
                  .getContainerData(containerId)
            : null;

        if (!ref.mounted) return;

        await tabs.addTab(
          url: url,
          tabMode: TabMode.regular,
          selectTab: true,
          containerSelection: resolveHomeTargetContainer(
            scopeToContainer: scopeToContainer,
            scopedContainer: scopedContainer,
            // A one-shot read takes no subscription, so this keep-alive
            // controller does not pin the auto-disposed stream.
            // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
            selectedContainer: ref.read(selectedContainerDataProvider).value,
          ),
        );
    }
  }

  /// Runs the configured target at cold start, unless the engine restored a
  /// selection of its own — the user is then already looking at a page.
  Future<void> _applyStartupTarget() async {
    if (await _hasRestoredSelection()) return;
    if (!ref.mounted) return;

    await applyTarget();
  }

  /// Whether the restored session came with a selected tab.
  ///
  /// The answer cannot be read off [selectedTabProvider] the moment restore
  /// completes: the two facts travel over independent native flows, and only
  /// the selected-tab one is debounced (~50ms, so that it lands after the
  /// tab-added and tab-list events). Restore-complete therefore reliably
  /// *overtakes* the selection it implies, and reading at that instant reports
  /// no tab for a session that has one. Acting on that latches the home surface
  /// over the restored tab, where it stays until the user picks a tab by hand.
  ///
  /// So the absence is waited on rather than read. [GeckoTabService.syncEvents]
  /// nudges native into pushing the current selection undebounced, but its
  /// reply is deliberately not the signal: native replies once it has *sent*
  /// the event, which says nothing about the event having arrived here — it
  /// travels on its own channel, and Flutter orders messages within a channel,
  /// not across them. The event itself is the signal; the nudge only shortens
  /// the wait for it.
  Future<bool> _hasRestoredSelection() async {
    if (ref.read(selectedTabProvider) != null) return true;

    final completer = Completer<bool>();

    // A ValueStream, so a selection that arrived before this subscription is
    // replayed into it — the gap between the read above and here cannot swallow
    // the event.
    final subscription = ref
        .read(eventServiceProvider)
        .selectedTabEvents
        .listen((tabId) {
          if (tabId != null && !completer.isCompleted) {
            completer.complete(true);
          }
        });

    // Bounds the wait for a session that genuinely restored nothing. Paid only
    // in that case, and against the home surface — which is already on screen
    // while no tab is selected, so the delay costs a target that opens or
    // resumes a tab slightly later, not a visible stall.
    final timeout = Timer(_restoredSelectionWindow, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    unawaited(
      GeckoTabService().syncEvents(onSelectedTabChange: true).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        // Non-fatal: the debounced push still arrives within the window.
        logger.w(
          'Failed to request the selected tab for the startup home target',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );

    try {
      return await completer.future;
    } finally {
      timeout.cancel();
      await subscription.cancel();
    }
  }

  @override
  void build() {
    ref.listen(
      // This controller is created lazily by the browser view. Restore can
      // already be complete by then, and a plain listen would sit waiting for
      // an edge that has been and gone, silently skipping the startup target.
      fireImmediately: true,
      browserRestoreCompleteProvider,
      (previous, next) {
        if (!next || _startupHandled) return;
        _startupHandled = true;

        unawaited(_applyStartupTarget());
      },
    );
  }
}
