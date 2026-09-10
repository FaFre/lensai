/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/pointer_input.g.dart';
import 'package:flutter_mozilla_components/src/pointer_input_bridge.dart';
import 'package:flutter_mozilla_components/src/pointer_input_surface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what the bridge tells the native router, in place of the channel.
class _RecordingHost extends PointerInputHostApi {
  final resets = <int>[];
  final hoverTargets = <PointerHitTest>[];

  @override
  Future<void> reset() async => resets.add(resets.length);

  @override
  Future<void> hoverTargetChanged(PointerHitTest hit) async =>
      hoverTargets.add(hit);
}

class _ViewController extends PlatformViewController {
  _ViewController(this.viewId);

  @override
  final int viewId;
  final events = <PointerEvent>[];

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async =>
      events.add(event);

  @override
  Future<void> dispose() async {}

  @override
  Future<void> clearFocus() async {}
}

/// A registered platform view, standing in for the real `AndroidViewSurface`
/// that [PointerInputSurface] builds.
Widget _surface(int id, {bool registered = true, _ViewController? controller}) {
  final surface = PlatformViewSurface(
    controller: controller ?? _ViewController(id),
    hitTestBehavior: PlatformViewHitTestBehavior.opaque,
    gestureRecognizers: const {},
  );
  return registered
      ? PointerInputRegistration(viewId: id, child: surface)
      : surface;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _RecordingHost host;

  setUp(() {
    host = _RecordingHost();
    PointerInputBridge.hostApi = () => host;
  });

  tearDown(() => PointerInputBridge.hostApi = PointerInputHostApi.new);

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(1600, 1200);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: child));
  }

  /// Asks the bridge what the native router would ask, in physical pixels.
  PointerHitTest hitTest(
    WidgetTester tester,
    Offset logicalPosition, {
    bool tracksHover = false,
  }) {
    final physical = logicalPosition * tester.view.devicePixelRatio;
    return PointerInputBridge.instance!.hitTest(
      physical.dx,
      physical.dy,
      tracksHover,
    );
  }

  Matcher isTarget(int viewId, double x, double y) => isA<PointerTarget>()
      .having((t) => t.viewId, 'viewId', viewId)
      .having((t) => t.x, 'x', x)
      .having((t) => t.y, 'y', y);

  testWidgets('first wheel hit chooses the surface without a preceding hover', (
    tester,
  ) async {
    await pump(tester, _surface(1));
    expect(host.resets, hasLength(1));
    expect(
      hitTest(tester, const Offset(100, 120)).target,
      isTarget(1, 200, 240),
    );
  });

  testWidgets('partial opaque chrome blocks only its hit area', (tester) async {
    await pump(
      tester,
      Stack(
        children: [
          Positioned.fill(child: _surface(1)),
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 100,
            child: Listener(behavior: HitTestBehavior.opaque),
          ),
        ],
      ),
    );
    expect(hitTest(tester, const Offset(50, 50)).target, isNull);
    expect(
      hitTest(tester, const Offset(50, 150)).target,
      isTarget(1, 100, 300),
    );
  });

  testWidgets('an IgnorePointer decoration does not cover the surface', (
    tester,
  ) async {
    await pump(
      tester,
      Stack(
        children: [
          Positioned.fill(child: _surface(1)),
          const Positioned.fill(
            child: IgnorePointer(child: ColoredBox(color: Colors.red)),
          ),
        ],
      ),
    );
    expect(hitTest(tester, const Offset(50, 50)).target, isTarget(1, 100, 100));
  });

  testWidgets('a popup body is distinct from its Flutter handle and scrim', (
    tester,
  ) async {
    await pump(
      tester,
      Stack(
        children: [
          Positioned.fill(child: _surface(1)),
          const Positioned.fill(child: ModalBarrier(dismissible: false)),
          Positioned(
            left: 100,
            top: 100,
            width: 400,
            height: 400,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Listener(behavior: HitTestBehavior.opaque),
                ),
                Expanded(child: _surface(2)),
              ],
            ),
          ),
        ],
      ),
    );
    expect(hitTest(tester, const Offset(50, 50)).target, isNull);
    expect(hitTest(tester, const Offset(150, 125)).target, isNull);
    expect(
      hitTest(tester, const Offset(150, 200)).target,
      isTarget(2, 100, 100),
    );
  });

  testWidgets('coordinates follow the transformed surface', (tester) async {
    await pump(
      tester,
      Stack(
        children: [
          Positioned(
            left: 100,
            top: 100,
            width: 200,
            height: 200,
            child: Transform.scale(
              scale: 0.5,
              alignment: Alignment.topLeft,
              child: _surface(1),
            ),
          ),
        ],
      ),
    );
    expect(
      hitTest(tester, const Offset(125, 150)).target,
      isTarget(1, 100, 200),
    );
    expect(hitTest(tester, const Offset(250, 250)).target, isNull);
  });

  testWidgets('an unregistered platform view covers the surface below it', (
    tester,
  ) async {
    await pump(
      tester,
      Stack(
        children: [
          Positioned.fill(child: _surface(1)),
          Positioned.fill(child: _surface(99, registered: false)),
        ],
      ),
    );
    expect(hitTest(tester, const Offset(100, 100)).target, isNull);
  });

  testWidgets('a menu overlay blocks the surface without a route change', (
    tester,
  ) async {
    final menu = MenuController();
    await pump(
      tester,
      Stack(
        children: [
          Positioned.fill(child: _surface(1)),
          Positioned(
            left: 100,
            top: 100,
            child: MenuAnchor(
              controller: menu,
              menuChildren: [
                MenuItemButton(
                  onPressed: () {},
                  child: const Text('Overlay item'),
                ),
              ],
              child: const SizedBox(width: 100, height: 40),
            ),
          ),
        ],
      ),
    );
    menu.open();
    await tester.pumpAndSettle();
    expect(
      hitTest(tester, tester.getCenter(find.text('Overlay item'))).target,
      isNull,
    );
    expect(
      hitTest(tester, const Offset(600, 400)).target,
      isTarget(1, 1200, 800),
    );
  });

  testWidgets('a dialog and its barrier both block the surface', (
    tester,
  ) async {
    await pump(tester, _surface(1));
    unawaited(
      showDialog<void>(
        context: tester.element(find.byType(PlatformViewSurface)),
        builder: (_) => const AlertDialog(content: Text('Dialog')),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      hitTest(tester, tester.getCenter(find.text('Dialog'))).target,
      isNull,
    );
    expect(hitTest(tester, const Offset(20, 20)).target, isNull);
  });

  testWidgets('revisions increase across every answer the bridge gives', (
    tester,
  ) async {
    await pump(tester, _surface(1));
    final first = hitTest(tester, const Offset(100, 100));
    final second = hitTest(tester, const Offset(100, 100));
    expect(second.revision, greaterThan(first.revision));
  });

  testWidgets('revisions keep climbing across a rebuilt bridge', (
    tester,
  ) async {
    await pump(tester, _surface(1));
    final before = hitTest(tester, const Offset(100, 100));

    // Every registration gone and back again: the surface is unmounted under a
    // full-screen route and mounted when it closes. The router hears the new
    // bridge's reset on one channel and its answers on another, so an answer
    // that started over would be dropped as stale against the one the router
    // has already applied.
    await pump(tester, const SizedBox());
    expect(PointerInputBridge.instance, isNull);
    await pump(tester, _surface(1));

    final after = hitTest(tester, const Offset(100, 100));
    expect(after.revision, greaterThan(before.revision));
  });

  testWidgets('a stationary hover follows overlays without scheduling frames', (
    tester,
  ) async {
    var covered = false;
    late StateSetter update;
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return Stack(
            children: [
              Positioned.fill(child: _surface(1)),
              if (covered)
                const Positioned.fill(
                  child: Listener(behavior: HitTestBehavior.opaque),
                ),
            ],
          );
        },
      ),
    );
    final initial = hitTest(tester, const Offset(100, 100), tracksHover: true);

    update(() => covered = true);
    await tester.pumpAndSettle();
    final exit = host.hoverTargets.last;
    expect(exit.revision, greaterThan(initial.revision));
    expect(exit.target, isNull);

    update(() => covered = false);
    await tester.pumpAndSettle();
    final enter = host.hoverTargets.last;
    expect(enter.revision, greaterThan(exit.revision));
    expect(enter.target, isTarget(1, 200, 200));
    expect(tester.binding.hasScheduledFrame, isFalse);

    // Once the cursor has left, nothing is watched any more.
    PointerInputBridge.instance!.pointerExit();
    host.hoverTargets.clear();
    update(() => covered = true);
    await tester.pumpAndSettle();
    expect(host.hoverTargets, isEmpty);
  });

  testWidgets('an overlay Flutter wins still scrolls in the framework', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pump(
      tester,
      Stack(
        children: [
          Positioned.fill(child: _surface(1)),
          Positioned.fill(
            child: ListView(
              controller: scroll,
              children: const [SizedBox(height: 2000)],
            ),
          ),
        ],
      ),
    );
    expect(hitTest(tester, const Offset(100, 100)).target, isNull);

    tester.binding.handlePointerEvent(
      const PointerScrollEvent(
        kind: PointerDeviceKind.mouse,
        position: Offset(100, 100),
        scrollDelta: Offset(0, 80),
      ),
    );
    await tester.pump();
    expect(scroll.offset, 80);
  });

  testWidgets('the last surface to unmount tears the bridge down', (
    tester,
  ) async {
    await pump(
      tester,
      Stack(
        children: [
          Positioned.fill(child: _surface(1)),
          Positioned.fill(child: _surface(2)),
        ],
      ),
    );
    expect(host.resets, hasLength(1));

    // One of two surfaces going away leaves the bridge in place.
    await tester.pumpWidget(MaterialApp(home: _surface(1)));
    expect(host.resets, hasLength(1));
    expect(PointerInputBridge.instance, isNotNull);

    await tester.pumpWidget(const SizedBox());
    expect(PointerInputBridge.instance, isNull);
    expect(host.resets, hasLength(2));

    await tester.pumpWidget(MaterialApp(home: _surface(1)));
    expect(host.resets, hasLength(3));
    expect(
      hitTest(tester, const Offset(100, 100)).target,
      isTarget(1, 200, 200),
    );
  });

  testWidgets('a surface that changes view id keeps its registration', (
    tester,
  ) async {
    await pump(tester, _surface(1));
    await tester.pumpWidget(MaterialApp(home: _surface(2)));
    expect(
      hitTest(tester, const Offset(100, 100)).target,
      isTarget(2, 200, 200),
    );
  });

  testWidgets('touch still goes through the platform view gesture arena', (
    tester,
  ) async {
    final controller = _ViewController(1);
    await pump(tester, _surface(1, controller: controller));
    await tester.tapAt(const Offset(100, 100));
    expect(controller.events.whereType<PointerDownEvent>(), hasLength(1));
    expect(controller.events.whereType<PointerUpEvent>(), hasLength(1));
    expect(host.hoverTargets, isEmpty);
  });
}
