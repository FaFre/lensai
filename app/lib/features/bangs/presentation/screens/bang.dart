import 'package:bang_navigator/core/routing/routes.dart';
import 'package:bang_navigator/features/bangs/domain/providers.dart';
import 'package:bang_navigator/features/bangs/presentation/widgets/bang_details.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/sheet.dart';
import 'package:bang_navigator/features/search_browser/domain/providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BangScreen extends HookConsumerWidget {
  const BangScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangsAsync = ref.watch(allBangsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bangs'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push(BangSearchRoute().location);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: bangsAsync.when(
        data: (bangs) {
          return ListView.builder(
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
          );
        },
        error: (error, stackTrace) => SizedBox.shrink(),
        loading: () => SizedBox.shrink(),
      ),
    );
  }
}
