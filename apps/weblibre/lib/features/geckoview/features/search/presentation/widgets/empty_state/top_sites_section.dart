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
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart'
    show MdiIcons;
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/wallpaper_surface.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/dialogs/edit_top_site_dialog.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_host.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_item.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_source.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/repositories/top_site_repository.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

const _gridMainAxisSpacing = 8.0;
const _gridCrossAxisSpacing = 8.0;
const _topSitesPreviewLimit = 8;
const _topSitesMaxLimit = 25;

class _TopSitesGridLayout {
  final int crossAxisCount;
  final double childAspectRatio;

  const _TopSitesGridLayout({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });
}

_TopSitesGridLayout _resolveGridLayout(double width) {
  const minTileWidth = 74.0;
  const effectiveTileWidth = minTileWidth + _gridCrossAxisSpacing;
  final rawCount = (width / effectiveTileWidth).floor();
  final crossAxisCount = rawCount.clamp(4, 7);

  // Keep cells compact on phones and allow slightly wider tiles on large screens.
  final childAspectRatio = switch (crossAxisCount) {
    4 => 0.92,
    5 => 0.96,
    _ => 1.0,
  };

  return _TopSitesGridLayout(
    crossAxisCount: crossAxisCount,
    childAspectRatio: childAspectRatio,
  );
}

/// Responsive grid delegate that resolves the column count from the available
/// cross-axis extent at the *render* layer (in [getLayout]), mirroring
/// [_resolveGridLayout].
///
/// This replaces a `SliverLayoutBuilder`, whose builder re-runs (and rebuilds
/// the entire grid subtree) on every [SliverConstraints] change — i.e. on every
/// scroll and every keyboard-inset animation frame — which rebuilt all
/// top-site tiles each frame. The delegate recomputes grid metrics on layout
/// without rebuilding any widgets.
class _TopSitesGridDelegate extends SliverGridDelegate {
  const _TopSitesGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final layout = _resolveGridLayout(constraints.crossAxisExtent);
    final crossAxisCount = layout.crossAxisCount;

    final usableCrossAxisExtent =
        (constraints.crossAxisExtent -
                _gridCrossAxisSpacing * (crossAxisCount - 1))
            .clamp(0.0, double.infinity);
    final childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final childMainAxisExtent = childCrossAxisExtent / layout.childAspectRatio;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + _gridMainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + _gridCrossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_TopSitesGridDelegate oldDelegate) => false;
}

class TopSitesSection extends HookConsumerWidget {
  final void Function(Uri uri) onUriSelected;

  const TopSitesSection({super.key, required this.onUriSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topSites = ref.watch(
      topSiteListProvider(
        limit: _topSitesMaxLimit,
      ).select((value) => value.value ?? []),
    );

    final reorderMode = useState(false);
    final reorderBusy = useState(false);

    final persistedItems = topSites.where((s) => s.isPersisted).toList();
    final historyItems = topSites.where((s) => !s.isPersisted).toList();

    // Home leads with the user's own shortcuts, so its preview is sized to the
    // curated tiles rather than to a fixed count: every pinned and default site
    // is on screen from the start, and frecency suggestions — which pad the
    // list out to [_topSitesMaxLimit] — stay behind "Show all N". The cap only
    // bites for someone who has pinned more than a grid's worth.
    //
    // The other surfaces sit above a search field where the grid is one module
    // among many, and keep the short fixed preview.
    final isHome = ModuleSurfaceScope.surfaceOf(context) == ModuleSurface.home;
    final previewLimit = isHome
        ? persistedItems.length.clamp(0, _topSitesMaxLimit)
        : _topSitesPreviewLimit;

    return SearchModuleSection(
      title: 'Shortcuts',
      moduleType: SearchModuleType.topSites,
      totalCount: topSites.length,
      previewLimit: previewLimit,
      headerTrailing: persistedItems.length >= 2
          ? IconButton.filledTonal(
              icon: const Icon(Icons.swap_vert),
              visualDensity: VisualDensity.compact,
              isSelected: reorderMode.value,
              iconSize: 18,
              padding: EdgeInsets.zero,
              tooltip: reorderMode.value
                  ? 'Disable reordering mode'
                  : 'Enable reordering mode',
              onPressed: () {
                final wasEnabled = reorderMode.value;
                reorderMode.value = !wasEnabled;
                if (!wasEnabled && context.mounted) {
                  ui_helper.showInfoMessage(
                    context,
                    'Drag and drop shortcuts to reorder',
                  );
                }
              },
            )
          : null,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) {
            // Suggestions are the tail of the list, so they are on screen
            // exactly when the visible window reaches past the curated tiles.
            // Reorder mode lays the two groups out itself and has to be told.
            final showSuggestions = visibleCount > persistedItems.length;

            return [
              if (!isCollapsed)
                if (reorderMode.value)
                  _ReorderableTopSitesGrid(
                    persistedItems: persistedItems,
                    historyItems: showSuggestions
                        ? historyItems
                        : const <TopSiteItem>[],
                    reorderBusy: reorderBusy,
                    onUriSelected: onUriSelected,
                  )
                else
                  _TopSitesGrid(
                    items: topSites,
                    visibleCount: visibleCount,
                    onUriSelected: onUriSelected,
                    // Counted over curated tiles only: the cap is on how many
                    // shortcuts you may keep, and gating on the padded length
                    // hid the "+" as soon as suggestions filled the list out.
                    showAddTile: persistedItems.length < _topSitesMaxLimit,
                  ),
            ];
          },
    );
  }
}

class _TopSitesGrid extends ConsumerWidget {
  final List<TopSiteItem> items;
  final int visibleCount;
  final void Function(Uri uri) onUriSelected;
  final bool showAddTile;

  const _TopSitesGrid({
    required this.items,
    required this.visibleCount,
    required this.onUriSelected,
    this.showAddTile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayItems = items.take(visibleCount).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      sliver: SliverGrid.builder(
        gridDelegate: const _TopSitesGridDelegate(),
        itemCount: displayItems.length + (showAddTile ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayItems.length) {
            return _AddShortcutTile(onPressed: () => _addItem(context, ref));
          }

          final item = displayItems[index];
          return _TopSiteGridTile(
            item: item,
            onTap: () => onUriSelected(item.url),
            onPin: item.isPersisted ? null : () => _pinItem(context, ref, item),
            onEdit: item.isPersisted
                ? () => _editItem(context, ref, item)
                : null,
            onRemove: () => _removeItem(context, ref, item),
            onRemoveDomain: () =>
                _removeItem(context, ref, item, wholeDomain: true),
          );
        },
      ),
    );
  }
}

/// Shell shared by every cell of the shortcuts grid, the trailing "+" included.
/// Fill, radius, outline and ink live here so the cells cannot drift apart —
/// they did once, when the "+" was the only translucent one among solid tiles.
///
/// The fill is deliberately not opaque: this grid paints straight onto the home
/// surface, so a wallpaper and the aura gradient behind it read through the
/// cells the way they read through a module card. It takes the denser of the
/// two wallpaper-surface levels, because a tile label is the smallest type on
/// the surface and sits directly over the image.
class _TopSiteTileSurface extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  const _TopSiteTileSurface({
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  static const borderRadius = BorderRadius.all(Radius.circular(12.0));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.wallpaperDense,
        borderRadius: borderRadius,
        border: Border.all(color: colorScheme.wallpaperOutline),
      ),
      // Transparent so the ink splash rides on the decoration above rather
      // than painting a second, opaque layer over it.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: child,
        ),
      ),
    );
  }
}

/// Trailing "+" cell. Creating a shortcut previously required visiting the site
/// and pinning it from the browser menu; there was no way to just type one in.
class _AddShortcutTile extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddShortcutTile({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _TopSiteTileSurface(
      onTap: onPressed,
      child: Tooltip(
        message: 'Add shortcut',
        child: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _ReorderableTopSitesGrid extends HookConsumerWidget {
  final List<TopSiteItem> persistedItems;
  final List<TopSiteItem> historyItems;
  final ValueNotifier<bool> reorderBusy;
  final void Function(Uri uri) onUriSelected;

  const _ReorderableTopSitesGrid({
    required this.persistedItems,
    required this.historyItems,
    required this.reorderBusy,
    required this.onUriSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localItems = useKeyedState(persistedItems, [persistedItems]);

    // Attached to the inner grid below, and handed to ReorderableBuilder so it
    // reads its scroll position from there rather than from the enclosing
    // CustomScrollView.
    //
    // The package records each tile's position as `localPosition +
    // scrollOffset` when the tile is first built, but during a drag it tests
    // collisions against `pointerLocalPosition + (scrollOffset -
    // scrollOffsetAtDragStart)`. Those two agree only if the scroll offset was
    // zero when the tiles were created. Left to find the outer scrollable, that
    // holds only when the surface happens to be scrolled to the top — and
    // reaching this module's reorder toggle usually means it is not, so every
    // tile ends up displaced by the scroll amount and the drop lands on the
    // wrong cell. The inner grid never scrolls, so sourcing the offset from it
    // pins it at zero and both sides reduce to plain local coordinates.
    final gridScrollController = useScrollController();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = _resolveGridLayout(constraints.maxWidth);
            return ReorderableBuilder.builder(
              scrollController: gridScrollController,
              itemCount: localItems.value.length,
              onReorderPositions: (positions) async {
                if (reorderBusy.value || positions.isEmpty) return;

                final oldIndex = positions.first.oldIndex;
                final newIndex = positions.first.newIndex;
                if (oldIndex < 0 || oldIndex >= localItems.value.length) return;
                if (newIndex < 0 || newIndex > localItems.value.length) return;

                final items = localItems.value.toList();
                var movedItem = items.removeAt(oldIndex);

                final targetIndex = newIndex.clamp(0, items.length);

                // The grid package reports target indices in the final order.
                items.insert(targetIndex, movedItem);
                localItems.value = items;

                reorderBusy.value = true;
                try {
                  final repo = ref.read(topSiteRepositoryProvider.notifier);

                  // Auto-persist default sites that don't have an ID yet
                  if (movedItem.id == null && movedItem.isDefault) {
                    final id = await repo.ensureDefaultPersisted(
                      title: movedItem.title,
                      url: movedItem.url,
                    );
                    movedItem = TopSiteItem(
                      id: id,
                      title: movedItem.title,
                      url: movedItem.url,
                      source: movedItem.source,
                      orderKey: movedItem.orderKey,
                      createdAt: movedItem.createdAt,
                    );
                  }
                  if (movedItem.id == null) return;

                  // Ensure neighbors are persisted too
                  for (var i = 0; i < items.length; i++) {
                    if (items[i].id == null && items[i].isDefault) {
                      final id = await repo.ensureDefaultPersisted(
                        title: items[i].title,
                        url: items[i].url,
                      );
                      items[i] = TopSiteItem(
                        id: id,
                        title: items[i].title,
                        url: items[i].url,
                        source: items[i].source,
                        orderKey: items[i].orderKey,
                        createdAt: items[i].createdAt,
                      );
                    }
                  }

                  final String key;
                  if (targetIndex <= 0) {
                    key = await repo.getLeadingOrderKey();
                  } else if (targetIndex >= items.length - 1) {
                    key = await repo.getTrailingOrderKey();
                  } else if (targetIndex < oldIndex) {
                    final previousId = items[targetIndex - 1].id;
                    final nextId = items[targetIndex + 1].id;
                    final afterPrevious = previousId == null
                        ? null
                        : await repo.getOrderKeyAfterSite(previousId);
                    if (afterPrevious != null) {
                      key = afterPrevious;
                    } else if (nextId != null) {
                      key = await repo.getOrderKeyBeforeSite(nextId);
                    } else {
                      key = await repo.getTrailingOrderKey();
                    }
                  } else {
                    key = await repo.getOrderKeyBeforeSite(
                      items[targetIndex + 1].id!,
                    );
                  }

                  await repo.assignOrderKey(movedItem.id!, key);
                } catch (e) {
                  localItems.value = persistedItems;
                  if (context.mounted) {
                    ui_helper.showErrorMessage(
                      context,
                      'Failed to reorder shortcut',
                    );
                  }
                } finally {
                  reorderBusy.value = false;
                }
              },
              childBuilder: (reorderableItemBuilder) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.builder(
                      // Never scrolls (the outer surface does), so this
                      // controller's offset stays at zero — which is exactly
                      // what ReorderableBuilder needs to read. Only this grid
                      // gets it: a controller attached to two positions throws
                      // when the package asks for `position`.
                      controller: gridScrollController,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: layout.crossAxisCount,
                        mainAxisSpacing: _gridMainAxisSpacing,
                        crossAxisSpacing: _gridCrossAxisSpacing,
                        childAspectRatio: layout.childAspectRatio,
                      ),
                      itemCount: localItems.value.length,
                      itemBuilder: (context, index) {
                        final item = localItems.value[index];
                        final draggable = CustomDraggable(
                          key: ValueKey(item.id ?? 'top-site-$index'),
                          data: item.id ?? 'top-site-$index',
                          child: _TopSiteGridTile(
                            item: item,
                            onTap: () => onUriSelected(item.url),
                            showDragHandle: true,
                          ),
                        );
                        return reorderableItemBuilder(draggable, index);
                      },
                    ),
                    if (historyItems.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: layout.crossAxisCount,
                          mainAxisSpacing: _gridMainAxisSpacing,
                          crossAxisSpacing: _gridCrossAxisSpacing,
                          childAspectRatio: layout.childAspectRatio,
                        ),
                        itemCount: historyItems.length,
                        itemBuilder: (context, index) {
                          final item = historyItems[index];
                          return Opacity(
                            opacity: 0.5,
                            child: _TopSiteGridTile(
                              item: item,
                              onTap: () => onUriSelected(item.url),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TopSiteGridTile extends StatefulWidget {
  final TopSiteItem item;
  final VoidCallback onTap;
  final VoidCallback? onPin;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onRemoveDomain;
  final bool showDragHandle;

  const _TopSiteGridTile({
    required this.item,
    required this.onTap,
    this.onPin,
    this.onEdit,
    this.onRemove,
    this.onRemoveDomain,
    this.showDragHandle = false,
  });

  static const _iconSize = 40.0;

  @override
  State<_TopSiteGridTile> createState() => _TopSiteGridTileState();
}

class _TopSiteGridTileState extends State<_TopSiteGridTile> {
  final _menuController = MenuController();

  bool get _hasMenu =>
      widget.onPin != null ||
      widget.onEdit != null ||
      widget.onRemove != null ||
      widget.onRemoveDomain != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MenuAnchor(
      controller: _menuController,
      menuChildren: [
        if (widget.onPin != null)
          MenuItemButton(onPressed: widget.onPin, child: const Text('Pin')),
        if (widget.onEdit != null)
          MenuItemButton(onPressed: widget.onEdit, child: const Text('Edit')),
        // Offered for history-derived tiles too. Without it a frequently
        // visited site — a PWA especially — could occupy most of the grid
        // with no way to get rid of it.
        if (widget.onRemove != null)
          MenuItemButton(
            onPressed: widget.onRemove,
            child: const Text('Remove'),
          ),
        if (widget.onRemoveDomain != null &&
            canonicalTopSiteHost(widget.item.url).isNotEmpty)
          MenuItemButton(
            onPressed: widget.onRemoveDomain,
            child: Text(
              'Hide all from ${canonicalTopSiteHost(widget.item.url)}',
            ),
          ),
      ],
      child: _TopSiteTileSurface(
        onTap: widget.onTap,
        onLongPress: _hasMenu
            ? () {
                if (_menuController.isOpen) {
                  _menuController.close();
                } else {
                  _menuController.open();
                }
              }
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final titleStyle = textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  );
                  final lineHeight =
                      (titleStyle?.fontSize ?? 12.0) *
                      (titleStyle?.height ?? 1.2);
                  const textLines = 2;
                  const gap = 6.0;
                  const minIconSize = 18.0;
                  const textHeightPadding = 16.0;
                  final minTextHeight = lineHeight + textHeightPadding;
                  final maxTextHeight =
                      lineHeight * textLines + textHeightPadding;
                  final iconSize = (constraints.maxHeight - minTextHeight - gap)
                      .clamp(minIconSize, _TopSiteGridTile._iconSize);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        child: SizedBox.square(
                          dimension: iconSize,
                          child: RepaintBoundary(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              child: UrlIcon([
                                widget.item.url,
                              ], iconSize: iconSize),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: gap),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxTextHeight),
                          child: Text(
                            widget.item.title,
                            maxLines: textLines,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: titleStyle,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (widget.item.source == TopSiteSource.pinned)
              Positioned(
                top: 4,
                right: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(
                      Icons.push_pin,
                      size: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            if (widget.item.source == TopSiteSource.defaultSite)
              Positioned(
                top: 4,
                right: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(
                      MdiIcons.crown,
                      size: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            if (widget.showDragHandle)
              Positioned(
                top: 2,
                left: 2,
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _pinItem(
  BuildContext context,
  WidgetRef ref,
  TopSiteItem item,
) async {
  try {
    await ref
        .read(topSiteRepositoryProvider.notifier)
        .addPinnedSite(title: item.title, url: item.url);
    if (context.mounted) {
      ui_helper.showInfoMessage(context, 'Pinned "${item.title}"');
    }
  } catch (e) {
    if (context.mounted) {
      ui_helper.showErrorMessage(context, 'Failed to pin site');
    }
  }
}

Future<void> _editItem(
  BuildContext context,
  WidgetRef ref,
  TopSiteItem item,
) async {
  final result = await showEditTopSiteDialog(
    context,
    initialTitle: item.title,
    initialUrl: item.url,
  );

  if (result == null || !context.mounted) return;

  try {
    final repo = ref.read(topSiteRepositoryProvider.notifier);

    // If the item has no ID (unpersisted default), persist it first
    var id = item.id;
    if (id == null && item.isDefault) {
      id = await repo.ensureDefaultPersisted(title: item.title, url: item.url);
    }
    if (id == null) return;

    // If the URL changed, hide the original so it doesn't reappear
    // from the const defaults list.
    if (item.url != result.url) {
      await repo.hideSite(item.url);
    }

    await repo.updateSite(id: id, title: result.title, url: result.url);
    if (context.mounted) {
      ui_helper.showInfoMessage(context, 'Shortcut updated');
    }
  } catch (e) {
    if (context.mounted) {
      ui_helper.showErrorMessage(context, 'Failed to update shortcut');
    }
  }
}

Future<void> _addItem(BuildContext context, WidgetRef ref) async {
  final result = await showEditTopSiteDialog(
    context,
    dialogTitle: 'Add shortcut',
    confirmLabel: 'Add',
  );

  if (result == null || !context.mounted) return;

  try {
    await ref
        .read(topSiteRepositoryProvider.notifier)
        .addPinnedSite(title: result.title, url: result.url);
    if (context.mounted) {
      ui_helper.showInfoMessage(context, 'Added "${result.title}"');
    }
  } catch (e) {
    if (context.mounted) {
      ui_helper.showErrorMessage(context, 'Failed to add shortcut');
    }
  }
}

Future<void> _removeItem(
  BuildContext context,
  WidgetRef ref,
  TopSiteItem item, {
  bool wholeDomain = false,
}) async {
  final repo = ref.read(topSiteRepositoryProvider.notifier);
  final wasPersisted = item.id != null;

  try {
    if (wasPersisted) {
      await repo.removeSite(item.id!);
    }
    // Hide it so it doesn't come back from the bundled defaults or from
    // frecency-ranked history.
    await repo.hideSite(item.url, wholeDomain: wholeDomain);

    if (context.mounted) {
      ui_helper.showInfoMessage(
        context,
        wholeDomain
            ? 'Hid all shortcuts from ${canonicalTopSiteHost(item.url)}'
            : 'Removed "${item.title}"',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            try {
              // Lift the suppression first, then restore the pin only if the
              // shortcut was one. An unpinned history entry comes back on its
              // own once it is no longer hidden; re-pinning it would silently
              // promote it to something the user never created.
              await repo.unhideSite(item.url, wholeDomain: wholeDomain);
              if (wasPersisted) {
                await repo.addPinnedSite(title: item.title, url: item.url);
              }
            } catch (_) {}
          },
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ui_helper.showErrorMessage(context, 'Failed to remove shortcut');
    }
  }
}
