import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bang_navigator/domain/entities/web_page_info.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/utils/url_builder.dart'
    as uri_builder;
import 'package:bang_navigator/features/share_intent/domain/entities/shared_content.dart';
import 'package:bang_navigator/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:bang_navigator/features/web_view/presentation/widgets/favicon.dart';
import 'package:bang_navigator/presentation/controllers/website_title.dart';
import 'package:bang_navigator/utils/ui_helper.dart' as ui_helper;
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingWebPageDialog extends HookConsumerWidget {
  final Uri url;

  final void Function()? onDismiss;

  const LoadingWebPageDialog(this.url, {this.onDismiss});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageInfoAsync = ref.watch(pageInfoProvider(url));

    return Skeletonizer(
      enabled: pageInfoAsync.isLoading,
      child: WebPageDialog(
        page: pageInfoAsync.valueOrNull ??
            WebPageInfo(url: url, favicon: null, title: ''),
        onDismiss: onDismiss,
      ),
    );
  }
}

class WebPageDialog extends HookConsumerWidget {
  final WebPageInfo page;
  final InAppWebViewController? webViewController;

  final void Function()? onDismiss;

  const WebPageDialog({
    required this.page,
    this.webViewController,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final urlTextController =
        useTextEditingController(text: page.url.toString());

    return Stack(
      children: [
        ModalBarrier(
          color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
          onDismiss: onDismiss,
        ),
        SimpleDialog(
          titlePadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 0.0),
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 24.0,
          ),
          title: ListTile(
            leading: FaviconImage(
              webPageInfo: page,
              size: 24,
            ),
            contentPadding: EdgeInsets.zero,
            title: Text(page.title ?? 'Unknown Title'),
            subtitle: Text(page.url.authority),
          ),
          children: [
            SizedBox(
              //We need this to stretch the dialog, then padding from dialog is applied
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: urlTextController,
                    decoration: InputDecoration(
                      suffixIcon: (webViewController != null)
                          ? IconButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  await webViewController!.loadUrl(
                                    urlRequest: URLRequest(
                                      url: WebUri.uri(
                                        Uri.parse(
                                          urlTextController.text,
                                        ),
                                      ),
                                    ),
                                  );

                                  onDismiss?.call();
                                }
                              },
                              icon: const Icon(Icons.send),
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (value != null) {
                        if (Uri.tryParse(value) case final Uri url) {
                          if (url.hasScheme && url.hasAuthority) {
                            return null;
                          }
                        }
                      }

                      return 'Invalid URL';
                    },
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(MdiIcons.contentCopy),
              title: const Text('Copy address'),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: page.url.toString()),
                );
                onDismiss?.call();
              },
            ),
            ListTile(
              onTap: () async {
                if (!await launchUrl(
                  page.url,
                  mode: LaunchMode.externalApplication,
                )) {
                  if (context.mounted) {
                    ui_helper.showErrorMessage(
                      context,
                      'Could not launch URL (${page.url})',
                    );
                  }
                }
              },
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Launch External'),
            ),
            ListTile(
              leading: const Icon(MdiIcons.tabPlus),
              title: const Text('Open in new tab'),
              onTap: () async {
                await ref
                    .read(switchNewTabControllerProvider.notifier)
                    .add(page.url);

                onDismiss?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share link'),
              onTap: () async {
                await Share.shareUri(page.url);

                onDismiss?.call();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(MdiIcons.text),
              title: const Text('Summarize'),
              onTap: () async {
                final url = uri_builder.summarizerUri(
                  document: SharedUrl(page.url),
                  mode: SummarizerMode.keyMoments,
                );

                await ref
                    .read(switchNewTabControllerProvider.notifier)
                    .add(url);

                onDismiss?.call();
              },
            ),
          ],
        ),
      ],
    );
  }
}
