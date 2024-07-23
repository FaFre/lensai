import 'dart:async';

import 'package:lensai/features/bangs/data/database/database.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search.g.dart';

@Riverpod()
class BangSearch extends _$BangSearch {
  late StreamController<List<BangData>> _streamController;
  late BangDatabase _db;

  Future<void> search(String input) async {
    if (input.isNotEmpty) {
      await _db.bangDao.queryBangs(input).get().then(_streamController.add);
    }
  }

  @override
  Stream<List<BangData>> build() {
    _db = ref.watch(bangDatabaseProvider);
    _streamController = StreamController();

    ref.onDispose(() async {
      await _streamController.close();
    });

    return _streamController.stream;
  }
}
