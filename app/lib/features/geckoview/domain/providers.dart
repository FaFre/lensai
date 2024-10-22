import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GeckoEventService eventService(EventServiceRef ref) {
  final service = GeckoEventService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
class EngineReadyState extends _$EngineReadyState {
  @override
  bool build() {
    final eventService = ref.watch(eventServiceProvider);

    final currentState =
        eventService.engineReadyStateEvents.valueOrNull ?? false;

    if (!currentState) {
      unawaited(
        eventService.engineReadyStateEvents
            .firstWhere((value) => value == true)
            .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            logger.w('Waiting for engine ready state timed out');
            return true;
          },
        ).whenComplete(() => state = true),
      );
    }

    final sub = eventService.engineReadyStateEvents.listen((value) {
      state = value;
    });

    ref.onDispose(() async {
      await sub.cancel();
    });

    return currentState;
  }
}

@Riverpod()
TabSession selectedTabSessionNotifier(SelectedTabSessionNotifierRef ref) {
  return ref.watch(tabSessionProvider(null).notifier);
}
