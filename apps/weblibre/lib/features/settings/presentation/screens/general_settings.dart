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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoBrowserService;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';

const List<SettingsSectionDefinition> generalSettingsSections = [
  SettingsSectionDefinition(
    title: 'Default Browser',
    keywords: ['browser defaults'],
    entries: [
      SettingsEntryDefinition(
        title: 'Default Browser',
        subtitle: 'Set WebLibre as your default browser',
        keywords: ['system browser'],
        child: _DefaultBrowserTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Appearance',
    entries: [
      SettingsEntryDefinition(
        title: 'Theme',
        subtitle: 'Choose system, light, or dark mode',
        keywords: ['light', 'dark', 'theme mode'],
        child: _ThemeSection(),
      ),
      SettingsEntryDefinition(
        title: 'Pure Black (OLED)',
        subtitle:
            'Use true-black surfaces in dark mode to save power on OLED '
            'screens',
        keywords: ['oled', 'amoled', 'high contrast', 'black', 'dark'],
        child: _PureBlackTile(),
      ),
      SettingsEntryDefinition(
        title: 'User Interface Zoom',
        subtitle: 'Make the user interface smaller or larger',
        keywords: ['ui scale', 'zoom'],
        child: _UiZoomSection(),
      ),
      SettingsEntryDefinition(
        title: 'Refresh Rate',
        subtitle: 'Request a high or low display refresh rate (Android)',
        keywords: [
          'fps',
          'hz',
          'hertz',
          'frame rate',
          'framerate',
          '60hz',
          '90hz',
          '120hz',
          'smooth',
          'high refresh',
          'display mode',
        ],
        child: _RefreshRateSection(),
      ),
      SettingsEntryDefinition(
        title: 'Disable Animations',
        subtitle: 'Reduce motion and turn off app animations',
        keywords: ['motion'],
        child: _DisableAnimationsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Show Modal Barrier',
        subtitle: 'Dim the background behind dialogs and bottom sheets',
        keywords: ['dialogs', 'bottom sheets', 'overlay'],
        child: _ShowModalBarrierTile(),
      ),
      SettingsEntryDefinition(
        title: 'Show Close Button',
        subtitle:
            'Add a button to dismiss the search / new-tab page without '
            'a back gesture',
        keywords: [
          'back',
          'close',
          'dismiss',
          'e-ink',
          'eink',
          'accessibility',
          'new tab',
        ],
        child: _ShowSearchCloseButtonTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Profile',
    keywords: ['user', 'profile'],
    entries: [
      SettingsEntryDefinition(
        title: 'Back up this profile',
        subtitle: 'Write an encrypted backup file of the profile you are using',
        keywords: [
          'backup',
          'archive',
          'export',
          'save',
          'encrypted',
          'restore',
        ],
        child: _BackupProfileTile(),
      ),
      SettingsEntryDefinition(
        title: 'Export & Import Settings',
        subtitle: 'Move settings to another profile, device, or a bug report',
        keywords: [
          'export',
          'import',
          'settings',
          'transfer',
          'share',
          'clipboard',
          'json',
          'copy',
          'migrate',
        ],
        child: _SettingsTransferTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Downloads',
    entries: [
      SettingsEntryDefinition(
        title: 'Use external download manager',
        subtitle: 'Manage downloads with another app',
        keywords: ['downloads'],
        child: _ExternalDownloadManagerTile(),
      ),
    ],
  ),
];

/// Takes a backup of the *active* profile without switching away from it.
///
/// The route it opens is the same one the user list reaches, and nothing about
/// the operation is special-cased here: the backup is queued and taken by the
/// next process, with the profile closed. This tile exists only because backing
/// up the profile you are using is the common case, and getting to it through
/// Profiles → yourself → Backup is not an obvious path.
class _BackupProfileTile extends HookConsumerWidget {
  const _BackupProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(selectedProfileProvider);

    return ListTile(
      enabled: profile.hasValue,
      leading: const Icon(MdiIcons.safe),
      title: const Text('Back up this profile'),
      subtitle: Text(switch (profile) {
        AsyncData(:final value) =>
          'Write "${value.name}" to an encrypted backup file',
        AsyncError() => 'Could not read the active profile',
        _ => 'Loading…',
      }),
      trailing: const Icon(Icons.chevron_right),
      onTap: profile.hasValue
          ? () async {
              await BackupProfileRoute(
                profile: jsonEncode(profile.requireValue.toJson()),
              ).push(context);
            }
          : null,
    );
  }
}

/// Settings only — the profile backup above it is the whole-profile answer.
///
/// Sits next to it because that is where people look for "get my setup onto
/// the other device", and the two differ in what they carry rather than in
/// where they live.
class _SettingsTransferTile extends StatelessWidget {
  const _SettingsTransferTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MdiIcons.swapHorizontal),
      title: const Text('Export & Import Settings'),
      subtitle: const Text(
        'Write settings to a file or the clipboard, and read them back',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const SettingsTransferRoute().push(context),
    );
  }
}

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'General',
      subtitle: 'Appearance, downloads, and browser defaults.',
      icon: Icons.tune,
      sections: generalSettingsSections,
    );
  }
}

class _DefaultBrowserTile extends HookConsumerWidget {
  const _DefaultBrowserTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultBrowserRefreshKey = useState(0);

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        defaultBrowserRefreshKey.value++;
      }
    });

    final isDefault = useCachedFuture(
      () => GeckoBrowserService().isDefaultBrowser(),
      [defaultBrowserRefreshKey.value],
    );

    final isCurrentDefaultBrowser = isDefault.data == true;

    return CustomListTile(
      title: 'Default Browser',
      subtitle: isCurrentDefaultBrowser
          ? 'WebLibre is your default browser'
          : 'Set WebLibre as your default browser',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.public,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: isCurrentDefaultBrowser
            ? null
            : () async {
                await GeckoBrowserService().requestDefaultBrowser();
                defaultBrowserRefreshKey.value++;
              },
        icon: Icon(isCurrentDefaultBrowser ? Icons.check : Icons.open_in_new),
        label: Text(isCurrentDefaultBrowser ? 'Default' : 'Set'),
      ),
    );
  }
}

class _UiZoomSection extends HookConsumerWidget {
  const _UiZoomSection();

  static final _sliderDivisions =
      ((maxUiScaleFactor - minUiScaleFactor) / uiScaleFactorStep).round();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiScaleFactor = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.uiScaleFactor),
    );
    final sliderValue = useKeyedState(uiScaleFactor, [uiScaleFactor]);

    final sliderLabel = '${(sliderValue.value * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('User Interface Zoom'),
            subtitle: Text('Make the user interface smaller or larger'),
            leading: Icon(Icons.zoom_in),
            contentPadding: EdgeInsets.zero,
          ),
          Row(
            children: [
              Text(sliderLabel, style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: Slider(
                  min: minUiScaleFactor,
                  max: maxUiScaleFactor,
                  divisions: _sliderDivisions,
                  label: sliderLabel,
                  value: sliderValue.value.clamp(
                    minUiScaleFactor,
                    maxUiScaleFactor,
                  ),
                  onChanged: (value) {
                    sliderValue.value = value;
                  },
                  onChangeEnd: (value) async {
                    final normalized = _normalizeUiScale(value);
                    sliderValue.value = normalized;
                    await ref
                        .read(saveGeneralSettingsControllerProvider.notifier)
                        .save(
                          (currentSettings) => currentSettings.copyWith
                              .uiScaleFactor(normalized),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

double _normalizeUiScale(double value) {
  final clampedValue = value.clamp(minUiScaleFactor, maxUiScaleFactor);
  final stepIndex = ((clampedValue - minUiScaleFactor) / uiScaleFactorStep)
      .round();
  final normalized = minUiScaleFactor + (stepIndex * uiScaleFactorStep);
  return normalized.clamp(minUiScaleFactor, maxUiScaleFactor);
}

class _DisableAnimationsTile extends HookConsumerWidget {
  const _DisableAnimationsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.disableAnimations),
    );

    return SwitchListTile.adaptive(
      title: const Text('Disable Animations'),
      subtitle: const Text('Reduce motion and turn off app animations'),
      secondary: const Icon(Icons.animation),
      value: disableAnimations,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.disableAnimations(value),
            );
      },
    );
  }
}

class _ShowModalBarrierTile extends HookConsumerWidget {
  const _ShowModalBarrierTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showModalBarrier = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showModalBarrier),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Modal Barrier'),
      subtitle: const Text(
        'Dim the background behind dialogs and bottom sheets',
      ),
      secondary: const Icon(Icons.layers),
      value: showModalBarrier,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.showModalBarrier(value),
            );
      },
    );
  }
}

class _ShowSearchCloseButtonTile extends HookConsumerWidget {
  const _ShowSearchCloseButtonTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSearchCloseButton = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.showSearchCloseButton,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Close Button'),
      subtitle: const Text(
        'Add a button to dismiss the search / new-tab page without a back '
        'gesture, useful on devices without a back button',
      ),
      secondary: const Icon(Icons.close),
      value: showSearchCloseButton,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.showSearchCloseButton(value),
            );
      },
    );
  }
}

class _PureBlackTile extends HookConsumerWidget {
  const _PureBlackTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pureBlack = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.pureBlack),
    );
    final themeMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.themeMode),
    );

    // OLED surfaces only apply to dark mode; disable the toggle when the app
    // is locked to light mode so the setting can't appear to have no effect.
    final enabled = themeMode != ThemeMode.light;

    return SwitchListTile.adaptive(
      title: const Text('Pure Black (OLED)'),
      subtitle: const Text(
        'Use true-black surfaces in dark mode to save power on OLED screens',
      ),
      secondary: const Icon(Icons.contrast),
      value: pureBlack,
      onChanged: enabled
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.pureBlack(value),
                  );
            }
          : null,
    );
  }
}

class _ThemeSection extends HookConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.themeMode),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Theme'),
            leading: Icon(Icons.palette),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.themeMode(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshRateSection extends HookConsumerWidget {
  const _RefreshRateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshRateMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.refreshRateMode),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Refresh Rate'),
            subtitle: Text(
              'Choose "High" for the smoothest scrolling and animations on '
              '90/120Hz screens, or "Low" to save battery.',
            ),
            leading: Icon(Icons.speed),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<RefreshRateMode>(
              segments: const [
                ButtonSegment(
                  value: RefreshRateMode.system,
                  icon: Icon(Icons.smartphone),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: RefreshRateMode.high,
                  icon: Icon(Icons.bolt),
                  label: Text('High'),
                ),
                ButtonSegment(
                  value: RefreshRateMode.low,
                  icon: Icon(Icons.battery_saver),
                  label: Text('Low'),
                ),
              ],
              selected: {refreshRateMode},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.refreshRateMode(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalDownloadManagerTile extends HookConsumerWidget {
  const _ExternalDownloadManagerTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useExternalDownloadManager = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.useExternalDownloadManager,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Use external download manager'),
      subtitle: const Text('Manage downloads with another app'),
      secondary: const Icon(Icons.download),
      value: useExternalDownloadManager,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.useExternalDownloadManager(value),
            );
      },
    );
  }
}
