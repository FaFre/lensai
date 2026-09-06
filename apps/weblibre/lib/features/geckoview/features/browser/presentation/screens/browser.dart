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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/extensions/media_query.dart';
import 'package:weblibre/features/app_links/presentation/widgets/app_link_prompt_host.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/keep_tab_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/browser_viewport_toolbar_insets.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/addon_popup_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_system_bars.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/draggable_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/view_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_grid_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_list_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_gestures.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tree_view.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_autofocus.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_mode_controller.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_browser_overlay.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';
import 'package:weblibre/utils/move_to_background.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class _AnimatedToolbar extends HookWidget {
  final bool visible;
  final TabBarPosition position;
  final Widget child;

  static const _kAnimationDuration = Duration(milliseconds: 250);

  const _AnimatedToolbar({
    required this.visible,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final controller = useAnimationController(
      duration: disableAnimations ? Duration.zero : _kAnimationDuration,
      initialValue: visible ? 1.0 : 0.0,
    );

    useEffect(() {
      if (visible) {
        unawaited(controller.forward());
      } else {
        unawaited(controller.reverse());
      }
      return null;
    }, [visible]);

    final slideAnimation = useMemoized(() {
      final begin = switch (position) {
        TabBarPosition.top => const Offset(0, -1),
        TabBarPosition.bottom => const Offset(0, 1),
        TabBarPosition.left => const Offset(-1, 0),
        TabBarPosition.right => const Offset(1, 0),
      };

      return Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutQuart),
      );
    }, [position]);

    // RepaintBoundary so the (heavy) toolbar content is rasterized once and
    // merely re-composited at a new offset for each frame of the slide, instead
    // of repainting the whole chip row + favicons + menus every animation tick.
    return SlideTransition(
      position: slideAnimation,
      child: RepaintBoundary(child: child),
    );
  }
}

/// Manages scroll-based auto-hide logic and returns the toolbar widget.
/// Whether the main toolbar row should be dropped for the browser home surface.
///
/// Never dropped under [HomeSearchBarPlacement.tabBar]: there the row's own
/// (empty) address field *is* the home surface's search entry, and the pill is
/// the thing that stands down instead. The two are mutually exclusive by
/// construction rather than by two independent settings, because the home
/// surface has no other way into search — a state where both are off is not
/// one the user should be able to reach.
///
/// Under [HomeSearchBarPlacement.top] the row is still held back when there is
/// no contextual toolbar: the tab count and the navigation menu relocate there
/// when it exists, and the main row is their only other home — dropping it
/// without one would leave no way to reach the menu. That leaves the row's
/// address field showing beside the pill, which is redundant but harmless;
/// blanking only the title would strand the pinned add-ons at the right of an
/// empty strip and still reserve [kToolbarHeight].
///
/// A function rather than an inline condition because it is evaluated in two
/// places — where the bar is built and where its height is measured for the
/// browser viewport inset. If those two disagree the browser is inset for a row
/// that is not drawn. For the same reason the placement is passed in already
/// resolved: [BrowserTabBar.getToolbarHeight] runs from the wrappers'
/// constructors, outside the widget tree, where no provider can be read.
bool _suppressMainToolbarForHome({
  required bool showBrowserHome,
  required bool showContextualToolbar,
  required HomeSearchBarPlacement placement,
}) =>
    showBrowserHome &&
    showContextualToolbar &&
    placement != HomeSearchBarPlacement.tabBar;

/// Animation is handled by the parent _AnimatedToolbar wrapper.
class _TabBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final Stream<Offset>? pointerMoveEvents;
  final TabBarPosition tabBarPosition;
  final bool isSmallWebMode;
  final bool enableGestures;

  const _TabBar({
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.tabBarPosition,
    required this.pointerMoveEvents,
    required this.isSmallWebMode,
    this.enableGestures = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    final displayedSheet = ref.watch(bottomSheetControllerProvider);

    // Auto-hide scroll detection hooks (run unconditionally per hook rules)
    final diffAcc = useRef(0.0);

    // Reset scroll accumulator on tab switch
    useEffect(() {
      diffAcc.value = 0.0;
      return null;
    }, [tabId]);

    // Reset scroll accumulator when controller shows toolbar
    // (covers: loading start, navigation, showToolbarAsExpanded, forceShow)
    ref.listen(toolbarVisibilityControllerProvider(tabId), (previous, next) {
      if (next == ToolbarVisibility.visible && previous != next) {
        diffAcc.value = 0.0;
      }
    });

    void resetHiddenState() {
      ref
          .read(
            toolbarVisibilityControllerProvider(
              ref.read(selectedTabProvider),
            ).notifier,
          )
          .show();
      diffAcc.value = 0.0;
    }

    useOnAppLifecycleStateChange((previous, current) {
      if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) return;
      if (current == AppLifecycleState.resumed) {
        resetHiddenState();
      }
    });

    useOnStreamChange(
      pointerMoveEvents,
      onData: (event) {
        final autoHide = ref
            .read(generalSettingsWithDefaultsProvider)
            .autoHideTabBar;
        if (!autoHide) return;

        final diff = event.dy;
        if (diff < 0) {
          if (diffAcc.value > 0) {
            diffAcc.value = 0.0;
          }
          diffAcc.value += diff;
          if (diffAcc.value.abs() > kToolbarHeight * 1.5) {
            ref
                .read(
                  toolbarVisibilityControllerProvider(
                    ref.read(selectedTabProvider),
                  ).notifier,
                )
                .requestHide();
          }
        } else if (diff > 0) {
          if (diffAcc.value < 0) {
            diffAcc.value = 0.0;
          }
          diffAcc.value += diff;
          if (diffAcc.value.abs() > kToolbarHeight) {
            resetHiddenState();
          }
        }
      },
    );

    final suppressMainToolbar = _suppressMainToolbarForHome(
      showBrowserHome: ref.watch(shouldShowBrowserHomeProvider),
      showContextualToolbar: showContextualToolbar,
      placement: ref.watch(
        generalSettingsWithDefaultsProvider.select(
          (settings) => settings.effectiveHomeSearchBarPlacement(),
        ),
      ),
    );

    // Return the toolbar widget - parent handles animation.
    // Rail positions are rendered by a dedicated Stack layer, not _TabBar, but
    // are handled here for exhaustiveness/correctness.
    return switch (tabBarPosition) {
      TabBarPosition.top => BrowserTopAppBar(
        showMainToolbar: showMainToolbar,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: isSmallWebMode,
        enableGestures: enableGestures,
        suppressMainToolbar: suppressMainToolbar,
      ),
      TabBarPosition.bottom => BrowserBottomAppBar(
        displayedSheet: displayedSheet,
        showMainToolbar: showMainToolbar,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: isSmallWebMode,
        suppressMainToolbar: suppressMainToolbar,
      ),
      TabBarPosition.left || TabBarPosition.right => BrowserSideRail(
        position: tabBarPosition,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: isSmallWebMode,
        suppressMainToolbar: suppressMainToolbar,
      ),
    };
  }
}

/// Which proxy this tab's traffic needs, so a failed load can offer to start
/// it. Null when the tab connects directly, or while routing is unresolved.
///
/// Read off the acknowledged routing snapshot rather than re-derived from
/// settings and container rows. The snapshot already holds the resolved
/// relation for every scope — private, global, per-container, per-isolation
/// group, and the isolation-context aliases — so this asks the same question
/// the extension answered when it blocked the request. Re-deriving it here is
/// how an isolated tab ended up with no prompt at all while the route that was
/// down was its own.
ProxyConnectionId? _proxyConnectionIdForLoadError(
  WidgetRef ref, {
  required String tabId,
  required String? contextId,
}) {
  final snapshot = ref.read(containerRoutingSnapshotProvider);
  if (snapshot == null) return null;

  final tabState = ref.read(tabStateProvider(tabId));
  // The failing load reports the cookie store it ran under; the tab's own is
  // the fallback for events that carry none.
  final loadContextId = (contextId != null && contextId.isNotEmpty)
      ? contextId
      : tabState?.contextId;

  final relation = effectiveRelationFor(
    snapshot,
    tabRoutingContextId(
      contextId: loadContextId,
      isPrivate: tabState?.tabMode is PrivateTabMode,
    ),
  );

  // Empty is an explicit direct connection: there is nothing to start, and the
  // load failed for some other reason.
  return relation.isEmpty ? null : ProxyConnectionId.decode(relation.first);
}

typedef _PendingProxyLoadError = ({
  String? contextId,
  String errorType,
  String? url,
});

class _BrowserScaffoldTheme extends ConsumerWidget {
  final String? selectedTabId;
  final bool isSmallWebActive;
  final bool tabInFullScreen;
  final bool sheetDisplayed;
  final Size bottomAppBarContentSize;
  final bool findInPageVisible;
  final double findInPageHeight;
  final Widget child;

  const _BrowserScaffoldTheme({
    required this.selectedTabId,
    required this.isSmallWebActive,
    required this.tabInFullScreen,
    required this.sheetDisplayed,
    required this.bottomAppBarContentSize,
    required this.findInPageVisible,
    required this.findInPageHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = isSmallWebActive
        ? ToolbarVisibility.visible
        : ref.watch(toolbarVisibilityControllerProvider(selectedTabId));
    final bottomToolbarVisible = isSmallWebActive
        ? !tabInFullScreen
        : sheetDisplayed ||
              (!tabInFullScreen && toolbarState == ToolbarVisibility.visible);
    final bottomInset =
        (bottomToolbarVisible ? bottomAppBarContentSize.height : 0.0) +
        8 +
        (findInPageVisible ? findInPageHeight : 0.0);

    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        bottomSheetTheme: theme.bottomSheetTheme.copyWith(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width -
                math.max(
                  MediaQuery.of(context).padding.left * 2,
                  MediaQuery.of(context).padding.right * 2,
                ),
          ),
        ),
        snackBarTheme: theme.snackBarTheme.copyWith(
          behavior: SnackBarBehavior.floating,
          insetPadding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomInset,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Computes auto-hide toolbar visibility for [selectedTabId] and animates
/// [child] in/out via [_AnimatedToolbar]. Shared by the bottom, top and side
/// rail toolbar layers so the (identical) visibility logic isn't duplicated
/// across ad-hoc `Consumer` closures.
class _ToolbarVisibilityAnimator extends ConsumerWidget {
  final TabBarPosition position;
  final String? selectedTabId;
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final Widget child;

  const _ToolbarVisibilityAnimator({
    required this.position,
    required this.selectedTabId,
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        sheetDisplayed ||
        (!tabInFullScreen && toolbarState == ToolbarVisibility.visible);

    return _AnimatedToolbar(position: position, visible: visible, child: child);
  }
}

/// Layer 0: browser content, positioned around the (possibly auto-hidden)
/// toolbars/rail.
class _BrowserContentPositioned extends ConsumerWidget {
  final OverlayPortalController overlayController;
  final StreamController<Offset> pointerMoveEventsController;
  final String? selectedTabId;
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool autoHideTabBar;
  final bool isRail;
  final bool isSmallWebActive;
  final double sideRailTotalWidth;
  final double topAppBarTotalHeight;
  final double bottomAppBarTotalHeight;

  /// Height of the screen the soft keyboard (and the find-in-page bar above it)
  /// takes from the bottom edge, measured from the window's bottom.
  ///
  /// Applied as a real bottom offset so the engine view — and with it Gecko's
  /// visual viewport — actually shrinks to the visible area. See the note on
  /// `keyboardViewportInset` in [BrowserScreen].
  final double keyboardViewportInset;

  const _BrowserContentPositioned({
    required this.overlayController,
    required this.pointerMoveEventsController,
    required this.selectedTabId,
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.autoHideTabBar,
    required this.isRail,
    required this.isSmallWebActive,
    required this.sideRailTotalWidth,
    required this.topAppBarTotalHeight,
    required this.bottomAppBarTotalHeight,
    required this.keyboardViewportInset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    // Deliberately does NOT include `sheetDisplayed` (unlike the layers that
    // render chrome above the page). A sheet is painted over the browser, so
    // letting it force the toolbar "visible" here would move the Positioned
    // that wraps the platform view — a native re-layout, and under hybrid
    // composition a surface recreation, in the same frame as the sheet's
    // slide-in. The geometry the page sees stays frozen while a sheet is up.
    final toolbarVisible =
        !tabInFullScreen && toolbarState == ToolbarVisibility.visible;

    // When auto-hide is disabled, constrain browser above toolbar
    // (unless toolbar is manually dismissed via swipe gesture).
    // Gated to horizontal positions so the rail (which forces
    // auto-hide off) doesn't reserve a phantom bottom inset.
    //
    // Both this and the keyboard inset are measured from the window's bottom
    // edge, so the browser clears whichever reaches higher — the keyboard is
    // drawn over the toolbar, not stacked on it.
    final bottomOffset = math.max(
      (tabBarPosition.isHorizontal && !autoHideTabBar && toolbarVisible)
          ? bottomAppBarTotalHeight
          : 0.0,
      keyboardViewportInset,
    );

    // For top bar: constrain browser below toolbar when visible
    // to ensure top-of-page content is always accessible
    final topOffset = (tabBarPosition == TabBarPosition.top && toolbarVisible)
        ? topAppBarTotalHeight
        : 0.0;

    // Side rail: inset the browser by the rail width on the docked
    // edge whenever the rail is visible (no auto-hide, so this is
    // a plain content offset — the rail slides out on dismiss).
    final leftOffset = (tabBarPosition == TabBarPosition.left && toolbarVisible)
        ? sideRailTotalWidth
        : 0.0;
    final rightOffset =
        (tabBarPosition == TabBarPosition.right && toolbarVisible)
        ? sideRailTotalWidth
        : 0.0;

    // Only fall back to the system bottom inset when the bottom
    // toolbar was explicitly dismissed. The normal auto-hide
    // hidden state is still handled by GeckoView's dynamic
    // toolbar/clipping logic. On the rail there is never a bottom
    // bar, so the browser always needs the bottom safe inset.
    //
    // `sheetDisplayed` is likewise excluded here: toggling the safe-area
    // padding on sheet open/close would resize the platform view for content
    // the sheet covers anyway.
    final applyBottomSafeArea =
        bottomOffset == 0 &&
        (isRail
            ? (!tabInFullScreen && !isSmallWebActive)
            : (!tabInFullScreen &&
                  !isSmallWebActive &&
                  toolbarState == ToolbarVisibility.dismissed));

    return Positioned(
      left: leftOffset,
      right: rightOffset,
      top: topOffset,
      bottom: bottomOffset,
      child: _Browser(
        overlayController: overlayController,
        tabInFullScreen: tabInFullScreen,
        pointerMoveEventSink: autoHideTabBar
            ? pointerMoveEventsController.sink
            : null,
        sheetDisplayed: sheetDisplayed,
        hasTopBarOffset: topOffset > 0,
        hasLeftBarOffset: leftOffset > 0,
        hasRightBarOffset: rightOffset > 0,
        applyBottomSafeArea: applyBottomSafeArea,
      ),
    );
  }
}

/// Layer 2: bottom toolbar (or the small-web discovery overlay in its place).
class _BottomToolbarLayer extends StatelessWidget {
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final bool isSmallWebActive;
  final TabBarPosition tabBarPosition;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final String? selectedTabId;
  final StreamController<Offset> pointerMoveEventsController;

  const _BottomToolbarLayer({
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.isSmallWebActive,
    required this.tabBarPosition,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.selectedTabId,
    required this.pointerMoveEventsController,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmallWebActive) {
      return _AnimatedToolbar(
        position: TabBarPosition.bottom,
        visible: !tabInFullScreen,
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 3,
          child: const SmallWebBrowserOverlay(),
        ),
      );
    }

    // _TabBar is passed via `child` so it is built once and reused across
    // toolbar show/hide toggles inside _ToolbarVisibilityAnimator.
    return _ToolbarVisibilityAnimator(
      position: TabBarPosition.bottom,
      selectedTabId: selectedTabId,
      sheetDisplayed: sheetDisplayed,
      tabInFullScreen: tabInFullScreen,
      child: _TabBar(
        tabBarPosition: TabBarPosition.bottom,
        showMainToolbar: tabBarPosition == TabBarPosition.bottom,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: false,
        pointerMoveEvents: tabBarPosition == TabBarPosition.bottom
            ? pointerMoveEventsController.stream
            : null,
      ),
    );
  }
}

/// Layer 3: top toolbar (only rendered when the tab bar position is top).
class _TopToolbarLayer extends StatelessWidget {
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final bool isSmallWebActive;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final String? selectedTabId;
  final StreamController<Offset> pointerMoveEventsController;

  const _TopToolbarLayer({
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.isSmallWebActive,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.selectedTabId,
    required this.pointerMoveEventsController,
  });

  @override
  Widget build(BuildContext context) {
    return _ToolbarVisibilityAnimator(
      position: TabBarPosition.top,
      selectedTabId: selectedTabId,
      sheetDisplayed: sheetDisplayed,
      tabInFullScreen: tabInFullScreen,
      child: _TabBar(
        tabBarPosition: TabBarPosition.top,
        showMainToolbar: true,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: isSmallWebActive,
        enableGestures: !isSmallWebActive,
        pointerMoveEvents: isSmallWebActive
            ? null
            : pointerMoveEventsController.stream,
      ),
    );
  }
}

/// Layer 3b: vertical side rail (left/right).
class _SideRailToolbarLayer extends StatelessWidget {
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final String? selectedTabId;

  /// Resolved by the caller, as for the horizontal bars: the rail is built here
  /// rather than by [_TabBar], so without this the home surface would keep the
  /// main toolbar row only in the rail positions.
  final bool suppressMainToolbar;

  const _SideRailToolbarLayer({
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.selectedTabId,
    required this.suppressMainToolbar,
  });

  @override
  Widget build(BuildContext context) {
    return _ToolbarVisibilityAnimator(
      position: tabBarPosition,
      selectedTabId: selectedTabId,
      sheetDisplayed: sheetDisplayed,
      tabInFullScreen: tabInFullScreen,
      child: BrowserSideRail(
        position: tabBarPosition,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: false,
        suppressMainToolbar: suppressMainToolbar,
      ),
    );
  }
}

/// Layer 4: draggable FAB, positioned clear of the toolbar/rail.
class _FabPositioner extends ConsumerWidget {
  final String? selectedTabId;
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final double bottomAppBarTotalHeight;
  final double bottomSafeArea;
  final double sideRailTotalWidth;
  final Widget child;

  const _FabPositioner({
    required this.selectedTabId,
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.bottomAppBarTotalHeight,
    required this.bottomSafeArea,
    required this.sideRailTotalWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        sheetDisplayed ||
        (!tabInFullScreen && toolbarState == ToolbarVisibility.visible);

    return DraggableFab(
      bottomToolbarVisible: visible,
      bottomAppBarHeight: bottomAppBarTotalHeight,
      bottomSafeArea: bottomSafeArea,
      leftReservedWidth: (tabBarPosition == TabBarPosition.left && visible)
          ? sideRailTotalWidth
          : 0.0,
      rightReservedWidth: (tabBarPosition == TabBarPosition.right && visible)
          ? sideRailTotalWidth
          : 0.0,
      child: child,
    );
  }
}

/// Layer 5: page load progress indicator, animated with toolbar visibility.
/// Split into a positioner (reacts to toolbar visibility) and a content
/// widget (reacts to load progress) so the two independent watches don't
/// force each other to rebuild.
class _ProgressIndicatorPositioner extends ConsumerWidget {
  final String? selectedTabId;
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool isRail;
  final double sideRailTotalWidth;
  final double topSafeArea;
  final double topAppBarTotalHeight;
  final double bottomAppBarTotalHeight;
  final Widget child;

  const _ProgressIndicatorPositioner({
    required this.selectedTabId,
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.isRail,
    required this.sideRailTotalWidth,
    required this.topSafeArea,
    required this.topAppBarTotalHeight,
    required this.bottomAppBarTotalHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        sheetDisplayed ||
        (!tabInFullScreen && toolbarState == ToolbarVisibility.visible);

    return AnimatedPositioned(
      duration: disableAnimations
          ? Duration.zero
          : _AnimatedToolbar._kAnimationDuration,
      curve: Curves.easeInOutQuart,
      // Rail insets track the rail's visibility so overlays
      // reclaim the space when it is swiped away.
      left: (tabBarPosition == TabBarPosition.left && visible)
          ? sideRailTotalWidth
          : 0.0,
      right: (tabBarPosition == TabBarPosition.right && visible)
          ? sideRailTotalWidth
          : 0.0,
      // On the rail there is no top/bottom bar; pin the progress
      // line to the top of the content area.
      top: isRail
          ? topSafeArea
          : tabBarPosition == TabBarPosition.top && visible
          ? topAppBarTotalHeight
          : null,
      bottom: isRail
          ? null
          : tabBarPosition == TabBarPosition.bottom && visible
          ? bottomAppBarTotalHeight
          : tabBarPosition == TabBarPosition.bottom
          ? 0
          : null,
      child: child,
    );
  }
}

class _ProgressIndicatorBar extends ConsumerWidget {
  const _ProgressIndicatorBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    final isLoading = ref.watch(
      tabStateProvider(tabId).select((state) => state?.isLoading == true),
    );

    //When not loading we assumed finished
    final value = isLoading ? ref.watch(tabProgressProvider(tabId)) : 100;

    return Visibility(
      visible: value < 100,
      child: LinearProgressIndicator(value: value / 100),
    );
  }
}

/// Layer 6: find-in-page widget, positioned above the toolbar/keyboard.
/// Same positioner/content split rationale as the progress indicator above.
class _FindInPagePositioner extends ConsumerWidget {
  final String? selectedTabId;
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool isRail;
  final double sideRailTotalWidth;
  final double bottomSafeArea;
  final double bottomAppBarTotalHeight;
  final Widget child;

  const _FindInPagePositioner({
    required this.selectedTabId,
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.isRail,
    required this.sideRailTotalWidth,
    required this.bottomSafeArea,
    required this.bottomAppBarTotalHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        sheetDisplayed ||
        (!tabInFullScreen && toolbarState == ToolbarVisibility.visible);

    return AnimatedPositioned(
      duration: disableAnimations
          ? Duration.zero
          : _AnimatedToolbar._kAnimationDuration,
      curve: Curves.easeInOutQuart,
      left: (tabBarPosition == TabBarPosition.left && visible)
          ? sideRailTotalWidth
          : 0.0,
      right: (tabBarPosition == TabBarPosition.right && visible)
          ? sideRailTotalWidth
          : 0.0,
      bottom: math.max(
        isRail
            ? bottomSafeArea
            : (visible ? bottomAppBarTotalHeight : bottomSafeArea),
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: child,
    );
  }
}

class _FindInPageContent extends ConsumerWidget {
  const _FindInPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = ref.watch(selectedTabProvider);
    if (tabId == null) {
      return const SizedBox.shrink();
    }
    return FindInPageWidget(key: ValueKey(tabId), tabId: tabId);
  }
}

/// Layer 7: app-link prompt banner (§2.6). Anchored above the bottom app
/// bar / keyboard exactly like find-in-page, so it is never hidden behind
/// the toolbar. Custom Tab sessions are prompted natively instead; this is
/// the browser-tab surface only.
class _AppLinkPromptLayer extends ConsumerWidget {
  final String? selectedTabId;
  final bool sheetDisplayed;
  final bool tabInFullScreen;
  final TabBarPosition tabBarPosition;
  final bool isRail;
  final double sideRailTotalWidth;
  final double bottomSafeArea;
  final double bottomAppBarTotalHeight;

  const _AppLinkPromptLayer({
    required this.selectedTabId,
    required this.sheetDisplayed,
    required this.tabInFullScreen,
    required this.tabBarPosition,
    required this.isRail,
    required this.sideRailTotalWidth,
    required this.bottomSafeArea,
    required this.bottomAppBarTotalHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );
    final visible =
        sheetDisplayed ||
        (!tabInFullScreen && toolbarState == ToolbarVisibility.visible);

    return Positioned(
      left: (tabBarPosition == TabBarPosition.left && visible)
          ? sideRailTotalWidth
          : 0.0,
      right: (tabBarPosition == TabBarPosition.right && visible)
          ? sideRailTotalWidth
          : 0.0,
      bottom: math.max(
        isRail
            ? bottomSafeArea
            : (visible ? bottomAppBarTotalHeight : bottomSafeArea),
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: const AppLinkPromptHost(),
    );
  }
}

class BrowserScreen extends HookConsumerWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventService = ref.watch(eventServiceProvider);
    final viewportService = ref.watch(viewportServiceProvider);
    final activeProxyPromptKeys = useRef(<String>{});
    final pendingProxyLoadErrors = useRef(<String, _PendingProxyLoadError>{});
    final selectedTabIdForProxyPrompt = ref.watch(selectedTabProvider);

    Future<void> handleProxyLoadError({
      required String tabId,
      required String? contextId,
      required String? url,
      required String errorType,
    }) async {
      final promptKey = '$tabId:${url ?? errorType}';
      if (!activeProxyPromptKeys.value.add(promptKey)) return;

      // Set once this tab starts a load of its own while the waits below run.
      // The unattended reload is only ever meant to get a tab past the load
      // that failed in the routing-install window; a tab that has started
      // loading again since — because the user retried, or because the engine
      // did — is no longer sitting on that failure, and reloading it would
      // throw away the page and the scroll position they now have.
      var tabReloadedMeanwhile = false;
      final tabLoadSubscription = ref.listenManual(
        tabStateProvider(tabId).select((state) => state?.isLoading ?? false),
        (previous, isLoading) {
          if (isLoading) tabReloadedMeanwhile = true;
        },
      );

      try {
        Future<void> reloadTab() async {
          if (!context.mounted || ref.read(selectedTabProvider) != tabId) {
            return;
          }
          await ref.read(tabSessionProvider(tabId: tabId).notifier).reload();
        }

        // The extension blocks *every* request until routing is installed, so a
        // load that lands in that window fails this way whether or not the tab
        // routes through a proxy at all — which is what a cold start, and the
        // first navigation of one, most often is. Wait the install out and
        // reload, instead of leaving a page the user has to retry by hand.
        final containerProxy = ref.read(
          containerProxyRepositoryProvider.notifier,
        );
        final routingWasPending = !await containerProxy.isRoutingReady();
        // Every read past this point goes through `ref`, which throws once the
        // screen is gone — and the throw is swallowed by the catch below, so
        // the recovery would be lost silently rather than loudly.
        if (!context.mounted) return;

        if (routingWasPending) {
          final routingReady = await containerProxy.waitUntilRoutingReady();
          // Routing that never arrives is a broken browser, not a proxy that
          // needs starting: there is no snapshot to say what this tab needs, so
          // the error page stands and the repair loop keeps retrying behind it.
          if (!routingReady || !context.mounted) return;
        }

        final proxyConnectionId = _proxyConnectionIdForLoadError(
          ref,
          tabId: tabId,
          contextId: contextId,
        );

        if (proxyConnectionId == null) {
          // Nothing to start — this context connects directly, so the block was
          // the install window itself and it is over.
          if (routingWasPending && !tabReloadedMeanwhile) await reloadTab();
          return;
        }

        // Starting a proxy asks the user about *a tab*, and the wait above can
        // run for seconds. If they have moved on since, hand the error back to
        // the queue that defers it until this tab is on screen again — the same
        // route an error for an unselected tab takes in the first place —
        // instead of prompting over whatever they are looking at now.
        if (ref.read(selectedTabProvider) != tabId) {
          pendingProxyLoadErrors.value[tabId] = (
            contextId: contextId,
            errorType: errorType,
            url: url,
          );
          return;
        }

        final isProxyStarted = await ensureProxyStartedForConnection(
          context,
          ref,
          proxyConnectionId,
        );

        if (isProxyStarted) {
          await reloadTab();
        }
      } catch (error, stackTrace) {
        logger.e(
          'Failed to handle proxy load error',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        tabLoadSubscription.close();
        activeProxyPromptKeys.value.remove(promptKey);
      }
    }

    useEffect(() {
      final tabId = selectedTabIdForProxyPrompt;
      if (tabId == null) return null;

      final pending = pendingProxyLoadErrors.value.remove(tabId);
      if (pending == null) return null;

      unawaited(
        handleProxyLoadError(
          tabId: tabId,
          contextId: pending.contextId,
          url: pending.url,
          errorType: pending.errorType,
        ),
      );
      return null;
    }, [selectedTabIdForProxyPrompt]);

    useOnStreamChange(
      eventService.proxyLoadErrorEvents,
      onData: (event) async {
        final selectedTabId = ref.read(selectedTabProvider);
        final tabId = event.tabId ?? selectedTabId;
        if (tabId == null) return;

        if (tabId != selectedTabId) {
          pendingProxyLoadErrors.value[tabId] = (
            contextId: event.contextId,
            errorType: event.errorType,
            url: event.url,
          );
          return;
        }

        await handleProxyLoadError(
          tabId: tabId,
          contextId: event.contextId,
          url: event.url,
          errorType: event.errorType,
        );
      },
    );

    final tabInFullScreen = ref.watch(
      selectedTabStateProvider.select((value) => value?.isFullScreen ?? false),
    );
    final tabIsLoading = ref.watch(
      selectedTabStateProvider.select((value) => value?.isLoading ?? false),
    );

    final overlayController = useOverlayPortalController();

    final isSmallWebActive = ref.watch(
      smallWebModeControllerProvider.select((value) => value != null),
    );

    final tabBarPosition = isSmallWebActive
        ? TabBarPosition.top
        : ref.watch(
            generalSettingsWithDefaultsProvider.select(
              (value) => value.tabBarPosition,
            ),
          );

    final showContextualToolbar =
        !isSmallWebActive &&
        ref.watch(
          generalSettingsWithDefaultsProvider.select(
            (value) => value.tabBarShowContextualBar,
          ),
        );

    final quickTabSwitcherRowCount = isSmallWebActive
        ? 0
        : ref.watch(quickTabSwitcherRowCountProvider).value ?? 0;

    // Vertical side rail (left/right). Auto-hide is not supported on the rail;
    // it is reserved via a plain content offset and dismissed only by gesture.
    final isRail = tabBarPosition.isVertical;

    final autoHideTabBar =
        !isSmallWebActive &&
        tabBarPosition.isHorizontal &&
        ref.watch(
          generalSettingsWithDefaultsProvider.select(
            (value) => value.autoHideTabBar,
          ),
        );

    ref.listen(overlayControllerProvider, (previous, next) {
      if (next != null) {
        overlayController.show();
      } else {
        overlayController.hide();
      }
    });

    useOnStreamChange(
      eventService.longPressEvent,
      onData: (event) async {
        await ContextMenuRoute(
          hitResult: event.hitResult.toJson(),
        ).push(context);
      },
    );

    final addonService = ref.watch(addonServiceProvider);
    useOnStreamChange(
      addonService.popupStream,
      onData: (event) async {
        await showAddonPopupBottomSheet(
          context,
          extensionId: event.extensionId,
          extensionName: event.extensionName,
        );
      },
    );
    useOnStreamChange(
      addonService.openAddonSettingsStream,
      onData: (addonId) async {
        await AddonInternalSettingsRoute(addonId: addonId).push<void>(context);
      },
    );

    useOnAppLifecycleStateChange((previous, current) {
      switch (current) {
        case AppLifecycleState.resumed:
          if (current != AppLifecycleState.resumed) {
            return;
          }

          if (!ref.read(syncIsAuthenticatedProvider)) {
            return;
          }

          unawaited(() async {
            try {
              final openedTabs = await ref
                  .read(syncRepositoryProvider.notifier)
                  .pollIncomingTabsAndOpen();

              if (openedTabs > 0 && context.mounted) {
                ui_helper.showOpenedTabsFromAnotherDeviceMessage(
                  context,
                  openedTabs,
                );
              }
            } catch (e, s) {
              logger.e(
                'Failed polling incoming sync tabs on resume',
                error: e,
                stackTrace: s,
              );
            }
          }());
        case AppLifecycleState.detached:
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
      }
    });

    final pointerMoveEventsController = useStreamController<Offset>();

    // Watch sheet state for rendering in Stack
    final displayedSheet = ref.watch(bottomSheetControllerProvider);
    final sheetDisplayed = displayedSheet != null;

    // Track selected tab. Toolbar visibility is watched in scoped Consumer
    // widgets below to avoid rebuilding the entire BrowserScreen on every
    // hide/show cycle during scrolling.
    final selectedTabId = ref.watch(selectedTabProvider);

    // Calculate relative safe area for sheet max size
    final relativeSafeArea = MediaQuery.of(context).relativeSafeArea();
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // Must match what _TabBar resolves, or the browser is inset for a toolbar
    // row that is not drawn.
    final suppressMainToolbarForHome = _suppressMainToolbarForHome(
      showBrowserHome: ref.watch(shouldShowBrowserHomeProvider),
      showContextualToolbar: showContextualToolbar,
      placement: ref.watch(
        generalSettingsWithDefaultsProvider.select(
          (settings) => settings.effectiveHomeSearchBarPlacement(),
        ),
      ),
    );

    // Calculate bottom toolbar size for FAB and sheet positioning
    final Size bottomAppBarContentSize;
    // The same size computed as if no sheet were displayed. `ViewTabsSheet`
    // hides the main toolbar and the quick tab switcher, which shrinks the bar
    // by 48-152px — and that value feeds the browser's viewport geometry
    // (dynamic toolbar inset, vertical clipping and the Positioned that wraps
    // the platform view). Resizing the Gecko viewport when a sheet opens costs
    // a page reflow plus, under hybrid composition, a native surface
    // recreation — all in the same frame as the sheet's slide-in animation.
    // The sheet is drawn *on top* of the page, so the page's viewport has no
    // reason to change: the inset math below uses this frozen value while the
    // widgets that actually render the bar keep the real one.
    final Size viewportBottomAppBarContentSize;
    if (isSmallWebActive) {
      bottomAppBarContentSize = const Size.fromHeight(
        SmallWebBrowserOverlay.barHeight,
      );
      viewportBottomAppBarContentSize = bottomAppBarContentSize;
    } else if (isRail) {
      // The rail occupies a side, not the bottom; no bottom bar is rendered.
      bottomAppBarContentSize = Size.zero;
      viewportBottomAppBarContentSize = bottomAppBarContentSize;
    } else {
      // Pass actual displayedSheet to get correct height when ViewTabsSheet hides main toolbar
      bottomAppBarContentSize = BrowserBottomAppBar(
        showMainToolbar: tabBarPosition == TabBarPosition.bottom,
        showContextualToolbar: showContextualToolbar,
        quickTabSwitcherRowCount: quickTabSwitcherRowCount,
        isSmallWebMode: false,
        displayedSheet: displayedSheet,
        suppressMainToolbar: suppressMainToolbarForHome,
      ).preferredSize;
      viewportBottomAppBarContentSize = displayedSheet == null
          ? bottomAppBarContentSize
          : BrowserBottomAppBar(
              showMainToolbar: tabBarPosition == TabBarPosition.bottom,
              showContextualToolbar: showContextualToolbar,
              quickTabSwitcherRowCount: quickTabSwitcherRowCount,
              isSmallWebMode: false,
              displayedSheet: null,
              suppressMainToolbar: suppressMainToolbarForHome,
            ).preferredSize;
    }
    // Total height includes safe area padding
    final bottomAppBarTotalHeight =
        bottomAppBarContentSize.height + bottomSafeArea;
    final viewportBottomAppBarTotalHeight =
        viewportBottomAppBarContentSize.height + bottomSafeArea;

    // Side rail width reservation (vertical positions only): the fixed content
    // width plus the system safe-area inset on the rail's outer edge.
    final horizontalSafeArea = switch (tabBarPosition) {
      TabBarPosition.left => MediaQuery.of(context).padding.left,
      TabBarPosition.right => MediaQuery.of(context).padding.right,
      _ => 0.0,
    };
    final sideRailTotalWidth = isRail
        ? BrowserTabBar.sideRailWidth + horizontalSafeArea
        : 0.0;
    // Horizontal insets used to keep overlays (progress, find-in-page) clear of
    // the rail on its docked edge.
    final railLeftInset = tabBarPosition == TabBarPosition.left
        ? sideRailTotalWidth
        : 0.0;
    final railRightInset = tabBarPosition == TabBarPosition.right
        ? sideRailTotalWidth
        : 0.0;

    // Calculate top toolbar size for browser offset and progress indicator
    final topSafeArea = MediaQuery.of(context).padding.top;
    final topAppBarContentSize = BrowserTopAppBar(
      showMainToolbar: tabBarPosition == TabBarPosition.top,
      showContextualToolbar: showContextualToolbar,
      quickTabSwitcherRowCount: quickTabSwitcherRowCount,
      isSmallWebMode: isSmallWebActive,
      enableGestures: !isSmallWebActive,
      suppressMainToolbar: suppressMainToolbarForHome,
    ).preferredSize;
    final topAppBarTotalHeight = topAppBarContentSize.height + topSafeArea;

    // Get pixel ratio for converting logical pixels to physical pixels
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final bottomSystemInsetPx =
        (MediaQuery.viewPaddingOf(context).bottom * pixelRatio).round();

    // Watch find-in-page visibility for the selected tab
    final findInPageVisible =
        selectedTabId != null &&
        ref.watch(
          findInPageControllerProvider(
            selectedTabId,
          ).select((state) => state.visible),
        );

    // Find in page widget height from the widget constant
    final findInPageHeight = findInPageVisible
        ? FindInPageWidget.findInPageHeight
        : 0.0;

    // Track dismissed state without triggering full rebuild on every
    // hide/show. Updated via ref.listen below and synced on tab switch.
    final toolbarDismissed = useKeyedState(
      ref.read(toolbarVisibilityControllerProvider(selectedTabId)) ==
          ToolbarVisibility.dismissed,
      [selectedTabId],
    );

    final autoHideToolbarHeight = switch (tabBarPosition) {
      // Gecko's dynamic toolbar value is consumed as a bottom inset by Dart and
      // native UI. The top toolbar itself is positioned with Flutter's topOffset.
      TabBarPosition.top ||
      TabBarPosition.bottom => viewportBottomAppBarTotalHeight,
      TabBarPosition.left || TabBarPosition.right => 0.0,
    };

    final stableToolbarHeight =
        autoHideTabBar && !toolbarDismissed.value && !tabInFullScreen
        ? autoHideToolbarHeight
        : 0.0;
    final stableToolbarHeightPx = (stableToolbarHeight * pixelRatio).round();

    final keyboardHeightPx = useState<int?>(null);

    useOnStreamChange(
      viewportService.keyboardEvents,
      onData: (event) {
        if (!event.isAnimating) {
          final nextKeyboardHeightPx = event.isVisible
              ? event.heightPx + bottomSystemInsetPx
              : null;
          if (keyboardHeightPx.value != nextKeyboardHeightPx) {
            keyboardHeightPx.value = nextKeyboardHeightPx;
          }
        }
      },
    );

    final keyboardVisible = keyboardHeightPx.value != null;

    // How far up from the window's bottom edge the browser has to stop while
    // the soft keyboard is up (plus the find-in-page bar, which is drawn over
    // the page just above it).
    //
    // This is a real inset on the platform view, not a dynamic-toolbar height.
    // Gecko sizes the visual viewport from the view it is given and treats a
    // dynamic toolbar as chrome that scrolls away, so describing the keyboard
    // as one leaves the last `keyboardHeight` pixels of every document
    // unreachable — and leaves Gecko believing a focused input behind the
    // keyboard is already on screen, so it never scrolls it into view. Shrink
    // the view instead, which is what a plain `adjustResize` window would do
    // and what GeckoView's own keyboard handling (`onKeyboardHeight`, fed from
    // the window insets) expects. See
    // https://github.com/FaFre/WebLibre/issues/502.
    //
    // A sheet is excluded: it covers the page, so a keyboard opened for a field
    // *in the sheet* has nothing to make room for, and resizing the platform
    // view under it would cost a reflow and a native surface recreation in the
    // same frame as the sheet's animation.
    final keyboardApplies = keyboardVisible && !sheetDisplayed;
    final keyboardViewportInset = keyboardApplies
        ? (keyboardHeightPx.value! / pixelRatio) + findInPageHeight
        : 0.0;

    // While the keyboard is up the bottom bar sits behind it, not over the
    // page, so there is no dynamic toolbar overlapping the (now shorter) view.
    final effectiveToolbarHeightPx = keyboardApplies
        ? 0
        : stableToolbarHeightPx;

    final lastToolbarMaxHeightPx = useRef<int?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(browserViewportToolbarInsetsControllerProvider.notifier)
            .reset();
      });

      return null;
    }, []);

    useEffect(() {
      if (lastToolbarMaxHeightPx.value != effectiveToolbarHeightPx) {
        lastToolbarMaxHeightPx.value = effectiveToolbarHeightPx;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(browserViewportToolbarInsetsControllerProvider.notifier)
              .setDynamicToolbarMaxHeight(effectiveToolbarHeightPx);
        });

        unawaited(
          viewportService.setDynamicToolbarMaxHeight(effectiveToolbarHeightPx),
        );
      }
      return null;
    }, [effectiveToolbarHeightPx]);

    // Track last clipping value to avoid redundant platform channel calls.
    // Clipping is set once when visibility changes (before animation starts),
    // rather than on every animation frame, to avoid platform channel spam.
    final lastClippingPx = useRef(0);

    void updateClipping() {
      final toolbarState = ref.read(
        toolbarVisibilityControllerProvider(selectedTabId),
      );
      final effectiveVisible = toolbarState == ToolbarVisibility.visible;
      final dismissed = toolbarState == ToolbarVisibility.dismissed;

      // Dynamic toolbar clipping is bottom-inset-only; top toolbar layout is
      // handled by Flutter's topOffset instead of Gecko's bottom inset channel.
      // When visible/dismissed or overridden by keyboard/loading: no clipping.
      final hiddenToolbarClippingPx = switch (tabBarPosition) {
        TabBarPosition.top || TabBarPosition.bottom =>
          -(viewportBottomAppBarTotalHeight * pixelRatio).round(),
        TabBarPosition.left || TabBarPosition.right => 0,
      };
      final targetClippingPx =
          autoHideTabBar &&
              !dismissed &&
              !effectiveVisible &&
              !keyboardVisible &&
              !tabIsLoading &&
              !tabInFullScreen
          ? hiddenToolbarClippingPx
          : 0;

      if (targetClippingPx != lastClippingPx.value) {
        lastClippingPx.value = targetClippingPx;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(browserViewportToolbarInsetsControllerProvider.notifier)
              .setVerticalClipping(targetClippingPx);
        });

        unawaited(viewportService.setVerticalClipping(targetClippingPx));
      }
    }

    // Update clipping when toolbar visibility changes (does NOT trigger
    // full rebuild). Also tracks dismissed state via useState so that
    // stableToolbarHeight / effectiveToolbarHeightPx stay correct.
    ref.listen(toolbarVisibilityControllerProvider(selectedTabId), (
      previous,
      next,
    ) {
      updateClipping();

      // Update dismissed state — triggers a targeted rebuild only when
      // the dismissed flag actually changes (not on every hide/show).
      final isDismissed = next == ToolbarVisibility.dismissed;
      if (toolbarDismissed.value != isDismissed) {
        toolbarDismissed.value = isDismissed;
      }
    });

    // Update clipping when other relevant state changes
    useEffect(
      () {
        updateClipping();
        return null;
      },
      [
        autoHideTabBar,
        keyboardVisible,
        tabIsLoading,
        tabInFullScreen,
        viewportBottomAppBarTotalHeight,
        pixelRatio,
        selectedTabId,
        tabBarPosition,
      ],
    );

    return PopScope(
      //We need this for BackButtonListener to work downstream
      //No direct pop result will be handled here
      canPop: false,
      child: _BrowserScaffoldTheme(
        selectedTabId: selectedTabId,
        isSmallWebActive: isSmallWebActive,
        tabInFullScreen: tabInFullScreen,
        sheetDisplayed: sheetDisplayed,
        bottomAppBarContentSize: bottomAppBarContentSize,
        findInPageVisible: findInPageVisible,
        findInPageHeight: findInPageHeight,
        child: Scaffold(
          // Minimal scaffold - only for Material overlay support (SnackBars)
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Layer 0: Browser content
              // Position changes instantly (no animation) to avoid jarring native view resize
              // The toolbar itself animates, providing visual continuity
              _BrowserContentPositioned(
                overlayController: overlayController,
                pointerMoveEventsController: pointerMoveEventsController,
                selectedTabId: selectedTabId,
                sheetDisplayed: sheetDisplayed,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                autoHideTabBar: autoHideTabBar,
                isRail: isRail,
                isSmallWebActive: isSmallWebActive,
                sideRailTotalWidth: sideRailTotalWidth,
                topAppBarTotalHeight: topAppBarTotalHeight,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                keyboardViewportInset: keyboardViewportInset,
              ),

              // Layer 0.5: System bar tint — fills the status-bar/nav-bar
              // inset regions with the active container color (or the tab bar
              // surface fallback) and drives the system bar icon brightness.
              // Sits above the browser content but below the toolbars, so the
              // tab bar's transparent safe-area padding reveals the bottom
              // strip and the top toolbar's SafeArea reveals the top strip.
              if (!tabInFullScreen)
                Positioned.fill(
                  child: BrowserSystemBars(
                    topInset: topSafeArea,
                    bottomInset: bottomSafeArea,
                  ),
                ),

              // Layer 1: Sheet (when displayed) - positioned above toolbar,
              // inset past the rail on its docked edge.
              if (sheetDisplayed)
                Positioned(
                  left: railLeftInset,
                  right: railRightInset,
                  top: 0,
                  bottom: bottomAppBarTotalHeight,
                  child: _SheetContainer(
                    displayedSheet: displayedSheet,
                    relativeSafeArea: relativeSafeArea,
                    bottomAppBarHeight: bottomAppBarTotalHeight,
                  ),
                ),

              // Layer 2: Bottom Toolbar (overlay, slides in/out)
              // In small web mode, show the discovery overlay instead.
              // Skipped entirely for the side rail (Layer 3b below).
              if (!isRail)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomToolbarLayer(
                    sheetDisplayed: sheetDisplayed,
                    tabInFullScreen: tabInFullScreen,
                    isSmallWebActive: isSmallWebActive,
                    tabBarPosition: tabBarPosition,
                    showContextualToolbar: showContextualToolbar,
                    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
                    selectedTabId: selectedTabId,
                    pointerMoveEventsController: pointerMoveEventsController,
                  ),
                ),

              // Layer 3: Top Toolbar (overlay, slides in/out) - only when position is top
              if (tabBarPosition == TabBarPosition.top)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _TopToolbarLayer(
                    sheetDisplayed: sheetDisplayed,
                    tabInFullScreen: tabInFullScreen,
                    isSmallWebActive: isSmallWebActive,
                    showContextualToolbar: showContextualToolbar,
                    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
                    selectedTabId: selectedTabId,
                    pointerMoveEventsController: pointerMoveEventsController,
                  ),
                ),

              // Layer 3b: Side rail (vertical, left/right). No auto-hide; it
              // slides horizontally out of view only on manual dismiss.
              if (isRail)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: tabBarPosition == TabBarPosition.left ? 0 : null,
                  right: tabBarPosition == TabBarPosition.right ? 0 : null,
                  child: _SideRailToolbarLayer(
                    sheetDisplayed: sheetDisplayed,
                    tabInFullScreen: tabInFullScreen,
                    tabBarPosition: tabBarPosition,
                    showContextualToolbar: showContextualToolbar,
                    quickTabSwitcherRowCount: quickTabSwitcherRowCount,
                    selectedTabId: selectedTabId,
                    suppressMainToolbar: suppressMainToolbarForHome,
                  ),
                ),

              // Layer 4: FAB (draggable via long press)
              _FabPositioner(
                selectedTabId: selectedTabId,
                sheetDisplayed: sheetDisplayed,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                bottomSafeArea: bottomSafeArea,
                sideRailTotalWidth: sideRailTotalWidth,
                child: const BrowserFab(),
              ),

              // Layer 5: Page load progress indicator (animates with toolbar visibility)
              _ProgressIndicatorPositioner(
                selectedTabId: selectedTabId,
                sheetDisplayed: sheetDisplayed,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                isRail: isRail,
                sideRailTotalWidth: sideRailTotalWidth,
                topSafeArea: topSafeArea,
                topAppBarTotalHeight: topAppBarTotalHeight,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                child: const _ProgressIndicatorBar(),
              ),

              // Layer 6: Find in Page widget (above toolbar or keyboard, whichever is higher)
              _FindInPagePositioner(
                selectedTabId: selectedTabId,
                sheetDisplayed: sheetDisplayed,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                isRail: isRail,
                sideRailTotalWidth: sideRailTotalWidth,
                bottomSafeArea: bottomSafeArea,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
                child: const _FindInPageContent(),
              ),

              // Layer 7: App-link prompt banner (§2.6). Anchored above the bottom app
              // bar / keyboard exactly like find-in-page, so it is never hidden behind
              // the toolbar. Custom Tab sessions are prompted natively instead; this is
              // the browser-tab surface only.
              _AppLinkPromptLayer(
                selectedTabId: selectedTabId,
                sheetDisplayed: sheetDisplayed,
                tabInFullScreen: tabInFullScreen,
                tabBarPosition: tabBarPosition,
                isRail: isRail,
                sideRailTotalWidth: sideRailTotalWidth,
                bottomSafeArea: bottomSafeArea,
                bottomAppBarTotalHeight: bottomAppBarTotalHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Container widget for bottom sheets - renders in Stack for proper layering.
class _SheetContainer extends HookConsumerWidget {
  final Sheet displayedSheet;
  final double relativeSafeArea;
  final double bottomAppBarHeight;

  const _SheetContainer({
    required this.displayedSheet,
    required this.relativeSafeArea,
    required this.bottomAppBarHeight,
  });

  /// How far the scrim is allowed to extend *under* the sheet. The sheets round
  /// their top corners (radius 28), and the page shows through those cutouts —
  /// so the scrim has to reach a little past the sheet's top edge or the
  /// corners would reveal unscrimmed content.
  static const _sheetCornerOverlap = 32.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final modalBarrierColor =
        Theme.of(context).bottomSheetTheme.modalBarrierColor ??
        colorScheme.scrim.withValues(alpha: 0.5);

    final (sheet, initialExtent) = switch (displayedSheet) {
      ViewTabsSheet() => (
        _ViewTabsSheet(maxChildSize: relativeSafeArea),
        _ViewTabsSheet.initialHeight,
      ),
      final SiteSettingsSheet parameter => (
        _SiteSettingsSheet(
          initialTabState: parameter.tabState,
          maxChildSize: relativeSafeArea,
          bottomAppBarHeight: bottomAppBarHeight,
        ),
        _SiteSettingsSheet.initialHeight,
      ),
    };

    // Drives the scrim's height. Seeded with the sheet's initial extent so the
    // very first frame is already clipped correctly, then tracked from the
    // sheet's own drag notifications.
    final sheetExtent = useValueNotifier(initialExtent);

    bool onSheetNotification(DraggableScrollableNotification notification) {
      sheetExtent.value = notification.extent;

      if (notification.extent <= 0.1) {
        logger.i('Dismissing sheet, reached min extend');
        ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        return true;
      }
      return false;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight;

        return Stack(
          children: [
            // Scrim. Hit-testing stays full-area (opaque) so tapping anywhere
            // the sheet doesn't occupy still dismisses — including beside a
            // width-constrained sheet — but the *paint* is clipped to the band
            // above the sheet. Under hybrid composition every pixel painted
            // over the platform view goes through an overlay surface, and once
            // the tab sheet settles near full extent almost all of a
            // full-screen scrim is hidden behind it anyway.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                },
                child: ValueListenableBuilder<double>(
                  valueListenable: sheetExtent,
                  builder: (context, extent, _) {
                    final scrimHeight =
                        (available * (1.0 - extent) + _sheetCornerOverlap)
                            .clamp(0.0, available);

                    return Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: scrimHeight,
                        width: double.infinity,
                        child: ColoredBox(color: modalBarrierColor),
                      ),
                    );
                  },
                ),
              ),
            ),

            // The sheet itself sits above the scrim, so taps on it hit its own
            // widgets and taps above it fall through to the scrim's detector.
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: NotificationListener<DraggableScrollableNotification>(
                  onNotification: onSheetNotification,
                  child: sheet,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Browser extends HookConsumerWidget {
  Duration get _backButtonPressTimeout => const Duration(seconds: 2);

  final OverlayPortalController overlayController;
  final StreamSink<Offset>? pointerMoveEventSink;
  final bool tabInFullScreen;
  final bool sheetDisplayed;
  final bool hasTopBarOffset;
  final bool hasLeftBarOffset;
  final bool hasRightBarOffset;
  final bool applyBottomSafeArea;

  const _Browser({
    required this.overlayController,
    required this.tabInFullScreen,
    required this.pointerMoveEventSink,
    required this.sheetDisplayed,
    required this.hasTopBarOffset,
    required this.hasLeftBarOffset,
    required this.hasRightBarOffset,
    required this.applyBottomSafeArea,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleBackCloseTab = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.doubleBackCloseTab),
    );

    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayBuilder = ref.watch(overlayControllerProvider);

    Future<bool> confirmIsolatedTabCloseIfNeeded(String tabId) async {
      final allStates = ref.read(tabStatesProvider);
      final tabState = allStates[tabId];
      final contextId = tabState?.isolationContextId;

      if (contextId == null) return true;

      final groupCount = allStates.values
          .where((state) => state.isolationContextId == contextId)
          .length;

      if (groupCount > 1 || !context.mounted) return groupCount > 1;

      return ui_helper.confirmIsolatedTabClose(context);
    }

    return DragTarget<TabDragData>(
      onMove: (details) {
        ref
            .read(willAcceptDropProvider.notifier)
            .setData(DeleteDropData(details.data.tabId));
      },
      onLeave: (data) {
        ref.read(willAcceptDropProvider.notifier).clear();
      },
      onAcceptWithDetails: (details) async {
        ref.read(willAcceptDropProvider.notifier).clear();
        if (!await confirmIsolatedTabCloseIfNeeded(details.data.tabId)) {
          return;
        }

        await ref
            .read(tabRepositoryProvider.notifier)
            .closeTab(details.data.tabId);

        if (context.mounted) {
          ui_helper.showTabUndoClose(
            context,
            ref.read(tabRepositoryProvider.notifier).undoClose,
          );
        }
      },
      builder: (context, _, _) {
        return OverlayPortal(
          controller: overlayController,
          overlayChildBuilder: (context) {
            // The OverlayPortal lifecycle is driven by ref.listen above, but
            // OverlayPortal can call this builder one extra frame after
            // dismiss() set the provider back to null (esp. on rebuilds
            // triggered by unrelated state changes). Render an empty box
            // instead of force-unwrapping a null builder.
            return overlayBuilder?.call(context) ?? const SizedBox.shrink();
          },
          child: Listener(
            onPointerDown: sheetDisplayed
                ? (_) {
                    ref
                        .read(bottomSheetControllerProvider.notifier)
                        .requestDismiss();
                  }
                : null,
            child: BackButtonListener(
              onBackButtonPressed: () async {
                final tabState = ref.read(selectedTabStateProvider);
                final promptOnBackBehavior = ref
                    .read(tabRepositoryProvider.notifier)
                    .backPromptBehaviorFor(tabState?.id);

                final tabCount = ref.read(
                  tabListProvider.select((tabs) => tabs.value.length),
                );

                //Don't do anything if a child route is active
                if (GoRouterState.of(context).topRoute?.name !=
                    BrowserRoute.name) {
                  return false;
                }

                // Dismiss modal routes (e.g. showModalBottomSheet).
                // maybePop rather than pop: this listener runs ahead of the
                // navigator, so popping outright would skip the PopScope of
                // whatever is on top — a modal that handles back itself (the
                // menu sheet's arrangement UI, a dialog that blocks back while
                // it works) would be closed instead of being asked. Either way
                // the gesture belongs to that modal, so it counts as handled.
                final rootNavigator = Navigator.of(
                  context,
                  rootNavigator: true,
                );
                if (rootNavigator.canPop()) {
                  await rootNavigator.maybePop();
                  return true;
                }

                if (ref.read(bottomSheetControllerProvider) != null) {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                  return true;
                }

                if (overlayBuilder != null) {
                  ref.read(overlayControllerProvider.notifier).dismiss();
                  return true;
                }

                if (tabState?.isFullScreen == true) {
                  await ref.read(selectedTabSessionProvider).exitFullscreen();
                  return true;
                }

                //Make sure app bar is visible
                final tabId = ref.read(selectedTabProvider);
                ref
                    .read(toolbarVisibilityControllerProvider(tabId).notifier)
                    .show();

                if (tabState?.isLoading == true) {
                  lastBackButtonPress.value = null;

                  final controller = ref.read(selectedTabSessionProvider);

                  await controller.stopLoading();
                  return true;
                } else if (tabState?.readerableState.active == true) {
                  lastBackButtonPress.value = null;

                  await ref
                      .read(readerableScreenControllerProvider.notifier)
                      .toggleReaderView(false);

                  return true;
                } else if (ref
                    .read(tabHistoryStateProvider(tabState?.id))
                    .canGoBack) {
                  lastBackButtonPress.value = null;

                  final controller = ref.read(selectedTabSessionProvider);

                  await controller.goBack();
                  return true;
                }

                if (promptOnBackBehavior != null) {
                  if (!context.mounted) return false;

                  final keep = await showKeepTabDialog(context);
                  if (keep == null) {
                    return true;
                  }

                  if (keep) {
                    if (tabState == null) {
                      return true;
                    }
                    ref
                        .read(tabRepositoryProvider.notifier)
                        .clearBackPromptBehavior(tabState.id);
                  } else if (tabState != null) {
                    if (!await confirmIsolatedTabCloseIfNeeded(tabState.id)) {
                      return true;
                    }

                    await ref
                        .read(tabRepositoryProvider.notifier)
                        .closeTab(tabState.id);
                  }

                  if (!context.mounted) return true;

                  switch (promptOnBackBehavior) {
                    case BackgroundAppTabBackPromptBehavior():
                      await moveToBackground();
                    case ReturnToSearchTabBackPromptBehavior(:final tabType):
                      ref
                          .read(searchAutofocusSuppressionProvider.notifier)
                          .suppressNext();
                      await SearchRoute(tabType: tabType).push(context);
                  }

                  return true;
                }

                //Go router has routes to go back to
                if (context.canPop()) {
                  return true;
                }

                // Handle double back to close (if enabled)
                if (doubleBackCloseTab) {
                  if (lastBackButtonPress.value != null &&
                      DateTime.now().difference(lastBackButtonPress.value!) <
                          _backButtonPressTimeout) {
                    lastBackButtonPress.value = null;

                    if (tabState != null && tabCount > 1) {
                      if (!await confirmIsolatedTabCloseIfNeeded(tabState.id)) {
                        return true;
                      }

                      await ref
                          .read(tabRepositoryProvider.notifier)
                          .closeTab(tabState.id);

                      if (context.mounted) {
                        ui_helper.showTabUndoClose(
                          context,
                          ref.read(tabRepositoryProvider.notifier).undoClose,
                        );
                      }

                      return true;
                    } else {
                      await moveToBackground();
                      return true;
                    }
                  } else {
                    lastBackButtonPress.value = DateTime.now();
                    ui_helper.showTabBackButtonMessage(
                      context,
                      tabCount,
                      _backButtonPressTimeout,
                    );

                    return true;
                  }
                }

                return true;
              },
              child: _BrowserView(
                isFullscreen: tabInFullScreen,
                pointerMoveEventSink: pointerMoveEventSink,
                hasTopBarOffset: hasTopBarOffset,
                hasLeftBarOffset: hasLeftBarOffset,
                hasRightBarOffset: hasRightBarOffset,
                applyBottomSafeArea: applyBottomSafeArea,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrowserView extends StatelessWidget {
  final bool isFullscreen;
  final StreamSink<Offset>? pointerMoveEventSink;
  final bool hasTopBarOffset;
  final bool hasLeftBarOffset;
  final bool hasRightBarOffset;
  final bool applyBottomSafeArea;

  const _BrowserView({
    required this.isFullscreen,
    required this.hasTopBarOffset,
    required this.hasLeftBarOffset,
    required this.hasRightBarOffset,
    required this.applyBottomSafeArea,
    this.pointerMoveEventSink,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Disable top SafeArea when top bar handles it (has offset applied)
      top: !isFullscreen && !hasTopBarOffset,
      // Disable a side's SafeArea when the rail on that edge already consumed
      // the inset via the content offset.
      right: !isFullscreen && !hasRightBarOffset,
      // Apply bottom SafeArea only when no toolbar/overlay is rendered at the
      // bottom (and not in fullscreen). Otherwise the toolbar handles its own
      // safe-area inset and the platform view extends behind it.
      bottom: applyBottomSafeArea,
      left: !isFullscreen && !hasLeftBarOffset,
      child: Stack(
        children: [BrowserView(pointerMoveEventSink: pointerMoveEventSink)],
      ),
    );
  }
}

class _SiteSettingsSheet extends HookConsumerWidget {
  final double maxChildSize;
  final TabState initialTabState;
  final double bottomAppBarHeight;

  static const initialHeight = 0.8;

  const _SiteSettingsSheet({
    required this.initialTabState,
    required this.bottomAppBarHeight,
    this.maxChildSize = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final draggableScrollableController = useDraggableScrollableController();

    void handleClearSiteDataExpansion(bool isExpanded) {
      if (isExpanded) {
        if (disableAnimations) {
          draggableScrollableController.jumpTo(1.0);
        } else {
          unawaited(
            draggableScrollableController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate,
            ),
          );
        }
      }
    }

    return DraggableScrollableSheet(
      controller: draggableScrollableController,
      expand: false,
      initialChildSize: initialHeight,
      minChildSize: 0.1,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: ViewTabSheetWidget(
            initialTabState: initialTabState,
            sheetScrollController: scrollController,
            draggableScrollableController: draggableScrollableController,
            onClose: () {
              final tabViewBottomSheet = ref
                  .read(generalSettingsWithDefaultsProvider)
                  .tabViewBottomSheet;

              if (tabViewBottomSheet) {
                ref
                    .read(bottomSheetControllerProvider.notifier)
                    .requestDismiss();
              } else {
                const BrowserRoute().go(context);
              }
            },
            initialHeight: initialHeight,
            bottomAppBarHeight: bottomAppBarHeight,
            onClearSiteDataExpandedChanged: handleClearSiteDataExpansion,
          ),
        );
      },
    );
  }
}

class _ViewTabsSheet extends HookConsumerWidget {
  final double maxChildSize;

  /// Matches [DraggableScrollableSheet]'s default, made explicit so the
  /// scrim in [_SheetContainer] can seed its clip from it.
  static const initialHeight = 0.5;

  const _ViewTabsSheet({this.maxChildSize = 1.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsViewMode = ref.watch(tabsViewModeControllerProvider);
    final tabsReorderable = ref.watch(tabsReorderableControllerProvider);

    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );

    final effectiveTabsViewMode = isSyncedScope
        ? TabsViewMode.list
        : tabsViewMode;

    final draggableScrollableController = useDraggableScrollableController(
      keys: [tabsReorderable],
    );

    return DraggableScrollableSheet(
      key: ValueKey(tabsReorderable),
      controller: draggableScrollableController,
      expand: false,
      initialChildSize: initialHeight,
      minChildSize: 0.1,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: TabTrayGestures(
            child: switch (effectiveTabsViewMode) {
              TabsViewMode.list => ViewTabListWidget(
                scrollController: scrollController,
                showNewTabFab: true,
                tabsReorderable: tabsReorderable,
                draggableScrollableController: draggableScrollableController,
                onClose: () {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                },
              ),
              TabsViewMode.grid => ViewTabGridWidget(
                scrollController: scrollController,
                showNewTabFab: true,
                tabsReorderable: tabsReorderable,
                draggableScrollableController: draggableScrollableController,
                onClose: () {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                },
              ),
              TabsViewMode.tree => ViewTabTreesWidget(
                scrollController: scrollController,
                showNewTabFab: true,
                onClose: () {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();
                },
              ),
            },
          ),
        );
      },
    );
  }
}
