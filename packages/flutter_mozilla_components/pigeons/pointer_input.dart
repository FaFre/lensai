/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:pigeon/pigeon.dart';

/// The native surface a mouse event belongs to.
class PointerTarget {
  /// The platform view id the surface was registered under.
  final int viewId;

  /// Physical pixels, local to that surface.
  final double x;
  final double y;

  PointerTarget({required this.viewId, required this.x, required this.y});
}

/// One answer to "who owns this cursor position", stamped so the native side
/// can tell a late reply from a newer decision.
///
/// Revisions are strictly increasing for the life of one Dart isolate, and
/// [PointerInputHostApi.reset] is what opens a new revision space.
class PointerHitTest {
  final int revision;

  /// Null when Flutter owns the position, which is also what covering a native
  /// surface with opaque Flutter chrome looks like.
  final PointerTarget? target;

  PointerHitTest({required this.revision, this.target});
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/pointer_input.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/pigeons/PointerInput.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.flutter_mozilla_components.pigeons',
      // Pigeon emits a `FlutterError` class per generated file; the gecko pigeon
      // already owns that name in this package.
      errorClassName: 'PointerInputFlutterError',
    ),
    dartPackageName: 'flutter_mozilla_components',
  ),
)
/// Asked by the native router before it delivers a retained mouse event.
@FlutterApi()
abstract class PointerInputFlutterApi {
  /// Hit-tests [x]/[y], given in physical pixels local to the Flutter view.
  ///
  /// [tracksHover] marks a hover event, and additionally arms the stationary
  /// watch that reports later changes through
  /// [PointerInputHostApi.hoverTargetChanged].
  PointerHitTest hitTest(double x, double y, bool tracksHover);

  /// The cursor left every registered surface, so the stationary watch stops.
  void pointerExit();
}

/// Told to the native router by the Dart half.
@HostApi()
abstract class PointerInputHostApi {
  /// Drops every retained event and opens a new revision space.
  ///
  /// A hot restart keeps the native router alive but gives Dart a new isolate,
  /// whose revisions start over from zero.
  void reset();

  /// A frame changed which surface is under a stationary cursor.
  void hoverTargetChanged(PointerHitTest hit);
}
