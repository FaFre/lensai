import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/bangs/domain/providers.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class BangCategoriesScreen extends HookConsumerWidget {
  const BangCategoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(bangCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bang Categories'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push(BangSearchRoute().location);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return FadingScroll(
            fadingSize: 25,
            builder: (context, controller) {
              return SingleChildScrollView(
                controller: controller,
                child: HookBuilder(
                  builder: (context) {
                    final expanded = useState(<String>{});

                    return ExpansionPanelList(
                      expansionCallback: (index, expand) {
                        final key = categories.keys.elementAt(index);
                        if (!expanded.value.contains(key)) {
                          expanded.value = {...expanded.value, key};
                        } else {
                          expanded.value = {...expanded.value}..remove(key);
                        }
                      },
                      children: categories.entries
                          .map(
                            (category) => ExpansionPanel(
                              canTapOnHeader: true,
                              isExpanded: expanded.value.contains(category.key),
                              headerBuilder: (context, isExpanded) => ListTile(
                                title: Text(category.key),
                              ),
                              body: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: category.value
                                      .map(
                                        (subCategory) => ListTile(
                                          title: Text(subCategory),
                                          onTap: () async {
                                            await context.push(
                                              BangSubCategoryRoute(
                                                category: category.key,
                                                subCategory: subCategory,
                                              ).location,
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Failed to load Bang Categories',
            exception: error,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
