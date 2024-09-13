import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/geckoview/features/topics/domain/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/topic.dart';
import 'package:lensai/presentation/widgets/selectable_chips.dart';

class TopicChips extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicRepositoryProvider);
    final selectedTopic = ref
        .watch(selectedTopicDataProvider.select((value) => value.valueOrNull));

    return topicsAsync.when(
      data: (availableTopics) => SizedBox(
        height: 48,
        child: Row(
          children: [
            const SizedBox(width: 16),
            if (selectedTopic != null || availableTopics.isNotEmpty)
              Expanded(
                child: SelectableChips(
                  deleteIcon: false,
                  itemId: (topic) => topic.id,
                  itemAvatar: (topic) => Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: topic.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  itemLabel: (topic) => Text(topic.name ?? 'New Topic'),
                  itemBadgeCount: (topic) => topic.tabCount,
                  availableItems: availableTopics,
                  selectedItem: selectedTopic,
                  onSelected: (topic) {
                    ref.read(selectedTopicProvider.notifier).setTopic(topic.id);
                  },
                  onDeleted: (topic) async {
                    ref.read(selectedTopicProvider.notifier).clearTopic();
                  },
                ),
              )
            else
              Expanded(
                child: Text(
                  "Press '>' to manage Topics.",
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            IconButton(
              onPressed: () async {
                await context.push(TopicListRoute().location);
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
