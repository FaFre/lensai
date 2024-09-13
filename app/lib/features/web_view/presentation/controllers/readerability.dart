import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:lensai/features/web_view/domain/repositories/web_view.dart';
import 'package:lensai/features/web_view/presentation/services/readerability_script.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerability.g.dart';

@Riverpod()
class ReaderabilityController extends _$ReaderabilityController {
  late ReaderabilityScriptService _service;
  late KeepAliveLink _aliveLink;

  @override
  AsyncValue<({bool readerable, bool applied})> build(
    String tabId,
  ) {
    _service = ref.watch(readerabilityScriptServiceProvider(tabId).notifier);
    _aliveLink = ref.keepAlive();

    ref.listen(
      isTabExistingProvider(tabId),
      (previous, next) {
        if (next.valueOrNull == false) {
          _aliveLink.close();
        }
      },
    );

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
        await ref.read(webViewControllerProvider(tabId))?.reload();
      } else {
        await _service.applyReaderable();
      }

      return (readerable: readerable, applied: !applied);
    });
  }

  void reset() {
    state = const AsyncLoading();
  }
}
