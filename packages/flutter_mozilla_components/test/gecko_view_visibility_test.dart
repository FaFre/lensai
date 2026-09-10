/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/geckoview_widget.dart';
import 'package:flutter_test/flutter_test.dart';

/// When [GeckoView] tells the native side to take the engine's surface off the
/// window, and when it puts it back.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const visibility = MethodChannel(
    'eu.weblibre.flutter_mozilla_components/engine_view',
  );

  const showFragmentChannel =
      'dev.flutter.pigeon.flutter_mozilla_components.GeckoBrowserApi'
      '.showNativeFragment';
  const pointerResetChannel =
      'dev.flutter.pigeon.flutter_mozilla_components.PointerInputHostApi.reset';

  late List<bool> calls;
  late StreamController<bool> viewReady;

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// A pigeon reply carrying [value], which the standard codec encodes the same
  /// way the generated codec does for the primitives used here.
  ByteData? reply(Object? value) =>
      const StandardMessageCodec().encodeMessage(<Object?>[value]);

  setUp(() {
    calls = [];
    viewReady = StreamController<bool>.broadcast();

    messenger.setMockMethodCallHandler(visibility, (call) async {
      expect(call.method, 'setEngineViewVisible');
      calls.add(call.arguments as bool);
      return true;
    });

    // Hybrid composition only sends `create` and `dispose`, and neither has a
    // reply the framework reads.
    messenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      (call) async => null,
    );

    // Answered so the attach succeeds on its first attempt: a failing one
    // retries behind delays this test would have to pump through.
    messenger.setMockMessageHandler(
      showFragmentChannel,
      (message) async => reply(true),
    );
    messenger.setMockMessageHandler(
      pointerResetChannel,
      (message) async => reply(null),
    );
  });

  tearDown(() {
    unawaited(viewReady.close());
    messenger
      ..setMockMethodCallHandler(visibility, null)
      ..setMockMethodCallHandler(SystemChannels.platform_views, null)
      ..setMockMessageHandler(showFragmentChannel, null)
      ..setMockMessageHandler(pointerResetChannel, null);
  });

  Future<void> pumpPainted(WidgetTester tester, {required bool isPainted}) =>
      tester.pumpWidget(
        MaterialApp(
          home: GeckoView(
            viewReadyEvents: viewReady.stream,
            isPainted: isPainted,
          ),
        ),
      );

  testWidgets('a view that stops being painted is hidden at once', (
    tester,
  ) async {
    await pumpPainted(tester, isPainted: true);
    await tester.pump();
    expect(calls, isEmpty);

    await pumpPainted(tester, isPainted: false);
    await tester.pump();

    // No grace period: the state the embedder leaves behind is not one that
    // resolves itself, so waiting only leaves the page on screen for longer.
    expect(calls, [false]);
  });

  testWidgets('the surface is asked back as soon as painting resumes', (
    tester,
  ) async {
    await pumpPainted(tester, isPainted: true);
    await tester.pump();

    await pumpPainted(tester, isPainted: false);
    await tester.pump();
    await pumpPainted(tester, isPainted: true);
    await tester.pump();

    expect(calls, [false, true]);
  });

  testWidgets('a container attaching while unpainted is hidden too', (
    tester,
  ) async {
    await pumpPainted(tester, isPainted: false);
    await tester.pump();

    // Nothing to hide yet: an unpainted view has no container in the Flutter
    // view hierarchy, and the one it eventually gets arrives visible.
    calls.clear();

    viewReady.add(true);
    await tester.pump();
    await tester.pump();

    expect(calls, contains(false));
  });

  testWidgets('a rebuild that changes nothing says nothing', (tester) async {
    await pumpPainted(tester, isPainted: true);
    await tester.pump();
    await pumpPainted(tester, isPainted: true);
    await tester.pump();

    expect(calls, isEmpty);
  });
}
