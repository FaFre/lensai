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
      return releaseReply?.future ?? Future<Object?>.value(<Object?>[null]);
    });
  }

  final TestDefaultBinaryMessenger messenger;
  final _backlog = Completer<List<Intent>>();

  int releaseCount = 0;
  Completer<Object?>? releaseReply;

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

  tearDown(() async {
    await receiver.dispose();
    host.tearDown();
  });

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

  test(
    'a stalled drain times out, opens live delivery and ignores a late reply',
    () async {
      final seen = <String?>[];
      final errors = <Object>[];
      receiver.events.listen(
        (intent) => seen.add(intent.data),
        onError: errors.add,
      );
      await host.sendLive(1, _link('https://example.com/queued'));

      await expectLater(
        receiver.pendingIntents,
        throwsA(isA<TimeoutException>()),
      );
      await host.sendLive(2, _link('https://example.com/live'));
      await pumpEventQueue();

      expect(seen, ['https://example.com/queued', 'https://example.com/live']);
      expect(errors.single, isA<TimeoutException>());

      host.answerDrain([_link('https://example.com/late')]);
      await pumpEventQueue();
      expect(seen, ['https://example.com/queued', 'https://example.com/live']);
    },
  );

  test(
    'a startup error is retained until the first listener attaches',
    () async {
      host._backlog.completeError(PlatformException(code: 'gone'));
      await pumpEventQueue();

      final errors = <Object>[];
      final seen = <String?>[];
      receiver.events.listen(
        (intent) => seen.add(intent.data),
        onError: errors.add,
      );
      await host.sendLive(1, _link('https://example.com/live'));
      await pumpEventQueue();

      expect(errors.single, isA<PlatformException>());
      expect(seen, ['https://example.com/live']);
    },
  );

  test(
    'only the newest 16 startup launches survive without a listener',
    () async {
      host.answerDrain();
      for (var i = 0; i < 20; i++) {
        await host.sendLive(i, _link('https://example.com/$i'));
      }

      final seen = <String?>[];
      receiver.events.listen((intent) => seen.add(intent.data));
      await pumpEventQueue();
      expect(seen, [for (var i = 4; i < 20; i++) 'https://example.com/$i']);
    },
  );

  test(
    'the merged backlog is bounded with newer live launches retained',
    () async {
      for (var i = 16; i < 20; i++) {
        await host.sendLive(i, _link('https://example.com/$i'));
      }
      host.answerDrain([
        for (var i = 0; i < 16; i++) _link('https://example.com/$i'),
      ]);
      await pumpEventQueue();

      final seen = <String?>[];
      receiver.events.listen((intent) => seen.add(intent.data));
      await pumpEventQueue();
      expect(seen, [for (var i = 4; i < 20; i++) 'https://example.com/$i']);
    },
  );

  test(
    'a replacement listener does not replay launches from its absence',
    () async {
      host.answerDrain();
      final first = receiver.events.listen((_) {});
      await first.cancel();
      await host.sendLive(1, _link('https://example.com/absent'));

      final seen = <String?>[];
      receiver.events.listen((intent) => seen.add(intent.data));
      await host.sendLive(2, _link('https://example.com/current'));
      await pumpEventQueue();
      expect(seen, ['https://example.com/current']);
    },
  );

  test(
    'cancelling during startup clears queued launches and skips late backlog',
    () async {
      final first = receiver.events.listen((_) {});
      await host.sendLive(1, _link('https://example.com/queued'));
      await first.cancel();
      host.answerDrain([_link('https://example.com/held')]);
      await pumpEventQueue();

      final seen = <String?>[];
      receiver.events.listen((intent) => seen.add(intent.data));
      await host.sendLive(2, _link('https://example.com/current'));
      await pumpEventQueue();
      expect(seen, ['https://example.com/current']);
    },
  );

  test('a stalled release cannot retain the event handler or stream', () async {
    host.answerDrain();
    host.releaseReply = Completer<Object?>();
    var closed = false;
    receiver.events.listen((_) {}, onDone: () => closed = true);
    final disposed = receiver.dispose();
    await pumpEventQueue();

    expect(host.releaseCount, 1);
    expect(await host.sendLive(1, _link('https://example.com/late')), isFalse);
    expect(closed, isTrue);
    await disposed.timeout(const Duration(seconds: 6));
  });

  test(
    'a consumer replaced before the drain still receives the backlog',
    () async {
      final first = receiver.events.listen((_) {});
      await host.sendLive(1, _link('https://example.com/queued'));
      await first.cancel();

      // The consumer was swapped out while the host was still answering, which
      // is what a rebuild of the bus looks like from here. The listener that
      // left took nothing with it: the queue had not opened yet.
      final seen = <String?>[];
      receiver.events.listen((intent) => seen.add(intent.data));
      await host.sendLive(2, _link('https://example.com/current'));
      host.answerDrain([_link('https://example.com/held')]);
      await pumpEventQueue();
      expect(seen, ['https://example.com/held', 'https://example.com/current']);
    },
  );

  test('the backlog is dropped only when no consumer is left', () async {
    final first = receiver.events.listen((_) {});
    await first.cancel();
    host.answerDrain([_link('https://example.com/held')]);
    await pumpEventQueue();

    // Answered into an empty room, so it is gone: a listener attaching now is
    // starting after the handover, not waiting for it.
    final seen = <String?>[];
    receiver.events.listen((intent) => seen.add(intent.data));
    await host.sendLive(1, _link('https://example.com/current'));
    await pumpEventQueue();
    expect(seen, ['https://example.com/current']);
  });

  test(
    'a late drain after disposal does not deliver or reclaim the channel',
    () async {
      await receiver.dispose();
      host.answerDrain([_link('https://example.com/late')]);
      await pumpEventQueue();
      expect(
        await host.sendLive(1, _link('https://example.com/live')),
        isFalse,
      );
      await receiver.dispose();
      expect(host.releaseCount, 1);
    },
  );
}
