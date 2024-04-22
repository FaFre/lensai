import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kagi_bang_bang/features/web_view/domain/repositories/web_view.dart';
import 'package:kagi_bang_bang/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:kagi_bang_bang/features/web_view/presentation/widgets/web_view_tab.dart';

class ViewTabsSheet extends HookConsumerWidget {
  final VoidCallback onClose;

  const ViewTabsSheet({required this.onClose, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
              onPressed: () async {
                await ref
                    .read(webViewRepositoryProvider.notifier)
                    .closeAllTabs();
              },
              icon: const Icon(Icons.delete),
              label: const Text('Close All'),
            ),
          ],
        ),
        Consumer(
          builder: (context, ref, child) {
            final tabs = ref.watch(
              webViewRepositoryProvider.select((tabs) => tabs.values),
            );
            final activeTab = ref.watch(
              webViewTabControllerProvider.select(
                (webView) => webView?.page.value.key,
              ),
            );

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.75,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              crossAxisCount: 2,
              children: tabs
                  .map(
                    (webView) => WebViewTab(
                      webView: webView,
                      isActive: webView.key == activeTab,
                      onClose: onClose,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
