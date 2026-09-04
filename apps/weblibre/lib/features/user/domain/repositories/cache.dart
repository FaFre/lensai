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
import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/icon_cache_marker.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'cache.g.dart';

/// One announced change to the favicon cache: the [origin] whose entry changed,
/// or `null` when the whole cache was cleared.
///
/// [revision] is a process-wide counter rather than a per-origin one so that a
/// listener which restarts — a provider rebuild, say — can never be handed a
/// number it has already seen and read it as "nothing changed".
typedef IconCacheInvalidation = ({String? origin, int revision});

@Riverpod(keepAlive: true)
class CacheRepository extends _$CacheRepository {
  /// Announces the origin whose cached icon just changed, or `null` when the
  /// whole cache was cleared.
  ///
  /// The icon cache is read once per row by every list on screen, so no reader
  /// can afford to hold a reactive query against it — that was one live SQLite
  /// watch per visible row, opened and torn down on every scroll pass, for a
  /// table that changes only when a favicon is actually fetched. See
  /// https://github.com/FaFre/WebLibre/issues/599.
  ///
  /// Every write passes through this repository, so the write side announces
  /// the change and readers re-read, which inverts the cost onto the side that
  /// occurs far less often. "Change" is meant literally: a write that leaves a
  /// reader rendering the same thing — the same favicon bytes arriving again on
  /// the next navigation, a no-op `cacheIconIfAbsent`, a missing-icon marker
  /// over an origin that already had none — announces nothing, because the only
  /// thing it could achieve is throwing away a decoded icon that is still
  /// correct.
  ///
  /// Deliberately never closed: the notifier outlives its [build] (Riverpod
  /// keeps the instance across rebuilds), so closing it from a build-scoped
  /// `onDispose` would silently mute every subscriber taken out since. It holds
  /// no resources and is collected with the notifier.
  final _iconInvalidations =
      StreamController<IconCacheInvalidation>.broadcast();

  var _revision = 0;

  // A side channel rather than provider state on purpose: see the invalidation
  // stream's doc above — readers re-read on announcement, they do not rebuild
  // on a state change.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  Stream<IconCacheInvalidation> get iconInvalidations =>
      _iconInvalidations.stream;

  void _notifyIconChanged(String? origin) {
    _iconInvalidations.add((origin: origin, revision: ++_revision));
  }

  /// Writes an icon, announcing it only when a reader would render something
  /// different afterwards.
  ///
  /// Every write path funnels through here so the "announce only real changes"
  /// rule cannot be forgotten by one of them.
  Future<void> _writeIcon(UserDatabase db, Uri url, Uint8List bytes) async {
    if (await db.cacheDao.cacheIconReportingChange(url.origin, bytes)) {
      _notifyIconChanged(url.origin);
    }
  }

  Future<void> clearCache() async {
    await ref.read(userDatabaseProvider).cacheDao.clearIconCache();
    _notifyIconChanged(null);
  }

  Future<void> cacheIcon(Uri url, Uint8List bytes) {
    return _writeIcon(ref.read(userDatabaseProvider), url, bytes);
  }

  Future<void> cacheIconIfAbsent(Uri url, Uint8List bytes) async {
    final wrote = await ref
        .read(userDatabaseProvider)
        .cacheDao
        .cacheIconIfAbsent(url.origin, bytes);

    if (wrote) {
      _notifyIconChanged(url.origin);
    }
  }

  Future<void> cacheMissingIcon(Uri url) async {
    final changed = await ref
        .read(userDatabaseProvider)
        .cacheDao
        .cacheMissingIcon(url.origin);

    if (changed) {
      _notifyIconChanged(url.origin);
    }
  }

  Future<Uint8List?> getCachedIcon(String origin) async {
    final bytes = await getCachedIconRaw(origin);
    if (isMissingIconMarker(bytes)) {
      return null;
    }
    return bytes;
  }

  Future<Uint8List?> getCachedIconRaw(String origin) {
    return ref
        .read(userDatabaseProvider)
        .cacheDao
        .getCachedIcon(origin)
        .getSingleOrNull();
  }

  bool isMissingIconBytes(Uint8List? bytes) {
    return isMissingIconMarker(bytes);
  }

  Future<DateTime?> getCachedIconFetchDate(String origin) {
    return ref
        .read(userDatabaseProvider)
        .cacheDao
        .getCachedIconFetchDate(origin)
        .getSingleOrNull();
  }

  @override
  void build() {
    final eventService = ref.watch(eventServiceProvider);

    final db = ref.watch(userDatabaseProvider);

    final sub = eventService.iconUpdateEvents.listen(
      (event) async {
        final url = Uri.tryParse(event.url);
        // `Uri.origin` throws for anything that is not http(s) with a host, and
        // Gecko reports icons for internal pages too.
        if (url == null || !url.isHttpOrHttps || url.host.isEmpty) {
          return;
        }

        // This is the path most favicons arrive by, and it fires on essentially
        // every navigation — which is exactly why it goes through the
        // change-reporting write rather than announcing unconditionally.
        await _writeIcon(db, url, event.bytes);
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in icon update events',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      await sub.cancel();
    });
  }
}
