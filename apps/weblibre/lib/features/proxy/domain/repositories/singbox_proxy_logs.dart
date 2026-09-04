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
import 'dart:collection';

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/proxy/data/models/proxy_log_message.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'singbox_proxy_logs.g.dart';

/// Cap to keep memory bounded. ~2KB per line × 2000 = ~4MB worst-case, which
/// is well within budget for a debugging surface.
const int _ringBufferCapacity = 2000;

/// Lower bound between two published snapshots. A chatty proxy can emit lines
/// far faster than the screen can render them, and every publication copies the
/// whole ring buffer, so coalescing bursts is free in terms of what the user
/// actually sees.
const _publishInterval = Duration(milliseconds: 100);

/// Ring buffer of proxy/Tor log lines.
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// It holds no provider state of its own: appending to a buffer thousands of
/// times a minute must not notify anybody, and materializing a snapshot is
/// [ProxyLogFeed]'s job, which only exists while something displays the logs.
@Riverpod(keepAlive: true)
class SingboxProxyLogs extends _$SingboxProxyLogs {
  final _buffer = Queue<ProxyLogMessage>();

  /// Ticks [changes]. Created with the notifier and never closed, deliberately.
  ///
  /// Riverpod reuses one notifier instance across rebuilds and runs the
  /// previous build's `onDispose` callbacks when it re-runs [build], so closing
  /// this in there closes it for the life of the process: the first rebuild — a
  /// new [singboxProxyClientProvider], or `torLogStream` rebuilding the Tor
  /// service — would leave [_notify] short-circuiting on `isClosed` and
  /// [ProxyLogFeed] listening to a stream that is already done, freezing the
  /// log screen on its seed snapshot with nothing logged anywhere.
  ///
  /// There is nothing to release either way: this provider is `keepAlive` and
  /// subscribed for the whole process, and a broadcast controller whose
  /// listeners have all cancelled holds nothing on.
  final _changes = StreamController<void>.broadcast();

  StreamSubscription<SingboxProxyLogMessage>? _singboxSubscription;
  StreamSubscription<TorLogMessage>? _torSubscription;

  // Deliberately outside `state`: routing the buffer through provider state
  // would notify every listener thousands of times a minute, which is exactly
  // what the side channel documented above exists to avoid.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  /// Buffer contents materialized on demand. Lets a freshly mounted screen
  /// paint the backlog in its first frame.
  List<ProxyLogMessage> get snapshot => List.unmodifiable(_buffer);

  // ignore: riverpod_lint/avoid_public_notifier_properties
  /// Ticks whenever [snapshot] would return something new.
  Stream<void> get changes => _changes.stream;

  void _append(ProxyLogMessage message) {
    _buffer.add(message);

    while (_buffer.length > _ringBufferCapacity) {
      _buffer.removeFirst();
    }

    _notify();
  }

  void clear() {
    _buffer.clear();
    _notify();
  }

  void _notify() {
    // Nothing is watching for most of the process's life — the buffer exists so
    // that a screen opened *later* has a backlog, and it fills at trace level
    // thousands of times a minute. A stream event per append when nobody is
    // there to receive it is a microtask per append for no one.
    if (_changes.isClosed || !_changes.hasListener) {
      return;
    }

    _changes.add(null);
  }

  @override
  void build() {
    final client = ref.watch(singboxProxyClientProvider);
    final torLogs = torLogStream(ref);

    _singboxSubscription = client.logStream.listen(
      (message) => _append(ProxyLogMessage.fromSingbox(message)),
    );
    _torSubscription = torLogs.listen(
      (message) => _append(ProxyLogMessage.fromTor(message)),
    );

    ref.onDispose(() {
      unawaited(_singboxSubscription?.cancel());
      unawaited(_torSubscription?.cancel());
    });
  }
}

/// Throttled snapshots of [SingboxProxyLogs]' ring buffer, most-recent-last.
///
/// Auto-disposed, and that is the whole point: copying up to
/// [_ringBufferCapacity] entries is only worth doing while something is
/// actually showing them, and tying that to the provider's own lifetime keeps
/// it out of a widget life-cycle. Publishing from `useEffect` — whose body runs
/// during build — wrote provider state mid-frame, which Riverpod refuses.
@riverpod
class ProxyLogFeed extends _$ProxyLogFeed {
  Timer? _publishTimer;

  @override
  List<ProxyLogMessage> build() {
    final logs = ref.watch(singboxProxyLogsProvider.notifier);

    final subscription = logs.changes.listen((_) {
      if (_publishTimer?.isActive ?? false) {
        return;
      }

      _publishTimer = Timer(_publishInterval, () {
        if (!ref.mounted) {
          return;
        }

        state = logs.snapshot;
      });
    });

    ref.onDispose(() {
      _publishTimer?.cancel();
      unawaited(subscription.cancel());
    });

    // Seeded from the live buffer so the backlog paints in the first frame
    // instead of after the first throttled publication.
    return logs.snapshot;
  }
}
