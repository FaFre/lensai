import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/bang_data.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/sync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Stream<BangData?> bangData(BangDataRef ref, String? trigger) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBang(trigger);
}

@Riverpod(keepAlive: true)
Stream<BangData?> kagiSearchBangData(KagiSearchBangDataRef ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBang('kagi');
}

@Riverpod()
Stream<List<BangData>> bangDataList(BangDataListRef ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBangs();
}

@Riverpod()
Stream<List<BangData>> frequentBangDataList(FrequentBangDataListRef ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchFrequentBangs();
}

@Riverpod()
Future<BangData> bangDataEnsureIcon(
  BangDataEnsureIconRef ref,
  BangData bang,
) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.ensureIconAvailable(bang).then(
        (value) => value.value,
      );
}

@Riverpod()
Stream<DateTime?> lastSyncOfGroup(
  LastSyncOfGroupRef ref,
  BangGroup group,
) {
  final repository = ref.watch(bangSyncRepositoryProvider.notifier);
  return repository.watchLastSyncOfGroup(group);
}

@Riverpod()
Stream<int> bangCountOfGroup(
  BangCountOfGroupRef ref,
  BangGroup group,
) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBangCount(group);
}
