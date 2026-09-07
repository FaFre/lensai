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
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';

const List<SettingsSectionDefinition> toolbarLayoutSettingsSections = [
  SettingsSectionDefinition(
    title: 'Tab Bar',
    entries: [
      SettingsEntryDefinition(
        title: 'Tab Bar Position',
        subtitle: 'Choose whether the tab bar stays at the top or bottom',
        keywords: ['top', 'bottom'],
        child: _TabBarPositionSection(),
      ),
      SettingsEntryDefinition(
        title: 'Tab Bar Style',
        subtitle: 'Choose between title and compact layouts',
        keywords: ['layout', 'compact'],
        child: _TabBarLayoutModeSection(),
      ),
      SettingsEntryDefinition(
        title: 'Auto Hide Tab Bar',
        subtitle: 'Hide the tab bar when scrolling',
        keywords: ['scroll'],
        child: _AutoHideTabBarTile(),
      ),
      SettingsEntryDefinition(
        title: 'Long Press URL to Copy',
        subtitle: 'Copy the current URL from the tab bar',
        keywords: ['copy url'],
        child: _TabBarLongPressUrlCopyTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Contextual Toolbar',
    entries: [
      SettingsEntryDefinition(
        title: 'Show Contextual Toolbar',
        subtitle: 'Show an additional toolbar for navigation and actions',
        keywords: ['bottom toolbar'],
        child: _ShowContextualTabBarTile(),
      ),
      SettingsEntryDefinition(
        title: 'Customize Toolbar Buttons',
        subtitle: 'Choose which actions appear in the contextual toolbar',
        keywords: ['buttons'],
        child: _CustomizeToolbarButtonsTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Quick Tab Switcher',
    entries: [
      SettingsEntryDefinition(
        title: 'Tab Stacking',
        subtitle: 'Choose how the quick tab switcher bar arranges tabs',
        keywords: [
          'recent tabs',
          'recently used',
          'container tabs',
          'accordion',
          'two level',
          'rows',
          'stacking',
          'disabled',
        ],
        child: _TabBarStackingModeSection(),
      ),
      SettingsEntryDefinition(
        title: 'Customize Switcher Buttons',
        subtitle: 'Choose which action buttons appear at the end of the bar',
        keywords: ['buttons', 'new tab', 'actions', 'trailing'],
        child: _CustomizeQuickSwitcherButtonsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Close Buttons on Tab Chips',
        subtitle: 'Which switcher chips show a close button',
        keywords: ['close', 'x button', 'active tab'],
        child: _QuickTabSwitcherCloseButtonsSection(),
      ),
      SettingsEntryDefinition(
        title: 'History Fallback in Quick Tab Switcher',
        subtitle: 'Use history suggestions when there are no matching tabs',
        keywords: ['suggestions'],
        child: _QuickTabSwitcherHistorySuggestionsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Show Titles in Quick Tab Switcher',
        subtitle: 'Display page titles in the switcher list',
        keywords: ['page titles'],
        child: _QuickTabSwitcherShowTitlesTile(),
      ),
      SettingsEntryDefinition(
        title: 'Title Width in Quick Tab Switcher',
        subtitle: 'Maximum width of tab titles on switcher chips',
        keywords: ['width', 'title', 'chip', 'length'],
        child: _QuickTabSwitcherTitleWidthTile(),
      ),
      SettingsEntryDefinition(
        title: 'Hierarchy Depth in Quick Tab Switcher',
        subtitle: 'How many nesting chevrons to show on switcher chips',
        keywords: ['hierarchy', 'nesting', 'depth', 'tree', 'chevrons'],
        child: _QuickTabSwitcherHierarchyGlyphsTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Tab View',
    entries: [
      SettingsEntryDefinition(
        title: 'Bottom Sheet Tab View',
        subtitle: 'Open the tab switcher as a bottom sheet',
        keywords: ['sheet'],
        child: _BottomSheetTabViewTile(),
      ),
      SettingsEntryDefinition(
        title: 'Show Favicons in List View',
        subtitle: 'Display site icons in the tab list',
        keywords: ['icons'],
        child: _TabListShowFaviconsTile(),
      ),
    ],
  ),
];

/// The browser menu's own arrangement entry.
///
/// Kept out of [toolbarLayoutSettingsSections] because onboarding renders those
/// too, and arranging the menu is not a first-run decision. Offered to the
/// settings screen as [ToolbarLayoutContent.extraSections] so it takes part in
/// the same filtering — a row rendered beside the filtered list would survive a
/// query that empties the list, leaving a match sitting above "No settings
/// match".
const List<SettingsSectionDefinition> menuLayoutSettingsSections = [
  SettingsSectionDefinition(
    title: 'Menu',
    keywords: ['three dot', 'overflow'],
    entries: [
      SettingsEntryDefinition(
        title: 'Customize Menu',
        subtitle:
            'Choose and order the sections and rows of the three-dot menu',
        keywords: ['sections', 'rows', 'reorder'],
        child: _CustomizeMenuTile(),
      ),
    ],
  ),
];

class ToolbarLayoutContent extends StatelessWidget {
  final String query;

  /// Sections shown after the toolbar's own, filtered by the same [query].
  final List<SettingsSectionDefinition> extraSections;

  const ToolbarLayoutContent({
    super.key,
    this.query = '',
    this.extraSections = const [],
  });

  @override
  Widget build(BuildContext context) {
    final filteredSections = filterSettingsSections(
      sections: [...toolbarLayoutSettingsSections, ...extraSections],
      query: query,
    );

    return SettingsSectionList(sections: filteredSections, query: query);
  }
}

class _CustomizeMenuTile extends StatelessWidget {
  const _CustomizeMenuTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.tune),
      title: const Text('Customize Menu'),
      subtitle: const Text(
        'Choose and order the sections and rows of the three-dot menu',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await const MenuLayoutSettingsRoute().push(context);
      },
    );
  }
}

class _TabBarPositionSection extends HookConsumerWidget {
  const _TabBarPositionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarPosition = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarPosition),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab Bar Position'),
            leading: Icon(MdiIcons.dockWindow),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: tabBarPosition,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarPosition(value),
                    );
              }
            },
            child: const Column(
              children: [
                RadioListTile.adaptive(
                  value: TabBarPosition.top,
                  title: Text('Top'),
                  subtitle: Text('Persistent tab bar without auto-hide'),
                ),
                RadioListTile.adaptive(
                  value: TabBarPosition.bottom,
                  title: Text('Bottom'),
                  subtitle: Text('Tab bar with auto-hide support'),
                ),
                RadioListTile.adaptive(
                  value: TabBarPosition.left,
                  title: Text('Left'),
                  subtitle: Text('Vertical side rail, swipe to hide'),
                ),
                RadioListTile.adaptive(
                  value: TabBarPosition.right,
                  title: Text('Right'),
                  subtitle: Text('Vertical side rail, swipe to hide'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarLayoutModeSection extends HookConsumerWidget {
  const _TabBarLayoutModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarLayout = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarLayout),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab Bar Style'),
            leading: Icon(MdiIcons.tabUnselected),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: tabBarLayout,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarLayout(value),
                    );
              }
            },
            child: const Column(
              children: [
                RadioListTile.adaptive(
                  value: TabBarLayout.withTitle,
                  title: Text('With Title'),
                  subtitle: Text('Shows page title and URL breadcrumb'),
                ),
                RadioListTile.adaptive(
                  value: TabBarLayout.compact,
                  title: Text('Compact'),
                  subtitle: Text('Centered URL pill without page title'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowContextualTabBarTile extends HookConsumerWidget {
  const _ShowContextualTabBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarShowContextualBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowContextualBar,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Contextual Toolbar'),
      subtitle: const Text(
        'Show additional bottom toolbar for navigation and actions',
      ),
      secondary: const Icon(MdiIcons.dockBottom),
      value: tabBarShowContextualBar,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabBarShowContextualBar(value),
            );
      },
    );
  }
}

class _CustomizeToolbarButtonsTile extends HookConsumerWidget {
  const _CustomizeToolbarButtonsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarShowContextualBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowContextualBar,
      ),
    );

    return ListTile(
      leading: const Icon(Icons.tune),
      title: const Text('Customize Toolbar Buttons'),
      trailing: const Icon(Icons.chevron_right),
      enabled: tabBarShowContextualBar,
      onTap: () async {
        await const ContextualToolbarSettingsRoute().push(context);
      },
    );
  }
}

class _CustomizeQuickSwitcherButtonsTile extends HookConsumerWidget {
  const _CustomizeQuickSwitcherButtonsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final switcherEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.effectiveTabBarStackingMode() != TabBarStackingMode.disabled,
      ),
    );

    return ListTile(
      leading: const Icon(Icons.tune),
      title: const Text('Customize Switcher Buttons'),
      subtitle: const Text(
        'Action buttons pinned at the end of the switcher bar (independent of '
        'the contextual toolbar)',
      ),
      trailing: const Icon(Icons.chevron_right),
      enabled: switcherEnabled,
      onTap: () async {
        await const QuickSwitcherToolbarSettingsRoute().push(context);
      },
    );
  }
}

class _TabBarStackingModeSection extends HookConsumerWidget {
  const _TabBarStackingModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final stackingMode = settings.effectiveTabBarStackingMode();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab Stacking'),
            subtitle: Text('How the quick tab switcher bar arranges its tabs'),
            leading: Icon(MdiIcons.folderSettings),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: stackingMode,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarStackingMode(value),
                    );
              }
            },
            child: Column(
              children: [
                const RadioListTile.adaptive(
                  value: TabBarStackingMode.lastUsedTabs,
                  title: Text('Recently Used Tabs'),
                  subtitle: Text('Recently used tabs across all containers'),
                ),
                if (settings.showContainerUi) ...[
                  const RadioListTile.adaptive(
                    value: TabBarStackingMode.containerTabs,
                    title: Text('Container Tabs'),
                    subtitle: Text('Ordered tabs of the selected container'),
                  ),
                  const RadioListTile.adaptive(
                    value: TabBarStackingMode.accordion,
                    title: Text('Accordion'),
                    subtitle: Text(
                      "All containers as chips, with the selected "
                      "container's tabs expanded inline",
                    ),
                  ),
                  // Two stacked rows don't fit the narrow vertical side rail,
                  // where the mode degrades to Container Tabs; hide the option
                  // for left/right positions to avoid a no-op choice.
                  if (!settings.tabBarPosition.isVertical)
                    const RadioListTile.adaptive(
                      value: TabBarStackingMode.twoLevel,
                      title: Text('Two Rows'),
                      subtitle: Text(
                        'Tabs of the selected container on top, recently used '
                        'tabs below',
                      ),
                    ),
                ],
                const RadioListTile.adaptive(
                  value: TabBarStackingMode.disabled,
                  title: Text('Disabled'),
                  subtitle: Text('Hide the quick tab switcher bar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTabSwitcherCloseButtonsSection extends HookConsumerWidget {
  const _QuickTabSwitcherCloseButtonsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closeButtonMode = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherCloseButtonMode,
      ),
    );
    final switcherEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.effectiveTabBarStackingMode() != TabBarStackingMode.disabled,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Close Buttons on Tab Chips'),
            subtitle: Text('Which switcher chips show a close button'),
            leading: Icon(MdiIcons.closeCircleOutline),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: closeButtonMode,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .quickTabSwitcherCloseButtonMode(value),
                    );
              }
            },
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: TabChipCloseButtonMode.activeTabOnly,
                  enabled: switcherEnabled,
                  title: const Text('Active Tab Only'),
                  subtitle: const Text(
                    'Only the chip of the tab currently open',
                  ),
                ),
                RadioListTile.adaptive(
                  value: TabChipCloseButtonMode.all,
                  enabled: switcherEnabled,
                  title: const Text('All Tabs'),
                  subtitle: const Text('Every chip on the bar'),
                ),
                RadioListTile.adaptive(
                  value: TabChipCloseButtonMode.never,
                  enabled: switcherEnabled,
                  title: const Text('Never'),
                  subtitle: const Text(
                    'No close buttons; close tabs from the long press menu '
                    'or by swiping the bar',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTabSwitcherTitleWidthTile extends HookConsumerWidget {
  const _QuickTabSwitcherTitleWidthTile();

  static final _divisions =
      ((maxQuickTabSwitcherTitleWidth - minQuickTabSwitcherTitleWidth) /
              quickTabSwitcherTitleWidthStep)
          .round();

  static String _label(double width) => '${width.round()} px';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleWidth = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherTitleWidth,
      ),
    );
    final showTitles = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
    final switcherEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.effectiveTabBarStackingMode() != TabBarStackingMode.disabled,
      ),
    );

    final sliderValue = useKeyedState(titleWidth, [titleWidth]);

    final enabled = switcherEnabled && showTitles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Title Width in Quick Tab Switcher'),
            subtitle: const Text(
              'Maximum width of tab titles on switcher chips',
            ),
            leading: const Icon(MdiIcons.arrowExpandHorizontal),
            contentPadding: EdgeInsets.zero,
            enabled: enabled,
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: minQuickTabSwitcherTitleWidth,
                  max: maxQuickTabSwitcherTitleWidth,
                  divisions: _divisions,
                  label: _label(sliderValue.value),
                  value: sliderValue.value.clamp(
                    minQuickTabSwitcherTitleWidth,
                    maxQuickTabSwitcherTitleWidth,
                  ),
                  onChanged: enabled
                      ? (value) {
                          sliderValue.value = value;
                        }
                      : null,
                  onChangeEnd: enabled
                      ? (value) async {
                          final normalized =
                              (value / quickTabSwitcherTitleWidthStep).round() *
                              quickTabSwitcherTitleWidthStep;
                          sliderValue.value = normalized;
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .quickTabSwitcherTitleWidth(normalized),
                              );
                        }
                      : null,
                ),
              ),
              Text(
                _label(sliderValue.value),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTabSwitcherHistorySuggestionsTile extends HookConsumerWidget {
  const _QuickTabSwitcherHistorySuggestionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showHistorySuggestions = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowHistorySuggestions,
      ),
    );
    final switcherEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.effectiveTabBarStackingMode() != TabBarStackingMode.disabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('History Fallback in Quick Tab Switcher'),
      subtitle: const Text(
        'Use browsing history suggestions when no tab chips are available',
      ),
      secondary: const Icon(MdiIcons.history),
      value: showHistorySuggestions,
      onChanged: switcherEnabled
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) => currentSettings.copyWith
                        .quickTabSwitcherShowHistorySuggestions(value),
                  );
            }
          : null,
    );
  }
}

class _QuickTabSwitcherShowTitlesTile extends HookConsumerWidget {
  const _QuickTabSwitcherShowTitlesTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickTabSwitcherShowTitles = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
    final switcherEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.effectiveTabBarStackingMode() != TabBarStackingMode.disabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Titles in Quick Tab Switcher'),
      subtitle: const Text(
        'Display tab titles alongside icons in the quick tab switcher bar',
      ),
      secondary: const Icon(MdiIcons.textRecognition),
      value: quickTabSwitcherShowTitles,
      onChanged: switcherEnabled
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) => currentSettings.copyWith
                        .quickTabSwitcherShowTitles(value),
                  );
            }
          : null,
    );
  }
}

class _QuickTabSwitcherHierarchyGlyphsTile extends HookConsumerWidget {
  const _QuickTabSwitcherHierarchyGlyphsTile();

  static String _label(int glyphs) => switch (glyphs) {
    0 => 'Off',
    1 => '1 level',
    _ => '$glyphs levels',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hierarchyGlyphs = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherHierarchyGlyphs,
      ),
    );
    final switcherEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.effectiveTabBarStackingMode() != TabBarStackingMode.disabled,
      ),
    );

    final sliderValue = useKeyedState(hierarchyGlyphs.toDouble(), [
      hierarchyGlyphs,
    ]);

    final currentGlyphs = sliderValue.value.round();
    final enabled = switcherEnabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Hierarchy Depth in Quick Tab Switcher'),
            subtitle: const Text(
              'How many nesting chevrons to show on switcher chips before '
              'collapsing into a count badge (0 hides the indicator)',
            ),
            leading: const Icon(MdiIcons.fileTree),
            contentPadding: EdgeInsets.zero,
            enabled: enabled,
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: minQuickTabSwitcherHierarchyGlyphs.toDouble(),
                  max: maxQuickTabSwitcherHierarchyGlyphs.toDouble(),
                  divisions:
                      maxQuickTabSwitcherHierarchyGlyphs -
                      minQuickTabSwitcherHierarchyGlyphs,
                  label: _label(currentGlyphs),
                  value: sliderValue.value.clamp(
                    minQuickTabSwitcherHierarchyGlyphs.toDouble(),
                    maxQuickTabSwitcherHierarchyGlyphs.toDouble(),
                  ),
                  onChanged: enabled
                      ? (value) {
                          sliderValue.value = value;
                        }
                      : null,
                  onChangeEnd: enabled
                      ? (value) async {
                          final normalized = value.round();
                          sliderValue.value = normalized.toDouble();
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .quickTabSwitcherHierarchyGlyphs(
                                      normalized,
                                    ),
                              );
                        }
                      : null,
                ),
              ),
              Text(
                _label(currentGlyphs),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutoHideTabBarTile extends HookConsumerWidget {
  const _AutoHideTabBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoHideTabBar = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.autoHideTabBar),
    );

    return SwitchListTile.adaptive(
      title: const Text('Auto Hide Tab Bar'),
      subtitle: const Text('Hide tab bar when scrolling'),
      secondary: const Icon(MdiIcons.folderHidden),
      value: autoHideTabBar,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.autoHideTabBar(value),
            );
      },
    );
  }
}

class _BottomSheetTabViewTile extends HookConsumerWidget {
  const _BottomSheetTabViewTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabViewBottomSheet = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabViewBottomSheet),
    );

    return SwitchListTile.adaptive(
      title: const Text('Bottom Sheet Tab View'),
      subtitle: const Text(
        'Display tabs in a bottom sheet instead of fullscreen',
      ),
      secondary: const Icon(MdiIcons.dockBottom),
      value: tabViewBottomSheet,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabViewBottomSheet(value),
            );
      },
    );
  }
}

class _TabBarLongPressUrlCopyTile extends HookConsumerWidget {
  const _TabBarLongPressUrlCopyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarLongPressUrlCopy = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarLongPressUrlCopy,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Long Press URL to Copy'),
      subtitle: const Text(
        'Copy the page URL to clipboard when long pressing the address bar',
      ),
      secondary: const Icon(MdiIcons.contentCopy),
      value: tabBarLongPressUrlCopy,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabBarLongPressUrlCopy(value),
            );
      },
    );
  }
}

class _TabListShowFaviconsTile extends HookConsumerWidget {
  const _TabListShowFaviconsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabListShowFavicons = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListShowFavicons),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Favicons in List View'),
      subtitle: const Text(
        'Display website icons instead of page thumbnails in tab list view',
      ),
      secondary: const Icon(MdiIcons.web),
      value: tabListShowFavicons,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabListShowFavicons(value),
            );
      },
    );
  }
}
