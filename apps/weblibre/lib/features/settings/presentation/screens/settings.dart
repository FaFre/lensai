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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';
import 'package:weblibre/features/settings/presentation/screens/advanced_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/browsing_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/extensions_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/general_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/home_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/privacy_security_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/proxy_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/search_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/web_content_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/features/web_push/presentation/screens/web_push_settings.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final search = useSettingsSearch();

    final categories = _buildCategories();
    final sections = search.normalizedQuery.isEmpty
        ? _buildCategorySections(categories)
        : _buildSearchSections([
            ...categories.browser,
            ...categories.services,
          ], search.normalizedQuery);

    return Scaffold(
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return CustomScrollView(
              controller: controller,
              slivers: [
                const SliverAppBar.large(
                  centerTitle: false,
                  title: Text('Settings'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: SettingsSearchField(
                      controller: search.controller,
                      hintText: 'Search all settings',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  sliver: SliverToBoxAdapter(
                    child: SettingsSectionList(
                      sections: sections,
                      query: search.rawQuery,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

typedef _CategoryGroups = ({
  List<_SettingsCategoryDefinition> browser,
  List<_SettingsCategoryDefinition> services,
});

_CategoryGroups _buildCategories() {
  final browser = [
    _SettingsCategoryDefinition(
      title: 'General',
      subtitle: 'Appearance, downloads',
      icon: Icons.tune,
      keywords: const ['theme', 'ui zoom', 'default browser'],
      sections: generalSettingsSections,
      onTap: (context) => GeneralSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Browsing',
      subtitle: 'Tabs, navigation, external links',
      icon: MdiIcons.compassOutline,
      keywords: const ['tabs', 'small web', 'url cleaner', 'unshortener'],
      sections: browsingSettingsSections,
      onTap: (context) => BrowsingSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Home & New Tab',
      subtitle: 'What the home and new tab pages show',
      icon: MdiIcons.homeOutline,
      keywords: const [
        'home',
        'new tab',
        'start page',
        'sections',
        'shortcuts',
        'top sites',
        'quote',
        'wallpaper',
        'background',
      ],
      sections: homeSettingsSections,
      onTap: (context) => const HomeSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Gestures',
      subtitle: 'Stroke gestures for browser actions',
      icon: MdiIcons.gestureSwipe,
      keywords: const ['gesture', 'swipe', 'stroke'],
      onTap: (context) => GestureSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Toolbar & Layout',
      subtitle: 'Tab bar, toolbar, quick switcher, tab view',
      icon: MdiIcons.viewDashboardOutline,
      keywords: const ['contextual toolbar', 'quick tab switcher'],
      sections: [
        ...toolbarLayoutSettingsSections,
        ...menuLayoutSettingsSections,
      ],
      onTap: (context) => ToolbarLayoutSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Web Content',
      subtitle: 'Page display, PDF, reader mode, AI',
      icon: MdiIcons.fileDocumentOutline,
      keywords: const ['reader mode', 'pdf', 'fonts'],
      sections: webContentSettingsSections,
      onTap: (context) => WebContentSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Notifications',
      subtitle: 'Web push delivery, distributor, site subscriptions',
      icon: MdiIcons.bellBadgeOutline,
      keywords: const ['push', 'unifiedpush', 'ntfy', 'distributor'],
      sections: webPushSettingsSections,
      onTap: (context) => WebPushSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Search',
      subtitle: 'Providers, bangs, search history',
      icon: MdiIcons.magnify,
      keywords: const ['bangs', 'suggestions', 'local search index'],
      sections: searchSettingsSections,
      onTap: (context) => SearchSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Privacy & Security',
      subtitle: 'Tracking protection, data clearing',
      icon: MdiIcons.shieldLock,
      keywords: const [
        'fingerprinting',
        'https',
        'doh',
        'safe browsing',
        'network protection',
      ],
      sections: privacySecuritySettingsSections,
      onTap: (context) => PrivacySecuritySettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Proxy',
      subtitle: 'Connections and routing',
      icon: MdiIcons.lanConnect,
      keywords: const [
        'proxy',
        'sing-box',
        'socks',
        'vpn',
        'wireguard',
        'routing',
        'tor',
        'container',
      ],
      sections: proxySettingsSections,
      onTap: (context) => const ProxySettingsRoute().push(context),
    ),
  ];

  final services = [
    _SettingsCategoryDefinition(
      title: 'Extensions',
      subtitle: 'Install and manage extension sources',
      icon: MdiIcons.puzzleOutline,
      keywords: const ['addons', 'unsigned extensions'],
      sections: extensionsSettingsSections,
      onTap: (context) => ExtensionsSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'WebLibre Account',
      subtitle: 'Sign in, sync settings',
      icon: Icons.account_circle_outlined,
      keywords: const ['account', 'subscription'],
      onTap: (context) => AccountSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Firefox Sync',
      subtitle: 'Account, sync now, engine selection',
      icon: Icons.sync,
      keywords: const ['pair', 'device name', 'engines'],
      onTap: (context) => SyncSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: 'Advanced',
      subtitle: 'JavaScript, user agent, debugging',
      icon: Icons.developer_mode,
      keywords: const ['experimental', 'error logs', 'javascript'],
      sections: advancedSettingsSections,
      onTap: (context) => AdvancedSettingsRoute().push(context),
    ),
  ];

  return (browser: browser, services: services);
}

List<SettingsSectionDefinition> _buildCategorySections(
  _CategoryGroups categories,
) {
  return [
    SettingsSectionDefinition(
      title: 'Browser',
      entries: [
        for (final category in categories.browser)
          _buildCategoryEntry(category),
      ],
    ),
    SettingsSectionDefinition(
      title: 'Services & Advanced',
      entries: [
        for (final category in categories.services)
          _buildCategoryEntry(category),
      ],
    ),
  ];
}

List<SettingsSectionDefinition> _buildSearchSections(
  List<_SettingsCategoryDefinition> categories,
  String normalizedQuery,
) {
  final results = <String, List<SettingsEntryDefinition>>{};

  for (final category in categories) {
    final categoryEntries = <SettingsEntryDefinition>[];

    if (matchesSettingsSearch(normalizedQuery, [
      category.title,
      category.subtitle,
      ...category.keywords,
    ])) {
      categoryEntries.add(_buildCategoryEntry(category));
    }

    for (final section in filterSettingsSections(
      sections: category.sections,
      query: normalizedQuery,
    )) {
      for (final entry in section.entries) {
        categoryEntries.add(
          SettingsEntryDefinition(
            title: entry.title,
            subtitle: '${section.title} • ${category.title}',
            keywords: entry.keywords,
            child: _SearchResultTile(
              title: entry.title,
              subtitle: entry.subtitle,
              category: category.title,
              section: section.title,
              icon: category.icon,
              onTap: category.onTap,
            ),
          ),
        );
      }
    }

    if (categoryEntries.isNotEmpty) {
      results[category.title] = categoryEntries;
    }
  }

  return [
    for (final result in results.entries)
      SettingsSectionDefinition(title: result.key, entries: result.value),
  ];
}

SettingsEntryDefinition _buildCategoryEntry(
  _SettingsCategoryDefinition category,
) {
  return SettingsEntryDefinition(
    title: category.title,
    subtitle: category.subtitle,
    keywords: category.keywords,
    child: _CategoryTile(category: category),
  );
}

class _SettingsCategoryDefinition {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> keywords;
  final List<SettingsSectionDefinition> sections;
  final Future<void> Function(BuildContext context) onTap;

  const _SettingsCategoryDefinition({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.keywords = const [],
    this.sections = const [],
  });
}

class _CategoryTile extends StatelessWidget {
  final _SettingsCategoryDefinition category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.title),
      subtitle: Text(category.subtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: Icon(category.icon),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await category.onTap(context);
      },
    );
  }
}

class _SearchResultTile extends HookConsumerWidget {
  final String title;
  final String? subtitle;
  final String category;
  final String section;
  final IconData icon;
  final Future<void> Function(BuildContext context) onTap;

  const _SearchResultTile({
    required this.title,
    required this.category,
    required this.section,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle == null || subtitle!.isEmpty
            ? '$category • $section'
            : '$category • $section\n$subtitle',
      ),
      isThreeLine: subtitle != null && subtitle!.isNotEmpty,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final pendingHighlight = ref.read(
          pendingSettingsHighlightProvider.notifier,
        );
        pendingHighlight.set(title);
        try {
          await onTap(context);
        } catch (_) {
          pendingHighlight.clear();
          rethrow;
        }
      },
    );
  }
}
