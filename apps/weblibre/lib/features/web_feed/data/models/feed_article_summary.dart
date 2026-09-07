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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/web_feed/data/models/feed_author.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';

/// Everything an article *list* row renders.
///
/// Exists so a list can be typed on what it actually shows rather than on the
/// full `FeedArticle`, whose five body columns (`summaryHtml`,
/// `summaryMarkdown`, `contentHtml`, `contentMarkdown`, `contentPlain`) hold the
/// whole entry. `FeedArticle` implements this, so the article detail screen and
/// search results — which do carry the body — still satisfy every list widget.
abstract interface class FeedArticleSummary {
  String get id;
  Uri get feedId;
  DateTime get fetched;
  DateTime? get created;
  DateTime? get updated;
  DateTime? get lastRead;
  String? get title;
  List<FeedAuthor>? get authors;
  List<FeedCategory>? get tags;
  List<FeedLink>? get links;

  /// The short preview the card shows. Kept because it is short — the RSS
  /// summary, not the article.
  String? get summaryPlain;

  /// Both derived from the `feed` row by the view.
  Uri? get icon;
  Uri? get siteLink;
}

/// A row of `article_list_view`.
class FeedArticleListEntry with FastEquatable implements FeedArticleSummary {
  @override
  final String id;
  @override
  final Uri feedId;
  @override
  final DateTime fetched;
  @override
  final DateTime? created;
  @override
  final DateTime? updated;
  @override
  final DateTime? lastRead;
  @override
  final String? title;
  @override
  final List<FeedAuthor>? authors;
  @override
  final List<FeedCategory>? tags;
  @override
  final List<FeedLink>? links;
  @override
  final String? summaryPlain;
  @override
  final Uri? icon;
  @override
  final Uri? siteLink;

  FeedArticleListEntry({
    required this.id,
    required this.feedId,
    required this.fetched,
    this.created,
    this.updated,
    this.lastRead,
    this.title,
    this.authors,
    this.tags,
    this.links,
    this.summaryPlain,
    this.icon,
    this.siteLink,
  });

  @override
  List<Object?> get hashParameters => [
    id,
    feedId,
    fetched,
    created,
    updated,
    lastRead,
    title,
    authors,
    tags,
    links,
    summaryPlain,
    icon,
    siteLink,
  ];
}
