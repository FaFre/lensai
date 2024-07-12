import 'package:bang_navigator/features/web_view/domain/providers.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerability_script.g.dart';

@Riverpod()
class ReaderabilityScriptService extends _$ReaderabilityScriptService {
  late Future<String> _readerabilityScript;

  @override
  Future<void> build(InAppWebViewController? controller) async {
    _readerabilityScript = ref.watch(readerabilityScriptProvider.future);
  }

  Future<void> _injectScript() async {
    if (controller != null) {
      await _readerabilityScript
          .then((script) => controller!.evaluateJavascript(source: script));
    }
  }

  Future<void> ensureScriptInjected() async {
    if (controller != null) {
      final injected = await controller!.evaluateJavascript(
        source:
            "(typeof window !== 'undefined' && typeof window.isReaderable === 'function')",
      ) as bool;

      if (!injected) {
        await _injectScript();
      }
    }
  }

  Future<bool> isReaderable() async {
    await ensureScriptInjected();

    if (controller != null) {
      return await controller!.evaluateJavascript(
        source: 'isReaderable();',
      ) as bool;
    }

    return false;
  }

  Future<void> applyReaderable() async {
    await ensureScriptInjected();

    if (controller != null) {
      await controller!.evaluateJavascript(source: 'applyReaderable();');
    }
  }
}
