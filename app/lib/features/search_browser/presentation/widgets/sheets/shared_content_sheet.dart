import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kagi_bang_bang/features/search_browser/domain/entities/modes.dart';
import 'package:kagi_bang_bang/features/search_browser/domain/entities/sheet.dart';
import 'package:kagi_bang_bang/features/search_browser/presentation/widgets/tabs/assistant_tab.dart';
import 'package:kagi_bang_bang/features/search_browser/presentation/widgets/tabs/search_tab.dart';
import 'package:kagi_bang_bang/features/search_browser/presentation/widgets/tabs/summarize_tab.dart';
import 'package:kagi_bang_bang/features/share_intent/domain/entities/shared_content.dart';
import 'package:kagi_bang_bang/presentation/hooks/sync_page_tab.dart';

typedef OnSubmitUri = void Function(Uri url);

class SharedContentSheet extends HookConsumerWidget {
  final CreateTab parameter;
  final OnSubmitUri onSubmit;

  const SharedContentSheet({
    required this.parameter,
    required this.onSubmit,
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedContent = useMemoized(
      () => (parameter.content != null)
          ? SharedContent.parse(parameter.content!)
          : null,
    );

    final tabController = useTabController(
      initialLength: KagiTool.values.length,
      initialIndex: parameter.preferredTool?.index ??
          switch (sharedContent) {
            SharedText(text: final text) => (text.length > 25)
                ? KagiTool.assistant.index
                : KagiTool.search.index,
            SharedUrl() => KagiTool.summarizer.index,
            null => KagiTool.assistant.index,
          },
    );
    final pageController = usePageController(initialPage: tabController.index);

    useSyncPageWithTab(tabController, pageController);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(
              icon: Icon(MdiIcons.searchWeb),
              text: 'Search',
            ),
            Tab(
              icon: Icon(MdiIcons.brain),
              text: 'Assistant',
            ),
            Tab(
              icon: Icon(MdiIcons.text),
              text: 'Summarize',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: ExpandablePageView(
            controller: pageController,
            children: [
              SearchTab(
                sharedContent: sharedContent,
                onSubmit: onSubmit,
              ),
              AssistantTab(
                sharedContent: sharedContent,
                onSubmit: onSubmit,
              ),
              SummarizeTab(
                sharedContent: sharedContent,
                onSubmit: onSubmit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
