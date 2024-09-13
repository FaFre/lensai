import 'dart:async';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/bangs/domain/repositories/search.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_details.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:lensai/features/search_browser/domain/entities/sheet.dart';
import 'package:lensai/features/search_browser/domain/providers.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class BangSearchScreen extends HookConsumerWidget {
  const BangSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(bangSearchProvider);
    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults()).incognitoMode,
      ),
    );

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
        data: (bangs) => FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView.builder(
              controller: controller,
              itemCount: bangs.length,
              itemBuilder: (context, index) {
                final bang = bangs[index];
                return BangDetails(
                  bang,
                  onTap: () {
                    ref
                        .read(selectedBangTriggerProvider().notifier)
                        .setTrigger(bang.trigger);

                    if (ref.read(bottomSheetProvider) is! CreateTabSheet) {
                      ref.read(bottomSheetProvider.notifier).show(
                            CreateTabSheet(preferredTool: KagiTool.search),
                          );
                    }

                    context.go(KagiRoute().location);
                  },
                );
              },
            );
          },
        ),
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Bang Search failed',
            exception: error,
          ),
        ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
