import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/domain/services/generic_website.dart';
import 'package:lensai/features/bangs/domain/providers.dart';
import 'package:lensai/features/chat_archive/domain/entities/chat_entity.dart';
import 'package:lensai/features/chat_archive/domain/repositories/archive.dart';
import 'package:lensai/features/search_browser/domain/entities/modes.dart';
import 'package:lensai/features/search_browser/domain/entities/sheet.dart';
import 'package:lensai/features/search_browser/domain/providers.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/web_view/domain/providers.dart';
import 'package:lensai/features/web_view/domain/repositories/web_view.dart';
import 'package:lensai/features/web_view/presentation/controllers/readerability.dart';
import 'package:lensai/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:lensai/features/web_view/presentation/widgets/web_page_dialog.dart';
import 'package:lensai/features/web_view/utils/download_helper.dart';
import 'package:lensai/utils/platform_util.dart' as platform_util;
import 'package:lensai/utils/ui_helper.dart' as ui_helper;
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
  final String tabId;
  final URLRequest? initialUrlRequest;

  const WebView({
    required this.tabId,
    required super.key,
    this.initialUrlRequest,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends ConsumerState<WebView> {
  Timer? _onLoadStopDebounce;
  Timer? _periodicScreenshotUpdate;

  Future<bool> _downloadChat(
    DownloadStartRequest downloadStartRequest,
    BuildContext context,
  ) async {
    final fileName = getDispositionFileName(
      downloadStartRequest.contentDisposition!,
    );

    if (fileName != null) {
      final entity = ChatEntity.fromFileName(fileName);
      if (entity.name != null) {
        final fileWrite = await ref
            .read(chatArchiveRepositoryProvider.notifier)
            .archiveChat(fileName, downloadStartRequest.url);

        return fileWrite.fold(
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Conversation "$entity" saved successfully!',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );

            return true;
          },
          onFailure: (errorMessage) {
            ui_helper.showErrorMessage(
              context,
              errorMessage.toString(),
            );

            return false;
          },
        );
      }
    }

    return false;
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    _onLoadStopDebounce?.cancel();
    _periodicScreenshotUpdate?.cancel();

    logger.i('Disposed ${widget.key} ${widget.tabId}');
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
        javaScriptEnabled: (ref.read(settingsRepositoryProvider).valueOrNull ??
                Settings.withDefaults())
            .enableJavascript,
        saveFormData: false,
        disabledActionModeMenuItems: ActionModeMenuItem.MENU_ITEM_WEB_SEARCH,
      ),
    );

    final showEarlyAccessFeatures = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults())
            .showEarlyAccessFeatures,
      ),
    );

    // We keep listening to changes and cache them in this ref.
    // This is important, since our WebView will not have the main scope anymore
    // to react to updates from ref.watch
    //
    // With this solution we dont need to read on every interception request
    // and can just obtain the value from here
    final blockContentHosts = useRef<Set<String>?>(null);
    ref.listen(
      blockContentHostsProvider,
      (previous, next) {
        blockContentHosts.value = next.valueOrNull;
      },
    );

    ref.listen(
      settingsRepositoryProvider.select(
        (value) =>
            (value.valueOrNull ?? Settings.withDefaults()).enableJavascript,
      ),
      (previous, next) async {
        final controller = ref.read(webViewControllerProvider(widget.tabId));
        await controller?.setSettings(
          settings: initialSettings.copy()..javaScriptEnabled = next,
        );
      },
    );

    final webViewProgress = useValueNotifier(100);
    final inPageSearchResult =
        useValueNotifier<({int activeMatchOrdinal, int numberOfMatches})?>(
      null,
    );

    final findInteractionController = useMemoized(
      () => FindInteractionController(
        onFindResultReceived: (
          controller,
          activeMatchOrdinal,
          numberOfMatches,
          isDoneCounting,
        ) {
          if (isDoneCounting) {
            inPageSearchResult.value = (
              activeMatchOrdinal: activeMatchOrdinal,
              numberOfMatches: numberOfMatches,
            );
          }
        },
      ),
    );

    useOnAppLifecycleStateChange((previous, current) async {
      final controller = ref.read(webViewControllerProvider(widget.tabId));

      switch (current) {
        case AppLifecycleState.paused:
          if (platform_util.isAndroid()) {
            await controller?.pause();
          }
          if (platform_util.isAndroid() || platform_util.isIOS()) {
            await controller?.pauseTimers();
          }
        case AppLifecycleState.resumed:
          if (platform_util.isAndroid()) {
            await controller?.resume();
          }
          if (platform_util.isAndroid() || platform_util.isIOS()) {
            await controller?.resumeTimers();
          }
        default:
      }
    });

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: widget.initialUrlRequest,
          initialSettings: initialSettings,
          findInteractionController: findInteractionController,
          contextMenu: ContextMenu(
            menuItems: [
              ContextMenuItem(
                id: 1,
                title: "Search",
                action: () async {
                  final controller =
                      ref.read(webViewControllerProvider(widget.tabId));

                  final selectedText = await controller?.getSelectedText();

                  if (selectedText != null && selectedText.isNotEmpty) {
                    final searchBang =
                        await ref.read(kagiSearchBangDataProvider.future);

                    await ref
                        .read(switchNewTabControllerProvider.notifier)
                        .add(searchBang!.getUrl(selectedText));
                  }
                },
              ),
              if (showEarlyAccessFeatures)
                ContextMenuItem(
                  id: 2,
                  title: "Assistant",
                  action: () async {
                    final controller =
                        ref.read(webViewControllerProvider(widget.tabId));

                    final selectedText = await controller?.getSelectedText();

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

            await ref
                .read(tabStateProvider(widget.tabId).notifier)
                .copyWith(controller: controller);
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            final sslError = challenge.protectionSpace.sslError;

            if (sslError != null && sslError.code != null) {
              final url = await controller.getUrl();
              if (challenge.protectionSpace.host == url?.host) {
                await ref
                    .read(tabStateProvider(widget.tabId).notifier)
                    .copyWith(sslError: sslError);

                if (context.mounted) {
                  ui_helper.showErrorMessage(
                    context,
                    'We detected an security issue and did not continue to ${url?.authority}: ${sslError.message}',
                  );
                }
              }

              return ServerTrustAuthResponse(
                // ignore: avoid_redundant_argument_values
                action: ServerTrustAuthResponseAction.CANCEL,
              );
            }

            await ref
                .read(tabStateProvider(widget.tabId).notifier)
                .copyWith(sslError: null);

            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
          shouldInterceptRequest: (controller, request) async {
            if (blockContentHosts.value?.contains(request.url.host) == true) {
              return WebResourceResponse(
                contentType: "text/plain",
                data: utf8.encode("Blocked"),
                statusCode: 403,
                reasonPhrase: "Forbidden",
              );
            }

            //Check if main page aka main frame is upgradeable
            if (request.url.isScheme('http') &&
                request.isForMainFrame == true) {
              final upgradedUri = await ref
                  .read(genericWebsiteServiceProvider.notifier)
                  .tryUpgradeToHttps(request.url);

              if (upgradedUri != null) {
                unawaited(
                  controller.loadUrl(
                    urlRequest: URLRequest(url: WebUri.uri(upgradedUri)),
                  ),
                );

                return WebResourceResponse(
                  statusCode: 200,
                  reasonPhrase: "Redirecting...",
                );
              }
            }

            if (request.url.isScheme('http')) {
              if ((ref.read(settingsRepositoryProvider).valueOrNull ??
                      Settings.withDefaults())
                  .blockHttpProtocol) {
                return WebResourceResponse(
                  contentType: "text/plain",
                  data: utf8.encode("HTTP protocol is blocked"),
                  statusCode: 403,
                  reasonPhrase: "Forbidden",
                );
              }
            }

            return null;
          },
          onProgressChanged: (controller, progress) {
            webViewProgress.value = progress;
          },
          onLoadStart: (controller, url) async {
            final readabilityNotifier = ref.read(
              readerabilityControllerProvider(widget.tabId).notifier,
            );

            if (url != null) {
              await ref.read(tabStateProvider(widget.tabId).notifier).copyWith(
                    url: url,
                    // ignore: avoid_redundant_argument_values
                    sslError: null,
                  );
            }

            readabilityNotifier.reset();
          },
          onLoadStop: (controller, url) async {
            if (url != null) {
              await ref
                  .read(tabStateProvider(widget.tabId).notifier)
                  .copyWith(url: url);
            }

            _onLoadStopDebounce?.cancel();
            _onLoadStopDebounce =
                Timer(const Duration(milliseconds: 150), () async {
              final readabilityNotifier = ref.read(
                readerabilityControllerProvider(widget.tabId).notifier,
              );

              await readabilityNotifier.checkReaderable();

              await ref
                  .read(tabStateProvider(widget.tabId).notifier)
                  .updateScreenshot()
                  .whenComplete(() {
                _periodicScreenshotUpdate?.cancel();
                _periodicScreenshotUpdate =
                    Timer.periodic(const Duration(seconds: 5), (timer) async {
                  await ref
                      .read(tabStateProvider(widget.tabId).notifier)
                      .updateScreenshot()
                      .onError((error, stackTrace) {
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

              await ref
                  .read(tabStateProvider(widget.tabId).notifier)
                  .copyWith(pageHistory: history);
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url;
            if (url != null) {
              final launchExternal = ref.read(
                settingsRepositoryProvider.select(
                  (value) => (value.valueOrNull ?? Settings.withDefaults())
                      .launchUrlExternal,
                ),
              );

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
                      WebPageDialog(
                        url: url!,
                        onDismiss: () {
                          ref.read(overlayDialogProvider.notifier).dismiss();
                        },
                      ),
                    );
              }
            }
          },
          onTitleChanged: (controller, title) async {
            await ref
                .read(tabStateProvider(widget.tabId).notifier)
                .copyWith(title: title);
          },
          onDownloadStartRequest: (controller, downloadStartRequest) async {
            final handled = switch (downloadStartRequest.mimeType) {
              'text/markdown' =>
                await _downloadChat(downloadStartRequest, context),
              _ => false
            };

            if (!handled) {
              if (context.mounted) {
                await ui_helper.launchUrlFeedback(
                  context,
                  downloadStartRequest.url,
                  mode: LaunchMode.platformDefault,
                );
              }
            }

            webViewProgress.value = 100;
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: HookBuilder(
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
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: HookConsumer(
            builder: (context, ref, child) {
              final showFindInPage = ref.watch(showFindInPageProvider);

              final textController = useTextEditingController();
              final progress = useValueListenable(webViewProgress);

              return Visibility(
                visible: showFindInPage,
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: (progress < 100) ? 4.0 : 0.0),
                  child: Material(
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            autofocus: true,
                            autocorrect: false,
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Find in page',
                            ),
                            keyboardType: TextInputType.text,
                            onSubmitted: (value) async {
                              if (value == '') {
                                inPageSearchResult.value = null;
                                await findInteractionController.clearMatches();
                              } else {
                                await findInteractionController.findAll(
                                  find: value,
                                );
                              }
                            },
                          ),
                        ),
                        HookConsumer(
                          builder: (context, ref, child) {
                            final searchResult =
                                useValueListenable(inPageSearchResult);

                            if (searchResult != null) {
                              if (searchResult.numberOfMatches == 0) {
                                return const Text('Not found');
                              }

                              return Text(
                                '${searchResult.activeMatchOrdinal + 1} of ${searchResult.numberOfMatches}',
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: () async {
                            await findInteractionController.findNext(
                              forward: false,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () async {
                            await findInteractionController.findNext();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () async {
                            ref
                                .read(showFindInPageProvider.notifier)
                                .update(false);

                            inPageSearchResult.value = null;
                            await findInteractionController.clearMatches();
                            textController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
