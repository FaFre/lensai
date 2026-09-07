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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/data/models/feed_author.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';

part 'feed_article.g.dart';

@JsonSerializable()
@CopyWith()
class FeedArticle
    with FastEquatable
    implements Insertable<FeedArticle>, FeedArticleSummary {
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
  final String? summaryHtml;
  final String? summaryMarkdown;
  @override
  final String? summaryPlain;
  final String? contentHtml;
  final String? contentMarkdown;
  final String? contentPlain;

  //Derived by view from feed table, should not get inserted
  @override
  final Uri? icon;
  @override
  final Uri? siteLink;

  FeedArticle({
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
    this.summaryHtml,
    this.summaryMarkdown,
    this.summaryPlain,
    this.contentHtml,
    this.contentMarkdown,
    this.contentPlain,
    this.icon,
    this.siteLink,
  });

  factory FeedArticle.fromJson(Map<String, dynamic> json) =>
      _$FeedArticleFromJson(json);

  Map<String, dynamic> toJson() => _$FeedArticleToJson(this);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['feed_id'] = Variable<String>(Article.$converterfeedId.toSql(feedId));
    }
    map['fetched'] = Variable<DateTime>(fetched);
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = Variable<DateTime>(updated);
    }
    if (!nullToAbsent || lastRead != null) {
      map['last_read'] = Variable<DateTime>(lastRead);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || authors != null) {
      map['authors'] = Variable<String>(
        Article.$converterauthorsn.toSql(authors),
      );
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(Article.$convertertagsn.toSql(tags));
    }
    if (!nullToAbsent || links != null) {
      map['links'] = Variable<String>(Article.$converterlinksn.toSql(links));
    }
    if (!nullToAbsent || summaryHtml != null) {
      map['summaryHtml'] = Variable<String>(summaryHtml);
    }
    if (!nullToAbsent || summaryMarkdown != null) {
      map['summaryMarkdown'] = Variable<String>(summaryMarkdown);
    }
    if (!nullToAbsent || summaryPlain != null) {
      map['summaryPlain'] = Variable<String>(summaryPlain);
    }
    if (!nullToAbsent || contentHtml != null) {
      map['contentHtml'] = Variable<String>(contentHtml);
    }
    if (!nullToAbsent || contentMarkdown != null) {
      map['contentMarkdown'] = Variable<String>(contentMarkdown);
    }
    if (!nullToAbsent || contentPlain != null) {
      map['contentPlain'] = Variable<String>(contentPlain);
    }
    return map;
  }

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
    summaryHtml,
    summaryMarkdown,
    summaryPlain,
    contentHtml,
    contentMarkdown,
    contentPlain,
    icon,
    siteLink,
  ];
}
