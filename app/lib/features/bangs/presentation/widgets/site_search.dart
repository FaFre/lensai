import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_icon.dart';
import 'package:lensai/features/bangs/presentation/widgets/search_field.dart';
import 'package:lensai/features/search_browser/domain/providers.dart';
import 'package:lensai/presentation/widgets/selectable_chips.dart';

class SiteSearch extends HookConsumerWidget {
  final String domain;
  final List<BangData> availableBangs;

  const SiteSearch({
    required this.domain,
    required this.availableBangs,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final selectedBang = ref.watch(
      selectedBangDataProvider(domain: domain)
          .select((value) => value.valueOrNull),
    );

    final activeBang = selectedBang ?? availableBangs.firstOrNull;

    final textController = useTextEditingController();

    Future<void> submitSearch() async {
      if (activeBang != null && (formKey.currentState?.validate() == true)) {
        await ref
            .read(bangDataRepositoryProvider.notifier)
            .increaseFrequency(activeBang.trigger);

        await ref
            .read(switchNewTabControllerProvider.notifier)
            .add(activeBang.getUrl(textController.text));

        ref.read(overlayDialogProvider.notifier).dismiss();
      }
    }

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            width: double.maxFinite,
            child: SelectableChips(
              itemId: (bang) => bang.trigger,
              itemAvatar: (bang) => BangIcon(bang, iconSize: 20),
              itemLabel: (bang) => Text(bang.websiteName),
              availableItems: availableBangs,
              selectedItem: selectedBang,
              onSelected: (bang) {
                ref
                    .read(
                      selectedBangTriggerProvider(domain: domain).notifier,
                    )
                    .setTrigger(bang.trigger);
              },
              onDeleted: (bang) {
                if (ref.read(
                      selectedBangTriggerProvider(domain: domain),
                    ) ==
                    bang.trigger) {
                  ref
                      .read(
                        selectedBangTriggerProvider(domain: domain).notifier,
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
              icon: const Icon(MdiIcons.cloudSearch),
            ),
          ),
        ],
      ),
    );
  }
}
