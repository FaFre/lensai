import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/search_browser/presentation/widgets/error_container.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';

class LandingAction extends HookConsumerWidget {
  const LandingAction({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionTokenAvailable = ref.watch(
      settingsRepositoryProvider.select(
        (value) => value.valueOrNull?.kagiSession?.isNotEmpty ?? false,
      ),
    );

    return Visibility(
      visible: !sessionTokenAvailable,
      child: ErrorContainer(
        content: Markdown(
          shrinkWrap: true,
          onTapLink: (text, href, title) async {
            if (href == 'settings') {
              await context.push(SettingsRoute().location);
            }
          },
          data: '## No Kagi Session Provided\n'
              'Please navigate to [Settings](settings) and enter your Kagi Session Token.\n'
              "You must provide a valid session in order to use Kagi's features.",
        ),
      ),
    );
  }
}
