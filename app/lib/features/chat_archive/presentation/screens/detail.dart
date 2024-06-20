import 'package:bang_navigator/core/routing/routes.dart';
import 'package:bang_navigator/features/chat_archive/data/services/file.dart';
import 'package:bang_navigator/features/chat_archive/domain/entities/chat_entity.dart';
import 'package:bang_navigator/features/chat_archive/domain/repositories/archive.dart';
import 'package:bang_navigator/features/chat_archive/utils/markdown_to_text.dart';
import 'package:bang_navigator/features/settings/data/models/settings.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:bang_navigator/presentation/widgets/failure_widget.dart';
import 'package:bang_navigator/utils/ui_helper.dart' as ui_helper;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatArchiveDetailScreen extends HookConsumerWidget {
  final String fileName;

  const ChatArchiveDetailScreen(this.fileName, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatAsync = ref.watch(readArchivedChatProvider(fileName));

    final entity = useMemoized(() => ChatEntity.fromFileName(fileName));

    return Scaffold(
      appBar: AppBar(
        title: Text(entity.toString()),
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
              );
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () async {
                  if (chatAsync.valueOrNull != null) {
                    await Clipboard.setData(
                      ClipboardData(
                        text: await Future.microtask(
                          () => markdownToText(chatAsync.valueOrNull!),
                        ),
                      ),
                    );
                  }
                },
                leadingIcon: const Icon(MdiIcons.textLong),
                child: const Text('Copy as plain text'),
              ),
              MenuItemButton(
                onPressed: () async {
                  if (chatAsync.valueOrNull != null) {
                    await Clipboard.setData(
                      ClipboardData(
                        text: chatAsync.valueOrNull!,
                      ),
                    );
                  }
                },
                // ignore: deprecated_member_use
                leadingIcon: const Icon(MdiIcons.languageMarkdown),
                child: const Text('Copy as markdown'),
              ),
              const Divider(),
              MenuItemButton(
                onPressed: () async {
                  await ref
                      .read(chatArchiveFileServiceProvider.notifier)
                      .delete(fileName);

                  if (context.mounted) {
                    context.pop();
                  }
                },
                leadingIcon: const Icon(Icons.delete),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: Skeletonizer(
        enabled: chatAsync.isLoading,
        justifyMultiLineText: false,
        child: chatAsync.when(
          data: (data) => Markdown(
            data: data,
            selectable: true,
            onTapLink: (text, href, title) async {
              if (href != null) {
                if (Uri.parse(href) case final Uri url) {
                  final launchExternal = ref.read(
                    settingsRepositoryProvider.select(
                      (value) => (value.valueOrNull ?? Settings.withDefaults())
                          .launchUrlExternal,
                    ),
                  );

                  if (launchExternal) {
                    await ui_helper.launchUrlFeedback(context, Uri.parse(href));
                  } else {
                    await ref
                        .read(switchNewTabControllerProvider.notifier)
                        .add(url);

                    if (context.mounted) {
                      context.go(KagiRoute().location);
                    }
                  }
                }
              }
            },
          ),
          error: (error, stackTrace) {
            return FailureWidget(
              title: 'Could not load chat',
              exception: error,
              onRetry: () => ref.refresh(readArchivedChatProvider(fileName)),
            );
          },
          loading: () => const Bone.multiText(
            lines: 15,
          ),
        ),
      ),
    );
  }
}
