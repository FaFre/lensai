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
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/font_size_constants.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/translation_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_cycle.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/gestures/data/models/gesture_action.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/data/models/gesture_stroke.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/host_rules.dart';
import 'package:weblibre/utils/move_to_background.dart';

part 'gesture_control.g.dart';

/// Bridges gesture settings and recognized-gesture events to app actions.
///
/// On build it (1) keeps the native recognizer's [GestureConfig] in sync with
/// the user's [GestureSettings], and (2) subscribes to recognized gestures and
/// dispatches the bound [GestureAction] against the currently selected tab.
///
/// Must be kept alive (eagerly listened to from the browser view) for the
/// lifetime of the browser so the subscription stays active.
@Riverpod(keepAlive: true)
class GestureControlService extends _$GestureControlService {
  /// Timestamp (ms since epoch) of the last fired gesture, for cooldown.
  int _lastDispatchMs = 0;

  @override
  void build() {
    final service = ref.read(gestureServiceProvider);

    // Keep the native recognizer in sync with the effective configuration
    // (settings folded together with the current site's exclusion state).
    ref.listen(
      fireImmediately: true,
      gestureNativeConfigProvider,
      (previous, next) async {
        await service.setGestureConfig(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error syncing gesture configuration',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final subscription = service.recognizedGestures.listen(
      (gestureKey) {
        unawaited(_dispatch(gestureKey));
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error handling recognized gesture',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    ref.onDispose(subscription.cancel);
  }

  Future<void> _dispatch(String gestureKey) async {
    final settings = ref.read(gestureSettingsWithDefaultsProvider);
    final action = settings.bindings[gestureKey];
    if (action == null) return;

    // Cooldown: ignore gestures fired within intervalMs of the previous one.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (settings.intervalMs > 0 &&
        now - _lastDispatchMs < settings.intervalMs) {
      return;
    }
    _lastDispatchMs = now;

    final tabId = ref.read(selectedTabProvider);
    if (tabId == null) return;

    try {
      // Feedback is handled live by the gesture overlay while the stroke is
      // drawn (driven by the native progress events), so nothing to show here.
      await _execute(action, tabId);
    } catch (error, stackTrace) {
      logger.e(
        'Error executing gesture action ${action.name}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _execute(GestureAction action, String tabId) async {
    final tabRepository = ref.read(tabRepositoryProvider.notifier);

    switch (action) {
      case GestureAction.back:
        await ref.read(tabSessionProvider(tabId: tabId).notifier).goBack();
      case GestureAction.forward:
        await ref.read(tabSessionProvider(tabId: tabId).notifier).goForward();
      case GestureAction.reload:
        await ref.read(tabSessionProvider(tabId: tabId).notifier).reload();
      case GestureAction.scrollTop:
        await ref.read(tabSessionProvider(tabId: tabId).notifier).scrollToTop();
      case GestureAction.scrollBottom:
        await ref
            .read(tabSessionProvider(tabId: tabId).notifier)
            .scrollToBottom();
      case GestureAction.pageUp:
        await ref.read(tabSessionProvider(tabId: tabId).notifier).pageUp();
      case GestureAction.pageDown:
        await ref.read(tabSessionProvider(tabId: tabId).notifier).pageDown();
      case GestureAction.newTab:
        await _openNewTab(tabId);
      case GestureAction.closeTab:
        await tabRepository.closeTab(tabId);
      case GestureAction.duplicateTab:
        final containerData = await ref
            .read(tabDataRepositoryProvider.notifier)
            .getTabContainerData(tabId);
        await tabRepository.duplicateTab(
          selectTabId: tabId,
          containerData: containerData,
          selectTab: true,
        );
      case GestureAction.nextTab:
        await tabRepository.selectNextTab(tabId);
      case GestureAction.previousTab:
        await tabRepository.selectPreviousTab(tabId);
      case GestureAction.lastUsedTab:
        await tabRepository.selectPreviouslyOpenedTab(tabId);
      case GestureAction.togglePinTab:
        final pinned =
            ref.read(watchPinnedTabIdsProvider).value?.contains(tabId) ?? false;
        await ref
            .read(tabDataRepositoryProvider.notifier)
            .setPinned(tabId, pinned: !pinned);
      case GestureAction.nextContainer:
        await _switchContainer(ContainerCycleDirection.next);
      case GestureAction.previousContainer:
        await _switchContainer(ContainerCycleDirection.previous);
      case GestureAction.toggleReaderMode:
        // One-shot reads from this keep-alive service take no subscription,
        // so nothing auto-disposed is pinned by them.
        final readerActive =
            // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
            ref.read(tabStateProvider(tabId))?.readerableState.active ?? false;
        await ref
            .read(readerableScreenControllerProvider.notifier)
            .toggleReaderView(!readerActive);
      case GestureAction.toggleDesktopMode:
        ref.read(desktopModeProvider(tabId).notifier).toggle();
      case GestureAction.findInPage:
        ref.read(findInPageControllerProvider(tabId).notifier).show();
      case GestureAction.increaseFontSize:
        await _adjustFontSize(increase: true);
      case GestureAction.decreaseFontSize:
        await _adjustFontSize(increase: false);
      case GestureAction.showHome:
        ref.read(forceBrowserHomeProvider.notifier).request();
      case GestureAction.toggleTabBar:
        final controller = ref.read(
          toolbarVisibilityControllerProvider(tabId).notifier,
        );
        // Dismissing is the only state the user cannot leave by scrolling, so
        // the same gesture has to bring the bar back.
        if (ref.read(toolbarVisibilityControllerProvider(tabId)) ==
            ToolbarVisibility.dismissed) {
          controller.forceShow();
        } else {
          controller.dismiss();
        }
      case GestureAction.showHistory:
        await _pushLocation(const HistoryRoute().location);
      case GestureAction.showBookmarks:
        await _pushLocation(
          BookmarkListRoute(entryGuid: BookmarkRoot.root.id).location,
        );
      case GestureAction.showContainers:
        await _pushLocation(const ContainerListRoute().location);
      case GestureAction.toggleBookmark:
        await _toggleBookmark(tabId);
      case GestureAction.translatePage:
        final context = await _navigatorContext();
        if (context != null && context.mounted) {
          await showTranslationBottomSheet(context, selectedTabId: tabId);
        }
      case GestureAction.moveToBackground:
        await moveToBackground();
      case GestureAction.quitBrowser:
        final context = await _navigatorContext();
        if (context != null && context.mounted) {
          final confirmed = await showQuitBrowserDialog(context);
          if (confirmed == true && context.mounted) {
            await exitApp(ProviderScope.containerOf(context, listen: false));
          }
        }
    }
  }

  /// Moves the selection one container along the chip order, wrapping at the
  /// ends, and resumes that container's most recently used tab.
  ///
  /// Resuming a tab is what makes this useful from web content: leaving the
  /// selected tab behind in another container would only ever land on the home
  /// screen (see [shouldShowBrowserHome]), which is still what happens when the
  /// target container has no tabs left.
  ///
  /// Unlike the tray's two-finger swipe this cannot offer to start the
  /// container's proxy — a stroke gesture has no context to host the dialog —
  /// so it relies on [SelectedContainer.setContainerId] refusing a container
  /// whose routing is not ready, like the quick tab switcher does.
  Future<void> _switchContainer(ContainerCycleDirection direction) async {
    // Containers are hidden entirely when their UI is off, and stepping through
    // them would move browsing state the user cannot see.
    if (!ref.read(generalSettingsWithDefaultsProvider).showContainerUi) return;

    // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
    final cycleOrder = ref.read(containerCycleOrderProvider);
    final index = adjacentContainerIndex(
      cycleOrder.map((container) => container?.id).toList(),
      ref.read(selectedContainerProvider),
      direction,
    );
    if (index == null) return;

    final container = cycleOrder[index];
    if (container == null) {
      ref.read(selectedContainerProvider.notifier).clearContainer();
    } else {
      final result = await ref
          .read(selectedContainerProvider.notifier)
          .setContainerId(container.id);
      if (result == SetContainerResult.failed) return;
    }

    if (!ref.mounted) return;

    await ref
        .read(tabRepositoryProvider.notifier)
        .resumeLatestContainerTab(container?.id);
  }

  /// Adds the current page to bookmarks, or removes it if already bookmarked,
  /// mirroring the contextual toolbar's bookmark toggle button.
  Future<void> _toggleBookmark(String tabId) async {
    // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
    final tabState = ref.read(tabStateProvider(tabId));
    if (tabState == null) return;

    final bookmarkUrl =
        // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
        ref.read(sandboxSourceUriForTabProvider(tabId: tabId)) ?? tabState.url;

    final repository = ref.read(bookmarksRepositoryProvider.notifier);
    final existingGuids = await repository.bookmarkGuidsForUrl(bookmarkUrl);
    if (existingGuids.isNotEmpty) {
      for (final guid in existingGuids) {
        await repository.delete(guid);
      }
    } else {
      await repository.addBookmark(
        parentGuid: BookmarkRoot.mobile.id,
        url: bookmarkUrl,
        title: tabState.titleOrAuthority,
      );
    }
  }

  /// Resolves the root navigator's [BuildContext] for actions that open a
  /// dialog/sheet. Null when the navigator is not currently mounted.
  Future<BuildContext?> _navigatorContext() async {
    final router = await ref.read(routerProvider.future);
    if (!ref.mounted) return null;
    return router.routerDelegate.navigatorKey.currentContext;
  }

  Future<void> _pushLocation(String location) async {
    final router = await ref.read(routerProvider.future);
    if (!ref.mounted) return;
    await router.push(location);
  }

  Future<void> _adjustFontSize({required bool increase}) async {
    final settings = ref.read(engineSettingsWithDefaultsProvider);

    // Manual adjustment is a no-op while automatic font sizing is enabled.
    if (settings.automaticFontSizeAdjustment) return;

    final current = settings.fontSizeFactor;
    final newValue = increase
        ? (current + fontSizeStep).clamp(fontSizeMin, fontSizeMax)
        : (current - fontSizeStep).clamp(fontSizeMin, fontSizeMax);
    final rounded = (newValue * 10).round() / 10;
    if (rounded == current) return;

    await ref
        .read(saveEngineSettingsControllerProvider.notifier)
        .save(
          (currentSettings) => currentSettings.copyWith.fontSizeFactor(rounded),
        );
  }

  Future<void> _openNewTab(String tabId) async {
    final router = await ref.read(routerProvider.future);
    if (!ref.mounted) return;

    final settings = ref.read(generalSettingsWithDefaultsProvider);
    final selectedTabType = ref
        .read(tabStatesProvider)[tabId]
        ?.tabMode
        .toTabType();

    final route = SearchRoute(
      tabType: selectedTabType ?? settings.effectiveDefaultCreateTabType,
    );
    await router.push(route.location);
  }
}

/// Whether gestures are currently disabled because the selected tab's site is
/// on the user's exclusion list.
@Riverpod(keepAlive: true)
bool gestureSiteExcluded(Ref ref) {
  final excludedSites = ref.watch(
    gestureSettingsWithDefaultsProvider.select((s) => s.excludedSites),
  );
  if (excludedSites.isEmpty) return false;

  final tabId = ref.watch(selectedTabProvider);
  if (tabId == null) return false;

  // Kept alive on purpose: the native recognizer config has to follow the
  // selected tab's site even with no gesture UI on screen, and the tab-state
  // selector it holds open is a cheap projection of the keep-alive state map.
  // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
  final url = ref.watch(tabStateProvider(tabId).select((state) => state?.url));
  if (url == null) return false;

  return hostMatchesRule(url, excludedSites);
}

/// The effective native recognizer configuration: the user's settings with the
/// recognizer disabled while the current site is excluded.
@Riverpod(keepAlive: true)
GestureConfig gestureNativeConfig(Ref ref) {
  final settings = ref.watch(gestureSettingsWithDefaultsProvider);
  final excluded = ref.watch(gestureSiteExcludedProvider);

  // Recognize as many fingers as any bound gesture requires, so multi-finger
  // bindings work without a separate finger setting.
  final requiredFingers = settings.bindings.keys
      .map((key) => GestureStroke.fromKey(key).fingers)
      .fold(settings.maxFingers, max);

  return GestureConfig(
    enabled: settings.effectiveEnabled && !excluded,
    strokeSize: settings.strokeSize,
    timeoutMs: settings.timeoutMs,
    maxFingers: requiredFingers,
    minStrokeIntervalMs: settings.minStrokeIntervalMs,
    activeGestureKeys: settings.bindings.keys.toList(),
  );
}

/// The in-progress stroke shown by the live feedback overlay.
///
/// Emits the current partial canonical key (e.g. `R:D`) while a stroke is being
/// drawn, and null when nothing should be shown — driven by the native gesture
/// progress/reset events.
@riverpod
Stream<String?> gestureProgress(Ref ref) {
  return ref.watch(gestureServiceProvider).gestureProgress;
}
