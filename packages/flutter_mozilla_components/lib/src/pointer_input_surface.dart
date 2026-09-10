/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/src/pointer_input_bridge.dart';

/// Registers the platform view rendered by [child] for mouse arbitration.
///
/// Android delivers wheel and hover straight to the native view under the
/// cursor, ignoring anything Flutter paints over it. Registering makes the
/// native side hold those events back and ask [PointerInputBridge] who owns
/// them, so Flutter chrome above the surface finally gets its own.
///
/// Every arbitrated surface must be registered: an unregistered platform view
/// reads as opaque cover, because the router has no way to deliver to it.
class PointerInputRegistration extends StatefulWidget {
  const PointerInputRegistration({
    required this.viewId,
    required this.child,
    super.key,
  });

  final int viewId;
  final Widget child;

  @override
  State<PointerInputRegistration> createState() =>
      _PointerInputRegistrationState();
}

class _PointerInputRegistrationState extends State<PointerInputRegistration> {
  PointerInputBridge? _bridge;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bridge ??= PointerInputBridge.attach(
      View.of(context),
      this,
      widget.viewId,
    );
  }

  @override
  void didUpdateWidget(covariant PointerInputRegistration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewId != widget.viewId) {
      _bridge!.update(this, widget.viewId);
    }
  }

  @override
  void dispose() {
    _bridge!.detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The [PlatformViewLink.surfaceFactory] surface for a native view that takes
/// part in mouse arbitration.
///
/// The hit-test behaviour is fixed at [PlatformViewHitTestBehavior.opaque]
/// because arbitration depends on it: the router asks Flutter where a cursor
/// landed, and a surface that keeps itself out of the hit-test path could never
/// be named as the answer.
class PointerInputSurface extends StatelessWidget {
  const PointerInputSurface({
    required this.controller,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    super.key,
  });

  final PlatformViewController controller;

  /// Touch recognizers for the surface, which arbitration does not touch:
  /// Flutter routes touch through the platform view's own gesture arena.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  Widget build(BuildContext context) {
    return PointerInputRegistration(
      viewId: controller.viewId,
      child: AndroidViewSurface(
        controller: controller as AndroidViewController,
        gestureRecognizers: gestureRecognizers,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}
