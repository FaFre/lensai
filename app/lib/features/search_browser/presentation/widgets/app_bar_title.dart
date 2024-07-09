import 'package:bang_navigator/features/web_view/domain/entities/web_view_page.dart';
import 'package:bang_navigator/features/web_view/presentation/widgets/favicon.dart';
import 'package:bang_navigator/features/web_view/presentation/widgets/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:text_scroll/text_scroll.dart';

class AppBarTitle extends HookWidget {
  final WebView activeWebView;

  final void Function()? onTap;

  const AppBarTitle({required this.activeWebView, this.onTap, super.key});

  Icon _securityStatusIcon(BuildContext context, WebViewPage page) {
    if (page.url.isScheme('http')) {
      return Icon(
        MdiIcons.lockOff,
        color: Theme.of(context).colorScheme.error,
        size: 14,
      );
    } else if (page.sslError != null) {
      return Icon(
        MdiIcons.lockAlert,
        color: Theme.of(context).colorScheme.errorContainer,
        size: 14,
      );
    } else {
      return const Icon(
        MdiIcons.lock,
        size: 14,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = useValueListenable(activeWebView.page);

    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          FaviconImage(
            webPageInfo: page,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextScroll(
                  key: ValueKey(page.title),
                  page.title ?? 'New Tab',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurface),
                  // mode: TextScrollMode.bouncing,
                  velocity: const Velocity(pixelsPerSecond: Offset(75, 0)),
                  delayBefore: const Duration(milliseconds: 500),
                  pauseBetween: const Duration(milliseconds: 5000),
                  fadedBorder: true,
                  fadeBorderSide: FadeBorderSide.right,
                  fadedBorderWidth: 0.05,
                  intervalSpaces: 4,
                  numberOfReps: 2,
                ),
                Row(
                  children: [
                    _securityStatusIcon(context, page),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text(
                        page.url.authority,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
