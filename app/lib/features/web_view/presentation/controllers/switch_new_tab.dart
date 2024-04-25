import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bang_navigator/features/web_view/domain/entities/web_view_page.dart';
import 'package:bang_navigator/features/web_view/domain/repositories/web_view.dart';
import 'package:bang_navigator/features/web_view/presentation/widgets/web_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'switch_new_tab.g.dart';

@riverpod
class SwitchNewTabController extends _$SwitchNewTabController {
  @override
  FutureOr<void> build() {}

  Future<void> add(Uri url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final newTab = WebViewPage(
          url: WebUri.uri(url),
        );

        ref
            .read(webViewRepositoryProvider.notifier)
            .addTab(WebView(tab: newTab));

        ref.read(webViewTabControllerProvider.notifier).showTab(newTab.key);
      },
    );
  }
}
