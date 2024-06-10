import 'dart:async';

import 'package:bang_navigator/core/routing/routes.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/bang_search.dart';
import 'package:bang_navigator/features/bangs/presentation/widgets/bang_details.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/sheet.dart';
import 'package:bang_navigator/features/search_browser/domain/providers.dart';
import 'package:bang_navigator/presentation/hooks/listenable_callback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BangSearchScreen extends HookConsumerWidget {
  const BangSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(bangSearchProvider);

    final textEditingController = useTextEditingController();

    useListenableCallback(textEditingController, () async {
      unawaited(
        ref
            .read(bangSearchProvider.notifier)
            .search(textEditingController.text),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: textEditingController,
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
        data: (bangs) => ListView.builder(
          itemCount: bangs.length,
          itemBuilder: (context, index) {
            final bang = bangs[index];
            return BangDetails(
              bang,
              onTap: () {
                ref
                    .read(selectedBangTriggerProvider.notifier)
                    .setTrigger(bang.trigger);

                if (ref.read(bottomSheetProvider) is! CreateTab) {
                  ref.read(bottomSheetProvider.notifier).show(
                        CreateTab(
                          preferredTool: KagiTool.search,
                        ),
                      );
                }

                context.go(KagiRoute().location);
              },
            );
          },
        ),
        error: (error, stackTrace) => SizedBox.shrink(),
        loading: () => SizedBox.shrink(),
      ),
    );
  }
}
