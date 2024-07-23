import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/search_browser/domain/entities/modes.dart';
import 'package:lensai/features/search_browser/domain/entities/sheet.dart';
import 'package:lensai/features/search_browser/domain/providers.dart';
import 'package:lensai/features/search_browser/domain/services/create_tab.dart';
import 'package:lensai/features/search_browser/domain/services/session.dart';
import 'package:lensai/features/search_browser/presentation/widgets/app_bar_title.dart';
import 'package:lensai/features/search_browser/presentation/widgets/landing/content.dart';
import 'package:lensai/features/search_browser/presentation/widgets/sheets/shared_content_sheet.dart';
import 'package:lensai/features/search_browser/presentation/widgets/sheets/view_tabs_sheet.dart';
import 'package:lensai/features/search_browser/presentation/widgets/tabs_action_button.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/web_view/domain/repositories/web_view.dart';
import 'package:lensai/features/web_view/presentation/controllers/readerability.dart';
import 'package:lensai/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:lensai/features/web_view/presentation/widgets/web_page_dialog.dart';
import 'package:lensai/presentation/hooks/overlay_portal_controller.dart';
import 'package:lensai/presentation/widgets/animate_gradient_shader.dart';
import 'package:lensai/presentation/widgets/animated_indexed_stack.dart';
import 'package:lensai/utils/ui_helper.dart' as ui_helper;
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';

class KagiScreen extends HookConsumerWidget {
  const KagiScreen({super.key});

  double _realtiveSafeArea(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return 1.0 - (mediaQuery.padding.top / mediaQuery.size.height);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedSheet = ref.watch(bottomSheetProvider);
    final displayedOverlayDialog = ref.watch(overlayDialogProvider);

    final showEarlyAccessFeatures = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults())
            .showEarlyAccessFeatures,
      ),
    );

    final quickAction = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults()).quickAction,
      ),
    );

    final quickActionVoice = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults())
            .quickActionVoiceInput,
      ),
    );

    final activeWebView = ref.watch(webViewTabControllerProvider);

    final menuController = useMemoized(() => MenuController());

    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayController = useOverlayPortalController();

    final activeKagiTool = useValueNotifier<KagiTool?>(null, [displayedSheet]);

    ref.listen(
      overlayDialogProvider,
      (previous, next) {
        if (next != null) {
          overlayController.show();
        } else {
          overlayController.hide();
        }
      },
    );

    ref.listen(
      settingsRepositoryProvider
          .select((value) => value.valueOrNull?.kagiSession),
      (previous, next) async {
        if (next != null && next.isNotEmpty) {
          await ref.read(sessionServiceProvider.notifier).setKagiSession(next);
        }
      },
    );

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        height: AppBar().preferredSize.height,
        padding: EdgeInsets.zero,
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 8.0,
          title: (activeWebView != null)
              ? AppBarTitle(
                  activeWebView: activeWebView,
                  onTap: () {
                    final page = activeWebView.page.value;

                    ref.read(overlayDialogProvider.notifier).show(
                          WebPageDialog(
                            page: page,
                            webViewController: page.controller,
                            onDismiss: ref
                                .read(overlayDialogProvider.notifier)
                                .dismiss,
                          ),
                        );
                  },
                )
              : HookBuilder(
                  builder: (context) {
                    final activeTool = useListenableSelector(
                      activeKagiTool,
                      () {
                        if (displayedSheet is SharedContentSheet) {
                          return null;
                        }

                        return activeKagiTool.value;
                      },
                    );

                    return Row(
                      children: [
                        IconButton(
                          color: (activeTool == KagiTool.search)
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          onPressed: () {
                            ref
                                .read(createTabStreamProvider.notifier)
                                .createTab(
                                  CreateTab(preferredTool: KagiTool.search),
                                );
                          },
                          icon: Icon(KagiTool.search.icon),
                        ),
                        IconButton(
                          color: (activeTool == KagiTool.summarizer)
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          onPressed: () {
                            ref
                                .read(createTabStreamProvider.notifier)
                                .createTab(
                                  CreateTab(preferredTool: KagiTool.summarizer),
                                );
                          },
                          icon: Icon(KagiTool.summarizer.icon),
                        ),
                        if (showEarlyAccessFeatures)
                          IconButton(
                            color: (activeTool == KagiTool.assistant)
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            onPressed: () {
                              ref
                                  .read(createTabStreamProvider.notifier)
                                  .createTab(
                                    CreateTab(
                                      preferredTool: KagiTool.assistant,
                                    ),
                                  );
                            },
                            icon: Icon(KagiTool.assistant.icon),
                          ),
                      ],
                    );
                  },
                ),
          actions: [
            if (activeWebView != null)
              HookConsumer(
                builder: (context, ref, child) {
                  final colorScheme = Theme.of(context).colorScheme;

                  final controller =
                      useListenable(activeWebView.page).value.controller;
                  final readerabilityState = ref.watch(
                    readerabilityControllerProvider(controller),
                  );

                  final enableReadability = ref.watch(
                    settingsRepositoryProvider.select(
                      (value) => (value.valueOrNull ?? Settings.withDefaults())
                          .enableReadability,
                    ),
                  );

                  final isReaderable = useValueListenable(
                    activeWebView.isReaderable,
                  );

                  final readerableApplied = useValueListenable(
                    activeWebView.readerableApplied,
                  );

                  final icon = useMemoized(
                    () => readerableApplied
                        ? Icon(
                            MdiIcons.bookOpen,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : const Icon(
                            MdiIcons.bookOpenOutline,
                            color: Colors.white,
                          ),
                    [readerableApplied],
                  );

                  return Visibility(
                    visible: enableReadability &&
                        (isReaderable == true || readerableApplied),
                    child: InkWell(
                      onTap: readerabilityState.isLoading
                          ? null
                          : () async {
                              final controller =
                                  activeWebView.currentController;

                              if (controller != null) {
                                final readabilityNotifier = ref.read(
                                  readerabilityControllerProvider(
                                    controller,
                                  ).notifier,
                                );

                                if (readerableApplied) {
                                  await activeWebView
                                      .updateReaderableApplied(false);
                                } else {
                                  await readabilityNotifier.applyReaderable();
                                  await activeWebView
                                      .updateReaderableApplied(true);
                                }
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 8.0,
                        ),
                        child: readerabilityState.when(
                          data: (_) => icon,
                          error: (error, stackTrace) => SizedBox.shrink(),
                          loading: () => AnimateGradientShader(
                            duration: const Duration(milliseconds: 500),
                            primaryEnd: Alignment.bottomLeft,
                            secondaryEnd: Alignment.topRight,
                            primaryColors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                            secondaryColors: [
                              colorScheme.secondary,
                              colorScheme.secondaryContainer,
                            ],
                            child: icon,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (activeWebView != null && quickAction != null)
              InkWell(
                onTap: () async {
                  var tab = CreateTab(
                    preferredTool: quickAction,
                  );

                  if (quickActionVoice) {
                    final completer = Completer<String>();

                    final isServiceAvailable =
                        await SpeechToTextGoogleDialog.getInstance()
                            .showGoogleDialog(
                      onTextReceived: (data) {
                        completer.complete(data.toString());
                      },
                      // locale: "en-US",
                    );

                    if (!isServiceAvailable) {
                      if (context.mounted) {
                        ui_helper.showErrorMessage(
                          context,
                          'Service is not available',
                        );
                      }
                    }

                    tab = CreateTab(
                      preferredTool: quickAction,
                      content: await completer.future,
                    );
                  }

                  ref.read(createTabStreamProvider.notifier).createTab(tab);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 8.0,
                  ),
                  child: Icon(quickActionVoice ? Icons.mic : quickAction.icon),
                ),
              ),
            TabsActionButton(
              onTap: () {
                if (displayedSheet case ViewTabs()) {
                  ref.read(bottomSheetProvider.notifier).dismiss();
                } else {
                  ref.read(bottomSheetProvider.notifier).show(ViewTabs());
                }
              },
            ),
            MenuAnchor(
              controller: menuController,
              builder: (context, controller, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: InkWell(
                    onTap: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
                      child: Icon(Icons.more_vert),
                    ),
                  ),
                );
              },
              menuChildren: [
                MenuItemButton(
                  onPressed: () async {
                    await context.push(AboutRoute().location);
                  },
                  leadingIcon: const Icon(Icons.info),
                  child: const Text('About'),
                ),
                const Divider(),
                MenuItemButton(
                  onPressed: () async {
                    await context.push(SettingsRoute().location);
                  },
                  leadingIcon: const Icon(Icons.settings),
                  child: const Text('Settings'),
                ),
                const Divider(),
                MenuItemButton(
                  onPressed: () async {
                    await context.push(BangCategoriesRoute().location);
                  },
                  leadingIcon: const Icon(MdiIcons.exclamationThick),
                  child: const Text('Bangs'),
                ),
                if (showEarlyAccessFeatures)
                  MenuItemButton(
                    onPressed: () async {
                      await context.push(ChatArchiveListRoute().location);
                    },
                    leadingIcon: const Icon(MdiIcons.archive),
                    child: const Text('Chat Archive'),
                  ),
                const Divider(),
                if (showEarlyAccessFeatures)
                  MenuItemButton(
                    onPressed: () {
                      ref.read(createTabStreamProvider.notifier).createTab(
                            CreateTab(preferredTool: KagiTool.assistant),
                          );
                    },
                    leadingIcon: Icon(KagiTool.assistant.icon),
                    child: const Text('Assistant'),
                  ),
                MenuItemButton(
                  onPressed: () {
                    ref.read(createTabStreamProvider.notifier).createTab(
                          CreateTab(preferredTool: KagiTool.summarizer),
                        );
                  },
                  leadingIcon: Icon(KagiTool.summarizer.icon),
                  child: const Text('Summarizer'),
                ),
                MenuItemButton(
                  onPressed: () {
                    ref.read(createTabStreamProvider.notifier).createTab(
                          CreateTab(preferredTool: KagiTool.search),
                        );
                  },
                  leadingIcon: Icon(KagiTool.search.icon),
                  child: const Text('Search'),
                ),
                const Divider(),
                MenuItemButton(
                  onPressed: () async {
                    final url =
                        await activeWebView?.currentController?.getUrl();
                    if (url != null) {
                      // ignore: use_build_context_synchronously
                      await ui_helper.launchUrlFeedback(context, url);
                    }
                  },
                  leadingIcon: const Icon(Icons.open_in_browser),
                  child: const Text('Launch External'),
                ),
                MenuItemButton(
                  onPressed: () async {
                    final url =
                        await activeWebView?.currentController?.getUrl();
                    if (url != null) {
                      await Share.shareUri(url);
                    }
                  },
                  leadingIcon: const Icon(Icons.share),
                  child: const Text('Share'),
                ),
                const Divider(),
                MenuItemButton(
                  onPressed: () async {
                    await activeWebView?.currentController?.reload();
                  },
                  leadingIcon: const Icon(Icons.refresh),
                  child: const Text('Reload'),
                ),
                const Divider(),
                HookBuilder(
                  builder: (context) {
                    final history = useListenableSelector(
                      activeWebView?.page,
                      () =>
                          activeWebView?.page.value.pageHistory ??
                          (canGoBack: false, canGoForward: false),
                    );

                    return Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: (history.canGoBack)
                                ? () async {
                                    await activeWebView?.currentController
                                        ?.goBack();
                                    menuController.close();
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                        const SizedBox(height: 48, child: VerticalDivider()),
                        Expanded(
                          child: IconButton(
                            onPressed: (history.canGoForward)
                                ? () async {
                                    await activeWebView?.currentController
                                        ?.goForward();
                                    menuController.close();
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: OverlayPortal(
        controller: overlayController,
        overlayChildBuilder: (context) {
          return displayedOverlayDialog!;
        },
        child: Listener(
          onPointerDown: (displayedSheet != null)
              ? (_) {
                  ref.read(bottomSheetProvider.notifier).dismiss();
                }
              : null,
          child: HookConsumer(
            builder: (context, ref, child) {
              final webViews = ref.watch(webViewRepositoryProvider);

              return BackButtonListener(
                onBackButtonPressed: () async {
                  //Don't do anything if a child route is active
                  if (GoRouterState.of(context).topRoute?.name != 'KagiRoute') {
                    return false;
                  }

                  if (displayedSheet != null) {
                    ref.read(bottomSheetProvider.notifier).dismiss();
                    return true;
                  }

                  if (displayedOverlayDialog != null) {
                    ref.read(overlayDialogProvider.notifier).dismiss();
                    return true;
                  }

                  if (activeWebView?.page.value.pageHistory.canGoBack == true) {
                    lastBackButtonPress.value = null;

                    await activeWebView?.page.value.controller?.goBack();
                    return true;
                  }

                  if (lastBackButtonPress.value != null &&
                      DateTime.now().difference(lastBackButtonPress.value!) <
                          const Duration(seconds: 2)) {
                    lastBackButtonPress.value = null;

                    if (activeWebView?.key != null && webViews.length > 1) {
                      ref
                          .read(webViewRepositoryProvider.notifier)
                          .closeTab(activeWebView!.key!);
                      return true;
                    } else {
                      //Mark back as unhandled and navigator will pop
                      return false;
                    }
                  } else {
                    lastBackButtonPress.value = DateTime.now();
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: (webViews.length > 1)
                              ? const Text(
                                  'Please click BACK again to close current tab',
                                )
                              : const Text(
                                  'Please click BACK again to exit app',
                                ),
                        ),
                      );

                    return true;
                  }
                },
                child: Stack(
                  children: [
                    SafeArea(
                      child: AnimatedIndexedStack(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (child, animation, secondaryAnimation) =>
                                SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        ),
                        key: ValueKey(
                          (activeWebView != null)
                              ? webViews.keys
                                  .toList()
                                  .indexOf(activeWebView.page.value.key)
                              : null,
                        ),
                        index: (activeWebView != null)
                            ? webViews.keys
                                    .toList()
                                    .indexOf(activeWebView.page.value.key) +
                                1
                            : 0,
                        children: [const LandingContent(), ...webViews.values],
                      ),
                    ),
                    if (displayedSheet != null)
                      ModalBarrier(
                        color: Theme.of(context).dialogTheme.barrierColor ??
                            Colors.black54,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomSheet: (displayedSheet != null)
          ? NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.1) {
                  ref.read(bottomSheetProvider.notifier).dismiss();
                  return true;
                } else {
                  ref
                      .read(bottomSheetExtendProvider.notifier)
                      .add(notification.extent);
                }

                return false;
              },
              child: switch (displayedSheet) {
                ViewTabs() => DraggableScrollableSheet(
                    key: ValueKey(displayedSheet),
                    expand: false,
                    minChildSize: 0.1,
                    maxChildSize: _realtiveSafeArea(context),
                    builder: (context, scrollController) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        child: ViewTabsSheet(
                          sheetScrollController: scrollController,
                          onClose: () {
                            ref.read(bottomSheetProvider.notifier).dismiss();
                          },
                        ),
                      );
                    },
                  ),
                final CreateTab parameter => DraggableScrollableSheet(
                    key: ValueKey(displayedSheet),
                    expand: false,
                    initialChildSize: 0.8,
                    minChildSize: 0.1,
                    maxChildSize: _realtiveSafeArea(context),
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: SharedContentSheet(
                          key: ValueKey(parameter),
                          parameter: parameter,
                          onSubmit: (url) async {
                            await ref
                                .read(switchNewTabControllerProvider.notifier)
                                .add(url);

                            ref.read(bottomSheetProvider.notifier).dismiss();
                          },
                          onActiveToolChanged: (tool) {
                            activeKagiTool.value = tool;
                          },
                        ),
                      );
                    },
                  ),
              },
            )
          : null,
    );
  }
}
