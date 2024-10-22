import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_tab.g.dart';

@Riverpod(keepAlive: true)
class SelectedTab extends _$SelectedTab {
  late TabDatabase _db;

  @override
  String? build() {
    final eventSerivce = ref.watch(eventServiceProvider);

    _db = ref.watch(tabDatabaseProvider);

    ref.listen(
      fireImmediately: true,
      engineReadyStateProvider,
      (previous, next) async {
        if (next) {
          await GeckoTabService().syncEvents(onSelectedTabChange: true);
        }
      },
    );

    final selectedTabSub = eventSerivce.selectedTabEvents.listen(
      (tabId) async {
        state = tabId;

        if (tabId != null) {
          await _db.tabDao.touchTab(tabId, timestamp: DateTime.now());
        }
      },
    );

    ref.onDispose(() {
      unawaited(selectedTabSub.cancel());
    });

    return null;
  }
}
