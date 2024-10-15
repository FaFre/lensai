import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/features/geckoview/domain/entities/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/topics/domain/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/tab_link.dart';

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
    final tabTopicId = ref.watch(
      tabTopicIdProvider(initialTab.id).select((value) => value.valueOrNull),
    );

    final topics = ref
        .watch(
          topicsWithCountProvider.select(
            (value) => EquatableCollection(value.valueOrNull, immutable: true),
          ),
        )
        .collection;

    final selectedTopic =
        topics?.firstWhereOrNull((topic) => topic.id == tabTopicId);

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
                leading: (selectedTopic != null)
                    ? CircleAvatar(backgroundColor: selectedTopic.color)
                    : null,
                title: (selectedTopic != null)
                    ? Text(selectedTopic.name ?? 'New Topic')
                    : const Text('Assign a Topic'),
                children: topics
                        ?.where((topic) => topic.id != tabTopicId)
                        .map(
                          (topic) => ListTile(
                            leading: CircleAvatar(backgroundColor: topic.color),
                            title: Text(topic.name ?? 'New Topic'),
                            onTap: () async {
                              await ref
                                  .read(tabLinkRepositoryProvider.notifier)
                                  .assignTab(initialTab.id, topic.id);

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
