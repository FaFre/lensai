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
/// Every launch — the backlog the host held while this side did not exist, and
/// every live one after — leaves through [events], in the order the host saw
/// them. Two things have to be true for that, and neither is free:
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
/// backlog, and a second one attaching later gets only what arrives from then
/// on. In this app that listener is `IntentBus`, which buffers again on its own
/// terms.
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
    final pending = host.takePendingIntents();
    pendingIntents = pending;

    unawaited(
      pending.then(
        _openWith,
        onError: (Object error, StackTrace stackTrace) {
          // Open anyway. There is no backlog to merge, but a queue that stayed
          // shut would hold every live launch from here on waiting for one that
          // is never coming.
          _openWith(const []);

          if (!_controller.isClosed) {
            _controller.addError(error, stackTrace);
          }
        },
      ),
    );
  }

  final BinaryMessenger? _binaryMessenger;
  final String _messageChannelSuffix;
  IntentHost? _host;

  late final StreamController<Intent> _controller =
      StreamController<Intent>.broadcast(onListen: _flush);

  /// Received, not yet handed to a listener, oldest first.
  final _queue = <Intent>[];

  /// Whether the host's backlog has been merged into [_queue].
  var _opened = false;

  int? _lastAdded;

  /// Every launch this side is responsible for, in the order the host saw them.
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
    if (_opened) {
      return;
    }

    _queue.insertAll(0, backlog);
    _opened = true;
    _flush();
  }

  void _emit(Intent intent) {
    if (_controller.isClosed) {
      return;
    }

    _queue.add(intent);
    _flush();
  }

  /// Hands over as much of the queue as there is somewhere to hand it to.
  ///
  /// Also the controller's `onListen`, which is what makes a late first
  /// listener still receive everything from the beginning.
  void _flush() {
    if (!_opened || !_controller.hasListener) {
      return;
    }

    while (_queue.isNotEmpty && !_controller.isClosed) {
      _controller.add(_queue.removeAt(0));
    }
  }

  /// Gives the channel back.
  ///
  /// The host is told first and the handler unregistered second, so there is no
  /// moment where it believes someone is listening and nobody is: it goes back
  /// to holding launches, and whatever it is already holding it keeps for
  /// whoever comes next.
  Future<void> dispose() async {
    final host = _host;
    _host = null;

    if (host != null) {
      // Teardown runs while the engine is being dismantled, so this channel can
      // already be gone. Failing here would only replace a tidy hand-back with
      // an unhandled error on the way out.
      await host.releaseDelivery().catchError((Object _) {});
    }

    IntentEvents.setUp(
      null,
      binaryMessenger: _binaryMessenger,
      messageChannelSuffix: _messageChannelSuffix,
    );

    _queue.clear();
    await _controller.close();
  }
}
