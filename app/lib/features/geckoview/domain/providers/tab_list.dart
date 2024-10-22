import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_list.g.dart';

@Riverpod(keepAlive: true)
class TabList extends _$TabList {
  late TabDatabase _db;

  List<String> build() {
    final eventService = ref.watch(eventServiceProvider);

    _db = ref.watch(tabDatabaseProvider);

    ref.listen(
      fireImmediately: true,
      engineReadyStateProvider,
      (previous, next) async {
        if (next) {
          await GeckoTabService().syncEvents(onTabListChange: true);
        }
      },
    );

    final tabListSub = eventService.tabListEvents.listen(
      (tabs) async {
        if (!const DeepCollectionEquality().equals(state, tabs)) {
          //Make sure we only syncing empty lists when there has been tabs
          //before as security measurement
          final syncTabs = tabs.isNotEmpty || state.isNotEmpty;

          state = tabs;

          if (syncTabs) {
            await _db.tabDao.syncTabs(retainTabIds: tabs);
          }
        }
      },
    );

    ref.onDispose(() {
      unawaited(tabListSub.cancel());
    });

    return [];
  }
}
