import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/topics/data/models/topic_data.dart';
import 'package:lensai/features/geckoview/features/topics/domain/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/topic.dart';
import 'package:lensai/features/geckoview/features/topics/presentation/widgets/topic_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

class _TopicTile extends HookWidget {
  final TopicData topic;
  final bool isSelected;

  final void Function(TopicResult edited) onEdit;
  final void Function() onDelete;
  final void Function() onTap;

  const _TopicTile(
    this.topic, {
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final menuController = useMemoized(() => MenuController());

    return ListTile(
      selected: isSelected,
      leading: CircleAvatar(backgroundColor: topic.color),
      title: Text(topic.name ?? 'New Topic'),
      trailing: MenuAnchor(
        controller: menuController,
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: InkWell(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
                child: Icon(Icons.more_vert),
              ),
            ),
          );
        },
        menuChildren: [
          MenuItemButton(
            onPressed: () async {
              final result = await showDialog<TopicResult?>(
                context: context,
                builder: (context) => TopicDialog.edit(
                  name: topic.name,
                  initialColor: topic.color,
                ),
              );

              if (result != null) {
                onEdit(result);
              }
            },
            leadingIcon: const Icon(Icons.edit),
            child: const Text('Edit'),
          ),
          MenuItemButton(
            onPressed: () async {
              final result = await showDialog<bool?>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Topic'),
                    content: const Text(
                      'Are you sure you want to delete this topic and all attached tabs?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (result == true) {
                onDelete();
              }
            },
            leadingIcon: const Icon(Icons.delete),
            child: const Text('Delete'),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class TopicListScreen extends HookConsumerWidget {
  const TopicListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          IconButton(
            onPressed: () async {
              final initialColor =
                  await ref.read(unusedRandomTopicColorProvider.future);

              if (context.mounted) {
                final result = await showDialog<TopicResult?>(
                  context: context,
                  builder: (context) => TopicDialog.create(
                    initialColor: initialColor,
                  ),
                );

                if (result != null) {
                  await ref
                      .read(topicRepositoryProvider.notifier)
                      .addTopic(name: result.name, color: result.color);
                }
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: HookConsumer(
        builder: (context, ref, child) {
          final topicsAsync = ref.watch(topicRepositoryProvider);
          final selectedTopic = ref.watch(selectedTopicProvider);

          return Skeletonizer(
            enabled: topicsAsync.isLoading,
            child: topicsAsync.when(
              data: (topics) => FadingScroll(
                fadingSize: 25,
                builder: (context, controller) {
                  return ListView.builder(
                    controller: controller,
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return _TopicTile(
                        topic,
                        key: ValueKey(topic.id),
                        isSelected: topic.id == selectedTopic,
                        onEdit: (edited) async {
                          await ref
                              .read(topicRepositoryProvider.notifier)
                              .replaceTopic(
                                id: topic.id,
                                name: edited.name,
                                color: edited.color,
                              );
                        },
                        onDelete: () async {
                          await ref
                              .read(topicRepositoryProvider.notifier)
                              .deleteTopic(topic.id);
                        },
                        onTap: () {
                          ref
                              .read(selectedTopicProvider.notifier)
                              .toggleTopic(topic.id);
                        },
                      );
                    },
                  );
                },
              ),
              error: (error, stackTrace) => SizedBox.shrink(),
              loading: () => ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => _TopicTile(
                  TopicData(id: 'null', color: Colors.transparent),
                  isSelected: false,
                  onEdit: (_) {},
                  onDelete: () {},
                  onTap: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
