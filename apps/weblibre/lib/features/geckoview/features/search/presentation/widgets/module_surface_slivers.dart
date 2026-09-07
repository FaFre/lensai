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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/containers_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/frequent_bangs_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/history_highlights_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/quick_actions_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/quote_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/recent_feed_articles_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/recent_history_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/recent_searches_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/recent_tabs_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/top_sites_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_module_reorder_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';

/// How a host opens the things its modules surface.
///
/// The two hosts reach the same content by different routes: the search screen
/// may be editing an existing tab, has a bottom sheet to dismiss and has to
/// navigate back to the browser; the browser home is already there and only
/// needs to select. Keeping that in the host rather than in each module is what
/// lets both share one set of section widgets.
class ModuleSurfaceCallbacks {
  final void Function(Uri uri) onUriSelected;
  final void Function(String tabId) onTabSelected;
  final void Function(FeedArticleSummary article) onArticleSelected;
  final void Function(ContainerDataWithCount container) onContainerSelected;

  /// Present only on surfaces that own a live text field. Modules that write
  /// into the query box are not offered where these are null.
  final TextEditingController? searchTextController;
  final Future<void> Function(String query)? submitSearch;

  /// Present only on [ModuleSurface.home], which is embedded in the browser
  /// shell and can act on it.
  final VoidCallback? onNewTab;
  final VoidCallback? onViewTabs;
  final VoidCallback? onResumeLastTab;

  const ModuleSurfaceCallbacks({
    required this.onUriSelected,
    required this.onTabSelected,
    required this.onArticleSelected,
    required this.onContainerSelected,
    this.searchTextController,
    this.submitSearch,
    this.onNewTab,
    this.onViewTabs,
    this.onResumeLastTab,
  });
}

/// Builders rather than widgets: a module that is switched off is never
/// constructed, so it never subscribes to its providers and never queries the
/// database. Building the widgets eagerly would make hidden modules cost the
/// same as visible ones.
Map<SearchModuleType, Widget Function()> buildSurfaceModuleBuilders({
  required ModuleSurface surface,
  required ModuleSurfaceCallbacks callbacks,
}) {
  return {
    if (callbacks.searchTextController != null &&
        callbacks.submitSearch != null)
      SearchModuleType.recentSearches: () => RecentSearchesSection(
        searchTextController: callbacks.searchTextController!,
        submitSearch: callbacks.submitSearch!,
      ),
    SearchModuleType.frequentBangs: () => const FrequentBangsSection(),
    SearchModuleType.topSites: () =>
        TopSitesSection(onUriSelected: callbacks.onUriSelected),
    SearchModuleType.recentArticles: () => RecentFeedArticlesSection(
      onArticleSelected: callbacks.onArticleSelected,
    ),
    SearchModuleType.recentTabs: () =>
        RecentTabsSection(onTabSelected: callbacks.onTabSelected),
    SearchModuleType.recentHistory: () =>
        RecentHistorySection(onUriSelected: callbacks.onUriSelected),
    SearchModuleType.historyHighlights: () =>
        HistoryHighlightsSection(onUriSelected: callbacks.onUriSelected),
    SearchModuleType.containers: () =>
        ContainersSection(onContainerSelected: callbacks.onContainerSelected),
    SearchModuleType.quote: () => const QuoteSection(),
    if (callbacks.onNewTab != null &&
        callbacks.onViewTabs != null &&
        callbacks.onResumeLastTab != null)
      SearchModuleType.quickActions: () => QuickActionsSection(
        onNewTab: callbacks.onNewTab!,
        onViewTabs: callbacks.onViewTabs!,
        onResumeLastTab: callbacks.onResumeLastTab!,
      ),
  };
}

/// Renders [surface]'s modules in the user's saved order, followed by the entry
/// point into the customization UI.
///
/// While reorder mode targets this surface the module list is replaced by the
/// reorder view. The check is per-surface: home stays mounted underneath the
/// pushed search screen, and without it, starting a reorder on one would put
/// the other into reorder mode too.
class ModuleSurfaceSliverList extends ConsumerWidget {
  final ModuleSurface surface;
  final ModuleSurfaceCallbacks callbacks;

  /// Lets a host suppress modules that do not apply to the current input, e.g.
  /// hiding search providers once the text parses as a URL.
  final bool Function(SearchModuleType type)? moduleFilter;

  const ModuleSurfaceSliverList({
    super.key,
    required this.surface,
    required this.callbacks,
    this.moduleFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(searchReorderModeProvider(surface))) {
      return SearchModuleReorderView(surface: surface);
    }

    final order = ref.watch(searchModuleOrderProvider(surface));
    final builders = buildSurfaceModuleBuilders(
      surface: surface,
      callbacks: callbacks,
    );

    return SliverMainAxisGroup(
      slivers: [
        for (final entry in order)
          if (entry.visible &&
              builders.containsKey(entry.type) &&
              (moduleFilter?.call(entry.type) ?? true))
            builders[entry.type]!(),
        CustomizeSectionsButton(surface: surface),
      ],
    );
  }
}

/// Always-present entry into the reorder UI, so a surface whose modules are all
/// hidden or empty is still configurable.
class CustomizeSectionsButton extends ConsumerWidget {
  final ModuleSurface surface;

  const CustomizeSectionsButton({super.key, required this.surface});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Low emphasis on purpose: this is a settings affordance sitting at the end
    // of the user's content, not an action the surface is asking for. It stays
    // visible rather than moving into settings because the header long-press is
    // the only other route to reorder mode, and nothing advertises it.
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: TextButton.icon(
            onPressed: () => ref
                .read(searchReorderModeProvider(surface).notifier)
                .activate(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: const Icon(Icons.tune, size: 18),
            label: Text(
              'Customize sections',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }
}
