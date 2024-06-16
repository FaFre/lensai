import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/data.dart';
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
Stream<Map<String, List<String>>> bangCategories(BangCategoriesRef ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchCategories();
}

@Riverpod()
Stream<List<BangData>> bangDataList(
  BangDataListRef ref, {
  ({
    Iterable<BangGroup>? groups,
    String? domain,
    ({String category, String? subCategory})? categoryFilter,
    bool? orderMostFrequentFirst,
  })? filter,
}) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBangs(
    groups: filter?.groups,
    domain: filter?.domain,
    categoryFilter: filter?.categoryFilter,
    orderMostFrequentFirst: filter?.orderMostFrequentFirst,
  );
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

@Riverpod()
Stream<double> bangIconCacheSizeMegabytes(BangIconCacheSizeMegabytesRef ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchIconCacheSize();
}
