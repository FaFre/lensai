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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/empty_state_content.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';
import 'package:weblibre/features/web_feed/extensions/atom.dart';
import 'package:weblibre/features/web_feed/extensions/feed_article.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class RecentFeedArticlesSection extends ConsumerWidget {
  final void Function(FeedArticleSummary article) onArticleSelected;

  const RecentFeedArticlesSection({super.key, required this.onArticleSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(
      searchEmptyRecentFeedArticlesProvider().select(
        (value) => value.value ?? [],
      ),
    );

    if (articles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SearchModuleSection(
      title: 'Recent Articles',
      moduleType: SearchModuleType.recentArticles,
      totalCount: articles.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverList.builder(
                itemCount: visibleCount,
                itemBuilder: (context, index) {
                  final article = articles[index];
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
                    title: Text(
                      article.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.summaryPlain != null)
                          Text(
                            article.summaryPlain!,
                            style: Theme.of(context).textTheme.bodySmall,
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
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    onTap: () => onArticleSelected(article),
                  );
                },
              ),
          ],
    );
  }
}
