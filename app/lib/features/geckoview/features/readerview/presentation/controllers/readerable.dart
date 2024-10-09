import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/features/readerview/domain/providers/readerable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerable.g.dart';

@Riverpod(keepAlive: true)
class ReaderableScreenController extends _$ReaderableScreenController {
  late GeckoReaderableService _service;

  Future<void> toggleReaderView(bool enable) async {
    state = const AsyncValue.loading();
    final eventChange = ref.read(eventServiceProvider).readerableEvents.first;
    final toggle = _service.toggleReaderView(enable);

    state = await AsyncValue.guard(() => Future.wait([toggle, eventChange]));
  }

  @override
  FutureOr<void> build() {
    _service = ref.watch(readerableServiceProvider);

    return null;
  }
}
