import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lensai/features/web_view/presentation/services/readerability_script.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerability.g.dart';

@Riverpod()
class ReaderabilityController extends _$ReaderabilityController {
  late ReaderabilityScriptService _service;

  @override
  FutureOr<void> build(InAppWebViewController? controller) async {
    _service =
        ref.watch(readerabilityScriptServiceProvider(controller).notifier);
  }

  Future<bool> isReaderable() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await _service.isReaderable();
    });
    state = result;

    return result.valueOrNull ?? false;
  }

  Future<void> applyReaderable() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.applyReaderable();
    });
  }
}
