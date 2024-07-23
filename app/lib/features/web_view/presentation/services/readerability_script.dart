import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/web_view/domain/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerability_script.g.dart';

@Riverpod()
class ReaderabilityScriptService extends _$ReaderabilityScriptService {
  late Future<String> _readerabilityScript;
  late bool _enableReadability;

  @override
  Future<void> build(InAppWebViewController? controller) async {
    _readerabilityScript = ref.watch(readerabilityScriptProvider.future);
    _enableReadability = ref.watch(
      settingsRepositoryProvider.select(
        (value) =>
            (value.valueOrNull ?? Settings.withDefaults()).enableReadability,
      ),
    );
  }

  Future<void> _injectScript() async {
    if (controller != null) {
      await _readerabilityScript
          .then((script) => controller!.evaluateJavascript(source: script));
    }
  }

  Future<void> _ensureScriptInjected() async {
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
    if (_enableReadability) {
      await _ensureScriptInjected();

      if (controller != null) {
        return await controller!.evaluateJavascript(
          source: 'isReaderable();',
        ) as bool;
      }
    }

    return false;
  }

  Future<void> applyReaderable() async {
    if (_enableReadability) {
      await _ensureScriptInjected();

      if (controller != null) {
        await controller!.evaluateJavascript(source: 'applyReaderable();');
      }
    }
  }
}
