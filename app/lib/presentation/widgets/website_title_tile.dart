import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/presentation/controllers/website_title.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WebsiteTitleTile extends HookConsumerWidget {
  final Uri url;
  final WebPageInfo? precachedInfo;

  const WebsiteTitleTile(this.url, {this.precachedInfo, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageInfoAsync = ref.watch(pageInfoProvider(url));

    return Skeletonizer(
      enabled: pageInfoAsync.isLoading && precachedInfo == null,
      child: pageInfoAsync.when(
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
        loading: () => (precachedInfo != null)
            ? ListTile(
                leading: FaviconImage(
                  favicon: precachedInfo!.favicon,
                  url: precachedInfo!.url,
                  size: 24,
                ),
                contentPadding: EdgeInsets.zero,
                title: Text(precachedInfo!.title ?? 'Unknown Title'),
                subtitle: Text(url.authority),
              )
            : const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Bone.text(),
                subtitle: Bone.text(),
              ),
      ),
    );
  }
}
