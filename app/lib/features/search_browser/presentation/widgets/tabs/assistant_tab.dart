import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/sheets/shared_content_sheet.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/speech_to_text_button.dart';
import 'package:bang_navigator/features/search_browser/utils/url_builder.dart'
    as uri_builder;
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/share_intent/domain/entities/shared_content.dart';
import 'package:bang_navigator/presentation/hooks/sync_page_tab.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AssistantTab extends HookConsumerWidget {
  final SharedContent? sharedContent;
  final OnSubmitUri onSubmit;

  const AssistantTab({
    required this.sharedContent,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider
          .select((value) => value.valueOrNull?.incognitoMode ?? false),
    );

    useAutomaticKeepAlive();

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController =
        useTextEditingController(text: sharedContent?.toString());

    final tabController =
        useTabController(initialLength: AssistantMode.values.length);
    final pageController = usePageController(initialPage: tabController.index);

    useSyncPageWithTab(tabController, pageController);

    final researchVariant = useState(ResearchVariant.expert);
    final chatModel = useState(ChatModel.gpt4o);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar.secondary(
            controller: tabController,
            tabs: const [
              Tab(
                text: 'Research',
                icon: Icon(MdiIcons.layersSearch),
              ),
              Tab(
                text: 'Code',
                icon: Icon(MdiIcons.codeJson),
              ),
              Tab(
                text: 'Chat',
                icon: Icon(MdiIcons.commentTextMultiple),
              ),
              Tab(
                text: 'Custom',
                icon: Icon(MdiIcons.creation),
              ),
            ],
          ),
          ExpandablePageView(
            controller: pageController,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  SegmentedButton<ResearchVariant>(
                    segments: const [
                      ButtonSegment(
                        value: ResearchVariant.expert,
                        icon: Icon(MdiIcons.textSearch),
                        label: Text('Research'),
                      ),
                      ButtonSegment(
                        value: ResearchVariant.fast,
                        icon: Icon(MdiIcons.invoiceTextFast),
                        label: Text('Fast'),
                      ),
                    ],
                    selected: {researchVariant.value},
                    onSelectionChanged: (value) {
                      researchVariant.value = value.first;
                    },
                  ),
                ],
              ),
              const SizedBox.shrink(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  DropdownMenu<ChatModel>(
                    initialSelection: chatModel.value,
                    expandedInsets: EdgeInsets.zero,
                    label: const Text('Model'),
                    inputDecorationTheme: const InputDecorationTheme(),
                    dropdownMenuEntries: ChatModel.values
                        .map(
                          (model) => DropdownMenuEntry(
                            value: model,
                            label: model.label,
                          ),
                        )
                        .toList(),
                    onSelected: (value) {
                      chatModel.value = value!;
                    },
                  ),
                ],
              ),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          TextFormField(
            controller: textController,
            enableIMEPersonalizedLearning: !incognitoEnabled,
            decoration: InputDecoration(
              label: const Text('Prompt'),
              hintText: 'Enter your prompt...',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: SpeechToTextButton(
                onTextReceived: (data) {
                  textController.text = data.toString();
                },
              ),
            ),
            maxLines: null,
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  onSubmit(
                    uri_builder.assistantUri(
                      prompt: textController.text,
                      assistantMode: AssistantMode.values[tabController.index],
                      researchVariant: researchVariant.value,
                      chatModel: chatModel.value,
                    ),
                  );
                }
              },
              label: const Text('Submit'),
              icon: const Icon(MdiIcons.invoiceTextSend),
            ),
          ),
        ],
      ),
    );
  }
}
