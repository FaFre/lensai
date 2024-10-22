import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/widgets/container_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

class _ContainerTile extends HookWidget {
  final ContainerData container;
  final bool isSelected;

  final void Function(ContainerResult edited) onEdit;
  final void Function() onDelete;
  final void Function() onTap;

  const _ContainerTile(
    this.container, {
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
      leading: CircleAvatar(backgroundColor: container.color),
      title: Text(container.name ?? 'New Container'),
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
              final result = await showDialog<ContainerResult?>(
                context: context,
                builder: (context) => ContainerDialog.edit(
                  name: container.name,
                  initialColor: container.color,
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
                    title: const Text('Delete Container'),
                    content: const Text(
                      'Are you sure you want to delete this container and close all attached tabs?',
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

class ContainerListScreen extends HookConsumerWidget {
  const ContainerListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Containers'),
        actions: [
          IconButton(
            onPressed: () async {
              final initialColor =
                  await ref.read(unusedRandomContainerColorProvider.future);

              if (context.mounted) {
                final result = await showDialog<ContainerResult?>(
                  context: context,
                  builder: (context) => ContainerDialog.create(
                    initialColor: initialColor,
                  ),
                );

                if (result != null) {
                  await ref
                      .read(containerRepositoryProvider.notifier)
                      .addContainer(name: result.name, color: result.color);
                }
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: HookConsumer(
        builder: (context, ref, child) {
          final containersAsync = ref.watch(containersWithCountProvider);
          final selectedContainer = ref.watch(selectedContainerProvider);

          return Skeletonizer(
            enabled: containersAsync.isLoading,
            child: containersAsync.when(
              data: (containers) => FadingScroll(
                fadingSize: 25,
                builder: (context, controller) {
                  return ListView.builder(
                    controller: controller,
                    itemCount: containers.length,
                    itemBuilder: (context, index) {
                      final container = containers[index];
                      return _ContainerTile(
                        container,
                        key: ValueKey(container.id),
                        isSelected: container.id == selectedContainer,
                        onEdit: (edited) async {
                          await ref
                              .read(containerRepositoryProvider.notifier)
                              .replaceContainer(
                                id: container.id,
                                name: edited.name,
                                color: edited.color,
                              );
                        },
                        onDelete: () async {
                          await ref
                              .read(containerRepositoryProvider.notifier)
                              .deleteContainer(container.id);
                        },
                        onTap: () {
                          ref
                              .read(selectedContainerProvider.notifier)
                              .toggleContainer(container.id);
                        },
                      );
                    },
                  );
                },
              ),
              error: (error, stackTrace) => SizedBox.shrink(),
              loading: () => ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => _ContainerTile(
                  ContainerData(id: 'null', color: Colors.transparent),
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
