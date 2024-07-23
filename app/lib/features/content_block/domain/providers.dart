import 'package:lensai/features/content_block/data/models/host.dart';
import 'package:lensai/features/content_block/domain/repositories/host.dart';
import 'package:lensai/features/content_block/domain/repositories/sync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Stream<DateTime?> lastSyncOfSource(
  LastSyncOfSourceRef ref,
  HostSource source,
) {
  final repository = ref.watch(hostSyncRepositoryProvider.notifier);
  return repository.watchLastSyncOfSource(source);
}

@Riverpod()
Stream<int> hostCountOfSource(
  HostCountOfSourceRef ref,
  HostSource source,
) {
  final repository = ref.watch(hostRepositoryProvider.notifier);
  return repository.watchHostCount(source);
}
