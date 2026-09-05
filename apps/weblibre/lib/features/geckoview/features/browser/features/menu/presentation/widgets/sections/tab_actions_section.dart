/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/content_selection_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/hooks/url_cleaner_controller.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/widgets/url_cleaner_tile.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_selection_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_relation_visibility.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/background_tab_open.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/repositories/top_site_repository.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/controllers/website_title.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Actions on the tab itself.
///
/// [MenuItemType.moreDisclosure] is a position in the item list rather than a
/// row: everything the user placed after it folds away behind a "More" row
/// until it is tapped. Switching the marker off shows the whole section flat,
/// and dragging it decides how much stays in view — which is how the shipped
/// "More: Clone Tab, Export, Pin Shortcut, Fetch Feeds" split survives being
/// user-configurable.
class TabActionsSection extends HookConsumerWidget {
  final String selectedTabId;
  final List<MenuItemType> items;

  const TabActionsSection({
    super.key,
    required this.selectedTabId,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showContainerUi = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.showContainerUi,
      ),
    );
    final showMore = useState(false);

    final applicable = [
      for (final item in items)
        if (item != MenuItemType.containers || showContainerUi) item,
    ];

    final markerIndex = applicable.indexOf(MenuItemType.moreDisclosure);
    final upfront = markerIndex == -1
        ? applicable
        : applicable.sublist(0, markerIndex);
    final folded = markerIndex == -1
        ? const <MenuItemType>[]
        : applicable.sublist(markerIndex + 1);

    return buildMenuCard(
      context,
      children: [
        for (final item in upfront) _buildItem(item),
        // A marker with nothing behind it would be a "More" row that reveals an
        // empty card, so it only earns its place once something is folded.
        if (folded.isNotEmpty && !showMore.value)
          ListTile(
            leading: const Icon(Icons.more_horiz),
            title: Text(MenuItemType.moreDisclosure.label),
            subtitle: Text(folded.map((item) => item.label).join(', ')),
            trailing: const Icon(Icons.expand_more),
            onTap: () => showMore.value = true,
          )
        else
          for (final item in folded) _buildItem(item),
      ],
    );
  }

  Widget _buildItem(MenuItemType item) => switch (item) {
    MenuItemType.containers => _ContainerExpansion(
      selectedTabId: selectedTabId,
    ),
    MenuItemType.share => _ShareExpansion(selectedTabId: selectedTabId),
    MenuItemType.cloneTab => _CloneTabExpansion(selectedTabId: selectedTabId),
    MenuItemType.export => _ExportExpansion(selectedTabId: selectedTabId),
    MenuItemType.pinTopSite => _PinTopSiteTile(selectedTabId: selectedTabId),
    MenuItemType.fetchFeeds => _FetchFeedsTile(selectedTabId: selectedTabId),
    _ => const SizedBox.shrink(),
  };
}

class _ContainerExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _ContainerExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(MdiIcons.folder),
        title: const Text('Containers'),
        children: [
          buildMenuSubTile(
            'Manage Containers',
            icon: MdiIcons.folder,
            onTap: () async {
              Navigator.pop(context);
              await const ContainerListRoute().push(context);
            },
          ),

          // Assign Container
          buildMenuSubTile(
            'Assign Container',
            icon: MdiIcons.folderArrowUpDownOutline,
            onTap: () async {
              final selection = await const ContainerSelectionRoute()
                  .push<ContainerSelectionResult?>(context);

              switch (selection) {
                case ContainerSelectionSelected(:final containerId):
                  final containerData = await ref
                      .read(containerRepositoryProvider.notifier)
                      .getContainerData(containerId);

                  if (containerData != null) {
                    final tabState = ref.read(tabStateProvider(selectedTabId))!;
                    await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .assignContainer(tabState.id, containerData);
                  }
                case ContainerSelectionUnassigned():
                  final tabState = ref.read(tabStateProvider(selectedTabId))!;
                  await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .unassignContainer(tabState.id);
                case null:
                  break;
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),

          // URL relation (conditional)
          ContainerRelationUnassignedVisibility(
            child: buildMenuSubTile(
              'Assign URL to Container',
              icon: MdiIcons.webPlus,
              onTap: () async {
                final selection = await const ContainerSelectionRoute()
                    .push<ContainerSelectionResult?>(context);

                if (selection case ContainerSelectionSelected(
                  :final containerId,
                )) {
                  final containerData = await ref
                      .read(containerRepositoryProvider.notifier)
                      .getContainerData(containerId);

                  if (containerData != null) {
                    final tabState = ref.read(tabStateProvider(selectedTabId));
                    final origin = tabState?.url.origin.mapNotNull(Uri.parse);

                    if (origin != null) {
                      await ref
                          .read(containerRepositoryProvider.notifier)
                          .replaceContainer(
                            containerData.copyWith.metadata(
                              containerData.metadata.copyWith.assignedSites([
                                ...?containerData.metadata.assignedSites,
                                origin,
                              ]),
                            ),
                          );
                    }
                  }
                }

                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),

          // Unassign URL relation (conditional)
          ContainerRelationAssignedVisibility(
            child: buildMenuSubTile(
              'Unassign URL from Container',
              icon: MdiIcons.webMinus,
              onTap: () async {
                final tabState = ref.read(tabStateProvider(selectedTabId));
                final origin = tabState?.url.origin.mapNotNull(Uri.parse);

                if (origin != null) {
                  final containerId = await ref
                      .read(containerRepositoryProvider.notifier)
                      .siteAssignedContainerId(origin);

                  if (containerId != null) {
                    final containerData = await ref
                        .read(containerRepositoryProvider.notifier)
                        .getContainerData(containerId);

                    if (containerData != null) {
                      final updatedSites = containerData.metadata.assignedSites
                          ?.where((site) => site != origin)
                          .toList();

                      await ref
                          .read(containerRepositoryProvider.notifier)
                          .replaceContainer(
                            containerData.copyWith.metadata(
                              containerData.metadata.copyWith.assignedSites(
                                updatedSites,
                              ),
                            ),
                          );
                    }
                  }
                }

                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),

          // Unassign Container (conditional)
          ContainerAssignedVisibility(
            tabId: selectedTabId,
            child: buildMenuSubTile(
              'Unassign Container',
              icon: MdiIcons.folderCancelOutline,
              onTap: () async {
                final tabState = ref.read(tabStateProvider(selectedTabId))!;
                await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .unassignContainer(tabState.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareExpansion extends HookConsumerWidget {
  final String selectedTabId;

  const _ShareExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final catalogAsync = ref.watch(urlCleanerCatalogServiceProvider);
    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: selectedTabId),
    );
    // Sandbox-captured tabs: every share/copy/QR/cleaner action must operate
    // on the canonical source URL — never the loopback loader.
    final tabUrl = sandboxSourceUri ?? tabState?.url;

    final cleanedUrl = useState<Uri?>(null);
    final cleaner = useUrlCleanerController(
      sourceUrl: (cleanedUrl.value ?? tabUrl)?.toString(),
      rules: catalogAsync.value,
      cleanerEnabled: settings.urlCleanerEnabled,
      allowReferralMarketing: settings.urlCleanerAllowReferralMarketing,
      autoApply: settings.urlCleanerAutoApply,
      getCurrentUrl: () => (cleanedUrl.value ?? tabUrl)?.toString(),
      onApplyCleanedUrl: (cleanedUrlValue) {
        cleanedUrl.value = Uri.parse(cleanedUrlValue);
      },
    );

    void applyCleanUrl() {
      if (cleaner.applyCleanUrl()) {
        ui_helper.showInfoMessage(context, 'URL cleaned');
      }
    }

    void applySelectedTrackingRemovals(String previewUrl) {
      if (cleaner.applyPreviewUrl(previewUrl)) {
        ui_helper.showInfoMessage(context, 'URL preview applied');
      }
    }

    final effectiveUrl = cleanedUrl.value ?? tabUrl;
    final cleaningHappened = cleanedUrl.value != null;
    final hasActiveTracking = cleaner.result?.removedParams.isNotEmpty ?? false;
    final cleanedTrailing = cleaningHappened
        ? Icon(
            hasActiveTracking
                ? MdiIcons.shieldLinkVariantOutline
                : MdiIcons.shieldLinkVariant,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          )
        : null;
    final showCleanerTile = tabUrl != null && cleaner.showTile;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(Icons.share),
        title: const Text('Share'),
        children: [
          if (showCleanerTile)
            UrlCleanerTile(
              result: cleaner.details!,
              currentUrl: effectiveUrl?.toString() ?? '',
              allowReferralMarketing: settings.urlCleanerAllowReferralMarketing,
              onClean: applyCleanUrl,
              onApplySelectedRemovals: applySelectedTrackingRemovals,
            ),

          // Copy Address
          buildMenuSubTile(
            'Copy Address',
            icon: MdiIcons.contentCopy,
            trailing: cleanedTrailing,
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: effectiveUrl.toString()),
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Share Screenshot
          buildMenuSubTile(
            'Share Screenshot',
            icon: Icons.mobile_screen_share,
            onTap: () async {
              final screenshot = await ref
                  .read(selectedTabSessionProvider)
                  .requestScreenshot();

              final ts = ref.read(tabStateProvider(selectedTabId))!;

              if (screenshot != null) {
                final png = await encodeScreenshotAsPng(screenshot);

                if (png != null) {
                  final file = XFile.fromData(png, mimeType: 'image/png');

                  await SharePlus.instance.share(
                    ShareParams(files: [file], subject: ts.titleOrAuthority),
                  );
                }
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Share Link
          buildMenuSubTile(
            'Share Link',
            icon: Icons.share,
            trailing: cleanedTrailing,
            onTap: () async {
              await SharePlus.instance.share(ShareParams(uri: effectiveUrl));
              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Send To Device (conditional)
          _SendToDeviceExpansion(selectedTabId: selectedTabId),

          // Show QR Code
          buildMenuSubTile(
            'Show QR Code',
            icon: Icons.qr_code,
            trailing: cleanedTrailing,
            onTap: () async {
              if (context.mounted) {
                Navigator.pop(context);
                await showQrCode(context, effectiveUrl.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SendToDeviceExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _SendToDeviceExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(syncIsAuthenticatedProvider);
    final devices = ref.watch(syncDevicesProvider);

    if (!isAuthenticated) return const SizedBox.shrink();

    return Skeletonizer(
      enabled: devices.isLoading && devices.value == null,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(left: 56, right: 16),
          leading: const Icon(Icons.send_outlined, size: 20),
          title: const Text('Send To Device', style: TextStyle(fontSize: 14)),
          children: devices.when(
            data: (deviceList) {
              final targets = deviceList
                  .where(
                    (device) => !device.isCurrentDevice && device.canSendTab,
                  )
                  .toList(growable: false);

              if (targets.isEmpty) {
                return [
                  const ListTile(
                    contentPadding: EdgeInsets.only(left: 72, right: 16),
                    title: Text(
                      'No target devices',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ];
              }

              return targets
                  .map(
                    (device) => ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 72,
                        right: 16,
                      ),
                      leading: const Icon(Icons.devices_other, size: 18),
                      title: Text(
                        device.displayName,
                        style: const TextStyle(fontSize: 13),
                      ),
                      dense: true,
                      onTap: () async {
                        final tabState = ref.read(
                          tabStateProvider(selectedTabId),
                        );
                        if (tabState == null) return;

                        final sendUrl =
                            ref.read(
                              sandboxSourceUriForTabProvider(
                                tabId: tabState.id,
                              ),
                            ) ??
                            tabState.url;
                        final title = tabState.title.isNotEmpty
                            ? tabState.title
                            : sendUrl.toString();

                        final success = await ref
                            .read(syncRepositoryProvider.notifier)
                            .sendTabToDevice(
                              deviceId: device.deviceId,
                              title: title,
                              url: sendUrl.toString(),
                              private: tabState.tabMode == TabMode.private,
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ui_helper.showInfoMessage(
                              context,
                              'Sent tab to ${device.displayName}',
                            );
                          } else {
                            ui_helper.showErrorMessage(
                              context,
                              'Failed to send tab',
                            );
                          }
                        }
                      },
                    ),
                  )
                  .toList(growable: false);
            },
            loading: () => const [
              ListTile(
                contentPadding: EdgeInsets.only(left: 72, right: 16),
                leading: Icon(Icons.devices_other, size: 18),
                title: Text(
                  'Loading devices...',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
            error: (_, _) => const [
              ListTile(
                contentPadding: EdgeInsets.only(left: 72, right: 16),
                title: Text(
                  'Failed to load devices',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloneTabExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _CloneTabExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(MdiIcons.contentDuplicate),
        title: const Text('Clone Tab'),
        children: [
          buildMenuSubTile(
            'Regular',
            icon: MdiIcons.tab,
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;
              final cloneUrl =
                  ref.read(
                    sandboxSourceUriForTabProvider(tabId: tabState.id),
                  ) ??
                  tabState.url;
              final containerData = await ref
                  .read(tabDataRepositoryProvider.notifier)
                  .getTabContainerData(selectedTabId);

              final tabId = (tabState.tabMode is! RegularTabMode)
                  ? await ref
                        .read(tabRepositoryProvider.notifier)
                        .addTab(
                          tabMode: TabMode.regular,
                          url: cloneUrl,
                          containerSelection: containerData == null
                              ? const TabContainerSelection.unassigned()
                              : TabContainerSelection.specific(containerData),
                          selectTab: false,
                        )
                  : await ref
                        .read(tabRepositoryProvider.notifier)
                        .duplicateTab(
                          selectTabId: selectedTabId,
                          containerData: containerData,
                          selectTab: false,
                        );

              if (context.mounted) {
                handleBackgroundTabOpened(context, ref, tabId);
                Navigator.pop(context);
              }
            },
          ),
          buildMenuSubTile(
            'Private',
            icon: MdiIcons.dominoMask,
            iconColor: appColors.privateTabPurple,
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;
              final cloneUrl =
                  ref.read(
                    sandboxSourceUriForTabProvider(tabId: tabState.id),
                  ) ??
                  tabState.url;
              final containerData = await ref
                  .read(tabDataRepositoryProvider.notifier)
                  .getTabContainerData(selectedTabId);

              final tabId = (tabState.tabMode is! PrivateTabMode)
                  ? await ref
                        .read(tabRepositoryProvider.notifier)
                        .addTab(
                          url: cloneUrl,
                          tabMode: TabMode.private,
                          containerSelection: containerData == null
                              ? const TabContainerSelection.unassigned()
                              : TabContainerSelection.specific(containerData),
                          selectTab: false,
                        )
                  : await ref
                        .read(tabRepositoryProvider.notifier)
                        .duplicateTab(
                          selectTabId: selectedTabId,
                          containerData: containerData,
                          selectTab: false,
                        );

              if (context.mounted) {
                handleBackgroundTabOpened(context, ref, tabId);
                Navigator.pop(context);
              }
            },
          ),
          if (settings.showIsolatedTabUi)
            buildMenuSubTile(
              'Isolated',
              icon: MdiIcons.snowflake,
              iconColor: appColors.isolatedTabTeal,
              onTap: () async {
                final tabState = ref.read(tabStateProvider(selectedTabId))!;
                final cloneUrl =
                    ref.read(
                      sandboxSourceUriForTabProvider(tabId: tabState.id),
                    ) ??
                    tabState.url;
                final containerData = await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .getTabContainerData(selectedTabId);

                final tabId = await ref
                    .read(tabRepositoryProvider.notifier)
                    .addTab(
                      url: cloneUrl,
                      tabMode: TabMode.newIsolated(),
                      containerSelection: containerData == null
                          ? const TabContainerSelection.unassigned()
                          : TabContainerSelection.specific(containerData),
                      selectTab: false,
                    );

                if (context.mounted) {
                  handleBackgroundTabOpened(context, ref, tabId);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ExportExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _ExportExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(MdiIcons.fileExport),
        title: const Text('Export'),
        children: [
          // Copy as Markdown
          buildMenuSubTile(
            'Copy as Markdown',
            // ignore: deprecated_member_use
            icon: MdiIcons.languageMarkdownOutline,
            onTap: () async {
              await _handleMarkdownExport(context, ref, selectedTabId, (
                content,
                fileName,
              ) async {
                await Clipboard.setData(ClipboardData(text: content));
                if (context.mounted) {
                  ui_helper.showInfoMessage(
                    context,
                    'Markdown copied to clipboard',
                  );
                }
              }, const Text('Copy as Markdown'));
            },
          ),

          // Export as Markdown
          buildMenuSubTile(
            'Export as Markdown',
            // ignore: deprecated_member_use
            icon: MdiIcons.languageMarkdown,
            onTap: () async {
              await _handleMarkdownExport(context, ref, selectedTabId, (
                content,
                fileName,
              ) async {
                await FilePicker.saveFile(
                  fileName: fileName ?? 'page',
                  type: FileType.custom,
                  allowedExtensions: ['md'],
                  bytes: utf8.encode(content),
                );
              }, const Text('Export as Markdown'));
            },
          ),

          // Export as PDF
          buildMenuSubTile(
            'Export as PDF',
            icon: MdiIcons.filePdfBox,
            onTap: () async {
              await ref
                  .read(tabSessionProvider(tabId: selectedTabId).notifier)
                  .saveToPdf();
              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Export as PNG
          buildMenuSubTile(
            'Export as PNG',
            icon: MdiIcons.fileImage,
            onTap: () async {
              final screenshot = await ref
                  .read(selectedTabSessionProvider)
                  .requestScreenshot();

              final ts = ref.read(tabStateProvider(selectedTabId))!;

              if (screenshot != null) {
                final png = await encodeScreenshotAsPng(screenshot);

                if (png != null) {
                  await FilePicker.saveFile(
                    fileName: '${ts.titleOrAuthority}.png',
                    type: FileType.custom,
                    allowedExtensions: ['png'],
                    bytes: png,
                  );
                }
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Print
          buildMenuSubTile(
            'Print',
            icon: MdiIcons.printer,
            onTap: () async {
              try {
                await ref
                    .read(tabSessionProvider(tabId: selectedTabId).notifier)
                    .printContent();
              } catch (e) {
                if (context.mounted) {
                  ui_helper.showErrorMessage(context, 'Failed to print page');
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleMarkdownExport(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    Future<void> Function(String content, String? fileName) shareAction,
    Widget title,
  ) async {
    final tabData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabDataById(tabId);

    if (tabData == null || tabData.fullContentMarkdown.isEmpty) {
      if (context.mounted) Navigator.pop(context);
      return;
    }

    final shouldShowDialog =
        tabData.isProbablyReaderable == true &&
        tabData.extractedContentMarkdown.isNotEmpty;

    if (shouldShowDialog && context.mounted) {
      Navigator.pop(context);
      await showContentSelectionDialog(
        context,
        title: title,
        tabData: tabData,
        shareMarkdownAction: shareAction,
      );
    } else {
      await shareAction(
        tabData.fullContentMarkdown!,
        tabData.title ?? tabData.url?.authority,
      );
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _PinTopSiteTile extends HookConsumerWidget {
  final String selectedTabId;

  const _PinTopSiteTile({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: selectedTabId),
    );
    final url = sandboxSourceUri ?? tabState?.url;

    final isPinned = useCachedFuture(
      () => url != null
          ? ref.read(topSiteRepositoryProvider.notifier).isPinnedTopSiteUrl(url)
          : Future.value(false),
      [url],
    );

    final pinned = isPinned.data ?? false;

    return ListTile(
      leading: Icon(pinned ? MdiIcons.pinOff : MdiIcons.pin),
      title: Text(pinned ? 'Unpin from Shortcuts' : 'Pin to Shortcuts'),
      onTap: () async {
        if (tabState == null || url == null) return;
        Navigator.pop(context);
        try {
          if (pinned) {
            await ref
                .read(topSiteRepositoryProvider.notifier)
                .unpinSiteByUrl(url);
            if (context.mounted) {
              ui_helper.showInfoMessage(context, 'Unpinned from Shortcuts');
            }
          } else {
            await ref
                .read(topSiteRepositoryProvider.notifier)
                .addPinnedSite(title: tabState.titleOrAuthority, url: url);
            if (context.mounted) {
              ui_helper.showInfoMessage(context, 'Pinned to Shortcuts');
            }
          }
        } catch (e) {
          if (context.mounted) {
            ui_helper.showErrorMessage(context, 'Failed to update Shortcuts');
          }
        }
      },
    );
  }
}

class _FetchFeedsTile extends HookConsumerWidget {
  final String selectedTabId;

  const _FetchFeedsTile({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFeeds = useState(false);

    if (!showFeeds.value) {
      return ListTile(
        leading: const Icon(Icons.rss_feed),
        title: const Text('Fetch Feeds on Page'),
        onTap: () {
          showFeeds.value = true;
        },
      );
    }

    final feedsAsync = ref.watch(websiteFeedProviderProvider(selectedTabId));

    return feedsAsync.when(
      skipLoadingOnReload: true,
      data: (feeds) {
        if (feeds.value.isEmpty) {
          return const ListTile(
            leading: Icon(Icons.rss_feed_outlined),
            title: Text('No Web Feeds Found'),
            enabled: false,
          );
        }

        return ListTile(
          leading: const Icon(Icons.rss_feed),
          title: const Text('Available Web Feeds'),
          trailing: Badge(label: Text(feeds.value!.length.toString())),
          onTap: () async {
            Navigator.pop(context);
            await SelectFeedDialogRoute(
              feedsJson: jsonEncode(
                feeds.value!.map((feed) => feed.toString()).toList(),
              ),
            ).push(context);
          },
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const ListTile(
        leading: Icon(Icons.rss_feed),
        title: Text('Fetching Web Feeds...'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
