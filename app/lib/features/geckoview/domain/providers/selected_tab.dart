import 'dart:async';

import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_tab.g.dart';

@Riverpod(keepAlive: true)
class SelectedTab extends _$SelectedTab {
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
