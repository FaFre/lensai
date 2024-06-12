import 'package:bang_navigator/core/routing/routes.dart';
import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/presentation/widgets/bang_icon.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/web_view/presentation/controllers/switch_new_tab.dart';
import 'package:bang_navigator/utils/ui_helper.dart' as ui_helper;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BangDetails extends HookConsumerWidget {
  final BangData bangData;
  final void Function()? onTap;

  const BangDetails(this.bangData, {this.onTap, super.key});

  String? _categoryString(BangData bang) {
    if (bang.category == null) {
      return null;
    } else if (bang.subCategory == null) {
      return bang.category;
    } else {
      return '${bang.category} / ${bang.subCategory}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BangIcon(bangData),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bangData.websiteName.trim(),
                          style: theme.textTheme.titleMedium,
                        ),
                        if (bangData.category != null)
                          Text(
                            _categoryString(bangData)!,
                            style: theme.textTheme.titleSmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonalIcon(
                    style:
                        const ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () async {
                      final url = Uri.parse(bangData.getUrl('').origin);

                      final launchExternal = ref
                              .read(settingsRepositoryProvider)
                              .valueOrNull
                              ?.launchUrlExternal ??
                          false;

                      if (launchExternal) {
                        await ui_helper.launchUrlFeedback(context, url);
                      } else {
                        await ref
                            .read(switchNewTabControllerProvider.notifier)
                            .add(url);

                        if (context.mounted) {
                          context.go(KagiRoute().location);
                        }
                      }
                    },
                    label: Text(bangData.domain),
                    icon: const Icon(Icons.open_in_new),
                  ),
                  Text(
                    '!${bangData.trigger}',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}