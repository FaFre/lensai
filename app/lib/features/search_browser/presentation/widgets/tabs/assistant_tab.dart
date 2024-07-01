import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/domain/providers.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/sheets/shared_content_sheet.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/speech_to_text_button.dart';
import 'package:bang_navigator/features/search_browser/utils/url_builder.dart'
    as uri_builder;
import 'package:bang_navigator/features/settings/data/models/settings.dart';
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
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults()).incognitoMode,
      ),
    );

    final researchVariant = ref.watch(activeResearchVariantProvider);
    final chatModel = ref.watch(activeChatModelProvider);

    useAutomaticKeepAlive();

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController =
        useTextEditingController(text: sharedContent?.toString());

    final tabController = useTabController(
      initialLength: AssistantMode.values.length,
      initialIndex: ref.read(lastUsedAssistantModeProvider).index,
    );
    final pageController = usePageController(initialPage: tabController.index);

    useSyncPageWithTab(
      tabController,
      pageController,
      onIndexChanged: (index) {
        ref
            .read(lastUsedAssistantModeProvider.notifier)
            .update(AssistantMode.values[index]);
      },
    );

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
                    selected: {researchVariant},
                    onSelectionChanged: (value) {
                      ref
                          .read(activeResearchVariantProvider.notifier)
                          .update(value.first);
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _PromptField(textController, incognitoEnabled),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  _PromptField(textController, incognitoEnabled),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  DropdownMenu<ChatModel>(
                    initialSelection: chatModel,
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
                      ref.read(activeChatModelProvider.notifier).update(value!);
                    },
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _PromptField(textController, incognitoEnabled),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  _PromptField(textController, incognitoEnabled),
                ],
              ),
            ],
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
                      researchVariant: researchVariant,
                      chatModel: chatModel,
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

class _PromptField extends StatelessWidget {
  final TextEditingController textController;
  final bool incognitoEnabled;

  const _PromptField(this.textController, this.incognitoEnabled);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
    );
  }
}
