import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GeckoEventService eventService(EventServiceRef ref) {
  final service = GeckoEventService.setUp();

  unawaited(GeckoTabService().syncEvents());

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod()
TabSession selectedTabSessionNotifier(SelectedTabSessionNotifierRef ref) {
  return ref.watch(tabSessionProvider(null).notifier);
}
