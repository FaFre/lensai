import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/web_view/domain/entities/abstract/tab.dart';
import 'package:lensai/features/web_view/domain/repositories/web_view.dart';
import 'package:lensai/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:lensai/features/web_view/presentation/widgets/web_view_tab.dart';

class _SliverHeaderDelagate extends SliverPersistentHeaderDelegate {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await ref
                        .read(switchNewTabControllerProvider.notifier)
                        .add(Uri.https('kagi.com'));

                    onClose();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Tab'),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(webViewRepositoryProvider.notifier).closeAllTabs();
                    onClose();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Close All'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class ViewTabsSheet extends HookConsumerWidget {
  final ScrollController sheetScrollController;
  final VoidCallback onClose;

  const ViewTabsSheet({
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
            final tabs = ref.watch(
              webViewRepositoryProvider.select((tabs) => tabs.values.toList()),
            );
            final activeTab = ref.watch(
              webViewTabControllerProvider.select(
                (webView) => webView?.tabId,
              ),
            );

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
                    tabs.indexWhere((webView) => webView.tabId == activeTab);

                if (index > -1) {
                  final reversedIndex = tabs.length - 1 - index;
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
              [],
            );

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              sliver: SliverGrid.count(
                //Sync values for itemHeight calculation _calculateItemHeight
                childAspectRatio: 0.75,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                crossAxisCount: 2,
                children: tabs.reversed
                    .map(
                      (webView) => HookBuilder(
                        key: ValueKey(webView.tabId),
                        builder: (context) {
                          final tab = useValueListenable(webView.page) as ITab;

                          return WebViewTab(
                            tab: tab,
                            isActive: webView.tabId == activeTab,
                            onClose: onClose,
                          );
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
