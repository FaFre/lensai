import 'package:animations/animations.dart';
import 'package:bang_navigator/core/routing/routes.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/sheet.dart';
import 'package:bang_navigator/features/search_browser/domain/providers.dart';
import 'package:bang_navigator/features/search_browser/domain/services/create_tab.dart';
import 'package:bang_navigator/features/search_browser/domain/services/session.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/app_bar_title.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/landing/content.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/sheets/shared_content_sheet.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/sheets/view_tabs_sheet.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/tabs_action_button.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/web_view/domain/repositories/web_view.dart';
import 'package:bang_navigator/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:bang_navigator/features/web_view/presentation/widgets/web_page_dialog.dart';
import 'package:bang_navigator/presentation/hooks/listenable_callback.dart';
import 'package:bang_navigator/presentation/hooks/overlay_portal_controller.dart';
import 'package:bang_navigator/presentation/widgets/animated_indexed_stack.dart';
import 'package:bang_navigator/utils/ui_helper.dart' as ui_helper;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class KagiScreen extends HookConsumerWidget {
  const KagiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedSheet = ref.watch(bottomSheetProvider);
    final displayedOverlayDialog = ref.watch(overlayDialogProvider);

    final lastBackButtonPress = useRef<DateTime?>(null);
    final webViewController = useRef<InAppWebViewController?>(null);

    final overlayController = useOverlayPortalController();

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: AppBarTitle(
          onTap: () {
            final page = ref.read(webViewTabControllerProvider)?.page.value;

            if (page != null) {
              ref.watch(overlayDialogProvider.notifier).show(
                    WebPageDialog(
                      page: page,
                      webViewController: webViewController.value,
                      onDismiss:
                          ref.watch(overlayDialogProvider.notifier).dismiss,
                    ),
                  );
            }
          },
        ),
        actions: [
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
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
              );
            },
            menuChildren: [
              HookConsumer(
                builder: (context, ref, child) {
                  final activeWebView = ref.watch(webViewTabControllerProvider);
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
                                  await webViewController.value?.goBack();
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
                                  await webViewController.value?.goForward();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              MenuItemButton(
                onPressed: () async {
                  await webViewController.value?.reload();
                },
                leadingIcon: const Icon(Icons.refresh),
                child: const Text('Reload'),
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
                  final url = await webViewController.value?.getUrl();
                  if (url != null) {
                    await Share.shareUri(url);
                  }
                },
                leadingIcon: const Icon(Icons.share),
                child: const Text('Share'),
              ),
              MenuItemButton(
                onPressed: () async {
                  final url = await webViewController.value?.getUrl();
                  if (url != null) {
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (context.mounted) {
                        ui_helper.showErrorMessage(
                          context,
                          'Could not launch URL ($url)',
                        );
                      }
                    }
                  }
                },
                leadingIcon: const Icon(Icons.open_in_browser),
                child: const Text('Launch External'),
              ),
              const Divider(),
              MenuItemButton(
                onPressed: () {
                  ref.read(createTabStreamProvider.notifier).createTab(
                        CreateTab(preferredTool: KagiTool.search),
                      );
                },
                leadingIcon: const Icon(MdiIcons.searchWeb),
                child: const Text('Search'),
              ),
              MenuItemButton(
                onPressed: () {
                  ref.read(createTabStreamProvider.notifier).createTab(
                        CreateTab(preferredTool: KagiTool.assistant),
                      );
                },
                leadingIcon: const Icon(MdiIcons.brain),
                child: const Text('Assistant'),
              ),
              MenuItemButton(
                onPressed: () {
                  ref.read(createTabStreamProvider.notifier).createTab(
                        CreateTab(preferredTool: KagiTool.summarizer),
                      );
                },
                leadingIcon: const Icon(MdiIcons.text),
                child: const Text('Summarizer'),
              ),
              const Divider(),
              MenuItemButton(
                onPressed: () async {
                  await context.push(AboutRoute().location);
                },
                leadingIcon: const Icon(Icons.info),
                child: const Text('About'),
              ),
            ],
          ),
        ],
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
              final activeWebView = ref.watch(webViewTabControllerProvider);
              useListenableCallback(activeWebView?.page, () {
                webViewController.value = activeWebView?.page.value.controller;
              });

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
                      await ref
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
                child: AnimatedIndexedStack(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation, secondaryAnimation) =>
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
                }

                return false;
              },
              child: switch (displayedSheet) {
                ViewTabs() => DraggableScrollableSheet(
                    expand: false,
                    minChildSize: 0.1,
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: ViewTabsSheet(
                          onClose: () {
                            ref.read(bottomSheetProvider.notifier).dismiss();
                          },
                        ),
                      );
                    },
                  ),
                final CreateTab parameter => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.8,
                    minChildSize: 0.1,
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: SharedContentSheet(
                          key: ObjectKey(parameter),
                          parameter: parameter,
                          onSubmit: (url) async {
                            await ref
                                .read(switchNewTabControllerProvider.notifier)
                                .add(url);

                            ref.read(bottomSheetProvider.notifier).dismiss();
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
