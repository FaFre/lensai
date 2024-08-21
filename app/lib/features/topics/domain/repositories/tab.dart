import 'package:lensai/features/topics/data/database/database.dart';
import 'package:lensai/features/topics/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  late TabDatabase _db;

  @override
  void build() {
    _db = ref.watch(tabDatabaseProvider);
  }
}
