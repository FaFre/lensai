import 'dart:async';

import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/features/topics/data/database/database.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_tab.g.dart';

@Riverpod(keepAlive: true)
class SelectedTab extends _$SelectedTab {
  late TabDatabase _db;

  @override
  String? build() {
    _db = ref.watch(tabDatabaseProvider);

    final eventSerivce = ref.watch(eventServiceProvider);

    final selectedTabSub = eventSerivce.selectedTabEvents.listen(
      (tabId) {
        state = tabId;
      },
    );

    ref.listenSelf((previous, next) async {
      if (next != null) {
        await _db.tabLinkDao.touchTabLink(next, timestamp: DateTime.now());
      }
    });

    ref.onDispose(() {
      unawaited(selectedTabSub.cancel());
    });

    return null;
  }
}
