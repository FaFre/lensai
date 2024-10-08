import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/domain/entities/web_page_info.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/providers.dart';
import 'package:lensai/features/bangs/presentation/widgets/site_search.dart';
import 'package:lensai/features/search_browser/domain/entities/modes.dart';
import 'package:lensai/features/search_browser/utils/url_builder.dart'
    as uri_builder;
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/share_intent/domain/entities/shared_content.dart';
import 'package:lensai/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:lensai/presentation/widgets/website_title_tile.dart';
import 'package:lensai/utils/ui_helper.dart' as ui_helper;
import 'package:lensai/utils/uri_parser.dart' as uri_parser;
import 'package:share_plus/share_plus.dart';

class WebPageDialog extends HookConsumerWidget {
  final Uri url;
  final WebPageInfo? precachedInfo;
  final InAppWebViewController? webViewController;

  final void Function()? onDismiss;

  const WebPageDialog({
    required this.url,
    this.precachedInfo,
    this.webViewController,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults()).incognitoMode,
      ),
    );

    final availableBangsAsync = ref.watch(
      bangDataListProvider(
        filter: (
          domain: url.host,
          groups: null,
          categoryFilter: null,
          orderMostFrequentFirst: true,
        ),
      ),
    );
    final availableBangCount = availableBangsAsync.valueOrNull?.length;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final urlTextController = useTextEditingController(text: url.toString());

    return Stack(
      children: [
        ModalBarrier(
          color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
          onDismiss: onDismiss,
        ),
        SimpleDialog(
          titlePadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 24.0,
          ),
          title: WebsiteTitleTile(url, precachedInfo: precachedInfo),
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
                    enableIMEPersonalizedLearning: !incognitoEnabled,
                    decoration: InputDecoration(
                      labelText: 'URL',
                      suffixIcon: (webViewController != null)
                          ? IconButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  await webViewController!.loadUrl(
                                    urlRequest: URLRequest(
                                      url: WebUri.uri(
                                        uri_parser.tryParseUrl(
                                          urlTextController.text,
                                          eagerParsing: true,
                                        )!,
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
                      if (uri_parser.tryParseUrl(value, eagerParsing: true) !=
                          null) {
                        return null;
                      }

                      return 'Invalid URL';
                    },
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: availableBangsAsync.when(
                data: (availableBangs) {
                  if (availableBangs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return SiteSearch(
                    domain: url.host,
                    availableBangs: availableBangs,
                  );
                },
                error: (error, stackTrace) => FailureWidget(
                  title: 'Could not load bangs',
                  exception: error,
                ),
                loading: () => SiteSearch(
                  domain: url.host,
                  availableBangs: [
                    BangData(
                      websiteName: 'websiteName',
                      domain: 'domain',
                      trigger: 'trigger',
                      urlTemplate: 'urlTemplate',
                    ),
                  ],
                ),
              ),
            ),
            if (availableBangsAsync.isLoading ||
                availableBangCount == null ||
                availableBangCount > 0)
              const Divider(),
            ListTile(
              leading: const Icon(MdiIcons.contentCopy),
              title: const Text('Copy address'),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: url.toString()),
                );
                onDismiss?.call();
              },
            ),
            ListTile(
              onTap: () async {
                await ui_helper.launchUrlFeedback(context, url);
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
                    .add(url);

                onDismiss?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share link'),
              onTap: () async {
                await Share.shareUri(url);

                onDismiss?.call();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(KagiTool.summarizer.icon),
              title: const Text('Summarize'),
              onTap: () async {
                final summarizerUrl = uri_builder.summarizerUri(
                  document: SharedUrl(url),
                  mode: SummarizerMode.keyMoments,
                );

                await ref
                    .read(switchNewTabControllerProvider.notifier)
                    .add(summarizerUrl);

                onDismiss?.call();
              },
            ),
          ],
        ),
      ],
    );
  }
}
