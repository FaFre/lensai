import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useSyncPageWithTab(
  TabController tabController,
  PageController pageController,
) {
  useEffect(
    () {
      Future<void> syncPage() async {
        await pageController.animateToPage(
          tabController.index,
          curve: Curves.linear,
          duration: const Duration(milliseconds: 300),
        );
      }

      void syncTab() {
        if (!tabController.indexIsChanging) {
          tabController.animateTo(pageController.page!.round());
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
