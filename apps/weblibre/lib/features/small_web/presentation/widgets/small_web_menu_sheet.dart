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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/small_web/data/models/kagi_category.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/data/providers.dart';
import 'package:weblibre/features/small_web/domain/providers.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_session_controller.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_attribution_card.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_attribution_navigation.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_history_list.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_mode_chips.dart';
import 'package:weblibre/features/small_web/presentation/widgets/wander_console_sheet.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

/// Hand-off between the small-web menu and the wander-console sheet. Each
/// sheet pops with one of these so [openSmallWebMenuFlow] can re-present the
/// next sheet from a stable parent context instead of the popped sheet's
/// deactivated context.
enum SmallWebSheetRequest { showMenu, showWander }

/// Top-level entry: opens the small-web menu and re-presents whichever sheet
/// the user requested next, looping until a sheet is dismissed without a
/// follow-up request.
Future<void> openSmallWebMenuFlow(BuildContext context) async {
  SmallWebSheetRequest? next = SmallWebSheetRequest.showMenu;
  while (next != null) {
    if (!context.mounted) return;
    if (next == SmallWebSheetRequest.showMenu) {
      next = await showSmallWebMenuSheet(context);
    } else {
      next = await showWanderConsoleSheet(context);
    }
  }
}

Future<SmallWebSheetRequest?> showSmallWebMenuSheet(BuildContext context) {
  return showModalBottomSheet<SmallWebSheetRequest>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _SmallWebMenuSheet(),
  );
}

class _SmallWebMenuSheet extends ConsumerWidget {
  const _SmallWebMenuSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(smallWebSessionControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return PointerScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SheetDragHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.explore, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Small Web',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  sessionAsync.when(
                    data: (session) => _SourceKindChip(
                      sourceKind: session.sourceKind,
                      onChanged: (kind) {
                        final notifier = ref.read(
                          smallWebSessionControllerProvider.notifier,
                        );
                        notifier.setSourceKind(kind);
                        // await notifier.discover();
                      },
                    ),
                    loading: () => _SourceKindChip(
                      sourceKind: SmallWebSourceKind.kagi,
                      onChanged: (_) {},
                    ),
                    error: (_, _) => IconButton(
                      onPressed: ref
                          .read(smallWebSessionControllerProvider.notifier)
                          .discover,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Retry',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessionAsync.when(
                data: (session) => _SmallWebMenuContent(
                  scrollController: scrollController,
                  session: session,
                ),
                loading: () =>
                    _SmallWebMenuLoading(scrollController: scrollController),
                error: (error, _) => _SmallWebMenuError(
                  scrollController: scrollController,
                  error: error,
                  onRetry: ref
                      .read(smallWebSessionControllerProvider.notifier)
                      .discover,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SourceKindChip extends StatelessWidget {
  final SmallWebSourceKind sourceKind;
  final ValueChanged<SmallWebSourceKind> onChanged;

  const _SourceKindChip({required this.sourceKind, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuAnchor(
      builder: (context, controller, _) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Chip(
          avatar: Icon(sourceKind.icon, size: 18),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sourceKind.label),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
          visualDensity: VisualDensity.compact,
        ),
      ),
      menuChildren: [
        for (final kind in SmallWebSourceKind.values)
          MenuItemButton(
            onPressed: () => onChanged(kind),
            leadingIcon: Icon(kind.icon, size: 20),
            trailingIcon: kind == sourceKind
                ? Icon(Icons.check, size: 20, color: colorScheme.primary)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kind.label),
                Text(
                  kind.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SmallWebMenuContent extends ConsumerWidget {
  final ScrollController scrollController;
  final SmallWebSessionState session;

  const _SmallWebMenuContent({
    required this.scrollController,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (session.sourceKind == SmallWebSourceKind.kagi) ...[
          SmallWebModeChips(
            currentMode: session.mode,
            isLoading: false,
            onModeSelected: (mode) {
              final notifier = ref.read(
                smallWebSessionControllerProvider.notifier,
              );
              notifier.setMode(mode);
              // await notifier.discover();
            },
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
        ],
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: _buildContentForMode(context, ref, scrollController),
          ),
        ),
      ],
    );
  }

  Widget _buildContentForMode(
    BuildContext context,
    WidgetRef ref,
    ScrollController scrollController,
  ) {
    if (session.sourceKind == SmallWebSourceKind.kagi &&
        session.mode == KagiSmallWebMode.web) {
      return _WebCategoriesPanel(
        key: const ValueKey('web_panel'),
        scrollController: scrollController,
        session: session,
      );
    }

    if (session.sourceKind == SmallWebSourceKind.kagi &&
        session.mode != null &&
        session.mode != KagiSmallWebMode.web) {
      return _ModeContextPanel(
        key: ValueKey('mode_${session.mode!.name}'),
        scrollController: scrollController,
        session: session,
        mode: session.mode!,
      );
    }

    return _DefaultContentPanel(
      key: const ValueKey('default_panel'),
      scrollController: scrollController,
      session: session,
    );
  }
}

class _WebCategoriesPanel extends ConsumerWidget {
  final ScrollController scrollController;
  final SmallWebSessionState session;

  const _WebCategoriesPanel({
    super.key,
    required this.scrollController,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(kagiCategoriesProvider);

    return categoriesAsync.when(
      data: (kagiCategories) => FadingScroll(
        controller: scrollController,
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              if (session.infoMessage != null) ...[
                _InfoMessageCard(message: session.infoMessage!),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Refine Category', style: theme.textTheme.titleSmall),
                  FilterChip(
                    label: const Text('All'),
                    selected: session.currentCategory == null,
                    showCheckmark: false,
                    onSelected: (_) async {
                      final notifier = ref.read(
                        smallWebSessionControllerProvider.notifier,
                      );
                      notifier.setCategory(null);
                      await notifier.discover();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final MapEntry(key: groupName, value: slugs)
                  in kagiCategories.groups.entries) ...[
                _SectionHeader(title: groupName),
                const SizedBox(height: 6),
                _CategoryGrid(
                  categories: kagiCategories.categories,
                  slugs: slugs,
                  currentCategory: session.currentCategory,
                  onCategorySelected: (slug) async {
                    final notifier = ref.read(
                      smallWebSessionControllerProvider.notifier,
                    );
                    notifier.setCategory(
                      session.currentCategory == slug ? null : slug,
                    );
                    await notifier.discover();
                  },
                ),
                const SizedBox(height: 10),
              ],
              SmallWebAttributionCard(
                data: SmallWebAttributionData.forSelection(
                  sourceKind: session.sourceKind,
                  mode: session.mode,
                ),
                onOpenUri: (uri) => openSmallWebAttributionUri(context, uri),
                compact: true,
              ),
              const SizedBox(height: 8),
              const _DiscoverButton(),
              const SizedBox(height: 12),
              SmallWebHistoryHeader(
                sourceKind: session.sourceKind,
                mode: session.mode,
              ),
              const SizedBox(height: 4),
              SmallWebHistoryList(
                sourceKind: session.sourceKind,
                mode: session.mode,
              ),
            ],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ModeContextPanel extends ConsumerWidget {
  final ScrollController scrollController;
  final SmallWebSessionState session;
  final KagiSmallWebMode mode;

  const _ModeContextPanel({
    super.key,
    required this.scrollController,
    required this.session,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final (IconData icon, String description) = switch (mode) {
      KagiSmallWebMode.appreciated => (
        Icons.volunteer_activism,
        'Browse highly curated, user-appreciated links from the small web community.',
      ),
      KagiSmallWebMode.videos => (
        Icons.video_library,
        'Discover video content from independent creators across the small web.',
      ),
      KagiSmallWebMode.code => (
        Icons.data_object,
        'Find code snippets, repositories, and technical articles from personal sites.',
      ),
      KagiSmallWebMode.comics => (
        Icons.auto_stories,
        'Explore indie comics and web-graphics from independent illustrators.',
      ),
      KagiSmallWebMode.web => (Icons.language, ''),
    };

    return FadingScroll(
      controller: scrollController,
      fadingSize: 25,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (session.infoMessage != null) ...[
              _InfoMessageCard(message: session.infoMessage!),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Searching ${mode.label}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SmallWebAttributionCard(
              data: SmallWebAttributionData.forSelection(
                sourceKind: session.sourceKind,
                mode: session.mode,
              ),
              onOpenUri: (uri) => openSmallWebAttributionUri(context, uri),
              compact: true,
            ),
            const SizedBox(height: 8),
            const _DiscoverButton(),
            const SizedBox(height: 12),
            SmallWebHistoryHeader(
              sourceKind: session.sourceKind,
              mode: session.mode,
            ),
            const SizedBox(height: 4),
            SmallWebHistoryList(
              sourceKind: session.sourceKind,
              mode: session.mode,
            ),
          ],
        );
      },
    );
  }
}

class _DefaultContentPanel extends ConsumerWidget {
  final ScrollController scrollController;
  final SmallWebSessionState session;

  const _DefaultContentPanel({
    super.key,
    required this.scrollController,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FadingScroll(
      controller: scrollController,
      fadingSize: 25,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (session.infoMessage != null) ...[
              _InfoMessageCard(message: session.infoMessage!),
              const SizedBox(height: 8),
            ],
            SmallWebAttributionCard(
              data: SmallWebAttributionData.forSelection(
                sourceKind: session.sourceKind,
                mode: session.mode,
              ),
              onOpenUri: (uri) => openSmallWebAttributionUri(context, uri),
            ),
            const SizedBox(height: 12),
            if (session.sourceKind == SmallWebSourceKind.wander) ...[
              _WanderConsoleCard(currentConsoleUrl: session.currentConsoleUrl),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () =>
                    Navigator.of(context).pop(SmallWebSheetRequest.showWander),
                icon: const Icon(Icons.dns, size: 18),
                label: const Text('Browse Consoles'),
              ),
              const SizedBox(height: 12),
            ],
            const _DiscoverButton(),
            const SizedBox(height: 12),
            SmallWebHistoryHeader(
              sourceKind: session.sourceKind,
              mode: session.mode,
            ),
            const SizedBox(height: 4),
            SmallWebHistoryList(
              sourceKind: session.sourceKind,
              mode: session.mode,
            ),
          ],
        );
      },
    );
  }
}

// --- Shared sub-widgets ---

class _DiscoverButton extends ConsumerWidget {
  const _DiscoverButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      smallWebSessionControllerProvider.select((s) => s.isLoading),
    );

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading
            ? null
            : () async {
                final notifier = ref.read(
                  smallWebSessionControllerProvider.notifier,
                );

                if (context.mounted) Navigator.pop(context);
                await notifier.discover();
              },
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.explore, size: 20),
        label: const Text('Discover'),
      ),
    );
  }
}

class _InfoMessageCard extends StatelessWidget {
  final String message;

  const _InfoMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final Map<String, KagiCategoryDefinition> categories;
  final List<String> slugs;
  final String? currentCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategoryGrid({
    required this.categories,
    required this.slugs,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final visibleSlugs = slugs.where((s) => categories.containsKey(s)).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: visibleSlugs.length,
      itemBuilder: (context, index) {
        final slug = visibleSlugs[index];
        final cat = categories[slug]!;
        return _CategoryTile(
          label: cat.label,
          emoji: cat.emoji,
          isSelected: currentCategory == slug,
          onTap: () => onCategorySelected(slug),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Loading / Error states ---

class _SmallWebMenuLoading extends StatelessWidget {
  final ScrollController scrollController;

  const _SmallWebMenuLoading({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode chips skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Bone(
                  width: 60,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(width: 8),
                Bone(
                  width: 70,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(width: 8),
                Bone(
                  width: 65,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FadingScroll(
              controller: scrollController,
              fadingSize: 25,
              builder: (context, controller) {
                return ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: const [
                    Bone.text(words: 2),
                    SizedBox(height: 8),
                    _SkeletonHistoryItem(),
                    _SkeletonHistoryItem(),
                    _SkeletonHistoryItem(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonHistoryItem extends StatelessWidget {
  const _SkeletonHistoryItem();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: EdgeInsets.only(left: 12, top: 10, bottom: 10),
        child: Row(
          children: [
            Bone.circle(size: 32),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(words: 2),
                  SizedBox(height: 3),
                  Bone.text(words: 3, fontSize: 12),
                ],
              ),
            ),
            SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _SmallWebMenuError extends StatelessWidget {
  final ScrollController scrollController;
  final Object error;
  final VoidCallback onRetry;

  const _SmallWebMenuError({
    required this.scrollController,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FadingScroll(
      controller: scrollController,
      fadingSize: 25,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            SizedBox(
              height: 240,
              child: FailureWidget(
                title: 'Small Web unavailable',
                exception: error,
                onRetry: onRetry,
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Wander console card ---

class _WanderConsoleCard extends ConsumerWidget {
  final Uri? currentConsoleUrl;

  const _WanderConsoleCard({required this.currentConsoleUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (currentConsoleUrl == null) {
      return Card(
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.dns_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'No console selected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final statsAsync = ref.watch(
      wanderConsoleStatsProvider(currentConsoleUrl!),
    );

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentConsoleUrl!.host,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            statsAsync.when(
              data: (stats) => Text(
                '${stats.linkedConsoles} linked consoles \u00b7 ${stats.pages} pages',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
