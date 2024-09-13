import 'dart:async';

import 'package:exceptions/exceptions.dart';
import 'package:lensai/features/about/data/repositories/package_info_repository.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/domain/repositories/sync.dart';
import 'package:lensai/features/content_block/data/models/host.dart';
import 'package:lensai/features/content_block/domain/repositories/sync.dart';
import 'package:lensai/features/search_browser/domain/services/session.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_initialization.g.dart';

@Riverpod(keepAlive: true)
class AppInitializationService extends _$AppInitializationService {
  /// Will de facto restart the app
  Future<void> reinitialize() {
    ref.invalidateSelf();
    return initialize();
  }

  Future<void> _initPackageInfo() {
    //Ensure Package info is loaded
    state = Result.success(
      (
        initialized: false,
        stage: 'Loading Package Info...',
        errors: List.empty(),
      ),
    );

    return ref.read(packageInfoProvider.future);
  }

  Future<Map<BangGroup, Result<void>>> _initBangs() {
    state = Result.success(
      (
        initialized: false,
        stage: 'Synchronizing Bangs...',
        errors: List.empty(),
      ),
    );

    return ref
        .read(bangSyncRepositoryProvider.notifier)
        .syncBangGroups(syncInterval: const Duration(days: 7));
  }

  FutureOr<Map<HostSource, Result<void>>> _initHosts(Settings settings) {
    if (settings.enableContentBlocking) {
      state = Result.success(
        (
          initialized: false,
          stage: 'Synchronizing Ad & Content Blocking Lists...',
          errors: List.empty(),
        ),
      );

      return ref.read(hostSyncRepositoryProvider.notifier).syncHostSources(
            sources: settings.enableHostList,
            syncInterval: const Duration(days: 7),
          );
    }

    return {};
  }

  Future<void> _initIncognito(Settings settings) async {
    state = Result.success(
      (
        initialized: false,
        stage: 'Enforcing Privacy...',
        errors: List.empty(),
      ),
    );

    if (settings.incognitoMode) {
      await ref.read(sessionServiceProvider.notifier).clearAllData();
      //Delete all unsasigned tabs
      await ref.read(tabDatabaseProvider).tabDao.deleteTopicTabs(null);
    }

    if (settings.kagiSession case final String session) {
      if (session.isNotEmpty) {
        await ref.read(sessionServiceProvider.notifier).setKagiSession(session);
      }
    }
  }

  Future<void> initialize() async {
    state = await Result.fromAsync(() async {
      final settings = await ref.read(settingsRepositoryProvider.future);
      final errors = <ErrorMessage>[];

      await _initPackageInfo();

      final bangSyncResults = await _initBangs();
      for (final MapEntry(value: result) in bangSyncResults.entries) {
        result.onFailure(errors.add);
      }

      final hostSyncResults = await _initHosts(settings);
      for (final MapEntry(value: result) in hostSyncResults.entries) {
        result.onFailure(errors.add);
      }

      await _initIncognito(settings);

      return (initialized: true, stage: null, errors: errors);
    });
  }

  @override
  Result<({bool initialized, String? stage, List<ErrorMessage> errors})>
      build() {
    return Result.success(
      (initialized: false, stage: null, errors: List.empty()),
    );
  }
}
