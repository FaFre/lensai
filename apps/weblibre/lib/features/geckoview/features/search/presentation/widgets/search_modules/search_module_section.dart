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
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/design/wallpaper_surface.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_header.dart';

const previewItemsPerModule = 3;

/// A reusable wrapper for search module sections that handles:
/// - Display state management (preview/expanded/collapsed)
/// - Pinned header with collapse/expand and show-all/show-less controls
/// - Visible item count calculation
///
/// **Always render this widget, even when [totalCount] is 0.** The header
/// carries the long-press affordance that activates reorder mode and the
/// visibility toggle — short-circuiting to `SizedBox.shrink()` at the call
/// site means the user can lose their only entry-point to module
/// configuration. Set [hideWhenEmpty] explicitly if the section should
/// collapse silently.
class SearchModuleSection extends ConsumerWidget {
  final String title;
  final SearchModuleType moduleType;
  final int totalCount;

  /// Builds the content slivers for this module.
  ///
  /// [isCollapsed] indicates whether the section is fully collapsed (no items).
  /// [visibleCount] is the number of items to display (0 when collapsed,
  /// limited in preview, or all when expanded).
  /// Optional widget placed in the header between title and trailing button.
  final Widget? headerTrailing;

  /// The maximum number of items shown in preview mode for this section.
  final int previewLimit;

  /// If true and [totalCount] is 0, the entire section (header included)
  /// is omitted. Use sparingly — see the class doc for why hiding the
  /// header is usually undesirable.
  final bool hideWhenEmpty;

  /// Set false for modules whose body is a single non-paginated widget
  /// (e.g. a chip strip with its own scrolling). When false:
  ///   - the "Show all N / Show less" affordance is suppressed,
  ///   - [visibleCount] passed to [contentSliverBuilder] is always
  ///     [totalCount] (the section can't be partially shown),
  ///   - the section can still be fully collapsed via the header chevron.
  ///
  /// This replaces the prior workaround of passing `totalCount: 0,
  /// previewLimit: 0` to suppress pagination.
  final bool showPagination;

  final List<Widget> Function({
    required bool isCollapsed,
    required int visibleCount,
  })
  contentSliverBuilder;

  /// Overrides the surface this section configures itself from. Normally left
  /// null so it is inherited from the enclosing [ModuleSurfaceScope]; set it in
  /// tests that render a section without a host.
  final ModuleSurface? surface;

  /// Draws the section as a single self-contained card — header included —
  /// instead of a bare heading over content on the page background.
  ///
  /// For modules that are one object rather than a list of them. A list wants
  /// the page's own background so its rows read as part of the surface; a
  /// standalone card wants an edge, because there is nothing else to tell the
  /// reader where it ends.
  ///
  /// Pass [headerLeading] to put a mark in front of the title, and prefer an
  /// [IconButton.filledTonal] for [headerTrailing]: inside a card the borderless
  /// header buttons lose the surrounding whitespace that made them legible.
  final bool card;

  /// Optional mark between the collapse chevron and the title.
  final Widget? headerLeading;

  const SearchModuleSection({
    super.key,
    required this.title,
    required this.moduleType,
    required this.totalCount,
    required this.contentSliverBuilder,
    this.headerTrailing,
    this.previewLimit = previewItemsPerModule,
    this.hideWhenEmpty = false,
    this.showPagination = true,
    this.surface,
    this.card = false,
    this.headerLeading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = this.surface == null ? ModuleSurfaceScope.of(context) : null;
    final surface = this.surface ?? scope!.surface;

    final moduleOrder = ref.watch(searchModuleOrderProvider(surface));
    final isVisible = moduleOrder.any((e) => e.type == moduleType && e.visible);
    if (!isVisible) {
      return MultiSliver(children: const []);
    }

    if (hideWhenEmpty && totalCount == 0) {
      return MultiSliver(children: const []);
    }

    final displayState = ref.watch(
      searchModuleDisplayStateControllerProvider(surface, moduleType),
    );

    final isCollapsed = displayState == SearchModuleDisplayState.collapsed;
    final showAllItems =
        !showPagination ||
        displayState == SearchModuleDisplayState.expanded ||
        totalCount <= previewLimit;
    final visibleCount = isCollapsed
        ? 0
        : (showAllItems ? totalCount : previewLimit);

    // A section rendered without a host (tests) behaves like the search
    // screen, which is the surface that has one.
    //
    // A card never pins: the decoration is painted across the section's own
    // extent, so a header that detached from it and stuck to the top of the
    // viewport would leave the card behind and float over the sections below.
    final pinnedBackground = card
        ? null
        : (scope == null
              ? Theme.of(context).canvasColor
              : scope.pinnedHeaderBackgroundColor);

    final header = SearchModuleHeader(
      title: title,
      totalCount: totalCount,
      displayState: displayState,
      headerTrailing: isCollapsed ? null : headerTrailing,
      previewLimit: previewLimit,
      showPagination: showPagination,
      onToggleCollapse: () => ref
          .read(
            searchModuleDisplayStateControllerProvider(
              surface,
              moduleType,
            ).notifier,
          )
          .toggleCollapse(),
      onToggleExpansion: () => ref
          .read(
            searchModuleDisplayStateControllerProvider(
              surface,
              moduleType,
            ).notifier,
          )
          .toggleExpansion(),
      onLongPress: () =>
          ref.read(searchReorderModeProvider(surface).notifier).activate(),
      leading: headerLeading,
      emphasized: card,
    );

    if (card) {
      final colorScheme = Theme.of(context).colorScheme;

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        sliver: DecoratedSliver(
          decoration: BoxDecoration(
            // Not fully opaque: the home surface's aura gradient and any
            // wallpaper behind it should still read through the card. Broad and
            // sparsely typeset, so it takes the lighter of the two levels.
            color: colorScheme.surfaceContainer.wallpaperBroad,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Color.alphaBlend(
                AppColors.brandGrey.withValues(alpha: 0.18),
                colorScheme.outlineVariant,
              ),
            ),
          ),
          sliver: SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(child: header),
                ...contentSliverBuilder(
                  isCollapsed: isCollapsed,
                  visibleCount: visibleCount,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiSliver(
      pushPinnedChildren: pinnedBackground != null,
      children: [
        // Sections are separated by space rather than a rule. A divider drawn
        // directly above a header that carries its own backdrop produces two
        // edges where the eye expects one.
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        if (pinnedBackground != null)
          SliverPinnedHeader(
            child: ColoredBox(color: pinnedBackground, child: header),
          )
        else
          SliverToBoxAdapter(child: header),
        ...contentSliverBuilder(
          isCollapsed: isCollapsed,
          visibleCount: visibleCount,
        ),
      ],
    );
  }
}
