import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/sheet.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/tabs/assistant_tab.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/tabs/search_tab.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/tabs/summarize_tab.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/share_intent/domain/entities/shared_content.dart';
import 'package:bang_navigator/presentation/hooks/sync_page_tab.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final showEarlyAccessFeatures = ref.watch(
      settingsRepositoryProvider.select(
        (value) => value.valueOrNull?.showEarlyAccessFeatures ?? true,
      ),
    );

    final sharedContent = useMemoized(
      () => (parameter.content != null)
          ? SharedContent.parse(parameter.content!)
          : null,
    );

    final tabController = useTabController(
      initialLength: KagiTool.values.length - (showEarlyAccessFeatures ? 0 : 1),
      initialIndex: parameter.preferredTool?.index ??
          switch (sharedContent) {
            SharedText(text: final text) =>
              (showEarlyAccessFeatures && text.length > 25)
                  ? KagiTool.assistant.index
                  : KagiTool.search.index,
            SharedUrl() => KagiTool.summarizer.index,
            null => showEarlyAccessFeatures
                ? KagiTool.assistant.index
                : KagiTool.search.index,
          },
    );
    final pageController = usePageController(initialPage: tabController.index);

    useSyncPageWithTab(tabController, pageController);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: tabController,
          tabs: [
            const Tab(
              icon: Icon(MdiIcons.searchWeb),
              text: 'Search',
            ),
            const Tab(
              icon: Icon(MdiIcons.text),
              text: 'Summarize',
            ),
            if (showEarlyAccessFeatures)
              const Tab(
                icon: Icon(MdiIcons.brain),
                text: 'Assistant',
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
              SummarizeTab(
                sharedContent: sharedContent,
                onSubmit: onSubmit,
              ),
              if (showEarlyAccessFeatures)
                AssistantTab(
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
