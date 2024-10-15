import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/dialogs/tab_action.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tab_preview.dart';
import 'package:lensai/features/geckoview/features/controllers/overlay_dialog.dart';
import 'package:lensai/features/geckoview/features/topics/domain/providers/selected_topic.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/tab_link.dart';
import 'package:lensai/features/geckoview/features/topics/presentation/widgets/topic_chips.dart';

class _SliverHeaderDelagate extends SliverPersistentHeaderDelegate {
  static const _headerSize = 104.0;

  final VoidCallback onClose;

  _SliverHeaderDelagate({required this.onClose});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      child: Consumer(
        builder: (context, ref, child) {
          //Fix layout issue https://github.com/flutter/flutter/issues/78748#issuecomment-1194680555
          return Align(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(tabRepositoryProvider.notifier)
                            .addTab(url: Uri.https('kagi.com'));

                        onClose();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Tab'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final topic = ref.read(selectedTopicProvider);
                        await ref
                            .read(tabLinkRepositoryProvider.notifier)
                            .closeAllTabs(topic);

                        onClose();
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Close All'),
                    ),
                  ],
                ),
                TopicChips(),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  double get minExtent => _headerSize;

  @override
  double get maxExtent => _headerSize;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class ViewTabsSheetWidget extends HookConsumerWidget {
  final ScrollController sheetScrollController;
  final VoidCallback onClose;

  const ViewTabsSheetWidget({
    required this.onClose,
    required this.sheetScrollController,
    super.key,
  });

  double _calculateItemHeight({
    required double screenWidth,
    required double childAspectRatio,
    required double horizontalPadding,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
    required int crossAxisCount,
  }) {
    final totalHorizontalPadding = horizontalPadding * 2;
    final totalCrossAxisSpacing = crossAxisSpacing * (crossAxisCount - 1);
    final availableWidth =
        screenWidth - totalHorizontalPadding - totalCrossAxisSpacing;
    final itemWidth = availableWidth / crossAxisCount;
    final itemHeight = itemWidth / childAspectRatio;
    final totalItemHeight = itemHeight + mainAxisSpacing;

    return totalItemHeight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      controller: sheetScrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelagate(onClose: onClose),
        ),
        HookConsumer(
          builder: (context, ref, child) {
            final topic = ref.watch(selectedTopicProvider);
            final availableTabs = ref
                .watch(
                  availableTabIdsProvider(topic).select(
                    (value) => EquatableCollection(
                      value.valueOrNull ?? [],
                      immutable: true,
                    ),
                  ),
                )
                .collection;
            final activeTab = ref.watch(selectedTabProvider);

            final itemHeight = useMemoized(
              () => _calculateItemHeight(
                screenWidth: MediaQuery.of(context).size.width,
                childAspectRatio: 0.75,
                horizontalPadding: 4.0,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                crossAxisCount: 2,
              ),
              [MediaQuery.of(context).size.width],
            );

            useEffect(
              () {
                final index =
                    availableTabs.indexWhere((webView) => webView == activeTab);

                if (index > -1) {
                  final reversedIndex = availableTabs.length - 1 - index;
                  final offset = (reversedIndex ~/ 2) * itemHeight;

                  if (offset != sheetScrollController.offset) {
                    unawaited(
                      sheetScrollController.animateTo(
                        offset,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      ),
                    );
                  }
                }

                return null;
              },
              [availableTabs, activeTab],
            );

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              sliver: SliverGrid.count(
                //Sync values for itemHeight calculation _calculateItemHeight
                childAspectRatio: 0.75,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                crossAxisCount: 2,
                children: availableTabs.reversed
                    .map(
                      (tabId) => Consumer(
                        key: ValueKey(tabId),
                        builder: (context, ref, child) {
                          final tab = ref.watch(tabStateProvider(tabId));

                          return (tab != null)
                              ? TabPreview(
                                  tab: tab,
                                  isActive: tabId == activeTab,
                                  onTap: () async {
                                    if (tabId != activeTab) {
                                      //Close first to avoid rebuilds
                                      onClose();
                                      await ref
                                          .read(
                                            tabRepositoryProvider.notifier,
                                          )
                                          .selectTab(tab.id);
                                    } else {
                                      onClose();
                                    }
                                  },
                                  onLongPress: () {
                                    ref
                                        .read(
                                          overlayDialogControllerProvider
                                              .notifier,
                                        )
                                        .show(
                                          TabActionDialog(
                                            initialTab: tab,
                                            onDismiss: ref
                                                .read(
                                                  overlayDialogControllerProvider
                                                      .notifier,
                                                )
                                                .dismiss,
                                          ),
                                        );
                                  },
                                  onDelete: () async {
                                    await ref
                                        .read(
                                          tabRepositoryProvider.notifier,
                                        )
                                        .closeTab(tab.id);
                                  },
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
