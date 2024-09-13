import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/entities/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab_session.dart';
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

@Riverpod()
TabState? tabState(TabStateRef ref, String? tabId) {
  if (tabId == null) {
    return null;
  }

  return ref.watch(
    tabRepositoryProvider.select((tabs) => tabs[tabId]),
  );
}

@Riverpod()
TabState? selectedTabState(SelectedTabStateRef ref) {
  final tabId = ref.watch(selectedTabControllerProvider);
  return ref.watch(tabStateProvider(tabId));
}

@Riverpod()
TabSession selectedTabSessionNotifier(SelectedTabSessionNotifierRef ref) {
  return ref.watch(tabSessionProvider(null).notifier);
}
