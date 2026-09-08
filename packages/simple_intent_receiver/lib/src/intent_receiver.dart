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

class IntentReceiver extends IntentEvents {
  final _controller = StreamController<Intent>.broadcast();
  int? _lastAdded;

  /// Intent events, including the ones that arrived before this side existed.
  ///
  /// Live callbacks arrive through the broadcast controller below. The backlog
  /// the host held is replayed per listener, so a caller that only listens to
  /// [events] still receives launches this isolate was not yet able to take.
  Stream<Intent> get events {
    return Stream.multi((controller) {
      final subscription = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      unawaited(
        pendingIntents.then(
          (intents) {
            for (final intent in intents) {
              if (controller.isClosed) return;
              controller.add(intent);
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        ),
      );

      controller.onCancel = subscription.cancel;
    }, isBroadcast: true);
  }

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
  /// was created for. The [events] stream already replays these; use this
  /// future directly only when they need one-shot handling outside the event
  /// stream.
  Future<List<Intent>> pendingIntents = Future.value(const []);

  @override
  void onIntentReceived(int sequence, Intent intent) {
    if (_lastAdded == null || sequence > _lastAdded!) {
      _lastAdded = sequence;
      _controller.add(intent);
    }
  }

  IntentReceiver.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    IntentEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );

    final host = IntentHost(
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
    // Strictly after [IntentEvents.setUp] above: this call is what tells the
    // host it may start delivering live, and the handler it will deliver to has
    // to be registered before that is true. The host flips and drains in one
    // step, so nothing falls between the last buffered launch and the first
    // live one.
    pendingIntents = host.takePendingIntents();
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
