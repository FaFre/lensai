import 'dart:async';

import 'package:exceptions/exceptions.dart';
import 'package:lensai/features/about/data/repositories/package_info_repository.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/domain/repositories/sync.dart';
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

  Future<void> initialize() async {
    state = await Result.fromAsync(() async {
      final errors = <ErrorMessage>[];

      await _initPackageInfo();

      final bangSyncResults = await _initBangs();
      for (final MapEntry(value: result) in bangSyncResults.entries) {
        result.onFailure(errors.add);
      }

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
