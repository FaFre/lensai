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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_intent_receiver/src/intent_receiver.dart';
import 'package:simple_intent_receiver/src/pigeons/intent.g.dart';

const _takePendingChannel =
    'dev.flutter.pigeon.simple_intent_receiver.IntentHost.takePendingIntents';
const _releaseChannel =
    'dev.flutter.pigeon.simple_intent_receiver.IntentHost.releaseDelivery';
const _eventChannel =
    'dev.flutter.pigeon.simple_intent_receiver.IntentEvents.onIntentReceived';

Intent _link(String url) => Intent(
  fromPackageName: null,
  action: 'android.intent.action.VIEW',
  data: url,
  categories: const [],
  mimeType: null,
  extra: const {},
);

/// The host half, driven by the test: it answers `takePendingIntents` only when
/// the test says so, which is what makes the ordering between the backlog and a
/// live launch observable at all.
class _FakeHost {
  _FakeHost(this.messenger) {
    _mock(
      _takePendingChannel,
      (_) => _backlog.future.then((b) => <Object?>[b]),
    );
    _mock(_releaseChannel, (_) {
      releaseCount++;
      return Future<Object?>.value(<Object?>[null]);
    });
  }

  final TestDefaultBinaryMessenger messenger;
  final _backlog = Completer<List<Intent>>();

  int releaseCount = 0;

  void _mock(String name, Future<Object?> Function(Object?) handler) {
    messenger.setMockDecodedMessageHandler<Object?>(
      BasicMessageChannel<Object?>(name, IntentHost.pigeonChannelCodec),
      handler,
    );
  }

  /// Answers the drain the receiver issued on construction.
  void answerDrain([List<Intent> backlog = const []]) =>
      _backlog.complete(backlog);

  /// Delivers a live intent the way the plugin would, over the event channel.
  ///
  /// Returns whether anything answered — `null` means no handler is registered,
  /// which is how "Dart has given the channel back" looks from the host side.
  Future<bool> sendLive(int sequence, Intent intent) async {
    final encoded = IntentEvents.pigeonChannelCodec.encodeMessage(<Object?>[
      sequence,
      intent,
    ]);
    final reply = await messenger.handlePlatformMessage(
      _eventChannel,
      encoded,
      null,
    );
    return reply != null;
  }

  void tearDown() {
    for (final name in const [_takePendingChannel, _releaseChannel]) {
      messenger.setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(name, IntentHost.pigeonChannelCodec),
        null,
      );
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDefaultBinaryMessenger messenger;
  late _FakeHost host;
  late IntentReceiver receiver;

  setUp(() {
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    host = _FakeHost(messenger);
    receiver = IntentReceiver.setUp(binaryMessenger: messenger);
  });

  tearDown(() => host.tearDown());

  test(
    'the backlog reaches a listener that attaches after it arrived',
    () async {
      host.answerDrain([_link('https://example.com/held')]);
      await pumpEventQueue();

      // Nobody was listening when the host answered. A broadcast stream would
      // have dropped it; this one still owes it.
      expect(
        await receiver.events.first,
        isA<Intent>().having((i) => i.data, 'data', 'https://example.com/held'),
      );
    },
  );

  test(
    'a live intent that overtakes the backlog is still delivered after it',
    () async {
      final seen = <String?>[];
      receiver.events.listen((intent) => seen.add(intent.data));

      // The host flipped to ready and sent this before the reply carrying the
      // backlog got here — the two travel on different channels, so nothing
      // guarantees which lands first.
      await host.sendLive(1, _link('https://example.com/live'));
      await pumpEventQueue();
      expect(seen, isEmpty, reason: 'nothing may go out ahead of the backlog');

      host.answerDrain([_link('https://example.com/held')]);
      await pumpEventQueue();

      expect(seen, ['https://example.com/held', 'https://example.com/live']);
    },
  );

  test('a live intent arriving before anyone listens is not dropped', () async {
    host.answerDrain();
    await host.sendLive(1, _link('https://example.com/live'));
    await pumpEventQueue();

    expect(
      await receiver.events.first,
      isA<Intent>().having((i) => i.data, 'data', 'https://example.com/live'),
    );
  });

  test('replayed sequence numbers are not delivered twice', () async {
    final seen = <String?>[];
    receiver.events.listen((intent) => seen.add(intent.data));
    host.answerDrain();

    await host.sendLive(2, _link('https://example.com/a'));
    await host.sendLive(1, _link('https://example.com/stale'));
    await host.sendLive(3, _link('https://example.com/b'));
    await pumpEventQueue();

    expect(seen, ['https://example.com/a', 'https://example.com/b']);
  });

  test('a host that cannot answer still lets live intents through', () async {
    final seen = <String?>[];
    receiver.events.listen((intent) => seen.add(intent.data), onError: (_) {});

    host._backlog.completeError(PlatformException(code: 'gone'));
    await pumpEventQueue();

    await host.sendLive(1, _link('https://example.com/live'));
    await pumpEventQueue();

    expect(seen, ['https://example.com/live']);
  });

  test('dispose hands the channel back before letting go of it', () async {
    host.answerDrain();
    receiver.events.listen((_) {});
    await pumpEventQueue();

    expect(await host.sendLive(1, _link('https://example.com/a')), isTrue);

    await receiver.dispose();

    // The host was told to stop sending...
    expect(host.releaseCount, 1);
    // ...and the handler it would have sent to is gone, so a launch in flight
    // cannot land in a closed sink and disappear.
    expect(await host.sendLive(2, _link('https://example.com/b')), isFalse);
  });
}
