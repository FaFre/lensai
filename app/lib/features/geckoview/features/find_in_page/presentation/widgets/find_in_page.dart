import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/find_in_page/domain/repositories/find_in_page.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/controllers/find_in_page_visibility.dart';

class FindInPageWidget extends HookConsumerWidget {
  final EdgeInsetsGeometry padding;

  const FindInPageWidget({this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFindInPage = ref.watch(findInPageVisibilityControllerProvider);
    final findInteractionController =
        ref.watch(findInPageRepositoryProvider(null).notifier);

    final textController = useTextEditingController();

    return Visibility(
      visible: showFindInPage,
      child: Padding(
        padding: padding,
        child: Material(
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  autocorrect: false,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Find in page',
                  ),
                  keyboardType: TextInputType.text,
                  onSubmitted: (value) async {
                    if (value == '') {
                      await findInteractionController.clearMatches();
                    } else {
                      await findInteractionController.findAll(text: value);
                    }
                  },
                ),
              ),
              HookConsumer(
                builder: (context, ref, child) {
                  final searchResult = ref.watch(
                    selectedTabStateProvider
                        .select((state) => state?.findResultState),
                  );

                  if (searchResult != null) {
                    if (searchResult.numberOfMatches == 0) {
                      return const Text('Not found');
                    }

                    return Text(
                      '${searchResult.activeMatchOrdinal + 1} of ${searchResult.numberOfMatches}',
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () async {
                  await findInteractionController.findNext(forward: false);
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () async {
                  await findInteractionController.findNext();
                },
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () async {
                  ref
                      .read(findInPageVisibilityControllerProvider.notifier)
                      .hide();

                  await findInteractionController.clearMatches();
                  textController.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
