import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bang_navigator/core/logger.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/sheet.dart';
import 'package:bang_navigator/features/search_browser/domain/providers.dart';
import 'package:bang_navigator/features/search_browser/utils/url_builder.dart'
    as uri_builder;
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/web_view/domain/entities/web_view_page.dart';
import 'package:bang_navigator/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:bang_navigator/features/web_view/presentation/widgets/web_page_dialog.dart';
import 'package:bang_navigator/features/web_view/utils/favicon_helper.dart';
import 'package:bang_navigator/utils/platform_util.dart' as platform_util;
import 'package:bang_navigator/utils/ui_helper.dart' as ui_helper;
import 'package:url_launcher/url_launcher.dart';

const _webViewSupportedSchemes = [
  "http",
  "https",
  "file",
  "chrome",
  "data",
  "javascript",
  "about",
];

class WebView extends StatefulHookConsumerWidget {
  final ValueNotifier<WebViewPage> _valueNotifier;

  ValueListenable<WebViewPage> get page => _valueNotifier;

  void updatePage(WebViewPage Function(WebViewPage page) update) {
    _valueNotifier.value = update(_valueNotifier.value);
  }

  WebView({required WebViewPage tab})
      : _valueNotifier = ValueNotifier(tab),
        super(key: tab.key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends ConsumerState<WebView> {
  Timer? _onLoadStopDebounce;
  Timer? _periodicScreenshotUpdate;

  Future<void> _updateScreenshot() async {
    final screenshot = await widget.page.value.controller
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

    widget.updatePage(
      (page) => page.copyWith.screenshot(screenshot),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    _onLoadStopDebounce?.cancel();
    _periodicScreenshotUpdate?.cancel();

    widget._valueNotifier.dispose();
    logger.i('Disposed ${widget.key} (${widget.page.value.title})');
  }

  @override
  Widget build(BuildContext context) {
    final initialSettings = useMemoized(
      () => InAppWebViewSettings(
        // isInspectable: kDebugMode,
        useOnDownloadStart: true,
        allowsLinkPreview: false,
        disableLongPressContextMenuOnLinks: true,
        useShouldOverrideUrlLoading: true,
        javaScriptEnabled: ref
                .read(settingsRepositoryProvider)
                .valueOrNull
                ?.enableJavascript ??
            true,
        saveFormData: false,
        disabledActionModeMenuItems: ActionModeMenuItem.MENU_ITEM_WEB_SEARCH,
      ),
    );

    final webViewProgress = useValueNotifier(100);

    useOnAppLifecycleStateChange((previous, current) async {
      switch (current) {
        case AppLifecycleState.paused:
          if (platform_util.isAndroid()) {
            await widget.page.value.controller?.pause();
          }
          if (platform_util.isAndroid() || platform_util.isIOS()) {
            await widget.page.value.controller?.pauseTimers();
          }
        case AppLifecycleState.resumed:
          if (platform_util.isAndroid()) {
            await widget.page.value.controller?.resume();
          }
          if (platform_util.isAndroid() || platform_util.isIOS()) {
            await widget.page.value.controller?.resumeTimers();
          }
        default:
      }
    });

    ref.listen(
      settingsRepositoryProvider
          .select((value) => value.valueOrNull?.enableJavascript),
      (previous, next) async {
        await widget.page.value.controller?.setSettings(
          settings: initialSettings.copy()..javaScriptEnabled = next,
        );
      },
    );

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri.uri(widget.page.value.url)),
          initialSettings: initialSettings,
          contextMenu: ContextMenu(
            menuItems: [
              ContextMenuItem(
                id: 1,
                title: "Search",
                action: () async {
                  final selectedText =
                      await widget.page.value.controller?.getSelectedText();

                  if (selectedText != null && selectedText.isNotEmpty) {
                    final url = uri_builder.searchUri(
                      searchQuery: selectedText,
                    );

                    await ref
                        .read(switchNewTabControllerProvider.notifier)
                        .add(url);
                  }
                },
              ),
              ContextMenuItem(
                id: 2,
                title: "Assistant",
                action: () async {
                  final selectedText =
                      await widget.page.value.controller?.getSelectedText();

                  if (selectedText != null && selectedText.isNotEmpty) {
                    ref.read(bottomSheetProvider.notifier).show(
                          CreateTab(
                            content: selectedText,
                            preferredTool: KagiTool.assistant,
                          ),
                        );
                  }
                },
              ),
            ],
          ),
          onWebViewCreated: (controller) async {
            if (platform_util.isAndroid()) {
              await controller.startSafeBrowsing();
            }

            widget.updatePage((page) => page.copyWith.controller(controller));
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            final sslError = challenge.protectionSpace.sslError;

            if (sslError != null && sslError.code != null) {
              if (challenge.protectionSpace.host ==
                  await controller.getUrl().then((value) => value?.host)) {
                widget.updatePage((page) => page.copyWith.sslError(sslError));
                if (context.mounted) {
                  ui_helper.showErrorMessage(
                    context,
                    'We detected an security issue and did not continue to ${widget.page.value.url.authority}: ${sslError.message}',
                  );
                }
              }

              return ServerTrustAuthResponse(
                // ignore: avoid_redundant_argument_values
                action: ServerTrustAuthResponseAction.CANCEL,
              );
            }

            widget.updatePage((page) => page.copyWith.sslError(null));
            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
          onProgressChanged: (controller, progress) {
            webViewProgress.value = progress;
          },
          onLoadStart: (controller, url) {
            if (url != null) {
              widget.updatePage(
                (page) => page.copyWith(
                  url: url,
                  // ignore: avoid_redundant_argument_values
                  sslError: null,
                ),
              );
            }
          },
          onLoadStop: (controller, url) {
            if (url != null) {
              widget.updatePage((page) => page.copyWith.url(url));
            }

            _onLoadStopDebounce?.cancel();
            _onLoadStopDebounce =
                Timer(const Duration(milliseconds: 150), () async {
              final favicon = await widget.page.value.controller
                  ?.getFavicons()
                  .then((icons) => choseFavicon(icons));
              widget.updatePage((page) => page.copyWith.favicon(favicon));

              await _updateScreenshot().whenComplete(() {
                _periodicScreenshotUpdate?.cancel();
                _periodicScreenshotUpdate =
                    Timer.periodic(const Duration(seconds: 5), (timer) async {
                  await _updateScreenshot().onError((error, stackTrace) {
                    logger.e(error, stackTrace: stackTrace);
                    timer.cancel();
                  });
                });
              });
            });
          },
          onUpdateVisitedHistory: (controller, url, isReload) async {
            if (isReload != true) {
              final history = (
                canGoBack: await controller.canGoBack(),
                canGoForward: await controller.canGoForward()
              );

              widget.updatePage((page) => page.copyWith.pageHistory(history));
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url;
            if (url != null) {
              final launchExternal = ref
                      .read(settingsRepositoryProvider)
                      .valueOrNull
                      ?.launchUrlExternal ??
                  false;

              final unhandledScheme =
                  !_webViewSupportedSchemes.contains(url.scheme);

              if (unhandledScheme ||
                  (launchExternal && url.host != 'kagi.com')) {
                if (await canLaunchUrl(url)) {
                  var success = false;
                  if (unhandledScheme) {
                    success = await launchUrl(url);
                  } else if (launchExternal) {
                    success = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }

                  if (!success) {
                    if (context.mounted) {
                      ui_helper.showErrorMessage(
                        context,
                        'Could not launch URL ($url)',
                      );
                    }
                  }
                  // and cancel the request
                  return NavigationActionPolicy.CANCEL;
                }
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLongPressHitTestResult: (controller, hitTestResult) async {
            if (switch (hitTestResult.type) {
              InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE ||
              InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE ||
              InAppWebViewHitTestResultType.IMAGE_TYPE =>
                true,
              _ => false,
            }) {
              final requestFocusNodeHrefResult =
                  await controller.requestFocusNodeHref();

              final url = requestFocusNodeHrefResult?.url ??
                  Uri.tryParse(requestFocusNodeHrefResult?.src ?? '');
              if (url?.hasScheme == true && url?.hasAuthority == true) {
                ref.read(overlayDialogProvider.notifier).show(
                      LoadingWebPageDialog(
                        url!,
                        onDismiss:
                            ref.watch(overlayDialogProvider.notifier).dismiss,
                      ),
                    );
              }
            }
          },
          onTitleChanged: (controller, title) {
            widget.updatePage((page) => page.copyWith.title(title));
          },

          // onDownloadStartRequest: (controller, downloadStartRequest) {
          // final regex = RegExp(
          //   r"filename\*=UTF-8''([\w%\-\.]+)(?:; ?|$)",
          //   caseSensitive: false,
          // );

          // final math =
          //     regex.firstMatch(downloadStartRequest.contentDisposition!);

          // print(math);
          // },
        ),
        HookBuilder(
          builder: (context) {
            final value = useValueListenable(webViewProgress);

            return Visibility(
              visible: value < 100,
              child: LinearProgressIndicator(
                value: value / 100,
              ),
            );
          },
        ),
      ],
    );
  }
}
