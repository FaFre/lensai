import 'package:bang_navigator/features/settings/data/models/settings.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/settings/presentation/controllers/save_settings.dart';
import 'package:bang_navigator/features/settings/utils/session_link_extractor.dart';
import 'package:bang_navigator/presentation/hooks/listenable_callback.dart';
import 'package:bang_navigator/utils/ui_helper.dart' as ui_helper;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kagiSessionTextController = useTextEditingController(
      text: ref.read(
        settingsRepositoryProvider
            .select((value) => value.valueOrNull?.kagiSession),
      ),
    );
    final hideSessionText = useState(true);

    // final isSavingSettings = ref.watch(
    //   saveSettingsControllerProvider.select((value) => value.isLoading),
    // );

    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider
          .select((value) => value.valueOrNull?.incognitoMode ?? false),
    );

    final javacsriptEnabled = ref.watch(
      settingsRepositoryProvider
          .select((value) => value.valueOrNull?.enableJavascript ?? false),
    );

    final launchUrlExternal = ref.watch(
      settingsRepositoryProvider
          .select((value) => value.valueOrNull?.launchUrlExternal ?? false),
    );

    useListenableCallback(kagiSessionTextController, () async {
      var text = kagiSessionTextController.text;
      if (Uri.tryParse(text) case final Uri uri) {
        if (extractKagiSession(uri) case final String session) {
          text = session;
        }
      }

      await ref.read(saveSettingsControllerProvider.notifier).save(
            (currentSettings) => currentSettings.copyWith.kagiSession(text),
          );
    });

    ref.listen(
        settingsRepositoryProvider.select(
          (settings) => settings.valueOrNull?.kagiSession,
        ), (previous, next) {
      if (next != null &&
          next.isNotEmpty &&
          kagiSessionTextController.text != next) {
        kagiSessionTextController.text = next;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: TextField(
                  controller: kagiSessionTextController,
                  obscureText: hideSessionText.value,
                  decoration: InputDecoration(
                    label: const Text('Kagi Session Token'),
                    hintText: 'https://kagi.com/search?token=...',
                    helperMaxLines: 2,
                    helper: Markdown(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      data:
                          'You can visit your [Kagi Account Settings](user_details) to get your Session Link.',
                      onTapLink: (text, href, title) async {
                        if (href == 'user_details') {
                          await ui_helper.launchUrlFeedback(
                            context,
                            Uri.parse(
                              'https://kagi.com/settings?p=user_details',
                            ),
                          );
                        }
                      },
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        hideSessionText.value = !hideSessionText.value;
                      },
                      icon: Icon(
                        hideSessionText.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ),
              SwitchListTile.adaptive(
                title: const Text('Incognito Mode'),
                subtitle: const Text(
                  'Deletes all browsing data upon app restart for enhanced privacy.',
                ),
                value: incognitoEnabled,
                onChanged: (value) async {
                  await ref.read(saveSettingsControllerProvider.notifier).save(
                        (currentSettings) =>
                            currentSettings.copyWith.incognitoMode(value),
                      );
                },
              ),
              SwitchListTile.adaptive(
                title: const Text('Enable JavaScript'),
                subtitle: const Text(
                  'While turning off JavaScript boosts security, privacy, and speed, it may cause some sites to not work as intended.',
                ),
                value: javacsriptEnabled,
                onChanged: (value) async {
                  await ref.read(saveSettingsControllerProvider.notifier).save(
                        (currentSettings) =>
                            currentSettings.copyWith.enableJavascript(value),
                      );
                },
              ),
              SwitchListTile.adaptive(
                title: const Text('Launch Links Externally'),
                subtitle: const Text(
                  'Opens all links (except for kagi.com) in your default browser.',
                ),
                value: launchUrlExternal,
                onChanged: (value) async {
                  await ref.read(saveSettingsControllerProvider.notifier).save(
                        (currentSettings) =>
                            currentSettings.copyWith.launchUrlExternal(value),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
