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
// The notifier subclasses below are test doubles: recording what a collaborator
// was asked to do is their whole purpose, and mutable public fields are how the
// tests read it back.
// ignore_for_file: riverpod_lint/avoid_public_notifier_properties

import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_demand.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a launch waiting now is served before anything else arrives', () async {
    const profileId = SingboxProxyConnectionId('profile-1');
    final harness = _Harness(
      pending: _demand('context-a', [profileId.encode()]),
    );
    addTearDown(harness.dispose);

    await harness.run();

    expect(harness.runtime.startCalls, [
      ['profile-1'],
    ]);
  });

  /// The head-of-line case. A Tor bootstrap outlasts the few seconds a launch
  /// spends waiting, so a loop that awaited one would leave the next launch's
  /// demand unread, unpublished and unstarted until it was over — the launch
  /// giving up on a proxy nothing had begun to bring up.
  test('a slow start does not hold up the launch behind it', () async {
    const profileId = SingboxProxyConnectionId('profile-1');
    final harness = _Harness();
    addTearDown(harness.dispose);
    // Both starts are held open, so the two claims are observable at once.
    harness.runtime.startGate = Completer<void>();

    await harness.run();

    harness.deliver(
      _demand('context-a', [const TorProxyConnectionId().encode()]),
    );
    await pumpEventQueue();
    expect(harness.tor.startCount, 1, reason: 'the Tor bootstrap has begun');
    expect(harness.tor.completer.isCompleted, isFalse);

    harness.deliver(_demand('context-b', [profileId.encode()]));
    await pumpEventQueue();

    expect(harness.runtime.startCalls, [
      ['profile-1'],
    ], reason: 'the second launch is served while Tor is still bootstrapping');
    expect(harness.container.read(proxyDemandServiceProvider), {
      const TorProxyConnectionId().encode(),
      profileId.encode(),
    }, reason: 'both launches are published as still coming up');

    harness.runtime.startGate!.complete();
    harness.tor.completer.complete();
    await pumpEventQueue();

    expect(harness.container.read(proxyDemandServiceProvider), isEmpty);
  });

  /// The runtime takes its whole profile list at once, so serving two launches
  /// separately restarts the first one's backend — dropping the port its page
  /// was just given — to bring the second one up.
  test(
    'launches that arrive together reach the runtime in one start',
    () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      harness.runtime.startGate = Completer<void>();

      await harness.run();

      harness.deliver(_demand('context-a', ['singbox:profile-1']));
      await pumpEventQueue();
      harness.deliver(_demand('context-b', ['singbox:profile-2']));
      harness.deliver(_demand('context-c', ['singbox:profile-3']));
      await pumpEventQueue();

      harness.runtime.startGate!.complete();
      await pumpEventQueue();

      expect(harness.runtime.startCalls, [
        ['profile-1'],
        ['profile-2', 'profile-3'],
      ]);
      expect(harness.container.read(proxyDemandServiceProvider), isEmpty);
    },
  );

  /// Two containers can name the same backend. The first launch settling must
  /// not withdraw the second one's claim while its start is still in flight.
  test(
    'a shared backend stays claimed until the last launch settles',
    () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      harness.tor.autoComplete = false;

      await harness.run();

      harness.deliver(
        _demand('context-a', [const TorProxyConnectionId().encode()]),
      );
      harness.deliver(
        _demand('context-b', [const TorProxyConnectionId().encode()]),
      );
      await pumpEventQueue();

      expect(
        harness.tor.startCount,
        1,
        reason: 'the second launch joins the first',
      );
      expect(harness.container.read(proxyDemandServiceProvider), {
        const TorProxyConnectionId().encode(),
      });

      harness.tor.completer.complete();
      await pumpEventQueue();

      expect(harness.container.read(proxyDemandServiceProvider), isEmpty);
    },
  );

  test('a demand naming nothing this profile knows is dropped', () async {
    final harness = _Harness(pending: _demand('context-a', ['nonsense']));
    addTearDown(harness.dispose);

    await harness.run();

    expect(harness.runtime.startCalls, isEmpty);
    expect(harness.tor.startCount, 0);
    expect(
      harness.container.read(proxyDemandServiceProvider),
      isEmpty,
      reason: 'resolved out of "not asked yet", but claiming nothing',
    );
  });

  test('nothing is claimed until native has been asked', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    expect(
      harness.container.read(proxyDemandServiceProvider),
      isNull,
      reason: 'null is what holds every endpoint-less route open',
    );

    await harness.run();

    expect(harness.container.read(proxyDemandServiceProvider), isEmpty);
  });
}

GeckoRoutingDemand _demand(String contextId, List<String> proxyIds) =>
    GeckoRoutingDemand(contextId: contextId, proxyIds: proxyIds);

class _Harness {
  _Harness({GeckoRoutingDemand? pending})
    : service = _FakeContainerProxyService(pending) {
    container = ProviderContainer(
      overrides: [
        geckoContainerProxyServiceProvider.overrideWithValue(service),
        singboxProxyRuntimeRepositoryProvider.overrideWith(() => runtime),
        startProxyControllerProvider.overrideWith(() => tor),
      ],
    );
  }

  final _FakeContainerProxyService service;
  final runtime = _FakeSingboxRuntimeRepository();
  final tor = _FakeStartProxyController();
  late final ProviderContainer container;

  /// Runs the service up to the point where it is waiting on native, which is
  /// where it spends its life.
  Future<void> run() async {
    unawaited(container.read(proxyDemandServiceProvider.notifier).run());
    await pumpEventQueue();
  }

  void deliver(GeckoRoutingDemand demand) => service.deliver(demand);

  void dispose() => container.dispose();
}

class _FakeContainerProxyService implements GeckoContainerProxyService {
  _FakeContainerProxyService(GeckoRoutingDemand? pending) {
    if (pending != null) _queue.add(pending);
  }

  /// Buffered, like the native side: a demand recorded while the app half is
  /// between reads is queued, not dropped.
  final _queue = <GeckoRoutingDemand>[];
  Completer<GeckoRoutingDemand>? _waiting;

  void deliver(GeckoRoutingDemand demand) {
    final waiting = _waiting;
    if (waiting != null) {
      _waiting = null;
      waiting.complete(demand);
      return;
    }
    _queue.add(demand);
  }

  @override
  Future<GeckoRoutingDemand?> takeRoutingDemand() async =>
      _queue.isEmpty ? null : _queue.removeAt(0);

  @override
  Future<GeckoRoutingDemand> nextRoutingDemand() {
    if (_queue.isNotEmpty) return Future.value(_queue.removeAt(0));

    return (_waiting = Completer<GeckoRoutingDemand>()).future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSingboxRuntimeRepository extends SingboxProxyRuntimeRepository {
  final startCalls = <List<String>>[];

  /// Held open to keep a start in flight while the test drives more demands.
  Completer<void>? startGate;

  @override
  Future<SingboxProxyRuntimeState> build() async => _stopped;

  @override
  Future<SingboxProxyRuntimeState> ensureProfilesStarted(
    List<String> profileIds, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    startCalls.add(profileIds);
    await startGate?.future;
    return _stopped;
  }

  static final _stopped = SingboxProxyRuntimeState(
    status: SingboxProxyRuntimeStatus.stopped,
    endpoints: const [],
  );
}

class _FakeStartProxyController extends StartProxyController {
  int startCount = 0;
  bool autoComplete = false;
  Completer<void> completer = Completer<void>();

  @override
  bool build() => false;

  @override
  Future<void> startProxy({bool showNotification = true}) {
    startCount += 1;
    if (autoComplete) return Future<void>.value();
    return completer.future;
  }
}
