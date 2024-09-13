import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_tab.g.dart';

@Riverpod(keepAlive: true)
class SelectedTabController extends _$SelectedTabController {
  final _tabsService = GeckoTabService();

  Future<void> selectTab(String tabId) {
    return _tabsService.selectTab(tabId: tabId);
  }

  @override
  String? build() {
    final eventSerivce = ref.watch(eventServiceProvider);

    final selectedTabSub = eventSerivce.selectedTabEvents.listen(
      (tabId) {
        state = tabId;
      },
    );

    ref.onDispose(() {
      unawaited(selectedTabSub.cancel());
    });

    return null;
  }
}
