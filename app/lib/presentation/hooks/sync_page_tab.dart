import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useSyncPageWithTab(
  TabController tabController,
  PageController pageController, {
  void Function(int index)? onIndexChanged,
}) {
  useEffect(
    () {
      Future<void> syncPage() async {
        await pageController.animateToPage(
          tabController.index,
          curve: Curves.linear,
          duration: const Duration(milliseconds: 300),
        );
        onIndexChanged?.call(tabController.index);
      }

      void syncTab() {
        if (!tabController.indexIsChanging) {
          final index = pageController.page!.round();

          tabController.animateTo(index);
          onIndexChanged?.call(index);
        }
      }

      tabController.addListener(syncPage);
      pageController.addListener(syncTab);

      return () {
        tabController.removeListener(syncPage);
        pageController.removeListener(syncTab);
      };
    },
    [tabController, pageController],
  );
}
