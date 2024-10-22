import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/features/geckoview/domain/entities/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab.dart';

class TabActionDialog extends HookConsumerWidget {
  final TabState initialTab;

  final void Function()? onDismiss;

  const TabActionDialog({
    required this.initialTab,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(initialTab.id)) ?? initialTab;
    final tabContainerId = ref.watch(
      tabContainerIdProvider(initialTab.id)
          .select((value) => value.valueOrNull),
    );

    final containers = ref
        .watch(
          containersWithCountProvider.select(
            (value) => EquatableCollection(value.valueOrNull, immutable: true),
          ),
        )
        .collection;

    final selectedContainer = containers
        ?.firstWhereOrNull((container) => container.id == tabContainerId);

    final expansionController = useExpansionTileController();

    return Stack(
      children: [
        ModalBarrier(
          color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
          onDismiss: onDismiss,
        ),
        SimpleDialog(
          titlePadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 24.0,
          ),
          title: ListTile(
            leading: RawImage(
              image: tabState.icon?.value,
              width: 24,
              height: 24,
            ),
            contentPadding: EdgeInsets.zero,
            title: Text(tabState.title),
            subtitle: Text(tabState.url.authority),
          ),
          children: [
            SizedBox(
              //We need this to stretch the dialog, then padding from dialog is applied
              width: double.maxFinite,
              child: ExpansionTile(
                controller: expansionController,
                leading: (selectedContainer != null)
                    ? CircleAvatar(backgroundColor: selectedContainer.color)
                    : null,
                title: (selectedContainer != null)
                    ? Text(selectedContainer.name ?? 'New Container')
                    : const Text('Assign a Container'),
                children: containers
                        ?.where((container) => container.id != tabContainerId)
                        .map(
                          (container) => ListTile(
                            leading:
                                CircleAvatar(backgroundColor: container.color),
                            title: Text(container.name ?? 'New Container'),
                            onTap: () async {
                              await ref
                                  .read(tabDataRepositoryProvider.notifier)
                                  .assignContainer(initialTab.id, container.id);

                              expansionController.collapse();
                            },
                          ),
                        )
                        .toList() ??
                    [],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
