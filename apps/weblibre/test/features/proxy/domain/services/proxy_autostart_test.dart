// The notifier subclasses below are test doubles: recording what a collaborator
// was asked to do is their whole purpose, and mutable public fields are how the
// tests read it back.
// ignore_for_file: riverpod_lint/avoid_public_notifier_properties

import 'dart:async';

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_autostart.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts only the profiles flagged for autostart, in one call', () async {
    final runtimeRepository = _FakeRuntimeRepository();
    final container = _container(
      profiles: [
        _profile(id: 'profile-1', autostart: true),
        _profile(id: 'profile-2'),
        _profile(id: 'profile-3', autostart: true),
      ],
      runtimeRepository: runtimeRepository,
    );
    addTearDown(container.dispose);

    await container.read(proxyAutostartServiceProvider.notifier).run();

    expect(runtimeRepository.startCalls, [
      ['profile-1', 'profile-3'],
    ]);
  });

  test('leaves the runtime untouched when nothing is flagged', () async {
    final runtimeRepository = _FakeRuntimeRepository();
    final container = _container(
      profiles: [_profile(id: 'profile-1')],
      runtimeRepository: runtimeRepository,
    );
    addTearDown(container.dispose);

    await container.read(proxyAutostartServiceProvider.notifier).run();

    expect(runtimeRepository.startCalls, isEmpty);
  });

  test('pendingStartFor exposes the in-flight start, then clears', () async {
    final runtimeRepository = _FakeRuntimeRepository(holdStart: true);
    final container = _container(
      profiles: [_profile(id: 'profile-1', autostart: true)],
      runtimeRepository: runtimeRepository,
    );
    addTearDown(container.dispose);

    final service = container.read(proxyAutostartServiceProvider.notifier);
    final run = service.run();
    await pumpEventQueue();

    expect(
      service.pendingStartFor(const SingboxProxyConnectionId('profile-1')),
      isNotNull,
    );
    expect(
      service.pendingStartFor(const SingboxProxyConnectionId('profile-2')),
      isNull,
    );

    runtimeRepository.completeStart();
    await run;

    expect(
      service.pendingStartFor(const SingboxProxyConnectionId('profile-1')),
      isNull,
    );
  });

  test('pendingStartFor covers the lookup, before the set is known', () async {
    final lookupGate = Completer<void>();
    final container = _container(
      profiles: [_profile(id: 'profile-1', autostart: true)],
      torAutostart: true,
      lookupGate: lookupGate,
    );
    addTearDown(container.dispose);

    final service = container.read(proxyAutostartServiceProvider.notifier);
    final run = service.run();

    // Nothing has been read from the database yet: the service must still
    // report both connections as starting, or an early restored tab gets the
    // manual "start proxy?" prompt.
    expect(
      service.pendingStartFor(const SingboxProxyConnectionId('profile-1')),
      isNotNull,
    );
    expect(service.pendingStartFor(const TorProxyConnectionId()), isNotNull);

    lookupGate.complete();
    await run;
  });

  test(
    'a profile that is not flagged resolves once the lookup lands',
    () async {
      final lookupGate = Completer<void>();
      final runtimeRepository = _FakeRuntimeRepository(holdStart: true);
      final container = _container(
        profiles: [_profile(id: 'profile-1', autostart: true)],
        runtimeRepository: runtimeRepository,
        lookupGate: lookupGate,
      );
      addTearDown(container.dispose);

      final service = container.read(proxyAutostartServiceProvider.notifier);
      final run = service.run();

      final pending = service.pendingStartFor(
        const SingboxProxyConnectionId('profile-2'),
      );
      expect(pending, isNotNull);

      lookupGate.complete();

      // profile-2 is not part of this startup, so its wait ends with the lookup
      // rather than behind profile-1's still-running start.
      await pending!.timeout(const Duration(seconds: 5));
      expect(runtimeRepository.startCalls, hasLength(1));

      runtimeRepository.completeStart();
      await run;
    },
  );

  test('a failing start is contained instead of breaking startup', () async {
    final runtimeRepository = _FakeRuntimeRepository(failStart: true);
    final container = _container(
      profiles: [_profile(id: 'profile-1', autostart: true)],
      runtimeRepository: runtimeRepository,
    );
    addTearDown(container.dispose);

    final service = container.read(proxyAutostartServiceProvider.notifier);

    await expectLater(service.run(), completes);
    expect(
      service.pendingStartFor(const SingboxProxyConnectionId('profile-1')),
      isNull,
    );
  });

  test('starts Tor only when its autostart setting is on', () async {
    final startedWithoutAutostart = _FakeStartProxyController();
    final withoutAutostart = _container(
      profiles: const [],
      startProxyController: startedWithoutAutostart,
    );
    addTearDown(withoutAutostart.dispose);

    await withoutAutostart.read(proxyAutostartServiceProvider.notifier).run();
    expect(startedWithoutAutostart.startCount, 0);

    final startedWithAutostart = _FakeStartProxyController();
    final withAutostart = _container(
      profiles: const [],
      torAutostart: true,
      startProxyController: startedWithAutostart,
    );
    addTearDown(withAutostart.dispose);

    await withAutostart.read(proxyAutostartServiceProvider.notifier).run();
    expect(startedWithAutostart.startCount, 1);
    // The connect banner would outlive a bootstrap finishing before the
    // browser view mounts, so autostart connects silently.
    expect(startedWithAutostart.notificationRequests, [false]);
  });
}

ProviderContainer _container({
  required List<ProxyProfile> profiles,
  bool torAutostart = false,
  _FakeRuntimeRepository? runtimeRepository,
  _FakeStartProxyController? startProxyController,
  Completer<void>? lookupGate,
}) {
  return ProviderContainer(
    overrides: [
      singboxProxyProfilesRepositoryProvider.overrideWith(
        () => _FakeProfilesRepository(profiles, lookupGate: lookupGate),
      ),
      singboxProxyRuntimeRepositoryProvider.overrideWith(
        () => runtimeRepository ?? _FakeRuntimeRepository(),
      ),
      torSettingsRepositoryProvider.overrideWith(
        () => _FakeTorSettingsRepository(
          autostart: torAutostart,
          lookupGate: lookupGate,
        ),
      ),
      startProxyControllerProvider.overrideWith(
        () => startProxyController ?? _FakeStartProxyController(),
      ),
    ],
  );
}

ProxyProfile _profile({required String id, bool autostart = false}) {
  final createdAt = DateTime(2026);
  return ProxyProfile(
    id: id,
    name: id,
    type: SingboxProxyProfileType.customOutbound,
    configJson: '{"type":"socks"}',
    autostart: autostart,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final List<ProxyProfile> profiles;

  /// Holds the autostart lookup open so a test can inspect the service before
  /// it knows which profiles are flagged.
  final Completer<void>? lookupGate;

  _FakeProfilesRepository(this.profiles, {this.lookupGate});

  @override
  Future<List<ProxyProfile>> fetchAutostartProfiles() async {
    await lookupGate?.future;
    return profiles.where((profile) => profile.autostart).toList();
  }

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}

class _FakeRuntimeRepository extends SingboxProxyRuntimeRepository {
  final bool failStart;

  /// Holds [startProfiles] open until [completeStart], so a test can observe
  /// the service while a start is still in flight.
  final bool holdStart;
  final startCalls = <List<String>>[];
  final _gate = Completer<void>();

  _FakeRuntimeRepository({this.failStart = false, this.holdStart = false});

  void completeStart() {
    if (!_gate.isCompleted) _gate.complete();
  }

  @override
  Future<SingboxProxyRuntimeState> startProfiles(
    List<String> profileIds, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    startCalls.add(profileIds);
    await Future<void>.delayed(Duration.zero);
    if (failStart) {
      throw StateError('start failed');
    }
    if (holdStart) {
      await _gate.future;
    }
    return SingboxProxyRuntimeState(
      status: SingboxProxyRuntimeStatus.running,
      endpoints: const [],
    );
  }

  @override
  Future<SingboxProxyRuntimeState> build() async {
    return SingboxProxyRuntimeState(
      status: SingboxProxyRuntimeStatus.stopped,
      endpoints: const [],
    );
  }
}

class _FakeTorSettingsRepository extends TorSettingsRepository {
  final bool autostart;
  final Completer<void>? lookupGate;

  _FakeTorSettingsRepository({required this.autostart, this.lookupGate});

  TorSettings get _settings => TorSettings.withDefaults(autostart: autostart);

  @override
  Future<TorSettings> fetchSettings() async {
    await lookupGate?.future;
    return _settings;
  }

  @override
  Stream<TorSettings> build() => Stream.value(_settings);
}

class _FakeStartProxyController extends StartProxyController {
  int startCount = 0;
  final notificationRequests = <bool>[];

  @override
  Future<void> startProxy({bool showNotification = true}) async {
    startCount++;
    notificationRequests.add(showNotification);
  }

  @override
  bool build() => false;
}
