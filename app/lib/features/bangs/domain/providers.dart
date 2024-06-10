import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/bang.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Stream<BangData?> bang(BangRef ref, String? trigger) {
  final repository = ref.watch(bangRepositoryProvider.notifier);
  return repository.watchBang(trigger);
}

@Riverpod(keepAlive: true)
Stream<BangData?> kagiSearchBang(KagiSearchBangRef ref) {
  final repository = ref.watch(bangRepositoryProvider.notifier);
  return repository.watchBang('kagi');
}

@Riverpod()
Stream<List<BangData>> allBangs(AllBangsRef ref) {
  final repository = ref.watch(bangRepositoryProvider.notifier);
  return repository.watchBangs();
}

@Riverpod()
Stream<List<BangData>> frequentBangs(FrequentBangsRef ref) {
  final repository = ref.watch(bangRepositoryProvider.notifier);
  return repository.watchFrequentBangs();
}

@Riverpod()
Future<BangData> ensureIconAvailable(
  EnsureIconAvailableRef ref,
  BangData bang,
) {
  final repository = ref.watch(bangRepositoryProvider.notifier);
  return repository.ensureIconAvailable(bang).then(
        (value) => value.value,
      );
}
