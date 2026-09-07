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
import 'package:nullability/nullability.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_query_result.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';
import 'package:weblibre/features/web_feed/domain/providers/article_filter.dart';
import 'package:weblibre/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:weblibre/features/web_feed/extensions/atom.dart';
import 'package:weblibre/features/web_feed/extensions/feed_article.dart';
import 'package:weblibre/features/web_feed/presentation/widgets/authors_horizontal_list.dart';
import 'package:weblibre/features/web_feed/presentation/widgets/tags_horizontal_list.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/text_highlight.dart';

class FeedArticleCard extends HookConsumerWidget {
  static const _matchPrefix = '***';
  static const _matchSuffix = '***';

  final FeedArticleSummary article;

  const FeedArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final tags = ref.watch(articleFilterProvider);

    final titleHighlight = switch (article) {
      final FeedArticleQueryResult result => result.titleHighlight.whenNotEmpty,
      _ => null,
    };

    final searchSnippet = switch (article) {
      final FeedArticleQueryResult result =>
        result.summarySnippet.whenNotEmpty ??
            result.contentSnippet.whenNotEmpty,
      _ => null,
    };

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await FeedArticleRoute(articleId: article.id).push(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrlIcon([
                    article.icon ??
                        article.links
                            ?.getRelation(FeedLinkRelation.alternate)
                            ?.uri ??
                        article.siteLink ??
                        article.feedId.base,
                  ], iconSize: 34.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (titleHighlight.isNotEmpty)
                          Text.rich(
                            buildHighlightedText(
                              titleHighlight!,
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              _matchPrefix,
                              _matchSuffix,
                            ),
                          ),
                        if (titleHighlight.isEmpty)
                          Text(
                            article.displayTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                        if (searchSnippet.isNotEmpty)
                          Text.rich(
                            buildHighlightedText(
                              searchSnippet!,
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                              _matchPrefix,
                              _matchSuffix,
                              normalizeWhitespaces: true,
                            ),
                          ),
                        if (searchSnippet.isEmpty &&
                            article.summaryPlain != null)
                          Text(
                            article.summaryPlain!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (article.lastRead != null)
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(feedRepositoryProvider.notifier)
                            .unsetArticleRead(article.id);
                      },
                      icon: const Icon(Icons.visibility),
                    ),
                ],
              ),
              if (article.authors.isNotEmpty || article.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                if (article.authors.isNotEmpty)
                  AuthorsHorizontalList(
                    authors: article.authors!,
                    selectedTags: tags,
                    onTagSelected: (tagId, value) {
                      if (value) {
                        ref.read(articleFilterProvider.notifier).addTag(tagId);
                      } else {
                        ref
                            .read(articleFilterProvider.notifier)
                            .removeTag(tagId);
                      }
                    },
                  ),
                if (article.tags.isNotEmpty)
                  TagsHorizontalList(
                    tags: article.tags!,
                    selectedTags: tags,
                    onTagSelected: (tagId, value) {
                      if (value) {
                        ref.read(articleFilterProvider.notifier).addTag(tagId);
                      } else {
                        ref
                            .read(articleFilterProvider.notifier)
                            .removeTag(tagId);
                      }
                    },
                  ),
              ],
              const Divider(),
              Row(
                children: [
                  Text(
                    'Published: ${(article.created != null) ? timeago.format(article.created!) : 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (article.updated != null &&
                      article.updated != article.created)
                    Text(
                      'Updated: ${timeago.format(article.updated!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
