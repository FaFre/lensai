import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/tab_link.dart';
import 'package:lensai/features/web_view/domain/entities/consistent_controller.dart';
import 'package:lensai/features/web_view/domain/entities/web_view_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'web_view.g.dart';

abstract class _TabStateCopyProxy {
  Future<void> copyWith({
    InAppWebViewController? controller,
    Uri? url,
    SslError? sslError,
    String? title,
    String? topicId,
    Favicon? favicon,
    Uint8List? screenshot,
    ({bool canGoBack, bool canGoForward})? pageHistory,
  });
}

@Riverpod()
class WebViewTabController extends _$WebViewTabController {
  String? _requestedTab;

  @override
  String? build() {
    final webViewTabs = ref.watch(
      tabRepositoryProvider.select(
        (value) => value.value ?? [],
      ),
    );

    if (_requestedTab != null) {
      if (webViewTabs.any((tab) => tab.id == _requestedTab)) {
        return _requestedTab;
      } else if (webViewTabs.isNotEmpty) {
        final topic = ref.read(selectedTopicProvider);
        return webViewTabs.where((tab) => tab.topicId == topic).lastOrNull?.id;
      }
    }

    return null;
  }

  void showTab(String? id) {
    _requestedTab = id;
    ref.invalidateSelf();
  }
}

@Riverpod()
class TabState extends _$TabState implements _TabStateCopyProxy {
  KeepAliveLink? _aliveLink;

  @override
  WebViewPage? build(String tabId) {
    final tabAsync = ref.watch(tabDataProvider(tabId));

    if (tabAsync.hasValue) {
      final tab = tabAsync.valueOrNull;

      final current = stateOrNull ??
          WebViewPage.create(
            id: tabId,
            url: tab?.url ?? Uri.https('localhost'),
          );

      if (tab != null) {
        _aliveLink ??= ref.keepAlive();

        return current.copyWith(
          topicId: tab.topicId,
          url: tab.url,
          title: tab.title,
          screenshot: tab.screenshot,
        );
      } else {
        _aliveLink?.close();
        _aliveLink = null;

        return current;
      }
    }

    return null;
  }

  Future<void> updateScreenshot() async {
    final screenshot = await state?.controller
        ?.takeScreenshot(
      screenshotConfiguration: ScreenshotConfiguration(
        compressFormat: CompressFormat.JPEG,
        quality: 20,
      ),
    )
        .timeout(
      const Duration(milliseconds: 1500),
      onTimeout: () {
        logger.w('Screenshot timed out');
        return null;
      },
    );

    await copyWith(screenshot: screenshot);
  }

  @override
  Future<void> copyWith({
    Object? controller = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? sslError = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? topicId = const $CopyWithPlaceholder(),
    Object? favicon = const $CopyWithPlaceholder(),
    Object? screenshot = const $CopyWithPlaceholder(),
    Object? pageHistory = const $CopyWithPlaceholder(),
  }) async {
    if (state != null) {
      final current = state!;

      state = WebViewPage(
        id: current.id,
        controller: controller == const $CopyWithPlaceholder()
            ? current.controller
            : controller as InAppWebViewController?,
        url: current.url,
        sslError: sslError == const $CopyWithPlaceholder()
            ? current.sslError
            : sslError as SslError?,
        title: current.title,
        topicId: current.topicId,
        favicon: favicon == const $CopyWithPlaceholder()
            ? current.favicon
            : favicon as Favicon?,
        screenshot: current.screenshot,
        pageHistory:
            pageHistory == const $CopyWithPlaceholder() || pageHistory == null
                ? current.pageHistory
                : pageHistory as ({bool canGoBack, bool canGoForward}),
      );

      await ref.read(tabRepositoryProvider.notifier).updateTab(
            current.id,
            url: url == const $CopyWithPlaceholder() || url == null
                ? const Value.absent()
                : Value(url as Uri),
            title: title == const $CopyWithPlaceholder()
                ? const Value.absent()
                : Value(title as String?),
            topicId: topicId == const $CopyWithPlaceholder()
                ? const Value.absent()
                : Value(topicId as String?),
            screenshot: screenshot == const $CopyWithPlaceholder()
                ? const Value.absent()
                : Value(screenshot as Uint8List?),
          );
    }
  }
}

@Riverpod()
InAppWebViewController? webViewController(
  WebViewControllerRef ref,
  String tabId,
) {
  return ref
      .watch(
        tabStateProvider(tabId)
            .select((value) => ConsistentController(value?.controller)),
      )
      .value;
}
