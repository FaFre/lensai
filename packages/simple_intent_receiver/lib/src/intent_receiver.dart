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
import 'package:simple_intent_receiver/src/pigeons/intent.g.dart';

/// The Dart end of the intent channel, and the single consumer of it.
///
/// The bounded startup backlog and subsequent live launches leave through
/// [events] in host order, provided the startup drain answers before its timeout.
/// Two things have to be true for that:
///
/// * **Nothing may be handed over before the backlog is.** The backlog arrives
///   as the reply to one call and live launches as calls on another channel, so
///   their arrival order here is not something to build on. Everything is
///   queued and released together instead.
/// * **Nothing may be handed over before someone is listening.** A broadcast
///   stream with no subscriber drops what is added to it, silently, which is
///   the same disappearance this class was written to stop.
///
/// So [events] is single-consumer by contract: the first listener receives the
/// newest 16 pending launches, and a replacement gets only what arrives from
/// then on. Once the first listener has attached, launches received with no
/// listener are dropped rather than replayed. In this app that listener is
/// `IntentBus`, which buffers again on its own terms.
class IntentReceiver extends IntentEvents {
  IntentReceiver.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) : _binaryMessenger = binaryMessenger,
       _messageChannelSuffix = messageChannelSuffix {
    IntentEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );

    final host = IntentHost(
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
    _host = host;

    // Strictly after [IntentEvents.setUp] above: this call is what tells the
    // host it may start delivering live, and the handler it will deliver to has
    // to be registered before that is true.
    final pending = host.takePendingIntents().timeout(_hostTimeout);
    pendingIntents = pending;

    unawaited(
      pending.then(
        _openWith,
        onError: (Object error, StackTrace stackTrace) {
          if (_disposed) return;

          // Open anyway. There is no backlog to merge, but a queue that stayed
          // shut would hold every live launch from here on waiting for one that
          // is never coming.
          // Retain the diagnostic too: startup usually has no listener yet.
          _pendingError = (error, stackTrace);
          _openWith(const []);
        },
      ),
    );
  }

  final BinaryMessenger? _binaryMessenger;
  final String _messageChannelSuffix;
  IntentHost? _host;
  static const _hostTimeout = Duration(seconds: 5);
  static const _maxPending = 16;

  late final StreamController<Intent> _controller =
      StreamController<Intent>.broadcast(
        onListen: () {
          _hasListened = true;
          _flush();
        },
        onCancel: () {
          _queue.clear();
          _discardBacklog = true;
        },
      );

  /// Received, not yet handed to a listener, oldest first.
  final _queue = <Intent>[];

  /// Whether the host's backlog has been merged into [_queue].
  var _opened = false;
  var _hasListened = false;
  var _discardBacklog = false;
  var _disposed = false;
  (Object, StackTrace)? _pendingError;

  int? _lastAdded;

  /// Startup launches followed by live events for the current consumer.
  Stream<Intent> get events => _controller.stream;

  /// The launches the host held until this side could take them, oldest first.
  ///
  /// Resolves to an empty list for instances not constructed via
  /// [IntentReceiver.setUp] (e.g. test fakes / subclasses), so callers can
  /// always `await` without guarding for `LateInitializationError`.
  ///
  /// Not just a cold-start concern, and that is why it is a list rather than
  /// the single "initial intent" it used to be. The host buffers a launch
  /// whenever nothing here is listening yet — which is every launch between
  /// process start and [IntentReceiver.setUp], not merely the one the activity
  /// was created for. These reach [events] on their own; read this future only
  /// when they need one-shot handling outside the stream.
  /// Fails after five seconds if the host does not answer; live events are then
  /// released without the backlog, and a late host reply is ignored.
  Future<List<Intent>> pendingIntents = Future.value(const []);

  @override
  void onIntentReceived(int sequence, Intent intent) {
    if (_lastAdded != null && sequence <= _lastAdded!) {
      return;
    }

    _lastAdded = sequence;
    _emit(intent);
  }

  /// Merges the host's backlog and lets everything through.
  ///
  /// The backlog goes in *front* of what is already queued: the host held it
  /// before it let this side have anything live, so it is older by
  /// construction, whichever of the two channels happened to arrive first.
  void _openWith(List<Intent> backlog) {
    if (_opened || _disposed) {
      return;
    }

    if (!_discardBacklog) {
      _queue.insertAll(0, backlog);
      _trimQueue();
    }
    _opened = true;
    _flush();
  }

  void _emit(Intent intent) {
    if (_disposed || (_hasListened && !_controller.hasListener)) {
      return;
    }

    _queue.add(intent);
    _trimQueue();
    _flush();
  }

  void _trimQueue() {
    if (_queue.length > _maxPending) {
      _queue.removeRange(0, _queue.length - _maxPending);
    }
  }

  /// Hands over as much of the queue as there is somewhere to hand it to.
  ///
  /// Also the controller's `onListen`, which is what makes a late first
  /// listener still receive the bounded startup backlog.
  void _flush() {
    if (_disposed || !_opened || !_controller.hasListener) {
      return;
    }

    final error = _pendingError;
    if (error != null) {
      _pendingError = null;
      _controller.addError(error.$1, error.$2);
    }

    while (_queue.isNotEmpty && !_controller.isClosed) {
      _controller.add(_queue.removeAt(0));
    }
  }

  /// Gives the channel back.
  ///
  /// Requests that the host resume buffering, then unregisters locally without
  /// waiting for its reply. In-flight live events are not acknowledged here;
  /// local teardown must still complete when the engine cannot answer.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final host = _host;
    _host = null;

    final released = host
        ?.releaseDelivery()
        .timeout(_hostTimeout)
        .catchError((Object _) {});

    IntentEvents.setUp(
      null,
      binaryMessenger: _binaryMessenger,
      messageChannelSuffix: _messageChannelSuffix,
    );

    _queue.clear();
    _pendingError = null;
    await Future.wait<void>([
      _controller.close(),
      if (released != null) released,
    ]);
  }
}
