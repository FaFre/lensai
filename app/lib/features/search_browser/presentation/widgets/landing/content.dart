import 'package:bang_navigator/features/search_browser/presentation/widgets/landing/action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LandingContent extends HookConsumerWidget {
  const LandingContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // ignore: discarded_futures
    final descriptionAssetFuture = useMemoized(
      () async => rootBundle.loadString('assets/landing/description.md'),
    );
    final descriptionAsset = useFuture(descriptionAssetFuture);

    // ignore: discarded_futures
    final changelogAssetFuture = useMemoized(
      () async => rootBundle.loadString('assets/landing/changelog.md'),
    );
    final changelogAsset = useFuture(changelogAssetFuture);

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
