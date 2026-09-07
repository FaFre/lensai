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
import 'package:exceptions/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/database/database.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/providers.dart';
import 'package:weblibre/features/bangs/data/services/data_source.dart';

part 'sync.g.dart';

@Riverpod(keepAlive: true)
class BangSyncRepository extends _$BangSyncRepository {
  static Future<Result<void>> _fetchAndSyncRemote({
    required BangDataSourceService sourceService,
    required BangDatabase db,
    required Uri url,
    required BangGroup group,
    required Duration? syncInterval,
  }) async {
    if (syncInterval != null) {
      final lastSync = await db.syncDao
          .getLastSyncOfGroup(group)
          .getSingleOrNull();

      if (lastSync != null &&
          DateTime.now().difference(lastSync) < syncInterval) {
        return Result.success(null);
      }
    }

    final result = await sourceService.fetchRemoteBangs(url, group);
    return result.flatMapAsync((remoteBangs) async {
      await db.syncDao.syncBangs(
        group: group,
        remoteBangs: remoteBangs,
        syncTime: DateTime.now(),
      );
      await db.definitionsDrift.optimizeBangFtsIndex();
      await db.definitionsDrift.optimizeTriggerFtsIndex();
    });
  }

  /// Imports one bundled group, given its already-loaded asset text.
  ///
  /// Runs entirely off the main isolate — see [syncBundledBangGroup] for why the
  /// asset is read by the caller rather than here.
  static Future<void> _syncBundledPayload({
    required BangDatabase db,
    required BangGroup group,
    required String assetJson,
    required DateTime sourceDate,
  }) async {
    final bangs = parseBundledBangs(assetJson, group);

    await db.syncDao.syncBangs(
      group: group,
      remoteBangs: bangs,
      syncTime: sourceDate,
    );
    await db.definitionsDrift.optimizeBangFtsIndex();
    await db.definitionsDrift.optimizeTriggerFtsIndex();
  }

  Future<Result<void>> syncRemoteBangGroup(
    BangGroup group,
    Duration? syncInterval,
  ) async {
    try {
      return Result.success(
        await ref
            .read(bangDatabaseProvider)
            .computeWithDatabase(
              connect: BangDatabase.new,
              computation: (db) async {
                final ref = ProviderContainer();
                final result = await _fetchAndSyncRemote(
                  sourceService: ref.read(
                    bangDataSourceServiceProvider.notifier,
                  ),
                  db: db,
                  url: Uri.parse(group.remote!),
                  group: group,
                  syncInterval: syncInterval,
                );

                //Throw if necessary
                return result.value;
              },
            ),
      );
    } catch (e) {
      return Result.failure(
        ErrorMessage(
          message: "Failed to sync Bangs (${group.name})",
          source: 'BangSync',
          details: e,
        ),
      );
    }
  }

  /// Imports the bundled copy of [group] when the shipped assets are newer than
  /// what this profile already holds.
  ///
  /// This runs on every launch, and on the launch after an app update it has
  /// real work to do: the main group is ~2.2 MB of JSON and ~10 900 rows. That
  /// used to be decoded, mapped and diffed on the main isolate while the startup
  /// spinner was up. Now only the two cheap reads happen here — the stored sync
  /// date, and (when a sync is actually due) the asset text, which `rootBundle`
  /// can only be asked for on the main isolate — and everything expensive runs
  /// in the isolate `computeWithDatabase` opens, the way the remote path already
  /// did.
  Future<Result<void>> syncBundledBangGroup(BangGroup group) async {
    final bundled = group.bundled;
    if (bundled == null) {
      return Result.failure(
        const ErrorMessage(source: 'BangSync', message: 'Not bundled'),
      );
    }

    try {
      final db = ref.read(bangDatabaseProvider);
      final sourceService = ref.read(bangDataSourceServiceProvider.notifier);

      final lastSync = await db.syncDao
          .getLastSyncOfGroup(group)
          .getSingleOrNull();

      final sourceDate = await sourceService.getBundledBangDate(
        'assets/bangs/last_sync.txt',
      );

      // The usual answer, and the reason this check stays out of the isolate:
      // nothing shipped is newer than what is stored, so no asset is read and
      // no isolate is spawned.
      if (lastSync != null &&
          (sourceDate == lastSync ||
              sourceDate.difference(lastSync).isNegative)) {
        return Result.success(null);
      }

      final assetJson = await sourceService.loadBundledBangJson(bundled);

      await db.computeWithDatabase(
        connect: BangDatabase.new,
        computation: (db) => _syncBundledPayload(
          db: db,
          group: group,
          assetJson: assetJson,
          sourceDate: sourceDate,
        ),
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ErrorMessage(
          message: "Failed to sync Bangs (${group.name})",
          source: 'BangSync',
          details: e,
        ),
      );
    }
  }

  Stream<DateTime?> watchLastSyncOfGroup(BangGroup group) {
    return ref
        .read(bangDatabaseProvider)
        .syncDao
        .getLastSyncOfGroup(group)
        .watchSingleOrNull();
  }

  Future<Map<BangGroup, Result<void>>> syncBundledBangGroups({
    Set<BangGroup>? groups,
  }) async {
    //Default to all sources
    groups ??= BangGroup.values.where((e) => e.bundled != null).toSet();

    // Sequential, deliberately. Each group that actually needs importing opens
    // its own isolate through `computeWithDatabase`, and `Future.wait` would
    // start all of them at once — three isolates competing for CPU during the
    // engine bring-up they were just moved alongside. They gain nothing from
    // overlapping: drift funnels every one of them onto the same background
    // executor, so the writes serialise regardless.
    final results = <BangGroup, Result<void>>{};
    for (final group in groups) {
      results[group] = await syncBundledBangGroup(group);
    }

    return results;
  }

  @override
  void build() {}
}
