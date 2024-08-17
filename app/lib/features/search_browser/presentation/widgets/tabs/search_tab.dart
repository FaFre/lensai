import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/bangs/domain/providers.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_icon.dart';
import 'package:lensai/features/bangs/presentation/widgets/search_field.dart';
import 'package:lensai/features/search_browser/domain/providers.dart';
import 'package:lensai/features/search_browser/presentation/widgets/sheets/shared_content_sheet.dart';
import 'package:lensai/features/share_intent/domain/entities/shared_content.dart';
import 'package:lensai/presentation/widgets/selectable_chips.dart';

class SearchTab extends HookConsumerWidget {
  final SharedContent? sharedContent;
  final OnSubmitUri onSubmit;

  const SearchTab({
    required this.sharedContent,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    final formKey = useMemoized(() => GlobalKey<FormState>());

    final selectedBang = ref
        .watch(selectedBangDataProvider().select((value) => value.valueOrNull));
    final defaultSearchBang = ref
        .watch(kagiSearchBangDataProvider.select((value) => value.valueOrNull));

    final activeBang = selectedBang ?? defaultSearchBang;

    final textController =
        useTextEditingController(text: sharedContent?.toString());

    Future<void> submitSearch() async {
      if (activeBang != null && (formKey.currentState?.validate() == true)) {
        await ref
            .read(bangDataRepositoryProvider.notifier)
            .increaseFrequency(activeBang.trigger);

        onSubmit(activeBang.getUrl(textController.text));
      }
    }

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Consumer(
            builder: (context, ref, child) {
              final frequentBangsAsync =
                  ref.watch(frequentBangDataListProvider);

              return frequentBangsAsync.when(
                data: (availableBangs) => SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      if (selectedBang != null || availableBangs.isNotEmpty)
                        Expanded(
                          child: SelectableChips(
                            itemId: (bang) => bang.trigger,
                            itemAvatar: (bang) => BangIcon(bang, iconSize: 20),
                            itemLabel: (bang) => Text(bang.websiteName),
                            available: availableBangs,
                            selected: selectedBang,
                            onSelected: (bang) {
                              ref
                                  .read(selectedBangTriggerProvider().notifier)
                                  .setTrigger(bang.trigger);
                            },
                            onDeleted: (bang) async {
                              if (ref.read(selectedBangTriggerProvider()) ==
                                  bang.trigger) {
                                ref
                                    .read(
                                      selectedBangTriggerProvider().notifier,
                                    )
                                    .clearTrigger();
                              } else {
                                final dialogResult = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Reset usage frequency of !${bang.trigger}?',
                                    ),
                                    content: const Text(
                                      'This will remove the Bang from quick select.',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Reset'),
                                      ),
                                    ],
                                  ),
                                );

                                if (dialogResult == true) {
                                  await ref
                                      .read(bangDataRepositoryProvider.notifier)
                                      .resetFrequency(bang.trigger);
                                }
                              }
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            "Press '>' to search Bangs.",
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed: () async {
                          await context.push(BangSearchRoute().location);
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                error: (error, stackTrace) => const SizedBox.shrink(),
                loading: () => const SizedBox(
                  height: 48,
                  width: double.infinity,
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              const maxOptionsHeight = SearchField.defaultMaxOptionsHeight;

              final openDirection = ref.watch(
                bottomSheetExtendProvider.select((value) {
                  final extend = value.valueOrNull;
                  if (extend == null ||
                      (MediaQuery.of(context).size.height * (1 - extend)) >
                          maxOptionsHeight) {
                    return OptionsViewOpenDirection.up;
                  } else {
                    return OptionsViewOpenDirection.down;
                  }
                }),
              );

              return SearchField(
                textController: textController,
                activeBang: activeBang,
                openDirection: openDirection,
                onFieldSubmitted: (_) async {
                  await submitSearch();
                },
              );
            },
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: submitSearch,
              label: const Text('Search'),
              icon: const Icon(MdiIcons.cloudSearch),
            ),
          ),
        ],
      ),
    );
  }
}
