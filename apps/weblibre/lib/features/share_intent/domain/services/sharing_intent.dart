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

import 'package:mime/mime.dart' as mime;
import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/startup_bootstrap.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/account/domain/services/account_callback_handler.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/services/intent_gatekeeper.dart';
import 'package:weblibre/features/share_intent/domain/entities/intent_container_mode.dart';
import 'package:weblibre/features/share_intent/domain/services/brokered_intents.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/services/profile_restart_request.dart';

part 'sharing_intent.g.dart';

const _alwaysAllowPackageExtra = 'eu.weblibre.gatekeeper.always_allow_package';

StreamTransformer<Intent, ReceivedIntentParameter>
_buildSharingIntentTransformer(
  IntentGatekeeper gatekeeper,
  GeneralSettingsRepository settingsRepository,
) => StreamTransformer<Intent, ReceivedIntentParameter>.fromHandlers(
  handleData: (intent, sink) async {
    if (_extractAccountCallback(intent) != null) {
      // Account callback intents are consumed by accountCallbackStreamProvider —
      // suppress them from the regular share/sharing intent pipeline so they
      // don't open a browser tab.
      return;
    }

    if (restartProfileIdClaim(intent) != null) {
      // Same reasoning: profileRestartRequestHandlerProvider consumes these. It
      // carries no URL, so letting it through here would open a blank tab in the
      // profile the user is about to leave.
      //
      // The *claim* rather than the authorization, deliberately: an unauthorized
      // request is refused there and must be dropped here too. Suppressing it is
      // the whole answer — it carries nothing to open — and consuming the
      // authorization twice would spend it on this branch.
      return;
    }

    final alwaysAllowPackage =
        intent.extra[_alwaysAllowPackageExtra] as String?;
    if (alwaysAllowPackage != null) {
      await settingsRepository.updateSettings(
        (current) => current.copyWith.externalAppIntentPolicies({
          ...current.externalAppIntentPolicies,
          alwaysAllowPackage: IntentSourcePolicy.allow,
        }),
      );
    }

    final shortcutContextId = intent.action == 'android.intent.action.VIEW'
        ? intent.extra['pwa_context_id'] as String?
        : null;
    final shortcutContainerMode =
        intent.extra['shortcut_container_mode'] as String?;
    final hasShortcutContainerMetadata =
        shortcutContextId != null || shortcutContainerMode != null;
    final containerMode = intent.action == 'android.intent.action.VIEW'
        ? hasShortcutContainerMetadata
              ? IntentContainerMode.fromWireValue(
                  shortcutContainerMode,
                  contextId: shortcutContextId,
                )
              : IntentContainerMode.unassigned
        : IntentContainerMode.useSelected;

    final allowed = await gatekeeper.shouldAllow(
      fromPackageName: intent.fromPackageName,
      url: intent.data,
    );
    if (!allowed) {
      logger.i(
        'Blocked intent from ${intent.fromPackageName ?? 'unknown app'}',
      );
      return;
    }

    final data = switch (intent.action) {
      'android.intent.action.PROCESS_TEXT' =>
        intent.extra['android.intent.extra.PROCESS_TEXT'] as String?,
      'android.intent.action.WEB_SEARCH' => intent.extra['query'] as String?,
      'android.intent.action.VIEW' => intent.data,
      'android.intent.action.SEND' =>
        intent.extra['android.intent.extra.STREAM'] as String? ??
            intent.extra['android.intent.extra.TEXT'] as String?,
      _ => null,
    };

    // Extract container context from shortcut intents.
    final contextId = shortcutContextId;

    if (data != null) {
      if (uri_to_file.isUriSupported(data)) {
        var path = data;
        if (p.extension(data).whenNotEmpty == null) {
          if (intent.mimeType.whenNotEmpty != null) {
            final ext = mime.extensionFromMime(intent.mimeType!);
            if (ext != null) {
              path = p.setExtension(path, '.$ext');
            } else {
              logger.w(
                'Could not determine file extension for: ${intent.mimeType}',
              );
            }
          } else {
            logger.w('Received intent without extension and mime type $path');
          }
        }

        try {
          final file = await uri_to_file.toFile(path);
          final mimeType = mime.lookupMimeType(file.path);
          switch (mimeType) {
            case 'application/pdf':
              sink.add(
                ReceivedIntentParameter(
                  path,
                  null,
                  contextId: contextId,
                  containerMode: containerMode,
                ),
              );
            default:
              logger.w('Unhandled mime type: $mimeType');
          }
        } catch (e) {
          logger.e('Failed to convert URI to file: $e');
          // Fallback: pass the original URI
          sink.add(
            ReceivedIntentParameter(
              data,
              null,
              contextId: contextId,
              containerMode: containerMode,
            ),
          );
        }
      } else {
        sink.add(
          ReceivedIntentParameter(
            data,
            null,
            contextId: contextId,
            containerMode: containerMode,
          ),
        );
      }
    }
  },
);

/// Shared intent receiver instance. Both the sharing intent stream
/// and the account callback handler listen to its broadcast events.
@Riverpod(keepAlive: true)
Raw<IntentReceiver> intentReceiver(Ref ref) {
  final receiver = IntentReceiver.setUp();
  ref.onDispose(receiver.dispose);
  return receiver;
}

/// The one sink every intent reaches Dart through.
///
/// Separate from [allIntents] because the two halves have different audiences:
/// consumers need the stream, and the brokered drain needs the *sink* — at a
/// moment strictly after those consumers exist, which a provider cannot do for its
/// own dependents. See [brokeredIntentDelivery].
class IntentBus {
  IntentBus() : _controller = StreamController<Intent>.broadcast();

  final StreamController<Intent> _controller;
  final List<Intent> _startupQueue = [];
  bool _deliveryStarted = false;

  Stream<Intent> get stream => _controller.stream;

  void emit(Intent intent) {
    if (_deliveryStarted) {
      _controller.add(intent);
    } else {
      _startupQueue.add(intent);
    }
  }

  /// Releases intents received while startup consumers were being installed.
  ///
  /// This is deliberately one-way rather than replaying the last event: a
  /// provider rebuilt later must not reopen an old external link.
  void startDelivery() {
    if (_deliveryStarted) return;

    _deliveryStarted = true;
    for (final intent in _startupQueue) {
      _controller.add(intent);
    }
    _startupQueue.clear();
  }

  void emitError(Object error, StackTrace stackTrace) =>
      _controller.addError(error, stackTrace);

  Future<void> close() => _controller.close();
}

@Riverpod(keepAlive: true)
Raw<IntentBus> intentBus(Ref ref) {
  final receiver = ref.watch(intentReceiverProvider);
  final bus = IntentBus();

  final subscription = receiver.events.listen(bus.emit, onError: bus.emitError);

  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(bus.close());
  });

  return bus;
}

/// Every intent this app acts on: the live ones, plus the ones that arrived
/// before it existed.
///
/// The plugin sends a live intent straight to Dart over Pigeon, which works only
/// when something is already listening. During profile selection, maintenance
/// and restart teardown nothing is, and those launches used to vanish without a
/// trace. The native broker holds them instead, and they are replayed into this
/// same stream, so a replayed launch meets exactly the handlers a live one does.
///
/// The broker is not the same thing as the plugin's own hold, and the two do not
/// overlap. The broker takes launches `MainActivity` never passes on, because no
/// profile is committed yet; the plugin holds the ones it *is* given while this
/// isolate has not yet reached [intentReceiver]. Both end up here.
@Riverpod(keepAlive: true)
Raw<Stream<Intent>> allIntents(Ref ref) => ref.watch(intentBusProvider).stream;

/// Replays the launches the native broker held, once.
///
/// Deliberately not part of [allIntents]. The bus holds native cold-start events
/// until this provider starts delivery, then the broker retires entries as soon as
/// this sink accepts them. Draining as a side effect of building the stream would
/// therefore acknowledge launches before all semantic consumers existed.
///
/// So delivery and the drain are one explicit step, and the caller runs it only
/// after reading every consumer of [allIntents]. Those consumers buffer (see
/// [bufferedIntentStream]), which covers the second half of the problem: the
/// widget that finally acts on a replayed launch mounts later still.
@Riverpod(keepAlive: true)
Future<int> brokeredIntentDelivery(Ref ref) {
  final bus = ref.watch(intentBusProvider);
  bus.startDelivery();

  return drainBrokeredIntents(
    engineId: engineInstanceId,
    deliver: (intent) async => bus.emit(intent),
  );
}

/// Subscribes to [source] now, and re-publishes it as a broadcast stream that
/// holds events while nothing is listening.
///
/// Both halves matter for a replayed launch. *Now*, because the broker is drained
/// once and a lazily-built stream would not be subscribed yet — the event would
/// reach nobody and be acknowledged anyway. *Held*, because the consumer that acts
/// on it (a browser widget, a route) mounts later, and a plain broadcast stream
/// drops whatever arrives before it does. Pausing the upstream subscription rather
/// than cancelling it is what buffers; the default would tear it down.
Raw<Stream<T>> bufferedIntentStream<T>(Ref ref, Stream<T> source) {
  final controller = StreamController<T>();

  final subscription = source.listen(
    controller.add,
    onError: controller.addError,
  );

  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });

  return controller.stream.asBroadcastStream(
    onListen: (upstream) => upstream.resume(),
    onCancel: (upstream) => upstream.pause(),
  );
}

/// Runs the receiver event stream through [transformer] and forwards it into a
/// buffered broadcast stream wired up to [ref]'s lifecycle.
///
/// Centralising this in one helper means the intent-consuming providers below
/// agree on the source: [allIntents] carries the recovered cold-start intent,
/// every live intent, and every launch the broker held while the app could not
/// receive one.
Raw<Stream<T>> _consumeIntents<T>(
  Ref ref,
  Stream<Intent> intents,
  StreamTransformer<Intent, T> transformer,
) => bufferedIntentStream(ref, intents.transform(transformer));

@Riverpod(keepAlive: true)
Raw<Stream<ReceivedIntentParameter>> sharingIntentStream(Ref ref) {
  final intents = ref.watch(allIntentsProvider);
  final gatekeeper = ref.watch(intentGatekeeperProvider.notifier);
  final settingsRepository = ref.watch(
    generalSettingsRepositoryProvider.notifier,
  );
  return _consumeIntents(
    ref,
    intents,
    _buildSharingIntentTransformer(gatekeeper, settingsRepository),
  );
}

/// Stream of account callback handoff codes extracted from deep link intents.
@Riverpod(keepAlive: true)
Raw<Stream<AccountCallback>> accountCallbackStream(Ref ref) {
  final intents = ref.watch(allIntentsProvider);
  return _consumeIntents(ref, intents, _accountCallbackTransformer);
}

/// Transformer that yields handoff codes for matching VIEW intents and
/// drops everything else. Shared with the sharing-intent suppression
/// branch via [_extractAccountCallback] so the two streams agree on which
/// intents are "account callbacks".
final _accountCallbackTransformer =
    StreamTransformer<Intent, AccountCallback>.fromHandlers(
      handleData: (intent, sink) {
        final callback = _extractAccountCallback(intent);
        if (callback != null) {
          // The whole callback, not just the code: the echoed nonce is what
          // decides whether it may be redeemed at all.
          sink.add(callback);
        }
      },
    );

AccountCallback? _extractAccountCallback(Intent intent) {
  if (intent.action != 'android.intent.action.VIEW' || intent.data == null) {
    return null;
  }
  return tryParseAccountCallback(intent.data!);
}
