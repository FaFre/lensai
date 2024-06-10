import 'package:bang_navigator/core/routing/routes.dart';
import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/domain/providers.dart';
import 'package:bang_navigator/features/bangs/presentation/widgets/bang_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BangChips extends HookConsumerWidget {
  static const _maxBangCount = 25;

  final BangData? selectedBang;
  final void Function(String trigger)? onSelected;
  final void Function(String trigger)? onDeleted;

  const BangChips({
    this.selectedBang,
    this.onSelected,
    this.onDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequentBangsAsync = ref.watch(frequentBangsProvider);

    return frequentBangsAsync.when(
      data: (bangs) {
        bangs = bangs.take(_maxBangCount).toList();
        if (selectedBang != null) {
          final selectedIndex =
              bangs.indexWhere((bang) => bang.trigger == selectedBang?.trigger);
          if (selectedIndex < 0) {
            bangs = [
              selectedBang!,
              ...bangs,
            ];
          } else {
            bangs = [
              bangs.removeAt(selectedIndex),
              ...bangs,
            ];
          }
        }

        return SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: bangs.length,
                  itemBuilder: (context, index) {
                    final bang = bangs[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: bang.trigger == selectedBang?.trigger,
                        showCheckmark: false,
                        onSelected: (value) {
                          if (value) {
                            onSelected?.call(bang.trigger);
                          } else {
                            onDeleted?.call(bang.trigger);
                          }
                        },
                        onDeleted: () {
                          onDeleted?.call(bang.trigger);
                        },
                        avatar: BangIcon(bang, iconSize: 20),
                        label: Text(bang.websiteName),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () async {
                  await context.push(BangRoute().location);
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => SizedBox.shrink(),
      loading: () => SizedBox.shrink(),
    );
  }
}
