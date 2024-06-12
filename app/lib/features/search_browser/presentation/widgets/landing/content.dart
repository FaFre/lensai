import 'package:bang_navigator/domain/services/app_initialization.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/error_container.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/landing/action.dart';
import 'package:bang_navigator/presentation/hooks/cached_future.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LandingContent extends HookConsumerWidget {
  const LandingContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final descriptionAsset = useCachedFuture(
      () async => rootBundle.loadString('assets/landing/description.md'),
    );
    final changelogAsset = useCachedFuture(
      () async => rootBundle.loadString('assets/landing/changelog.md'),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'BangNavigator',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            'A Privacy-Focused Browser for Kagi',
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          FractionallySizedBox(
            widthFactor: 0.5,
            child: Image.asset('assets/icon/icon.png'),
          ),
          const LandingAction(),
          Consumer(
            builder: (context, ref, child) {
              final errors = ref.watch(
                appInitializationServiceProvider
                    .select((result) => result.valueOrNull?.errors),
              );

              if (errors == null || errors.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...errors.map(
                    (error) {
                      final theme = Theme.of(context);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ErrorContainer(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Error during App Initialization!',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                error.message,
                                style: theme.textTheme.titleSmall,
                              ),
                              if (error.details != null)
                                Text(error.details.toString()),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          await ref
                              .read(appInitializationServiceProvider.notifier)
                              .reinitialize();
                        },
                        style: OutlinedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        label: const Text('Restart App'),
                        icon: const Icon(Icons.refresh_outlined),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Markdown(
            data: descriptionAsset.data ?? '',
            selectable: true,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          Text(
            'Changelog',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Markdown(
            data: changelogAsset.data ?? '',
            selectable: true,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }
}
