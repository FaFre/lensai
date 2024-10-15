import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:lensai/features/geckoview/features/browser/domain/services/create_tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/services/engine_settings.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/dialogs/web_page_dialog.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/app_bar_title.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/sheets/create_tab.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/sheets/view_tabs.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:lensai/features/geckoview/features/controllers/bottom_sheet.dart';
import 'package:lensai/features/geckoview/features/controllers/overlay_dialog.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/controllers/find_in_page_visibility.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/widgets/find_in_page.dart';
import 'package:lensai/features/geckoview/features/readerview/presentation/widgets/reader_appearance_button.dart';
import 'package:lensai/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:lensai/features/kagi/data/services/session.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/presentation/hooks/overlay_portal_controller.dart';
import 'package:lensai/utils/ui_helper.dart' as ui_helper;
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';

class BrowserScreen extends HookConsumerWidget {
  const BrowserScreen({super.key});

  double _realtiveSafeArea(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return 1.0 - (mediaQuery.padding.top / mediaQuery.size.height);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedSheet = ref.watch(bottomSheetControllerProvider);
    final displayedOverlayDialog = ref.watch(overlayDialogControllerProvider);

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

    final selectedTabId =
        ref.watch(selectedTabStateProvider.select((value) => value?.id));

    final menuController = useMemoized(() => MenuController());

    final lastBackButtonPress = useRef<DateTime?>(null);

    final overlayController = useOverlayPortalController();

    final activeKagiTool = useValueNotifier<KagiTool?>(null, [displayedSheet]);

    ref.listen(
      overlayDialogControllerProvider,
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
          .select((value) => value.valueOrNull?.enableJavascript),
      (previous, next) async {
        if (next != null) {
          await ref.read(engineSettingsServiceProvider).javaScriptEnabled(next);
        }
      },
    );

    ref.listen(
      settingsRepositoryProvider
          .select((value) => value.valueOrNull?.kagiSession),
      (previous, next) async {
        if (next != null && next.isNotEmpty) {
          await ref
              .read(kagiSessionServiceProvider.notifier)
              .setKagiSession(next);
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
          title: (selectedTabId != null)
              ? Consumer(
                  builder: (context, ref, child) {
                    final tabState = ref.watch(tabStateProvider(selectedTabId));

                    return (tabState != null)
                        ? AppBarTitle(
                            tab: tabState,
                            onTap: () {
                              ref
                                  .read(
                                    overlayDialogControllerProvider.notifier,
                                  )
                                  .show(
                                    WebPageDialog(
                                      url: tabState.url,
                                      precachedInfo: tabState,
                                      onDismiss: ref
                                          .read(
                                            overlayDialogControllerProvider
                                                .notifier,
                                          )
                                          .dismiss,
                                    ),
                                  );
                            },
                          )
                        : const SizedBox.shrink();
                  },
                )
              : HookBuilder(
                  builder: (context) {
                    final activeTool = useListenableSelector(
                      activeKagiTool,
                      () {
                        if (displayedSheet is CreateTabSheetWidget) {
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
                                  CreateTabSheet(
                                    preferredTool: KagiTool.search,
                                  ),
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
                                  CreateTabSheet(
                                    preferredTool: KagiTool.summarizer,
                                  ),
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
                                    CreateTabSheet(
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
            if (selectedTabId != null) ReaderButton(),
            if (quickAction != null)
              InkWell(
                onTap: () async {
                  var tab = CreateTabSheet(
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

                    tab = CreateTabSheet(
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
              isActive: displayedSheet is ViewTabsSheet,
              onTap: () {
                if (displayedSheet case ViewTabsSheet()) {
                  ref.read(bottomSheetControllerProvider.notifier).dismiss();
                } else {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .show(ViewTabsSheet());
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
                            CreateTabSheet(preferredTool: KagiTool.assistant),
                          );
                    },
                    leadingIcon: Icon(KagiTool.assistant.icon),
                    child: const Text('Assistant'),
                  ),
                MenuItemButton(
                  onPressed: () {
                    ref.read(createTabStreamProvider.notifier).createTab(
                          CreateTabSheet(preferredTool: KagiTool.summarizer),
                        );
                  },
                  leadingIcon: Icon(KagiTool.summarizer.icon),
                  child: const Text('Summarizer'),
                ),
                MenuItemButton(
                  onPressed: () {
                    ref.read(createTabStreamProvider.notifier).createTab(
                          CreateTabSheet(preferredTool: KagiTool.search),
                        );
                  },
                  leadingIcon: Icon(KagiTool.search.icon),
                  child: const Text('Search'),
                ),
                const Divider(),
                if (selectedTabId != null)
                  MenuItemButton(
                    onPressed: () async {
                      final tabState =
                          ref.read(tabStateProvider(selectedTabId));

                      if (tabState?.url case final Uri url) {
                        await ui_helper.launchUrlFeedback(context, url);
                      }
                    },
                    leadingIcon: const Icon(Icons.open_in_browser),
                    child: const Text('Launch External'),
                  ),
                if (selectedTabId != null)
                  MenuItemButton(
                    onPressed: () async {
                      final tabState =
                          ref.read(tabStateProvider(selectedTabId));

                      if (tabState?.url case final Uri url) {
                        await Share.shareUri(url);
                      }
                    },
                    leadingIcon: const Icon(Icons.share),
                    child: const Text('Share'),
                  ),
                if (selectedTabId != null) const Divider(),
                if (selectedTabId != null)
                  MenuItemButton(
                    onPressed: () {
                      ref
                          .read(findInPageVisibilityControllerProvider.notifier)
                          .show();
                    },
                    leadingIcon: const Icon(Icons.search),
                    child: const Text('Find in page'),
                  ),
                if (selectedTabId != null) const Divider(),
                if (selectedTabId != null)
                  MenuItemButton(
                    onPressed: () async {
                      final controller =
                          ref.read(tabSessionProvider(selectedTabId).notifier);

                      await controller.reload();
                      menuController.close();
                    },
                    leadingIcon: const Icon(Icons.refresh),
                    child: const Text('Reload'),
                  ),
                if (selectedTabId != null) const Divider(),
                if (selectedTabId != null)
                  Consumer(
                    builder: (context, ref, child) {
                      final history = ref.watch(
                        tabStateProvider(selectedTabId)
                            .select((value) => value?.historyState),
                      );

                      return Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: (history?.canGoBack == true)
                                  ? () async {
                                      final controller = ref.read(
                                        tabSessionProvider(
                                          selectedTabId,
                                        ).notifier,
                                      );

                                      await controller.goBack();
                                      menuController.close();
                                    }
                                  : null,
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ),
                          const SizedBox(height: 48, child: VerticalDivider()),
                          Expanded(
                            child: IconButton(
                              onPressed: (history?.canGoForward == true)
                                  ? () async {
                                      final controller = ref.read(
                                        tabSessionProvider(
                                          selectedTabId,
                                        ).notifier,
                                      );

                                      await controller.goForward();
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
                  ref.read(bottomSheetControllerProvider.notifier).dismiss();
                }
              : null,
          child: HookConsumer(
            builder: (context, ref, child) {
              return BackButtonListener(
                onBackButtonPressed: () async {
                  final tabState = (selectedTabId != null)
                      ? ref.read(tabStateProvider(selectedTabId))
                      : null;

                  final tabCount =
                      ref.read(tabStatesProvider.select((tabs) => tabs.length));

                  //Don't do anything if a child route is active
                  if (GoRouterState.of(context).topRoute?.path !=
                      BrowserRoute().location) {
                    return false;
                  }

                  if (displayedSheet != null) {
                    ref.read(bottomSheetControllerProvider.notifier).dismiss();
                    return true;
                  }

                  if (displayedOverlayDialog != null) {
                    ref
                        .read(overlayDialogControllerProvider.notifier)
                        .dismiss();
                    return true;
                  }

                  if (tabState?.historyState.canGoBack == true) {
                    lastBackButtonPress.value = null;

                    final controller = ref.read(
                      tabSessionProvider(selectedTabId).notifier,
                    );

                    await controller.goBack();
                    return true;
                  }

                  if (lastBackButtonPress.value != null &&
                      DateTime.now().difference(lastBackButtonPress.value!) <
                          const Duration(seconds: 2)) {
                    lastBackButtonPress.value = null;

                    if (tabState != null && tabCount > 1) {
                      await ref
                          .read(tabStatesProvider.notifier)
                          .closeTab(tabState.id);
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
                          content: (tabCount > 1)
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
                      child: Stack(
                        children: [
                          GeckoView(
                            preInitializationStep: () async {
                              await ref
                                  .read(eventServiceProvider)
                                  .fragmentReadyStateEvents
                                  .firstWhere((state) => state == true)
                                  .timeout(
                                const Duration(seconds: 3),
                                onTimeout: () {
                                  logger.e(
                                    'Browser fragement not reported ready, trying to intitialize anyways',
                                  );
                                  return true;
                                },
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Consumer(
                              builder: (context, ref, child) {
                                final value = ref.watch(
                                  selectedTabStateProvider.select(
                                    (state) => state?.progress ?? 100,
                                  ),
                                );

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
                            child: Consumer(
                              builder: (context, ref, child) {
                                final value = ref.watch(
                                  selectedTabStateProvider.select(
                                    (state) => EdgeInsets.only(
                                      bottom: (state?.progress != null &&
                                              state!.progress < 100)
                                          ? 4.0
                                          : 0.0,
                                    ),
                                  ),
                                );

                                return FindInPageWidget(padding: value);
                              },
                            ),
                          ),
                        ],
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
      floatingActionButton: ReaderAppearanceButton(),
      bottomSheet: (displayedSheet != null)
          ? NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.1) {
                  ref.read(bottomSheetControllerProvider.notifier).dismiss();
                  return true;
                } else {
                  ref
                      .read(bottomSheetExtendProvider.notifier)
                      .add(notification.extent);
                }

                return false;
              },
              child: switch (displayedSheet) {
                ViewTabsSheet() => DraggableScrollableSheet(
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
                        child: ViewTabsSheetWidget(
                          sheetScrollController: scrollController,
                          onClose: () {
                            ref
                                .read(bottomSheetControllerProvider.notifier)
                                .dismiss();
                          },
                        ),
                      );
                    },
                  ),
                final CreateTabSheet parameter => DraggableScrollableSheet(
                    key: ValueKey(displayedSheet),
                    expand: false,
                    initialChildSize: 0.8,
                    minChildSize: 0.1,
                    maxChildSize: _realtiveSafeArea(context),
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: CreateTabSheetWidget(
                          key: ValueKey(parameter),
                          parameter: parameter,
                          onSubmit: (url) async {
                            await ref
                                .read(tabRepositoryProvider.notifier)
                                .addTab(url: url);

                            ref
                                .read(bottomSheetControllerProvider.notifier)
                                .dismiss();
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
