import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/web_view/presentation/widgets/favicon.dart';
import 'package:lensai/presentation/controllers/website_title.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WebsiteTitleTile extends HookConsumerWidget {
  final Uri url;

  const WebsiteTitleTile(this.url, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final websiteTileAsync = ref.watch(pageInfoProvider(url));

    return Skeletonizer(
      enabled: websiteTileAsync.isLoading,
      child: websiteTileAsync.when(
        data: (info) {
          return ListTile(
            leading: FaviconImage(
              favicon: info.favicon,
              url: info.url,
              size: 24,
            ),
            contentPadding: EdgeInsets.zero,
            title: Text(info.title ?? 'Unknown Title'),
            subtitle: Text(url.authority),
          );
        },
        error: (error, stackTrace) {
          return FailureWidget(
            title: error.toString(),
            onRetry: () => ref.refresh(pageInfoProvider(url)),
          );
        },
        loading: () => const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Bone.text(),
          subtitle: Bone.text(),
        ),
      ),
    );
  }
}
