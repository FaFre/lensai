import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/extensions/date_time.dart';
import 'package:lensai/features/chat_archive/domain/repositories/archive.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatArchiveListScreen extends HookConsumerWidget {
  const ChatArchiveListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatArchiveRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Archive'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push(ChatArchiveSearchRoute().location);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Skeletonizer(
        enabled: chatsAsync.isLoading,
        child: chatsAsync.when(
          data: (chats) {
            return FadingScroll(
              fadingSize: 25,
              builder: (context, controller) {
                return ListView.builder(
                  controller: controller,
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    return ListTile(
                      title: Text(chat.toString()),
                      subtitle: (chat.dateTime != null)
                          ? Text(chat.dateTime!.formatWithMinutePrecision())
                          : null,
                      onTap: () async {
                        await context.push(
                          ChatArchiveDetailRoute(fileName: chat.fileName)
                              .location,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
          error: (error, stackTrace) {
            return FailureWidget(
              title: 'Could not load archived chats',
              exception: error,
              onRetry: () => ref.refresh(chatArchiveRepositoryProvider),
            );
          },
          loading: () => ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => const ListTile(
              title: Bone.text(),
              subtitle: Bone.text(),
            ),
          ),
        ),
      ),
    );
  }
}
