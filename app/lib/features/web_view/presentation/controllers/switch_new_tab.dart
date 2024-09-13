import 'package:lensai/features/geckoview/features/topics/domain/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/tab_link.dart';
import 'package:lensai/features/web_view/domain/entities/web_view_page.dart';
import 'package:lensai/features/web_view/domain/repositories/web_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'switch_new_tab.g.dart';

@Riverpod(keepAlive: true)
class SwitchNewTabController extends _$SwitchNewTabController {
  @override
  FutureOr<void> build() {}

  Future<void> add(Uri url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final topic = ref.read(selectedTopicProvider);
        final newTab = WebViewPage.create(
          url: WebUri.uri(url),
          topicId: topic,
        );

        await ref
            .read(topicTabRepositoryProvider(topic).notifier)
            .addTab(newTab);

        ref.read(webViewTabControllerProvider.notifier).showTab(newTab.id);
      },
    );
  }
}
