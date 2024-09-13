import 'dart:async';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/extensions/date_time.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/chat_archive/domain/entities/chat_entity.dart';
import 'package:lensai/features/chat_archive/domain/repositories/search.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class ChatArchiveSearchScreen extends HookConsumerWidget {
  const ChatArchiveSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(chatArchiveSearchRepositoryProvider);
    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults()).incognitoMode,
      ),
    );

    final textEditingController = useTextEditingController();

    useListenableCallback(textEditingController, () async {
      unawaited(
        ref
            .read(chatArchiveSearchRepositoryProvider.notifier)
            .search(textEditingController.text),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          enableIMEPersonalizedLearning: !incognitoEnabled,
          controller: textEditingController,
          autofocus: true,
          autocorrect: false,
          decoration: const InputDecoration.collapsed(hintText: 'Search'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (textEditingController.text.isEmpty) {
                context.pop();
              } else {
                textEditingController.clear();
              }
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: resultsAsync.when(
        skipLoadingOnReload: true,
        data: (chats) => FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView.builder(
              controller: controller,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final chatEntity = ChatEntity.fromFileName(chat.fileName);

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      await context.push(
                        ChatArchiveDetailRoute(fileName: chat.fileName)
                            .location,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Markdown(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            data: '## ${chat.title}',
                          ),
                          if (chatEntity.dateTime != null)
                            Text(
                              chatEntity.dateTime!.formatWithMinutePrecision(),
                            ),
                          const SizedBox(height: 8.0),
                          Markdown(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            data: chat.contentSnippet,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Chat Search failed',
            exception: error,
          ),
        ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
