import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lensai/features/web_view/domain/entities/consistent_controller.dart';
import 'package:lensai/features/web_view/presentation/services/readerability_script.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerability.g.dart';

@Riverpod()
class ReaderabilityController extends _$ReaderabilityController {
  late InAppWebViewController? _controller;
  late ReaderabilityScriptService _service;
  late KeepAliveLink _aliveLink;

  @override
  AsyncValue<({bool readerable, bool applied})> build(
    ConsistentController controller,
  ) {
    _controller = controller.value;
    _service =
        ref.watch(readerabilityScriptServiceProvider(controller).notifier);
    _aliveLink = ref.keepAlive();

    return const AsyncLoading();
  }

  Future<bool> checkReaderable() async {
    final applied = state.valueOrNull?.applied ?? false;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return (readerable: await _service.isReaderable(), applied: applied);
    });
    state = result;

    return result.valueOrNull?.readerable ?? false;
  }

  Future<void> toggleReaderable() async {
    final applied = state.valueOrNull?.applied ?? false;
    final readerable = state.valueOrNull?.readerable ?? false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (applied) {
        await _controller?.reload();
      } else {
        await _service.applyReaderable();
      }

      return (readerable: readerable, applied: !applied);
    });
  }

  void reset() {
    state = const AsyncLoading();
  }

  void dispose() {
    _aliveLink.close();
  }
}
