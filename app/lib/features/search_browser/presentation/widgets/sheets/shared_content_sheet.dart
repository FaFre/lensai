import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:lensai/features/search_browser/domain/entities/sheet.dart';
import 'package:lensai/features/search_browser/presentation/widgets/tabs/assistant_tab.dart';
import 'package:lensai/features/search_browser/presentation/widgets/tabs/search_tab.dart';
import 'package:lensai/features/search_browser/presentation/widgets/tabs/summarize_tab.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/share_intent/domain/entities/shared_content.dart';
import 'package:lensai/presentation/hooks/sync_page_tab.dart';

typedef OnSubmitUri = void Function(Uri url);

class SharedContentSheet extends HookConsumerWidget {
  final CreateTabSheet parameter;
  final OnSubmitUri onSubmit;
  final void Function(KagiTool tool)? onActiveToolChanged;

  const SharedContentSheet({
    required this.parameter,
    required this.onSubmit,
    this.onActiveToolChanged,
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showEarlyAccessFeatures = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults())
            .showEarlyAccessFeatures,
      ),
    );

    final sharedContent = useMemoized(
      () => (parameter.content != null)
          ? SharedContent.parse(parameter.content!)
          : null,
      [parameter],
    );

    final initialIndex = useMemoized(
      () =>
          parameter.preferredTool?.index ??
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
      [sharedContent],
    );

    final tabController = useTabController(
      initialLength: KagiTool.values.length - (showEarlyAccessFeatures ? 0 : 1),
      initialIndex: initialIndex,
    );
    final pageController = usePageController(initialPage: tabController.index);

    useSyncPageWithTab(
      tabController,
      pageController,
      onIndexChanged: (index) {
        onActiveToolChanged?.call(KagiTool.values[index]);
      },
    );

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onActiveToolChanged?.call(KagiTool.values[initialIndex]);
        });
        return null;
      },
      [initialIndex],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: tabController,
          tabs: [
            Tab(
              icon: Icon(KagiTool.search.icon),
              text: 'Search',
            ),
            Tab(
              icon: Icon(KagiTool.summarizer.icon),
              text: 'Summarize',
            ),
            if (showEarlyAccessFeatures)
              Tab(
                icon: Icon(KagiTool.assistant.icon),
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
