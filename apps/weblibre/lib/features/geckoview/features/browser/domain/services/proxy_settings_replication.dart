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

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_pref_baseline.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_start_expectation.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

part 'proxy_settings_replication.g.dart';

/// How long to wait before retrying a snapshot that failed to install.
const _retryDelay = Duration(seconds: 1);

/// How often to re-check that the extension still holds the snapshot this
/// notifier believes it installed.
///
/// Everything else here is edge-driven: a snapshot is pushed when its inputs
/// change. The extension can lose one without any input changing — its
/// background script restarts and the native replay fails, or its
/// acknowledgement never arrives — and an extension with no snapshot blocks
/// every request. Without a probe that state persists until the user happens to
/// change a container setting, or restarts the app.
const _readinessProbeInterval = Duration(seconds: 30);

/// The routing state to install, or null while the inputs that decide it are
/// still loading.
///
/// Waiting is what keeps startup fail-closed. Every routing input defaults to
/// empty while its stream loads, and an empty routing state reads as "every
/// container connects directly" — pushing that would tell the extension to
/// unproxy the very containers it is meant to protect, for as long as it takes
/// the databases to answer. Until then no snapshot exists, the extension holds
/// none, and it blocks rather than guesses.
///
/// Proxy *endpoints* are deliberately not waited on. A relation whose backend
/// is not running yet stays in the snapshot with no matching endpoint, which
/// the extension blocks — so a slow Tor bootstrap costs the containers that use
/// Tor their connectivity, not the whole browser its routing. What the snapshot
/// does carry is whether such an endpoint is still *coming*
/// ([ProxyStartExpectation]), which is the difference between blocking a
/// container and holding its requests for the second it takes its backend to
/// finish starting.
///
/// Waiting forever is a different matter: see [containerRoutingInputProviders].
@Riverpod(keepAlive: true)
ContainerRoutingSnapshot? containerRoutingSnapshot(Ref ref) {
  // The `...WithDefaults` view substitutes defaults while the row loads, which
  // resolves to "no global proxy" — the exact misconfiguration this guards.
  final routingSettings = ref.watch(proxyRoutingSettingsRepositoryProvider);
  final containers = ref.watch(watchContainersWithCountProvider);
  final isolationContexts = ref.watch(watchIsolatedContextContainerMapProvider);
  final strictContexts = ref.watch(watchStrictContextAssignmentsProvider);
  final siteAssignments = ref.watch(watchAllAssignedSitesProvider);

  final inputs = <String, AsyncValue<Object?>>{
    _routingSettingsInput: routingSettings,
    _containersInput: containers,
    _isolationContextsInput: isolationContexts,
    _strictContextsInput: strictContexts,
    _siteAssignmentsInput: siteAssignments,
  };

  final unresolved = [
    for (final entry in inputs.entries)
      if (!entry.value.hasValue) entry,
  ];

  if (unresolved.isNotEmpty) {
    // Trace every change in the unresolved set. A gate that logs this once and
    // never again is not waiting on its inputs — it is not being recomputed at
    // all, which is a wiring fault rather than a database one, and the two look
    // identical from the recovery timer.
    final signature = unresolved.map((entry) => entry.key).join(',');
    if (signature != _lastUnresolvedSignature) {
      _lastUnresolvedSignature = signature;
      logger.d('Container routing gate still waiting on: $signature');
    }

    // An input that *errored* is the one failure here that never resolves on
    // its own, and it is otherwise completely silent: the error leaves
    // `hasValue` false, this returns null, and `ProviderObserver.providerDidFail`
    // only reports build failures, not errors a stream emits. Without this the
    // symptom is a browser that blocks every request with nothing in the log
    // saying why.
    for (final entry in unresolved) {
      final value = entry.value;
      if (value.hasError) {
        logger.e(
          'Container routing input "${entry.key}" failed; until it produces a '
          'value the extension blocks every request',
          error: value.error,
          stackTrace: value.stackTrace,
        );
      }
    }

    return null;
  }

  final singboxProfiles =
      ref.watch(singboxProxyProfilesRepositoryProvider).value ?? const [];

  final resolvedRoutingSettings = ref.watch(
    proxyRoutingSettingsWithDefaultsProvider,
  );

  final singboxRuntime = ref.watch(singboxProxyRuntimeRepositoryProvider).value;

  return computeContainerRoutingSnapshot(
    // `usableSocksPort`, not the raw port: Tor publishes one long before its
    // bootstrap reaches 100%, and an endpoint in the snapshot is a promise that
    // traffic sent there will be carried. Publishing it early would also end
    // the extension's wait — the relation would resolve to a live proxy — and
    // spend it on a port that cannot answer yet.
    torSocksPort: ref.watch(torProxyServiceProvider).usableSocksPort,
    // Endpoints only while the runtime says it is running. A stopped, stopping
    // or errored runtime can still be carrying the addresses of its last run,
    // and those name loopback ports nothing owns any more — or that something
    // else has since taken. Dropping them blocks the relation instead, which is
    // the fail-closed answer.
    singboxEndpoints:
        singboxRuntime?.status == SingboxProxyRuntimeStatus.running
        ? singboxRuntime!.endpoints
        : const [],
    singboxProfileNames: {
      for (final profile in singboxProfiles)
        profile.proxyConnectionId: profile.name,
    },
    routingSettings: resolvedRoutingSettings,
    startExpectation: ref.watch(proxyStartExpectationProvider),
    // Carried by the same settings partition as the rest of routing, so it is
    // already covered by the gate above.
    isolationContextRoutes: resolvedRoutingSettings.isolationContextRoutes,
    containers: containers.requireValue,
    isolationContextContainers: isolationContexts.requireValue,
    siteAssignments: siteAssignments.requireValue,
    strictContexts: strictContexts.requireValue,
    onConflict: logger.w,
  );
}

/// Exactly the inputs [containerRoutingSnapshot] refuses to produce a snapshot
/// without.
///
/// Each of them is a single point of failure for the whole browser's
/// connectivity: one that ends in an error never produces a first value, so the
/// gate above never opens and the extension blocks every request. Nothing
/// re-subscribes a drift stream that ended, which would make one failed query
/// at startup an unrecoverable browser for the lifetime of the process. Listed
/// here so recovery can re-create precisely what the gate waits on — an input
/// added to one and not the other is a bug this pairing is meant to make
/// obvious.
final containerRoutingInputProviders = <ProviderOrFamily>[
  proxyRoutingSettingsRepositoryProvider,
  watchContainersWithCountProvider,
  watchIsolatedContextContainerMapProvider,
  watchStrictContextAssignmentsProvider,
  watchAllAssignedSitesProvider,
];

/// Last set of unresolved inputs reported, so the trace only fires on change.
String? _lastUnresolvedSignature;

const _routingSettingsInput = 'proxyRoutingSettings';
const _containersInput = 'containers';
const _isolationContextsInput = 'isolationContexts';
const _strictContextsInput = 'strictContexts';
const _siteAssignmentsInput = 'siteAssignments';

/// Which gate inputs have still not produced a value.
///
/// Reads rather than watches: [containerRoutingSnapshot] already subscribes
/// every one of these whenever this is called, so this only samples what is
/// there and adds no dependency of its own.
List<String> unresolvedContainerRoutingInputs(Ref ref) => [
  if (!ref.read(proxyRoutingSettingsRepositoryProvider).hasValue)
    _routingSettingsInput,
  if (!ref.read(watchContainersWithCountProvider).hasValue) _containersInput,
  if (!ref.read(watchIsolatedContextContainerMapProvider).hasValue)
    _isolationContextsInput,
  if (!ref.read(watchStrictContextAssignmentsProvider).hasValue)
    _strictContextsInput,
  if (!ref.read(watchAllAssignedSitesProvider).hasValue) _siteAssignmentsInput,
];

/// How long the inputs may stay unresolved before they are re-created.
///
/// Longer than a cold start's database work, because re-creating them mid-load
/// only restarts that work.
const _inputRecoveryDelay = Duration(seconds: 15);

/// Ceiling for the backoff between recovery attempts. Retrying forever is the
/// point — the alternative is a browser that stays unusable until restarted —
/// but a database that is genuinely broken should not be hammered.
const _maxInputRecoveryDelay = Duration(minutes: 2);

/// Single serialised writer that installs [containerRoutingSnapshotProvider]
/// into Gecko's proxy extension.
///
/// Side-effect-only and `keepAlive`, mounted from app startup rather than from
/// a widget: routing must not depend on any part of the UI being built, and
/// must survive it being torn down.
@Riverpod(keepAlive: true)
class ProxySettingsReplication extends _$ProxySettingsReplication {
  final _pushLock = Lock();

  /// Most recent snapshot to install, coalescing anything that arrives while a
  /// push is in flight. Genuinely nullable (nothing pushed yet).
  // ignore: use_late_for_private_fields_and_variables
  ContainerRoutingSnapshot? _latest;
  var _pushDirty = false;
  Timer? _readinessProbe;
  Timer? _inputRecovery;

  Future<void> _queuePush(ContainerRoutingSnapshot snapshot) async {
    _latest = snapshot;
    _pushDirty = true;

    // Every caller queues on the lock, including one that arrives while a push
    // is in flight. Returning early on `inLock` instead would drop a snapshot
    // that lands between the holder's last `_pushDirty` check and its release:
    // it sets the flag, sees the lock held, and nothing ever drains it. A
    // waiter that finds the flag already cleared simply falls through.
    await _pushLock.synchronized(() async {
      while (_pushDirty) {
        _pushDirty = false;
        final pending = _latest!;
        final requiresProxy = routingRequiresProxy(pending);
        final baseline = ref.read(proxyPrefBaselineProvider.notifier);
        try {
          // Arming has to happen before the routing that depends on it exists.
          // Disarming deliberately does not wait for the push: a snapshot that
          // needs no proxy leaves the prefs protecting nothing, and gating them
          // on a push that may never land (an extension that fails to install
          // never acknowledges one) would stand a browser up on a dead proxy
          // pref on every launch, with no in-app way back.
          await baseline.setRequired(required: requiresProxy);

          await ref
              .read(containerProxyRepositoryProvider.notifier)
              .applySnapshot(pending);

          _startReadinessProbe();
        } catch (error, stackTrace) {
          // Until this lands the extension blocks everything, so retrying is
          // about restoring connectivity, not about closing a leak.
          logger.w(
            'Failed to install container routing snapshot; will retry',
            error: error,
            stackTrace: stackTrace,
          );
          _pushDirty = true;
          await Future<void>.delayed(_retryDelay);
        }
      }
    });
  }

  /// Re-creates the routing inputs if they still have not produced a snapshot,
  /// then schedules the next attempt with a longer delay.
  ///
  /// Only ever runs while [containerRoutingSnapshotProvider] is null, i.e. while
  /// the extension is blocking everything anyway, so the churn of invalidating
  /// providers other parts of the app watch costs nothing that is not already
  /// broken.
  void _scheduleInputRecovery(Duration delay) {
    _inputRecovery?.cancel();
    _inputRecovery = Timer(delay, () {
      if (!ref.mounted) return;
      if (ref.read(containerRoutingSnapshotProvider) != null) return;

      logger.e(
        'Container routing inputs have not resolved after ${delay.inSeconds}s; '
        'all traffic is blocked. Still unresolved: '
        '${unresolvedContainerRoutingInputs(ref).join(', ')}. Re-creating them.',
      );

      for (final provider in containerRoutingInputProviders) {
        ref.invalidate(provider);
      }

      final next = delay * 2;
      _scheduleInputRecovery(
        next > _maxInputRecoveryDelay ? _maxInputRecoveryDelay : next,
      );
    });
  }

  /// Starts probing once something has actually been installed — before that
  /// there is nothing to compare the extension against.
  void _startReadinessProbe() {
    _readinessProbe ??= Timer.periodic(
      _readinessProbeInterval,
      (_) => unawaited(_probeReadiness()),
    );
  }

  Future<void> _probeReadiness() async {
    final pending = _latest;
    // A push already in flight will settle readiness on its own, and its own
    // failures are retried by the loop.
    if (pending == null || _pushLock.locked) return;

    final bool ready;
    try {
      ready = await ref
          .read(containerProxyRepositoryProvider.notifier)
          .isRoutingReady();
    } catch (error, stackTrace) {
      logger.w(
        'Failed to read container routing status',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    if (ready) return;

    // The extension is holding no snapshot, so it is blocking everything.
    logger.w('Container routing was lost by the extension; reinstalling');
    await _queuePush(pending);
  }

  @override
  void build() {
    ref.onDispose(() {
      _readinessProbe?.cancel();
      _readinessProbe = null;
      _inputRecovery?.cancel();
      _inputRecovery = null;
    });

    _scheduleInputRecovery(_inputRecoveryDelay);

    ref.listen(
      fireImmediately: true,
      containerRoutingSnapshotProvider,
      (previous, next) {
        if (next == null) return;

        // The inputs answered, so the gate is open for good: an [AsyncValue]
        // that has produced a value keeps `hasValue` true even if its stream
        // later errors.
        _inputRecovery?.cancel();
        _inputRecovery = null;

        unawaited(_queuePush(next));
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error computing container routing snapshot',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }
}
