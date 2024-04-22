import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kagi_bang_bang/features/web_view/domain/repositories/web_view.dart';
import 'package:kagi_bang_bang/features/web_view/presentation/widgets/favicon.dart';
import 'package:kagi_bang_bang/features/web_view/presentation/widgets/web_view.dart';

class WebViewTab extends HookConsumerWidget {
  final WebView webView;
  final bool isActive;

  final VoidCallback onClose;

  const WebViewTab({
    required this.webView,
    required this.isActive,
    required this.onClose,
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final page = useValueListenable(webView.page);

    return Container(
      key: UniqueKey(),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outline,
          width: isActive ? 2.0 : 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          onTap: () {
            if (!isActive) {
              ref.read(webViewTabControllerProvider.notifier).showTab(page.key);
            } else {
              onClose();
            }
          },
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        page.title ?? 'New Tab',
                        maxLines: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity:
                        const VisualDensity(horizontal: -4.0, vertical: -4.0),
                    onPressed: () async {
                      await ref
                          .read(webViewRepositoryProvider.notifier)
                          .closeTab(page.key);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 6.0,
                  ),
                  FaviconImage(
                    webPageInfo: page,
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Expanded(
                    child: Text(
                      page.url.authority,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              if (page.screenshot != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.memory(
                        fit: BoxFit.fitWidth,
                        page.screenshot!,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
