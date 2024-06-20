import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:bang_navigator/features/bangs/domain/providers.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/data.dart';
import 'package:bang_navigator/features/content_block/data/models/host.dart';
import 'package:bang_navigator/features/settings/data/models/settings.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:bang_navigator/features/settings/presentation/controllers/save_settings.dart';
import 'package:bang_navigator/features/settings/presentation/widgets/bang_group_list_tile.dart';
import 'package:bang_navigator/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:bang_navigator/features/settings/presentation/widgets/host_list_tile.dart';
import 'package:bang_navigator/features/settings/utils/session_link_extractor.dart';
import 'package:bang_navigator/presentation/hooks/listenable_callback.dart';
import 'package:bang_navigator/utils/ui_helper.dart' as ui_helper;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  Widget _buildSection(ThemeData theme, String name) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: theme.textTheme.titleLarge),
            const Divider(),
          ],
        ),
      );

  Widget _buildSubSection(ThemeData theme, String name) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final settings = ref.watch(
      settingsRepositoryProvider.select(
        (value) =>
            value.valueOrNull ?? Settings.withDefaults(kagiSession: null),
      ),
    );

    final kagiSessionTextController = useTextEditingController(
      text: settings.kagiSession,
    );
    final hideSessionText = useState(true);

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
      body: ListView(
        children: [
          _buildSection(theme, 'Kagi'),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: TextField(
              enableIMEPersonalizedLearning: false,
              autocorrect: false,
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
            title: const Text('Show Early Access Features'),
            subtitle: const Text(
              "Displays Kagi's early access features in the UI. As an Ultimate subscriber, you will likely want to have this enabled.",
            ),
            value: settings.showEarlyAccessFeatures,
            onChanged: (value) async {
              await ref.read(saveSettingsControllerProvider.notifier).save(
                    (currentSettings) =>
                        currentSettings.copyWith.showEarlyAccessFeatures(value),
                  );
            },
          ),
          const SizedBox(
            height: 16,
          ),
          _buildSection(theme, 'General'),
          SwitchListTile.adaptive(
            title: const Text('Incognito Mode'),
            subtitle: const Text(
              'Deletes all browsing data upon app restart for enhanced privacy.',
            ),
            value: settings.incognitoMode,
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
            value: settings.enableJavascript,
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
            value: settings.launchUrlExternal,
            onChanged: (value) async {
              await ref.read(saveSettingsControllerProvider.notifier).save(
                    (currentSettings) =>
                        currentSettings.copyWith.launchUrlExternal(value),
                  );
            },
          ),
          const SizedBox(
            height: 16,
          ),
          _buildSection(theme, 'Content Blocking'),
          SwitchListTile.adaptive(
            title: const Text('Enable Content Blocking'),
            subtitle: const Text(
              'Prevents access to unwanted websites and ads, as defined in the selected lists below.',
            ),
            value: settings.enableContentBlocking,
            onChanged: (value) async {
              await ref.read(saveSettingsControllerProvider.notifier).save(
                    (currentSettings) =>
                        currentSettings.copyWith.enableContentBlocking(value),
                  );
            },
          ),
          _buildSubSection(theme, 'Lists'),
          HostListTile(
            enableContentBlocking: settings.enableContentBlocking,
            enableHostLists: settings.enableHostList,
            source: HostSource.stevenBlackUnified,
            title: 'StevenBlack: Unified',
            subtitle: 'Blocks domains containing adware, malware and trackers.',
          ),
          HostListTile(
            enableContentBlocking: settings.enableContentBlocking,
            enableHostLists: settings.enableHostList,
            source: HostSource.stevenBlackFakeNews,
            title: 'StevenBlack: Fake News',
            subtitle: 'Blocks domains known for spreading fake news.',
          ),
          HostListTile(
            enableContentBlocking: settings.enableContentBlocking,
            enableHostLists: settings.enableHostList,
            source: HostSource.stevenBlackGambling,
            title: 'StevenBlack: Gambling',
            subtitle: 'Blocks domains related to gambling.',
          ),
          HostListTile(
            enableContentBlocking: settings.enableContentBlocking,
            enableHostLists: settings.enableHostList,
            source: HostSource.stevenBlackPorn,
            title: 'StevenBlack: Porn',
            subtitle: 'Blocks adult content domains.',
          ),
          HostListTile(
            enableContentBlocking: settings.enableContentBlocking,
            enableHostLists: settings.enableHostList,
            source: HostSource.stevenBlackSocial,
            title: 'StevenBlack: Social',
            subtitle: 'Blocks social media domains.',
          ),
          const SizedBox(
            height: 16,
          ),
          _buildSection(theme, 'Bangs'),
          CustomListTile(
            title: 'Bang Frequencies',
            subtitle: 'Tracked usage for Bang recommendations',
            suffix: FilledButton.icon(
              onPressed: () async {
                await ref
                    .read(bangDataRepositoryProvider.notifier)
                    .resetFrequencies();
              },
              icon: const Icon(Icons.delete),
              label: const Text('Clear'),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final size = ref.watch(
                bangIconCacheSizeMegabytesProvider.select(
                  (value) => value.valueOrNull,
                ),
              );

              return CustomListTile(
                title: 'Icon Cache',
                subtitle: 'Stored favicons for Bangs',
                content: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: DefaultTextStyle(
                    style: GoogleFonts.robotoMono(),
                    child: Table(
                      columnWidths: const {0: FixedColumnWidth(100)},
                      children: [
                        TableRow(
                          children: [
                            const Text('Size'),
                            Text('${size?.toStringAsFixed(2) ?? 0} MB'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                suffix: FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(bangDataRepositoryProvider.notifier)
                        .clearIconData();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                ),
              );
            },
          ),
          _buildSubSection(theme, 'Repositories'),
          const BangGroupListTile(
            group: BangGroup.general,
            title: 'General Bangs',
            subtitle: 'Automatically syncs every 7 days',
          ),
          const BangGroupListTile(
            group: BangGroup.assistant,
            title: 'Assistant Bangs',
            subtitle: 'Automatically syncs every 7 days',
          ),
          const BangGroupListTile(
            group: BangGroup.kagi,
            title: 'Kagi Bangs',
            subtitle: 'Automatically syncs every 7 days',
          ),
        ],
      ),
    );
  }
}
