import 'package:bang_navigator/features/bangs/domain/providers.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/data.dart';
import 'package:bang_navigator/features/bangs/presentation/widgets/bang_chips.dart';
import 'package:bang_navigator/features/bangs/presentation/widgets/search_field.dart';
import 'package:bang_navigator/features/search_browser/domain/providers.dart';
import 'package:bang_navigator/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SiteSearch extends HookConsumerWidget {
  final String domain;

  const SiteSearch({required this.domain, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final availableBangsAsync = ref.watch(
      bangDataListProvider(
        filter: (
          domain: domain,
          groups: null,
          categoryFilter: null,
          orderMostFrequentFirst: true,
        ),
      ),
    );
    final availableBangCount = availableBangsAsync.valueOrNull?.length ?? 0;

    final selectedBang = ref.watch(
      selectedBangDataProvider(domain: domain)
          .select((value) => value.valueOrNull),
    );

    final activeBang =
        selectedBang ?? availableBangsAsync.valueOrNull?.firstOrNull;

    final textController = useTextEditingController();

    Future<void> submitSearch() async {
      if (activeBang != null && (formKey.currentState?.validate() == true)) {
        await ref
            .read(bangDataRepositoryProvider.notifier)
            .increaseFrequency(activeBang.trigger);

        await ref
            .read(switchNewTabControllerProvider.notifier)
            .add(activeBang.getUrl(textController.text));

        ref.watch(overlayDialogProvider.notifier).dismiss();
      }
    }

    return availableBangsAsync.when(
      data: (availableBangs) {
        return Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (availableBangCount > 1)
                SizedBox(
                  height: 48,
                  width: double.maxFinite,
                  child: BangChips(
                    availableBangs: availableBangs,
                    selectedBang: selectedBang,
                    onSelected: (trigger) {
                      ref
                          .read(
                            selectedBangTriggerProvider(domain: domain)
                                .notifier,
                          )
                          .setTrigger(trigger);
                    },
                    onDeleted: (trigger) {
                      if (ref.read(
                            selectedBangTriggerProvider(domain: domain),
                          ) ==
                          trigger) {
                        ref
                            .read(
                              selectedBangTriggerProvider(domain: domain)
                                  .notifier,
                            )
                            .clearTrigger();
                      }
                    },
                  ),
                ),
              SearchField(
                textController: textController,
                activeBang: activeBang,
                onFieldSubmitted: (_) async {
                  await submitSearch();
                },
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: submitSearch,
                  label: const Text('Search on Site'),
                  icon: const Icon(MdiIcons.invoiceTextSend),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox(height: 48),
    );
  }
}
