import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerable.g.dart';

@Riverpod(keepAlive: true)
GeckoReaderableService readerableService(ReaderableServiceRef ref) {
  final service = GeckoReaderableService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod()
Stream<bool> appearanceButtonVisibility(AppearanceButtonVisibilityRef ref) {
  final service = ref.watch(readerableServiceProvider);
  return service.appearanceVisibility;
}

@Riverpod()
Stream<bool> readerButtonVisibility(ReaderButtonVisibilityRef ref) {
  final service = ref.watch(readerableServiceProvider);
  return service.readerVisibility;
}
