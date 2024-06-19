import 'package:bang_navigator/features/content_block/domain/repositories/host.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Stream<Set<String>?> blockContentHosts(BlockContentHostsRef ref) {
  final hostRepository = ref.watch(hostRepositoryProvider.notifier);
  final enableContentBlocking = ref.watch(
    settingsRepositoryProvider
        .select((value) => value.valueOrNull?.enableContentBlocking ?? false),
  );
  final enableHostList = ref.watch(
    settingsRepositoryProvider
        .select((value) => value.valueOrNull?.enableHostList ?? {}),
  );

  if (!enableContentBlocking || enableHostList.isEmpty) {
    return Stream.value(null);
  }

  return hostRepository
      .watchHosts(sources: enableHostList)
      .map((hosts) => hosts.toSet());
}
