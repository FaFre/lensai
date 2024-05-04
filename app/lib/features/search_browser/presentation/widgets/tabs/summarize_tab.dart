import 'dart:async';

import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/sheets/shared_content_sheet.dart';
import 'package:bang_navigator/features/search_browser/utils/url_builder.dart'
    as uri_builder;
import 'package:bang_navigator/features/share_intent/domain/entities/shared_content.dart';
import 'package:bang_navigator/presentation/widgets/website_title_tile.dart';
import 'package:bang_navigator/utils/uri_parser.dart' as uri_parser;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SummarizeTab extends HookConsumerWidget {
  final SharedContent? sharedContent;
  final OnSubmitUri onSubmit;

  const SummarizeTab({
    required this.sharedContent,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final selectedMode = useState(SummarizerMode.keyMoments);
    final textController =
        useTextEditingController(text: sharedContent?.toString());

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<SummarizerMode>(
            segments: const [
              ButtonSegment(
                value: SummarizerMode.keyMoments,
                icon: Icon(MdiIcons.scriptTextKey),
                label: Text('Key Moments'),
              ),
              ButtonSegment(
                value: SummarizerMode.summary,
                icon: Icon(MdiIcons.invoiceTextMinus),
                label: Text('Summary'),
              ),
            ],
            selected: {selectedMode.value},
            onSelectionChanged: (value) {
              selectedMode.value = value.first;
            },
          ),
          const SizedBox(
            height: 12,
          ),
          ...switch (sharedContent) {
            SharedUrl() => [
                TextFormField(
                  controller: textController,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    label: Text('Document'),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '';
                    }

                    return null;
                  },
                ),
                HookBuilder(
                  builder: (context) {
                    final url =
                        useState(uri_parser.tryParseUrl(textController.text));
                    useEffect(
                      () {
                        Timer? timer;
                        void debounce() {
                          timer?.cancel();
                          timer = Timer(const Duration(milliseconds: 250), () {
                            url.value =
                                uri_parser.tryParseUrl(textController.text);
                          });
                        }

                        textController.addListener(debounce);
                        return () => textController.removeListener(debounce);
                      },
                      [textController],
                    );

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (url.value != null) WebsiteTitleTile(url.value!),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            SharedText() || null => [
                TextFormField(
                  controller: textController,
                  decoration: const InputDecoration(
                    // border: OutlineInputBorder(),
                    label: Text('Document'),
                  ),
                  maxLines: null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
          },
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  onSubmit(
                    uri_builder.summarizerUri(
                      document: SharedContent.parse(textController.text),
                      mode: selectedMode.value,
                    ),
                  );
                }
              },
              label: const Text('Summarize'),
              icon: const Icon(MdiIcons.invoiceTextSend),
            ),
          ),
        ],
      ),
    );
  }
}
