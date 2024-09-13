import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/web_view/domain/providers.dart';
import 'package:lensai/features/web_view/domain/repositories/web_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerability_script.g.dart';

@Riverpod()
class ReaderabilityScriptService extends _$ReaderabilityScriptService {
  late InAppWebViewController? _controller;
  late Future<String> _readerabilityScript;
  late bool _enableReadability;

  @override
  Future<void> build(String tabId) async {
    _controller = ref.watch(webViewControllerProvider(tabId));
    _readerabilityScript = ref.watch(readerabilityScriptProvider.future);
    _enableReadability = ref.watch(
      settingsRepositoryProvider.select(
        (value) =>
            (value.valueOrNull ?? Settings.withDefaults()).enableReadability,
      ),
    );
  }

  Future<void> _injectScript() async {
    if (_controller != null) {
      await _readerabilityScript
          .then((script) => _controller!.evaluateJavascript(source: script));
    }
  }

  Future<void> _ensureScriptInjected() async {
    if (_controller != null) {
      final injected = await _controller!.evaluateJavascript(
        source:
            "(typeof window !== 'undefined' && typeof window.isReaderable === 'function')",
      ) as bool;

      if (!injected) {
        await _injectScript();
      }
    }
  }

  Future<bool> isReaderable() async {
    if (_enableReadability) {
      await _ensureScriptInjected();

      if (_controller != null) {
        return await _controller!.evaluateJavascript(
          source: 'isReaderable();',
        ) as bool;
      }
    }

    return false;
  }

  Future<void> applyReaderable() async {
    if (_enableReadability) {
      await _ensureScriptInjected();

      if (_controller != null) {
        await _controller!.evaluateJavascript(source: 'applyReaderable();');
      }
    }
  }
}
