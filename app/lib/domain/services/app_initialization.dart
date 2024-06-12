import 'package:bang_navigator/features/about/data/repositories/package_info_repository.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/sync.dart';
import 'package:bang_navigator/features/search_browser/domain/services/session.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:exceptions/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_initialization.g.dart';

@Riverpod(keepAlive: true)
class AppInitializationService extends _$AppInitializationService {
  /// Will de facto restart the app
  Future<void> reinitialize() async {
    ref.invalidateSelf();
    return initialize();
  }

  Future<void> initialize() async {
    state = await Result.fromAsync(() async {
      final errors = <ErrorMessage>[];

      //Ensure Package info is loaded
      state = Result.success(
        (
          initialized: false,
          stage: 'Loading Package Info...',
          errors: List.empty()
        ),
      );
      await ref.read(packageInfoProvider.future);

      state = Result.success(
        (
          initialized: false,
          stage: 'Synchronizing Bangs...',
          errors: List.empty()
        ),
      );
      final syncResults = await ref
          .read(bangSyncRepositoryProvider.notifier)
          .syncAllBangGroups(syncInterval: const Duration(days: 7));
      for (final MapEntry(value: result) in syncResults.entries) {
        result.onFailure(errors.add);
      }

      state = Result.success(
        (
          initialized: false,
          stage: 'Enforcing Privacy...',
          errors: List.empty()
        ),
      );
      final settings = await ref.read(settingsRepositoryProvider.future);
      if (settings.incognitoMode) {
        await ref.read(sessionServiceProvider.notifier).clearAllData();
      }

      if (settings.kagiSession case final String session) {
        if (session.isNotEmpty) {
          await ref
              .read(sessionServiceProvider.notifier)
              .setKagiSession(session);
        }
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
