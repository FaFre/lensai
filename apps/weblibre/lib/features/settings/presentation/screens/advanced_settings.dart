/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/app_state.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/dialogs/user_agent_restart_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart';

const List<SettingsSectionDefinition> advancedSettingsSections = [
  SettingsSectionDefinition(
    title: 'Content & Identity',
    keywords: ['engine'],
    entries: [
      SettingsEntryDefinition(
        title: 'Enable JavaScript',
        subtitle: 'Turn website scripting on or off',
        keywords: ['javascript'],
        child: _JavaScriptTile(),
      ),
      SettingsEntryDefinition(
        title: 'Custom User Agent',
        subtitle: 'Override the browser user agent string',
        keywords: ['ua'],
        child: _UserAgentTile(),
      ),
      SettingsEntryDefinition(
        title: 'Use third party CA certificates',
        subtitle: 'Allow Android CA store certificates',
        keywords: ['certificates', 'enterprise roots', 'ca'],
        child: _EnterpriseRootsTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Experimental',
    entries: [
      SettingsEntryDefinition(
        title: 'Experimental Features',
        subtitle: 'Low-level runtime features and startup behavior',
        keywords: ['runtime', 'startup'],
        child: _ExperimentalSettingsTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Developer Tools',
    keywords: ['debug'],
    entries: [
      SettingsEntryDefinition(
        title: 'Unmount Engine Off-Screen',
        subtitle:
            'Rebuild the web engine after an overlay, instead of '
            'keeping it warm',
        keywords: ['geckoview', 'memory', 'performance', 'suspend'],
        child: _UnmountGeckoViewOffRouteTile(),
      ),
      SettingsEntryDefinition(
        title: 'Icon Cache',
        subtitle: 'Stored favicons',
        keywords: ['favicons', 'cache'],
        child: _IconCacheTile(),
      ),
      SettingsEntryDefinition(
        title: 'ML Downloads',
        subtitle: 'Downloaded AI models and runtime files',
        keywords: ['ai', 'ml', 'models', 'onnx', 'cache'],
        child: _MlCacheTile(),
      ),
      SettingsEntryDefinition(
        title: 'Error Logs',
        subtitle: 'View and copy logs for issue reporting',
        keywords: ['logs'],
        child: _ErrorLogsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Dart VM',
        subtitle: 'Copy Dart VM service URL',
        keywords: ['service url'],
        child: _DartVmTile(),
      ),
      SettingsEntryDefinition(
        title: 'Reset UI',
        subtitle: 'Rebuild the entire browser UI',
        keywords: ['refresh ui'],
        child: _ResetUITile(),
      ),
    ],
  ),
];

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Advanced',
      subtitle: 'Engine behavior, runtime overrides, and developer tools.',
      icon: MdiIcons.tuneVertical,
      sections: advancedSettingsSections,
    );
  }
}

class _JavaScriptTile extends HookConsumerWidget {
  const _JavaScriptTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final javascriptEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.javascriptEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enable JavaScript'),
      subtitle: const Text(
        'While turning off JavaScript can boost security, privacy, and speed, it may cause some sites to not work as intended.',
      ),
      // ignore: deprecated_member_use use this icon for now
      secondary: const Icon(MdiIcons.languageJavascript),
      value: javascriptEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.javascriptEnabled(value),
            );
      },
    );
  }
}

class _UserAgentTile extends HookConsumerWidget {
  const _UserAgentTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAgent = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.userAgent),
    );

    final userAgentTextController = useTextEditingController(
      text: userAgent,
      keys: [userAgent],
    );

    return ListTile(
      leading: const Icon(MdiIcons.cardAccountDetails),
      title: TextField(
        controller: userAgentTextController,
        decoration: const InputDecoration(
          labelText: 'Custom User Agent',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'Mozilla/5.0 …',
        ),
        onSubmitted: (value) async {
          await ref
              .read(saveEngineSettingsControllerProvider.notifier)
              .save(
                (currentSettings) => currentSettings.copyWith.userAgent(value),
              );

          if (context.mounted) {
            final restart = await showUserAgentRestartDialog(context);

            if (restart == true) {
              await exitApp(ref.container);
            }
          }
        },
      ),
    );
  }
}

class _EnterpriseRootsTile extends HookConsumerWidget {
  const _EnterpriseRootsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enterpriseRootsEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.enterpriseRootsEnabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Use third party CA certificates'),
      subtitle: const Text(
        'Allows the use of third party certificates from the Android CA store',
      ),
      secondary: const Icon(MdiIcons.certificate),
      value: enterpriseRootsEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.enterpriseRootsEnabled(value),
            );
      },
    );
  }
}

class _ExperimentalSettingsTile extends StatelessWidget {
  const _ExperimentalSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Experimental Features'),
      subtitle: const Text('Low-level runtime features and startup behavior'),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.flaskOutline),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await ExperimentalSettingsRoute().push(context);
      },
    );
  }
}

class _UnmountGeckoViewOffRouteTile extends HookConsumerWidget {
  const _UnmountGeckoViewOffRouteTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unmountGeckoViewOffRoute = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.unmountGeckoViewOffRoute,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Unmount Engine Off-Screen'),
      subtitle: const Text(
        'Tear the web engine down while a full-screen overlay (settings, tabs, '
        'search) is on top, and build it again on the way back, freeing its '
        'resources in between. Returning to the page costs a reattach and can '
        'flicker or reload, so this is a memory trade rather than a fix for '
        'anything. On Android 12 and lower it is always done.',
      ),
      secondary: const Icon(Icons.memory),
      value: unmountGeckoViewOffRoute,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.unmountGeckoViewOffRoute(value),
            );
      },
    );
  }
}

class _IconCacheTile extends HookConsumerWidget {
  const _IconCacheTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(
      iconCacheSizeMegabytesProvider.select((value) => value.value),
    );

    return CustomListTile(
      title: 'Icon Cache',
      subtitle: 'Stored favicons',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.image,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: DefaultTextStyle(
          style: GoogleFonts.robotoMono(
            textStyle: DefaultTextStyle.of(context).style,
          ),
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
          await ref.read(cacheRepositoryProvider.notifier).clearCache();
        },
        icon: const Icon(Icons.delete),
        label: const Text('Clear'),
      ),
    );
  }
}

class _MlCacheTile extends HookWidget {
  const _MlCacheTile();

  Future<bool> _confirmClear(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear ML downloads?'),
        content: const Text(
          'This clears downloaded AI models and ONNX runtime files for this profile. '
          'They will be downloaded again when needed. Restart WebLibre before retrying ML features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isClearing = useState(false);

    return CustomListTile(
      title: 'ML Downloads',
      subtitle: 'Downloaded AI models and runtime files',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.memory,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: isClearing.value
            ? null
            : () async {
                if (!await _confirmClear(context)) {
                  return;
                }

                isClearing.value = true;
                try {
                  await GeckoMlService().clearMlCache();

                  if (context.mounted) {
                    showInfoMessage(
                      context,
                      'ML downloads cleared. Restart WebLibre before retrying.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showErrorMessage(
                      context,
                      'Failed to clear ML downloads: $e',
                    );
                  }
                } finally {
                  if (context.mounted) {
                    isClearing.value = false;
                  }
                }
              },
        icon: isClearing.value
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete),
        label: Text(isClearing.value ? 'Clearing' : 'Clear'),
      ),
    );
  }
}

class _ErrorLogsTile extends StatelessWidget {
  const _ErrorLogsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.bug_report,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Error Logs'),
      subtitle: const Text('View and copy logs for issue reporting'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await ErrorLogsRoute().push(context);
      },
    );
  }
}

class _DartVmTile extends StatelessWidget {
  const _DartVmTile();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return CustomListTile(
      title: 'Dart VM',
      subtitle: 'Copy Dart VM service URL',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.bug_report,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          final serviceProtocolInfo = await Service.getInfo();

          await Clipboard.setData(
            ClipboardData(
              text: serviceProtocolInfo.serverUri?.toString() ?? 'Error',
            ),
          );

          if (context.mounted) {
            showInfoMessage(context, 'Service URL copied');
          }
        },
        icon: const Icon(Icons.copy),
        label: const Text('Copy'),
      ),
    );
  }
}

class _ResetUITile extends ConsumerWidget {
  const _ResetUITile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomListTile(
      title: 'Reset UI',
      subtitle: 'Rebuild the entire browser UI',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.bug_report,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () {
          ref.read(appStateKeyProvider.notifier).reset();
        },
        icon: const Icon(Icons.restore),
        label: const Text('Reset'),
      ),
    );
  }
}
