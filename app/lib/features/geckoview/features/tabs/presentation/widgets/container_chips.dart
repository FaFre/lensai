import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/presentation/widgets/selectable_chips.dart';

class ContainerChips extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(containersWithCountProvider);
    final selectedContainer = ref.watch(
      selectedContainerDataProvider.select((value) => value.valueOrNull),
    );

    return containersAsync.when(
      data: (availableContainers) => SizedBox(
        height: 48,
        child: Row(
          children: [
            const SizedBox(width: 16),
            if (selectedContainer != null || availableContainers.isNotEmpty)
              Expanded(
                child: SelectableChips(
                  deleteIcon: false,
                  itemId: (container) => container.id,
                  itemAvatar: (container) => Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: container.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  itemLabel: (container) =>
                      Text(container.name ?? 'New Container'),
                  itemBadgeCount: (container) => container.tabCount,
                  availableItems: availableContainers,
                  selectedItem: selectedContainer,
                  onSelected: (container) {
                    ref
                        .read(selectedContainerProvider.notifier)
                        .setContainerId(container.id);
                  },
                  onDeleted: (container) async {
                    ref
                        .read(selectedContainerProvider.notifier)
                        .clearContainer();
                  },
                ),
              )
            else
              Expanded(
                child: Text(
                  "Press '>' to manage Containers.",
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            IconButton(
              onPressed: () async {
                await context.push(ContainerListRoute().location);
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
  }
}
