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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

/// Maximum gap (epoch millis) between a WebLibre `visit_container` relation row
/// and a Mozilla Places `VisitInfo` for them to be considered the same visit.
/// The relation's `visit_time` is captured near — not exactly at — the Places
/// record time (the native delegate stamps `System.currentTimeMillis()`), so
/// tagging/filtering matches the closest relation within this tolerance.
const int historyVisitContainerMatchWindowMs = 5000;

/// A single history-screen row: a Mozilla Places visit (the source of truth for
/// url, title, visit type and time) annotated with the WebLibre container(s)
/// it belonged to.
///
/// [containerIds] is the visit's resolved container tag — at most one entry for
/// a normal visit (the nearest relation within
/// [historyVisitContainerMatchWindowMs]); empty when the visit was uncontained
/// or predates history-relation recording.
class HistoryEntry with FastEquatable {
  // Destructured into `hashParameters` field by field instead of listed here:
  // `VisitInfo` is a Pigeon class with identity equality, so listing it would
  // make every rebuilt entry compare unequal.
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  /// The underlying Places visit; still used verbatim for opening the page and
  /// for the precise `(url, time)` Places delete.
  final VisitInfo visit;
  final List<String> containerIds;

  /// Primary key of the `visit_container` row that this visit paired with (the
  /// same one-to-one pairing that produced [containerIds]), or null when the
  /// visit is uncontained. Carried on the entry so a delete can drop exactly
  /// this visit's relation without re-deriving the nearest-time join — which
  /// could otherwise pick a sibling same-URL visit's relation and mislabel it.
  final int? containerRelationId;

  HistoryEntry({
    required this.visit,
    required this.containerIds,
    this.containerRelationId,
  });

  String get url => visit.url;
  String? get title => visit.title;
  int get visitTime => visit.visitTime;
  VisitType get visitType => visit.visitType;
  String? get previewImageUrl => visit.previewImageUrl;
  String? get contentId => visit.contentId;

  @override
  List<Object?> get hashParameters => [
    visit.url,
    visit.title,
    visit.visitTime,
    visit.visitType,
    visit.previewImageUrl,
    visit.contentId,
    containerIds,
    containerRelationId,
  ];
}

/// One-to-one nearest-time pairing between visits and `visit_container`
/// relations that share a canonical URL, given their epoch-millis timestamps.
///
/// Returns a map from visit index (into [visitTimes]) to the relation index
/// (into [relationTimes]) it pairs with. Pairs are assigned greedily from the
/// smallest in-window delta, consuming both sides, so a relation never tags two
/// visits and a visit never takes two relations. Shared by history annotation
/// and the per-container Places-delete mirror so they always agree on which
/// relation belongs to which visit.
Map<int, int> pairVisitsToRelationsByTime(
  List<int> visitTimes,
  List<int> relationTimes,
) {
  // All in-window (visit, relation) pairs, smallest delta first.
  final pairs = <({int visitIndex, int relationIndex, int delta})>[];
  for (var visitIndex = 0; visitIndex < visitTimes.length; visitIndex++) {
    for (
      var relationIndex = 0;
      relationIndex < relationTimes.length;
      relationIndex++
    ) {
      final delta = (relationTimes[relationIndex] - visitTimes[visitIndex])
          .abs();
      if (delta <= historyVisitContainerMatchWindowMs) {
        pairs.add((
          visitIndex: visitIndex,
          relationIndex: relationIndex,
          delta: delta,
        ));
      }
    }
  }
  pairs.sort((a, b) => a.delta.compareTo(b.delta));

  final relationByVisit = <int, int>{};
  final usedVisits = <int>{};
  final usedRelations = <int>{};
  for (final pair in pairs) {
    if (usedVisits.contains(pair.visitIndex) ||
        usedRelations.contains(pair.relationIndex)) {
      continue;
    }
    usedVisits.add(pair.visitIndex);
    usedRelations.add(pair.relationIndex);
    relationByVisit[pair.visitIndex] = pair.relationIndex;
  }
  return relationByVisit;
}
