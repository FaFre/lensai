/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_query_result.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/features/web_feed/extensions/atom.dart';
import 'package:weblibre/features/web_feed/extensions/feed_article.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/text_highlight.dart';

class FeedSearch extends HookConsumerWidget {
  static const _matchPrefix = '***';
  static const _matchSuffix = '***';

  final ValueListenable<TextEditingValue> searchTextNotifier;

  const FeedSearch({super.key, required this.searchTextNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final articlesAsync = ref.watch(articleSearchProvider(null));
    final totalResults = articlesAsync.value?.length ?? 0;

    useOnListenableChangeSelector(
      searchTextNotifier,
      () => searchTextNotifier.value.text,
      () async {
        await ref
            .read(articleSearchProvider(null).notifier)
            .search(
              searchTextNotifier.value.text,
              matchPrefix: _matchPrefix,
              matchSuffix: _matchSuffix,
            );
      },
    );

    if (articlesAsync.hasValue && (articlesAsync.value.isEmpty)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SearchModuleSection(
      title: 'Articles',
      moduleType: SearchModuleType.articles,
      totalCount: totalResults,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            SliverSkeletonizer(
              enabled: articlesAsync.isLoading,
              child: articlesAsync.when(
                skipLoadingOnReload: true,
                data: (articles) {
                  return SliverList.builder(
                    itemCount: visibleCount,
                    itemBuilder: (context, index) {
                      final article = articles[index];

                      final titleHighlight = switch (article) {
                        final FeedArticleQueryResult result =>
                          result.titleHighlight.whenNotEmpty,
                        _ => null,
                      };

                      final searchSnippet = switch (article) {
                        final FeedArticleQueryResult result =>
                          result.summarySnippet.whenNotEmpty ??
                              result.contentSnippet.whenNotEmpty,
                        _ => null,
                      };

                      final articleDate = article.updated ?? article.created;

                      return ListTile(
                        leading: RepaintBoundary(
                          child: UrlIcon([
                            article.icon ??
                                article.links
                                    ?.getRelation(FeedLinkRelation.alternate)
                                    ?.uri ??
                                article.siteLink ??
                                article.feedId.base,
                          ], iconSize: 24.0),
                        ),
                        title: (titleHighlight.isNotEmpty)
                            ? Text.rich(
                                buildHighlightedText(
                                  titleHighlight!,
                                  Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  _matchPrefix,
                                  _matchSuffix,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                article.displayTitle,
                                style: theme.textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (searchSnippet.isNotEmpty)
                              Text.rich(
                                buildHighlightedText(
                                  searchSnippet!,
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  _matchPrefix,
                                  _matchSuffix,
                                  normalizeWhitespaces: true,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )
                            else if (article.summaryPlain != null)
                              Text(
                                article.summaryPlain!,
                                style: theme.textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (articleDate != null)
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  ref
                                      .read(formatProvider.notifier)
                                      .fullDateTime(articleDate),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          FeedArticleRoute(
                            articleId: article.id,
                          ).pushReplacement(context);
                        },
                      );
                    },
                  );
                },
                error: (error, stackTrace) {
                  return SliverToBoxAdapter(
                    child: FailureWidget(
                      title: 'Failed searching Articles',
                      exception: error,
                    ),
                  );
                },
                loading: () => SliverList.builder(
                  itemCount: isCollapsed ? 0 : previewItemsPerModule,
                  itemBuilder: (context, index) {
                    return const ListTile(title: Bone.text());
                  },
                ),
              ),
            ),
          ],
    );
  }
}
