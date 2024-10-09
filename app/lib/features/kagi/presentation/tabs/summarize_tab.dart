import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/sheets/create_tab.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:lensai/features/kagi/utils/url_builder.dart' as uri_builder;
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/share_intent/domain/entities/shared_content.dart';
import 'package:lensai/presentation/widgets/website_title_tile.dart';
import 'package:lensai/utils/uri_parser.dart' as uri_parser;

class _InputField extends ConsumerWidget {
  final TextEditingController? controller;

  const _InputField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults()).incognitoMode,
      ),
    );

    return TextFormField(
      controller: controller,
      enableIMEPersonalizedLearning: !incognitoEnabled,
      decoration: const InputDecoration(
        label: Text('Document'),
        hintText: 'Enter URL or text to summarize',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      maxLines: null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return '';
        }

        return null;
      },
    );
  }
}

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
                _InputField(controller: textController),
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
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final pickResult = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );

                      if (pickResult?.files.first.path
                          case final String filePath) {
                        final content = await PDFDoc.fromPath(filePath)
                            .then((doc) => doc.text);
                        textController.text = content;
                      }
                    },
                    icon: const Icon(MdiIcons.fileUpload),
                    label: const Text('Read PDF document'),
                  ),
                ),
                _InputField(controller: textController),
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
