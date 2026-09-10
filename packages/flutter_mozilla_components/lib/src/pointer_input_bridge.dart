/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/src/pigeons/pointer_input.g.dart';

/// Answers the native pointer router's hit tests, and tells it when the answer
/// changes under a cursor that has not moved.
///
/// Android walks a wheel notch or a hover straight down the native view
/// hierarchy, so it reaches the engine view whatever Flutter paints on top. The
/// native side holds those events back and asks here who owns them; see
/// `PointerInputRouter` on the Kotlin side for the whole picture.
///
/// One bridge per engine, living for as long as at least one
/// [PointerInputRegistration] is mounted.
class PointerInputBridge implements PointerInputFlutterApi {
  PointerInputBridge._(this._view) : _host = hostApi() {
    PointerInputFlutterApi.setUp(this);
    // A hot restart keeps the native router alive but hands it a new isolate,
    // whose revisions start again from zero.
    unawaited(_call(_host.reset(), 'reset'));
  }

  static PointerInputBridge? _instance;

  /// The live bridge, or null while nothing is registered.
  @visibleForTesting
  static PointerInputBridge? get instance => _instance;

  /// How a bridge reaches the native router. Replaced in tests.
  @visibleForTesting
  static PointerInputHostApi Function() hostApi = PointerInputHostApi.new;

  final FlutterView _view;
  final PointerInputHostApi _host;

  /// The platform view id each mounted registration stands for.
  ///
  /// Keyed by the registration rather than the id, because one id can briefly
  /// appear twice while a surface is being replaced.
  final _registrations = <Object, int>{};

  var _revision = 0;
  var _watchingFrames = false;
  var _live = true;
  Offset? _hoverPosition;
  PointerTarget? _hoverTarget;

  /// Registers [owner]'s platform view, creating the bridge if it is the first.
  factory PointerInputBridge.attach(
    FlutterView view,
    Object owner,
    int viewId,
  ) {
    final bridge = _instance ??= PointerInputBridge._(view);
    assert(
      bridge._view == view,
      'Arbitrated platform views must share one FlutterView: the native router '
      'has a single Flutter view to hit-test positions against.',
    );
    bridge._registrations[owner] = viewId;
    return bridge;
  }

  void update(Object owner, int viewId) => _registrations[owner] = viewId;

  /// Drops [owner]'s registration, tearing the bridge down with the last one.
  void detach(Object owner) {
    _registrations.remove(owner);
    if (_registrations.isNotEmpty) {
      return;
    }

    _live = false;
    _hoverPosition = null;
    _hoverTarget = null;
    PointerInputFlutterApi.setUp(null);
    _instance = null;
    // Nothing is left to arbitrate for, so nothing may stay retained natively.
    unawaited(_call(_host.reset(), 'reset'));
  }

  @override
  PointerHitTest hitTest(double x, double y, bool tracksHover) {
    final position = Offset(x, y);
    final target = _targetAt(position);

    if (tracksHover) {
      _hoverPosition = position;
      _hoverTarget = target;
      _watchFrames();
    }

    return PointerHitTest(revision: ++_revision, target: target);
  }

  @override
  void pointerExit() {
    _hoverPosition = null;
    _hoverTarget = null;
  }

  /// The registered platform view under [physicalPosition], or null when
  /// Flutter owns that position.
  ///
  /// This is the framework's ordinary hit test, which is the point: opaque
  /// chrome over the surface wins the position whether or not it would do
  /// anything with the event, while an [IgnorePointer] decoration does not.
  PointerTarget? _targetAt(Offset physicalPosition) {
    final ratio = _view.devicePixelRatio;
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(
      result,
      physicalPosition / ratio,
      _view.viewId,
    );

    for (final entry in result.path) {
      final target = entry.target;
      if (target is! PlatformViewRenderBox || entry is! BoxHitTestEntry) {
        continue;
      }
      // Some other platform view is in the way. The router has no way to hand
      // it anything, so it counts as covering the surface underneath.
      final viewId = target.controller.viewId;
      if (!_registrations.containsValue(viewId)) {
        return null;
      }

      final local = entry.localPosition * ratio;
      return PointerTarget(viewId: viewId, x: local.dx, y: local.dy);
    }
    return null;
  }

  /// Watches for the owner of a resting cursor changing underneath it.
  ///
  /// Overlays open and close over a stationary mouse and nothing in the pointer
  /// pipeline reports that. Frames are only ever *observed*, never requested:
  /// an idle page must not acquire an animation loop just because a cursor is
  /// sitting on it.
  void _watchFrames() {
    if (_watchingFrames) {
      return;
    }
    _watchingFrames = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _watchingFrames = false;
      final position = _hoverPosition;
      if (!_live || position == null) {
        return;
      }

      final target = _targetAt(position);
      if (target != _hoverTarget) {
        _hoverTarget = target;
        unawaited(
          _call(
            _host.hoverTargetChanged(
              PointerHitTest(revision: ++_revision, target: target),
            ),
            'hoverTargetChanged',
          ),
        );
      }
      _watchFrames();
    });
  }

  /// Runs [call], reporting a bridge that has stopped answering rather than
  /// letting it fail an unrelated frame.
  Future<void> _call(Future<void> call, String description) async {
    try {
      await call.timeout(const Duration(seconds: 1));
    } catch (error, stackTrace) {
      developer.log(
        'Could not reach the native pointer router ($description)',
        name: 'PointerInputBridge',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
