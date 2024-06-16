import 'package:bang_navigator/core/extension/date_time.dart';
import 'package:bang_navigator/core/routing/routes.dart';
import 'package:bang_navigator/features/chat_archive/domain/repositories/archive.dart';
import 'package:bang_navigator/presentation/widgets/failure_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      body: SafeArea(
        child: Skeletonizer(
          enabled: chatsAsync.isLoading,
          child: chatsAsync.when(
            data: (chats) {
              return ListView.builder(
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
      ),
    );
  }
}
