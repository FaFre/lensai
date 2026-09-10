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
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/device_info.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/app_links/domain/services/app_link_policy_replication.dart';
import 'package:weblibre/features/bangs/data/models/web_search_bang.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/browser_extension.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/controllers/home_target_controller.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/intent.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/lifecycle.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_home.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/local_index_pruner.dart';
import 'package:weblibre/features/gestures/domain/services/gesture_control.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_feedback_overlay.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/pending_intent_decision.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/services/intent_gatekeeper.dart';
import 'package:weblibre/features/intent_gatekeeper/presentation/widgets/intent_gatekeeper_dialog.dart';
import 'package:weblibre/features/share_intent/domain/entities/intent_container_mode.dart';
import 'package:weblibre/features/share_intent/domain/entities/shared_content.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/features/wallpaper/domain/providers.dart';
import 'package:weblibre/features/web_feed/domain/providers/add_dialog_blocking.dart';
import 'package:weblibre/features/web_feed/domain/services/article_content_processor.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/utils/ui_helper.dart';

class BrowserView extends StatefulHookConsumerWidget {
  final Duration screenshotPeriod;

  /// How stale a thumbnail may get while nothing is interacting with the page.
  ///
  /// The interaction check in [_BrowserViewState._timerTick] cannot see a page
  /// that changes on its own — a video, a CSS animation, a JS clock, a live
  /// feed — so this is the backstop that keeps such a tab's thumbnail from
  /// freezing at whatever it showed when the user last touched it. Several
  /// times [screenshotPeriod], because the whole point is that an idle article
  /// stops being re-rendered every ten seconds — but only a few, because a tab
  /// tray is a common entry point and a visibly stale preview of a video or a
  /// dashboard is the cost of getting this wrong in the other direction.
  final Duration maxThumbnailAge;

  final Duration suggestionTimeout;
  final Future<void> Function()? postInitializationStep;
  final StreamSink<Offset>? pointerMoveEventSink;

  const BrowserView({
    super.key,
    this.screenshotPeriod = const Duration(seconds: 10),
    this.maxThumbnailAge = const Duration(seconds: 30),
    this.suggestionTimeout = const Duration(seconds: 30),
    this.postInitializationStep,
    this.pointerMoveEventSink,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BrowserViewState();
}

class _BrowserViewState extends ConsumerState<BrowserView>
    with WidgetsBindingObserver {
  Timer? _periodicScreenshotUpdate;
  final Completer<void> _initializationCompleter = Completer<void>();

  //This is managed by widget state changes to resume a timer
  bool _timerPaused = false;

  DateTime? _suggestionCountTime;

  static const _pointerThrottleInterval = Duration(milliseconds: 32);
  DateTime _lastPointerEvent = DateTime(0);
  Offset _accumulatedDelta = Offset.zero;

  /// Whether anything has happened to the page since the last thumbnail was
  /// captured.
  ///
  /// A render-to-bitmap of a page nobody has touched produces the thumbnail that
  /// is already stored, so the periodic capture used to spend a Gecko off-screen
  /// render plus a 720px decode every [BrowserView.screenshotPeriod] for the
  /// whole time a tab sat open on an article. Set on the events that can change
  /// what a thumbnail would show — a load finishing, a touch, a tab becoming
  /// selected — and cleared once a capture has been asked for.
  ///
  /// Starts `true` so the first tick after the timer arms still captures.
  bool _pageDirtySinceCapture = true;

  /// When the last capture was asked for, or `null` if none has been.
  ///
  /// Pairs with [_pageDirtySinceCapture]: interaction is what makes a capture
  /// worth doing promptly, and this is what makes one happen anyway for a page
  /// that changes without being touched.
  DateTime? _lastCaptureRequest;

  Future<void> _timerTick(Timer timer) async {
    // Skip the (expensive) Gecko render-to-bitmap while a full-cover route
    // (settings, tab tray, search, …) occludes the browser. The screenshot
    // would force an off-screen render the user can't see and competes for the
    // GPU with the overlay's transition animation. The timer is kept alive so
    // capture resumes automatically once the browser is foregrounded again.
    // See https://github.com/FaFre/WebLibre/issues/492.
    final topRoute = ref.read(currentTopRouteProvider);
    if (topRoute is! GoRoute || topRoute.name != BrowserRoute.name) {
      return;
    }

    // In-tree sheets (tab tray, site settings, …) are not routes — they are
    // Stack layers driven by [bottomSheetControllerProvider] — so the route
    // check above does not catch them. They occlude the browser just the same,
    // and the resulting thumbnail event would rebuild the tray that is on
    // screen, so skip the capture while one is displayed.
    if (ref.read(bottomSheetControllerProvider) != null) {
      return;
    }

    // Nothing has touched the page, so a capture would mostly reproduce the
    // stored thumbnail — but "mostly" is not "always": a video, an animation or
    // a JS-driven page changes with no input at all, and the interaction flag
    // cannot see that. So the flag only decides whether to capture *promptly*;
    // [BrowserView.maxThumbnailAge] still forces one through. The timer is left
    // running either way.
    final lastCapture = _lastCaptureRequest;
    final isStale =
        lastCapture == null ||
        DateTime.now().difference(lastCapture) >= widget.maxThumbnailAge;

    if (!_pageDirtySinceCapture && !isStale) {
      return;
    }

    _pageDirtySinceCapture = false;
    _lastCaptureRequest = DateTime.now();

    await ref
        .read(selectedTabSessionProvider)
        .requestScreenshot(requireImageResult: false)
        .onError((error, stackTrace) {
          logger.e(error, stackTrace: stackTrace);
          timer.cancel();

          return null;
        });
  }

  @override
  Widget build(BuildContext context) {
    useOnInitialization(() async {
      await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .fetchSettings()
          .then((settings) async {
            await ref
                .read(browserDataServiceProvider.notifier)
                .deleteDataOnEngineStart(settings.deleteBrowsingDataOnQuit);

            if (settings.historyAutoCleanInterval > Duration.zero) {
              await ref
                  .read(historyRepositoryProvider.notifier)
                  .deleteVisitsBetween(
                    DateTime(0),
                    DateTime.now().subtract(settings.historyAutoCleanInterval),
                  );

              unawaited(ref.read(localIndexPrunerProvider.notifier).prune());
            }

            if (settings.unassignedTabsAutoCleanInterval > Duration.zero) {
              await ref
                  .read(tabDataRepositoryProvider.notifier)
                  .deleteUnassignedTabsOlderThan(
                    DateTime.now().subtract(
                      settings.unassignedTabsAutoCleanInterval,
                    ),
                  );
            }
          });

      // Wallpapers nothing points at any more: replaced images, a container
      // edit that imported one and was then cancelled, containers since
      // deleted. Startup is the one moment when no picker can be holding a
      // staged import, and nothing waits on the result.
      unawaited(
        ref.read(wallpaperSweeperProvider.notifier).sweep().onError((e, s) {
          logger.w('Wallpaper sweep failed', error: e, stackTrace: s);
        }),
      );

      // Clear data for containers with clearDataOnExit enabled
      final containersToClear = await ref
          .read(containerRepositoryProvider.notifier)
          .getContainersToClearOnExit();

      if (containersToClear.isNotEmpty) {
        await ref
            .read(browserDataServiceProvider.notifier)
            .clearContainerDataOnEngineStart(containersToClear);
      }
    });

    final showHome = ref.watch(shouldShowBrowserHomeProvider);

    // Instantiate the home-target controller so its cold-start listener is
    // alive. Its state is void, so watching costs nothing.
    ref.watch(homeTargetControllerProvider);

    final topRoute = ref.watch(currentTopRouteProvider);
    final androidInfoAsync = ref.watch(androidDeviceInfoProvider);
    final unmountGeckoViewOffRoute = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.unmountGeckoViewOffRoute,
      ),
    );

    final isOnBrowserRoute =
        topRoute is GoRoute && topRoute.name == BrowserRoute.name;

    // Whether the route on top of the browser has finished covering it.
    //
    // A pushed route's overlay entry only turns opaque when its transition
    // *completes* ([TransitionRoute._handleStatusChanged]), and that is the
    // moment the navigator stops painting everything below it — the engine
    // surface included. This route's secondary animation is that same
    // animation, so its status is the signal.
    //
    // Paired with the go-router check because status alone would also report a
    // dialog or a modal sheet, and those are not opaque: the browser keeps
    // being painted underneath them, and telling the engine otherwise would
    // blank the page behind an open dialog.
    final secondaryAnimation = ModalRoute.of(context)?.secondaryAnimation;
    // Seeded rather than read once in the effect, which flutter_hooks runs
    // *during* the build that created it: a browser rebuilt from nothing under
    // a route that is already covering it — a UI reset, for one — gets no
    // status change to learn that from, and assigning it there would be a
    // build-time markNeedsBuild.
    final coveringRouteSettled = useState(
      secondaryAnimation?.isCompleted ?? false,
    );

    useEffect(() {
      if (secondaryAnimation == null) {
        return null;
      }

      void onStatus(AnimationStatus status) {
        coveringRouteSettled.value = status == AnimationStatus.completed;
      }

      secondaryAnimation.addStatusListener(onStatus);

      return () => secondaryAnimation.removeStatusListener(onStatus);
    }, [secondaryAnimation]);

    final isGeckoViewVisible = androidInfoAsync.when(
      data: (androidInfo) {
        if (androidInfo == null) {
          // Not Android, always show GeckoView based on route
          return isOnBrowserRoute;
        }
        // Android 12 and lower (API <= 31): always unmount off-route to work
        // around the native visibility bug. On Android 13+ the engine normally
        // stays mounted to avoid reload/flicker, unless the developer setting
        // opts into the same off-route unmounting.
        //
        // Neither is what keeps a stale engine surface off the route above it
        // any more; [GeckoView.isPainted] is, on every version and for the home
        // surface too. What this decides is only whether the engine is worth
        // keeping warm while it cannot be seen.
        if (androidInfo.sdkInt <= 31 || unmountGeckoViewOffRoute) {
          return isOnBrowserRoute;
        }
        // Android 13+: always show GeckoView
        return true;
      },
      loading: () => true, // Show by default while loading
      error: (_, _) => true, // Show by default on error
    );

    // The two ways this subtree stops being painted while the platform view
    // stays mounted: the home surface going up over it, and an opaque route
    // finishing its transition on top of the whole browser.
    final isEnginePainted =
        !showHome && (isOnBrowserRoute || !coveringRouteSettled.value);

    return Listener(
      behavior: HitTestBehavior.translucent,
      // A touch is the cheapest available proxy for "the page may look
      // different now" — it covers scrolling, tapping a disclosure, dismissing a
      // banner. Marked on down rather than on move so a tap counts too.
      onPointerDown: (_) => _pageDirtySinceCapture = true,
      onPointerUp: (_) {
        _pageDirtySinceCapture = true;

        if (widget.pointerMoveEventSink != null &&
            _accumulatedDelta != Offset.zero) {
          widget.pointerMoveEventSink!.add(_accumulatedDelta);
          _accumulatedDelta = Offset.zero;
        }
      },
      onPointerMove: (widget.pointerMoveEventSink != null)
          ? (event) {
              if (event.down) {
                _accumulatedDelta += event.localDelta;
                final now = DateTime.now();
                if (now.difference(_lastPointerEvent) >=
                    _pointerThrottleInterval) {
                  _lastPointerEvent = now;
                  widget.pointerMoveEventSink!.add(_accumulatedDelta);
                  _accumulatedDelta = Offset.zero;
                }
              }
            }
          : null,
      child: Stack(
        // Expand rather than the default loose fit: every layer here is meant
        // to fill the viewport, and the enclosing stack passes loose
        // constraints down. Under a loose fit the stack would size itself from
        // its only non-positioned child — the engine — and collapse to nothing
        // whenever that child is offstage, taking the [Positioned.fill] home
        // surface and gesture overlay down with it.
        fit: StackFit.expand,
        children: [
          // Two separate concerns, deliberately not folded into one flag:
          //
          // [Offstage] — the home surface covers the whole viewport, so the
          // engine contributes no visible pixels while it is up. Painting it
          // anyway pushes a platform-view layer, which puts every frame through
          // [AndroidExternalViewEmbedder] hybrid composition: the frame is split
          // into a platform-view surface plus Flutter overlay surfaces and
          // submitted with a platform-thread round-trip, pinning the raster
          // thread for tens of milliseconds. Offstage still lays the view out
          // and keeps the element (and with it the view controller and the
          // native fragment) alive, so there is no teardown, reload or flicker
          // — it just stops painting, and the home composites as a single
          // surface.
          //
          // [Visibility] — the off-route unmount, which deliberately *does*
          // destroy the platform view (see [isGeckoViewVisible] above), so it
          // keeps the default maintainState: false.
          //
          // Not painting a hybrid-composition view is not the same as taking it
          // off the screen, so both of these have to be reported to
          // [GeckoView.isPainted] as well: the engine's surface layer stays on
          // the window until something hides the surface view itself.
          Offstage(
            offstage: showHome,
            child: Visibility(
              visible: isGeckoViewVisible,
              child: GeckoView(
                // Reports when the native container enters the window, which
                // under the [Offstage] above is not until the home surface is
                // dismissed. [GeckoView] attaches the browser fragment on every
                // such report, so an engine kept alive but unpainted for the
                // whole of startup still gets its fragment the moment it is
                // shown. See https://github.com/FaFre/WebLibre/issues/557.
                viewReadyEvents: ref
                    .read(eventServiceProvider)
                    .viewReadyStateEvents,
                isPainted: isEnginePainted,
                postInitializationStep: () async {
                  await widget.postInitializationStep?.call();

                  if (!_initializationCompleter.isCompleted) {
                    _initializationCompleter.complete();

                    const quickActions = QuickActions();

                    //Debounce: https://github.com/flutter/flutter/issues/131121
                    DateTime? lastAction;
                    await quickActions.initialize((type) async {
                      if (lastAction == null ||
                          DateTime.now().difference(lastAction!) >
                              const Duration(seconds: 5)) {
                        if (type == 'new_tab') {
                          lastAction = DateTime.now();

                          final router = await ref.read(routerProvider.future);
                          const route = SearchRoute(tabType: TabType.regular);

                          await router.push(route.location);
                        } else if (type == 'new_private_tab') {
                          lastAction = DateTime.now();

                          final router = await ref.read(routerProvider.future);
                          const route = SearchRoute(tabType: TabType.private);

                          await router.push(route.location);
                        } else if (type == 'new_isolated_tab') {
                          final settings = ref.read(
                            generalSettingsWithDefaultsProvider,
                          );
                          if (!settings.showIsolatedTabUi) {
                            return;
                          }

                          lastAction = DateTime.now();

                          final router = await ref.read(routerProvider.future);
                          const route = SearchRoute(tabType: TabType.isolated);

                          await router.push(route.location);
                        } else {
                          throw UnimplementedError(
                            'Unknown quick action shortcut type',
                          );
                        }
                      }
                    });

                    final settings = ref.read(
                      generalSettingsWithDefaultsProvider,
                    );
                    await quickActions.setShortcutItems([
                      const ShortcutItem(
                        type: 'new_tab',
                        localizedTitle: 'New Tab',
                        icon: 'mdi_icon_tab',
                      ),
                      const ShortcutItem(
                        type: 'new_private_tab',
                        localizedTitle: 'New Private Tab',
                        icon: 'mdi_icon_domino_mask',
                      ),
                      if (settings.showIsolatedTabUi)
                        const ShortcutItem(
                          type: 'new_isolated_tab',
                          localizedTitle: 'New Isolated Tab',
                          icon: 'mdi_icon_snowflake',
                        ),
                    ]);
                  }
                },
              ),
            ),
          ),
          if (showHome) const Positioned.fill(child: BrowserHome()),
          const Positioned.fill(child: GestureFeedbackOverlay()),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(browserViewLifecycleProvider.notifier)
          .update(SchedulerBinding.instance.lifecycleState);
    });

    WidgetsBinding.instance.addObserver(this);

    ref.listenManual(
      selectedTabStateProvider.select(
        (state) => (
          tabId: state?.id,
          isLoading: state?.isLoading,
          isFullScreen: state?.isFullScreen,
        ),
      ),
      (previous, next) {
        // Any of these means the next tick has something new to capture: a
        // different tab, or this one having just finished loading.
        _pageDirtySinceCapture = true;

        if (previous?.tabId != next.tabId ||
            next.isLoading == true ||
            next.isFullScreen == true) {
          _periodicScreenshotUpdate?.cancel();
          _periodicScreenshotUpdate = null;
          _timerPaused = false;
          return;
        }

        if ((_periodicScreenshotUpdate?.isActive ?? false) == false) {
          _timerPaused = false;
          _periodicScreenshotUpdate?.cancel();
          _periodicScreenshotUpdate = Timer.periodic(
            widget.screenshotPeriod,
            _timerTick,
          );
        }
      },
    );

    ref.listenManual(feedRequestedProvider, (previous, next) async {
      if (next.value.mapNotNull(Uri.tryParse) case final Uri url) {
        if (GoRouterState.of(context).topRoute?.name != FeedAddRoute.name) {
          if (ref.read(addFeedDialogBlockingProvider.notifier).canPush(url)) {
            await FeedAddRoute(uri: url.toString()).push(context);
          }
        }
      }
    });

    ref.listenManual<AsyncValue<PendingIntentDecision>>(
      fireImmediately: true,
      intentGatekeeperProvider,
      (previous, next) async {
        final request = next.value;
        if (request == null) {
          return;
        }

        final gatekeeper = ref.read(intentGatekeeperProvider.notifier);
        if (!gatekeeper.isPending(request.id)) {
          return;
        }

        if (!context.mounted) {
          await gatekeeper.resolve(
            id: request.id,
            decision: IntentSourcePolicy.block,
          );
          return;
        }

        final outcome = await showDialog<DialogOutcome>(
          context: context,
          builder: (context) => IntentGatekeeperDialog(request: request),
        );

        await gatekeeper.resolve(
          id: request.id,
          decision: outcome?.decision ?? IntentSourcePolicy.block,
          persist: outcome?.persist ?? false,
          packageName: request.packageName,
        );
      },
    );

    ref.listenManual(
      engineBoundIntentStreamProvider,
      (previous, next) {
        next.whenData((sharedContent) async {
          final settings = ref.read(generalSettingsWithDefaultsProvider);

          switch (settings.effectiveTabIntentOpenSetting) {
            case TabIntentOpenSetting.regular:
            case TabIntentOpenSetting.private:
            case TabIntentOpenSetting.isolated:
              await ref
                  .read(engineReadyStateProvider.notifier)
                  .waitUntilReady();

              final tabMode = switch (settings.effectiveTabIntentOpenSetting) {
                TabIntentOpenSetting.private => TabMode.private,
                TabIntentOpenSetting.isolated => TabMode.newIsolated(),
                _ => TabMode.regular,
              };

              switch (sharedContent) {
                case SharedUrl():
                  final containerSelection =
                      settings.effectiveTabIntentOpenSetting ==
                          TabIntentOpenSetting.isolated
                      ? const TabContainerSelection.unassigned()
                      : await _resolveContainerSelection(
                          ref,
                          sharedContent.contextId,
                          sharedContent.containerMode,
                        );

                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .addTab(
                        url: sharedContent.url,
                        tabMode: tabMode,
                        launchedFromIntent: true,
                        selectTab: true,
                        containerSelection: containerSelection,
                      );
                case SharedText():
                  final bang =
                      ref.read(selectedBangDataProvider()) ??
                      await ref.read(defaultSearchBangProvider.future);

                  if (bang != null && isWebSearchBang(bang)) {
                    final router = await ref.read(routerProvider.future);
                    await router.push(
                      SearchRoute(
                        tabType: tabMode.toTabType(),
                        searchText: sharedContent.text,
                        launchedFromIntent: true,
                        autoSubmitSearch: true,
                      ).location,
                    );
                    break;
                  }

                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .addTab(
                        url: bang?.getTemplateUrl(sharedContent.text),
                        tabMode: tabMode,
                        launchedFromIntent: true,
                        selectTab: true,
                      );
              }
            case TabIntentOpenSetting.ask:
              final router = await ref.read(routerProvider.future);

              switch (sharedContent) {
                case SharedUrl():
                  final route = OpenSharedContentRoute(
                    sharedUrl: sharedContent.url.toString(),
                    contextId: sharedContent.contextId,
                    containerMode: sharedContent.containerMode.queryValueOrNull,
                  );
                  await router.push(route.location);
                case SharedText():
                  final route = SearchRoute(
                    tabType:
                        ref.read(selectedTabTypeProvider) ??
                        settings.effectiveDefaultCreateTabType,
                    searchText: sharedContent.text,
                    launchedFromIntent: true, //launched from intent
                  );
                  await router.push(route.location);
              }
          }
        });
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineBoundIntentStreamProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    //Initialize and register dependencies
    ref.listenManual(
      fireImmediately: true,
      tabRepositoryProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to tabRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      selectionActionServiceProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to selectionActionServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      desktopModeRuleApplierProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to desktopModeRuleApplierProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      gestureControlServiceProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to gestureControlServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      appLinkPolicyReplicationProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to appLinkPolicyReplicationProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    // historyExclusionReplication is deliberately NOT activated here: it must
    // keep pushing while this view is gone (the container editor is where the
    // setting is changed). main.dart owns it.
    //
    // For the same reason main.dart now owns everything that talks to the
    // engine or to native: preferenceFixator, engineSettingsReplication (and
    // with it the settings.json baseline), both webExtensionsState families,
    // nativeIntentGatekeeperReplicator, cacheRepository and
    // searchHistoryCleanup. This view is only mounted on the browser route, and
    // a start that lands on the home surface with no tab never mounts it — so
    // anything activated from here did not run at all until the user opened a
    // tab.

    ref.listenManual(
      fireImmediately: true,
      articleContentProcessorServiceProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to articleContentProcessorServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    // Ensure PWA manifest state is collected and stays alive
    ref.listenManual(
      fireImmediately: true,
      pwaManifestStateProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to pwaManifestStateProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    // Keep-alive subscription for Tor status. The body is intentionally empty:
    // the listener exists so the provider stays active while the browser view
    // is mounted and Tor state events are not dropped. singboxProxyLogs is
    // kept alive from main.dart so startup logs are captured even before the
    // browser view mounts.
    ref.listenManual(
      fireImmediately: true,
      torProxyServiceProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to torProxyServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ref.read(browserViewLifecycleProvider.notifier).update(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (_periodicScreenshotUpdate?.isActive == true) {
          _periodicScreenshotUpdate?.cancel();
          _timerPaused = true;
        }

        ref
            .read(localAuthenticationServiceProvider.notifier)
            .evictCacheOnBackground();

        if (state == AppLifecycleState.paused) {
          _suggestionCountTime = DateTime.now();
        }
      case AppLifecycleState.resumed:
        if (_timerPaused) {
          _periodicScreenshotUpdate?.cancel();
          _periodicScreenshotUpdate = Timer.periodic(
            widget.screenshotPeriod,
            _timerTick,
          );
          _timerPaused = false;
        }

        unawaited(
          ref.read(profileAuthStateProvider.notifier).revalidateAfterResume(),
        );

        if (_suggestionCountTime != null &&
            DateTime.now().difference(_suggestionCountTime!) >
                widget.suggestionTimeout) {
          final topRoute = ref.read(currentTopRouteProvider);

          //Don't do anything if a child route is active
          if (topRoute is GoRoute && topRoute.name == BrowserRoute.name) {
            final settings = ref.read(generalSettingsWithDefaultsProvider);

            if (settings.allowClipboardAccess) {
              unawaited(
                showSuggestNewTabMessage(
                  context,
                  onAdd: (searchText) async {
                    await SearchRoute(
                      tabType:
                          ref.read(selectedTabTypeProvider) ??
                          settings.effectiveDefaultCreateTabType,
                      searchText: searchText ?? SearchRoute.emptySearchText,
                    ).push(context);
                  },
                ),
              );
            }
          }
        }

        _suggestionCountTime = null;
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);

    _periodicScreenshotUpdate?.cancel();

    super.dispose();
  }
}

/// Resolves a [TabContainerSelection] from incoming launch container metadata.
Future<TabContainerSelection> _resolveContainerSelection(
  WidgetRef ref,
  String? contextId,
  IntentContainerMode containerMode,
) async {
  if (contextId == null) {
    return switch (containerMode) {
      IntentContainerMode.unassigned =>
        const TabContainerSelection.unassigned(),
      _ => const TabContainerSelection.useSelected(),
    };
  }

  final container = await ref
      .read(containerRepositoryProvider.notifier)
      .getContainerByContextualIdentity(contextId);

  if (container != null) {
    return TabContainerSelection.specific(container);
  }

  return switch (containerMode) {
    IntentContainerMode.useSelected =>
      const TabContainerSelection.useSelected(),
    _ => const TabContainerSelection.unassigned(),
  };
}
