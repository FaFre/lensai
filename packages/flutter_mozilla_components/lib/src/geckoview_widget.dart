/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/domain/services/gecko_browser.dart';
import 'package:flutter_mozilla_components/src/pointer_input_surface.dart';

class GeckoView extends StatefulWidget {
  /// Whether the native container backing this platform view is attached to the
  /// window, as reported by `NativeFragmentView`.
  ///
  /// The browser fragment can only be attached while this holds `true`, and the
  /// container is only inserted into the Flutter view hierarchy once the
  /// platform-view layer is first composited — which an ancestor that lays the
  /// view out without painting it (`Offstage`) defers for as long as it stays
  /// offstage. Every attach attempt is therefore driven by this stream rather
  /// than by a single burst of retries after creation, which would otherwise
  /// expire while the container is still unreachable and never run again.
  /// See https://github.com/FaFre/WebLibre/issues/557.
  final Stream<bool> viewReadyEvents;

  /// Whether an ancestor is currently painting this view.
  ///
  /// Not painting a hybrid-composition view is not the same as taking it off
  /// the screen. The engine renders into a `SurfaceView`, which owns a
  /// compositor layer of its own, and that layer is not retired by hiding
  /// anything above it: measured on Android 13, the `FlutterMutatorView`
  /// wrapper is `GONE` and the container reports `isShown == false` while the
  /// last page rendered is still on the window, over everything Flutter has
  /// drawn since. Only setting visibility on the surface view itself reconciles
  /// the layer, and nothing in the embedder does that.
  ///
  /// So the host has to say when it stopped painting, and `EngineViewVisibility`
  /// on the Kotlin side walks down and does it. `true` is the safe value — it
  /// is what a caller that never goes offstage would report — so a host that
  /// keeps the view painted at all times can leave this alone.
  final bool isPainted;

  final Future<void> Function()? postInitializationStep;

  const GeckoView({
    super.key,
    required this.viewReadyEvents,
    this.isPainted = true,
    this.postInitializationStep,
  });

  @override
  State<GeckoView> createState() => _GeckoViewState();
}

class _GeckoViewState extends State<GeckoView> {
  static const platform = MethodChannel(
    'eu.weblibre.flutter_mozilla_components/trim_memory',
  );

  static const _visibility = MethodChannel(
    'eu.weblibre.flutter_mozilla_components/engine_view',
  );

  final browserService = GeckoBrowserService();
  late final AppLifecycleListener _listener;
  StreamSubscription<bool>? _viewReadySubscription;

  /// Serialises attach attempts.
  ///
  /// The container can be reported attached while an earlier attempt is still
  /// retrying, and two concurrent attempts would both find no usable fragment
  /// and race to replace each other's.
  Future<void> _attachQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _setupMethodCallHandler();
    _listener = AppLifecycleListener(
      onResume: () {
        //Make sure fragment visible after resuming the app in case native resources have been disposed
        unawaited(_enqueueShowNativeFragment());
        unawaited(_applyContainerVisibility());
      },
    );

    _viewReadySubscription = widget.viewReadyEvents
        .where((ready) => ready)
        .listen((_) async {
          await _enqueueShowNativeFragment();
          // The container that just attached is a new view, at its default
          // visibility, and it can attach long after the view stopped being
          // painted — an engine kept alive but unpainted for the whole of
          // startup reaches this with nothing else left to hide it.
          await _applyContainerVisibility();
        });
  }

  /// Queues an attach attempt behind any that is still running.
  ///
  /// Returns when this attempt is done, so callers that need to sequence work
  /// after it can await it; failures are contained so one bad attempt cannot
  /// poison the queue for the ones the ready stream triggers later.
  Future<void> _enqueueShowNativeFragment() {
    final attempt = _attachQueue.then((_) async {
      if (!mounted) {
        return;
      }

      try {
        await _showNativeFragment();
      } catch (error, stackTrace) {
        developer.log(
          'Fragment attach attempt failed',
          name: 'GeckoView',
          level: 900,
          error: error,
          stackTrace: stackTrace,
        );
      }
    });

    _attachQueue = attempt;

    return attempt;
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onTrimMemory') {
        await browserService.onTrimMemory(call.arguments as int);
      }
    });
  }

  /// Attaches the browser fragment to the native container.
  ///
  /// The retries cover the transient reasons an attach can fail once the
  /// container is reachable — a saved fragment-manager state, a frame in which
  /// the fragment's view has no size yet. They deliberately do *not* cover
  /// waiting for the container to appear in the first place: that wait is
  /// unbounded, and [viewReadyEvents] reports it instead.
  Future<bool> _showNativeFragment({
    int maxRetries = 10,

    /// Default ist about one frame
    Duration retryDelay = const Duration(milliseconds: 1000 ~/ 60),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final result = await browserService.showNativeFragment();

      if (result) {
        developer.log(
          'Fragment ATTACHED after $attempt tries',
          name: 'GeckoView',
        );
        return true;
      }

      if (attempt < maxRetries - 1) {
        await Future.delayed(retryDelay);
      }
    }

    developer.log(
      'Fragment FAILED after $maxRetries tries',
      name: 'GeckoView',
      level: 900,
    );
    return false;
  }

  @override
  void didUpdateWidget(covariant GeckoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isPainted != widget.isPainted) {
      unawaited(_applyContainerVisibility());
    }
  }

  /// Puts the native container in the state [GeckoView.isPainted] describes.
  ///
  /// Sent on the edge itself rather than after a grace period. The embedder
  /// hides its own wrapper promptly and correctly — measured, it is already
  /// `GONE` by the time anything asks — and that is precisely what does *not*
  /// retire the engine's surface layer, so waiting to see whether it will only
  /// buys a window in which the stale page is on screen.
  ///
  /// Also re-sent whenever the container may be a different one, or may have
  /// come back on its own: it can attach after the view has already stopped
  /// being painted, and nothing else would then hide it.
  Future<void> _applyContainerVisibility() async {
    try {
      await _visibility.invokeMethod<void>(
        'setEngineViewVisible',
        widget.isPainted,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to set engine view visibility',
        name: 'GeckoView',
        level: 900,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    platform.setMethodCallHandler(null);
    unawaited(_viewReadySubscription?.cancel());
    _listener.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'eu.weblibre/gecko',
      surfaceFactory: (context, controller) =>
          PointerInputSurface(controller: controller),
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: 'eu.weblibre/gecko',
            layoutDirection: TextDirection.ltr,
            creationParams: {},
            creationParamsCodec: const StandardMessageCodec(),
          )
          ..addOnPlatformViewCreatedListener((value) {
            params.onPlatformViewCreated(value);

            SchedulerBinding.instance.addPostFrameCallback((_) async {
              // A first attempt for the common case where the view is painted
              // from the frame it is created in, so the container is already
              // attached by now. When it is not, this attempt is cheap and the
              // ready subscription takes over as soon as it becomes attached.
              await _enqueueShowNativeFragment();
              await widget.postInitializationStep?.call();
            });
          })
          // ignore: discarded_futures that hos it is done in docs
          ..create();
      },
    );
  }
}
