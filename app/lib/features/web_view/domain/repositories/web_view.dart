import 'dart:collection';

import 'package:lensai/features/web_view/domain/entities/consistent_controller.dart';
import 'package:lensai/features/web_view/presentation/controllers/readerability.dart';
import 'package:lensai/features/web_view/presentation/widgets/web_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'web_view.g.dart';

@Riverpod(keepAlive: true)
class WebViewTabController extends _$WebViewTabController {
  late Map<String, WebView> _webViewTabs;

  @override
  WebView? build() {
    _webViewTabs = ref.watch(webViewRepositoryProvider);
    return (stateOrNull != null)
        ? _webViewTabs[stateOrNull!.tabId] ?? _webViewTabs.values.lastOrNull
        : null;
  }

  void showTab(String? id) {
    state = (id != null) ? _webViewTabs[id] : null;
  }
}

@Riverpod(keepAlive: true)
class WebViewRepository extends _$WebViewRepository {
  @override
  Map<String, WebView> build() {
    return stateOrNull ?? {};
  }

  void _disposeReaderability(String id) {
    final controller = state[id]?.currentController;
    if (controller != null) {
      ref
          .read(
            readerabilityControllerProvider(ConsistentController(controller))
                .notifier,
          )
          .dispose();
    }
  }

  void addTab(WebView webView) {
    state = {...state, webView.tabId: webView};
  }

  void closeTab(String id) {
    _disposeReaderability(id);
    state = Map.of(state)..remove(id);
  }

  void closeAllTabs() {
    state.keys.forEach(_disposeReaderability);
    state = {};
  }
}
