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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/small_web/domain/providers.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_session_controller.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_menu_sheet.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/sliding_pill_toggle.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart';

Future<SmallWebSheetRequest?> showWanderConsoleSheet(BuildContext context) {
  return showModalBottomSheet<SmallWebSheetRequest>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _WanderConsoleSheet(),
  );
}

class _WanderConsoleSheet extends HookConsumerWidget {
  const _WanderConsoleSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(smallWebSessionControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final searchController = useTextEditingController();
    final searchQuery = useListenableSelector(
      searchController,
      () => searchController.text.toLowerCase(),
    );
    final showAllConsoles = useState<bool?>(null);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(SmallWebSheetRequest.showMenu),
                    icon: const Icon(Icons.arrow_back),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Console',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: sessionAsync.isLoading || sessionAsync.hasError
                        ? null
                        : () async {
                            final notifier = ref.read(
                              smallWebSessionControllerProvider.notifier,
                            );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                            await notifier.discover(forceNewConsole: true);
                          },
                    icon: const Icon(Icons.shuffle, size: 18),
                    label: const Text('Random'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessionAsync.when(
                data: (session) {
                  final currentConsoleUrl = session.currentConsoleUrl;
                  final effectiveShowAllConsoles =
                      showAllConsoles.value ?? currentConsoleUrl == null;

                  return _WanderConsoleSheetContent(
                    session: session,
                    searchController: searchController,
                    searchQuery: searchQuery,
                    scrollController: scrollController,
                    showAllConsoles: effectiveShowAllConsoles,
                    onToggleAllConsoles: (value) {
                      showAllConsoles.value = value;
                    },
                    onAddConsole: () => _showAddConsoleDialog(context, ref),
                  );
                },
                loading: () => _WanderConsoleSheetLoading(
                  scrollController: scrollController,
                ),
                error: (error, _) => _WanderConsoleSheetError(
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

class _WanderConsoleSheetContent extends StatelessWidget {
  final SmallWebSessionState session;
  final TextEditingController searchController;
  final String searchQuery;
  final ScrollController scrollController;
  final bool showAllConsoles;
  final ValueChanged<bool> onToggleAllConsoles;
  final VoidCallback onAddConsole;

  const _WanderConsoleSheetContent({
    required this.session,
    required this.searchController,
    required this.searchQuery,
    required this.scrollController,
    required this.showAllConsoles,
    required this.onToggleAllConsoles,
    required this.onAddConsole,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentConsoleUrl = session.currentConsoleUrl;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: searchController,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'Filter consoles...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: searchController.clear,
                      icon: const Icon(Icons.clear, size: 20),
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        if (currentConsoleUrl != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SlidingPillToggle(
              selectedIndex: showAllConsoles ? 1 : 0,
              labels: const ['Linked', 'All'],
              onChanged: (index) => onToggleAllConsoles(index == 1),
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              if (showAllConsoles)
                _AllConsoleList(
                  searchQuery: searchQuery,
                  scrollController: scrollController,
                  selectedConsoleUrl: currentConsoleUrl,
                  isLoading: false,
                )
              else if (currentConsoleUrl == null)
                const Center(
                  child: Text('No console selected yet. Press Discover.'),
                )
              else
                _LinkedConsoleList(
                  consoleUrl: currentConsoleUrl,
                  searchQuery: searchQuery,
                  scrollController: scrollController,
                  selectedConsoleUrl: currentConsoleUrl,
                  isLoading: false,
                ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  onPressed: onAddConsole,
                  tooltip: 'Add console by URL',
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WanderConsoleSheetLoading extends StatelessWidget {
  final ScrollController scrollController;

  const _WanderConsoleSheetLoading({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: FadingScroll(
        controller: scrollController,
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: const [
              TextField(
                decoration: InputDecoration(hintText: 'Filter consoles...'),
              ),
              SizedBox(height: 12),
              _SkeletonConsoleTile(),
              _SkeletonConsoleTile(),
              _SkeletonConsoleTile(),
            ],
          );
        },
      ),
    );
  }
}

class _SkeletonConsoleTile extends StatelessWidget {
  const _SkeletonConsoleTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: EdgeInsets.only(left: 12, top: 10, bottom: 10, right: 12),
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
                  Bone.text(words: 1, fontSize: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WanderConsoleSheetError extends StatelessWidget {
  final ScrollController scrollController;
  final Object error;
  final VoidCallback onRetry;

  const _WanderConsoleSheetError({
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
                title: 'Could not load Small Web session',
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

class _LinkedConsoleList extends ConsumerWidget {
  final Uri consoleUrl;
  final String searchQuery;
  final ScrollController scrollController;
  final Uri? selectedConsoleUrl;
  final bool isLoading;

  const _LinkedConsoleList({
    required this.consoleUrl,
    required this.searchQuery,
    required this.scrollController,
    required this.selectedConsoleUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neighborsAsync = ref.watch(
      wanderNeighborConsolesProvider(consoleUrl),
    );

    return neighborsAsync.when(
      data: (consoles) {
        final filtered = searchQuery.isEmpty
            ? consoles
            : consoles
                  .where(
                    (c) =>
                        c.url.host.toLowerCase().contains(searchQuery) ||
                        c.url.toString().toLowerCase().contains(searchQuery),
                  )
                  .toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty
                  ? 'No linked consoles found.'
                  : 'No consoles matching "$searchQuery".',
            ),
          );
        }
        return FadingScroll(
          controller: scrollController,
          fadingSize: 25,
          builder: (context, controller) {
            return ListView.builder(
              controller: controller,
              padding: const EdgeInsets.only(top: 4, bottom: 56),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final console = filtered[index];
                return _ConsoleListTile(
                  url: console.url,
                  pageCount: console.pageCount,
                  selectedConsoleUrl: selectedConsoleUrl,
                  isLoading: isLoading,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Failed to load consoles.')),
    );
  }
}

class _AllConsoleList extends ConsumerWidget {
  final String searchQuery;
  final ScrollController scrollController;
  final Uri? selectedConsoleUrl;
  final bool isLoading;

  const _AllConsoleList({
    required this.searchQuery,
    required this.scrollController,
    required this.selectedConsoleUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consolesAsync = ref.watch(wanderAllConsolesProvider(searchQuery));

    return consolesAsync.when(
      data: (consoles) {
        if (consoles.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty
                  ? 'No consoles discovered yet.'
                  : 'No consoles matching "$searchQuery".',
            ),
          );
        }
        return FadingScroll(
          controller: scrollController,
          fadingSize: 25,
          builder: (context, controller) {
            return ListView.builder(
              controller: controller,
              padding: const EdgeInsets.only(top: 4, bottom: 56),
              itemCount: consoles.length,
              itemBuilder: (context, index) {
                final console = consoles[index];
                return _ConsoleListTile(
                  url: console.url,
                  pageCount: console.pageCount,
                  selectedConsoleUrl: selectedConsoleUrl,
                  isLoading: isLoading,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Failed to load consoles.')),
    );
  }
}

class _ConsoleListTile extends ConsumerWidget {
  final Uri url;
  final int pageCount;
  final Uri? selectedConsoleUrl;
  final bool isLoading;

  const _ConsoleListTile({
    required this.url,
    required this.pageCount,
    required this.selectedConsoleUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = selectedConsoleUrl == url;

    const borderRadius = BorderRadius.all(Radius.circular(12));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: isLoading
              ? null
              : () {
                  final notifier = ref.read(
                    smallWebSessionControllerProvider.notifier,
                  );
                  notifier.selectConsole(url);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // await notifier.discover();
                },
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 10,
              bottom: 10,
              right: 12,
            ),
            child: Row(
              children: [
                UrlIcon([url], iconSize: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        url.host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colorScheme.primary : null,
                        ),
                      ),
                      if (pageCount > 0) ...[
                        const SizedBox(height: 3),
                        Text(
                          '$pageCount pages',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showAddConsoleDialog(BuildContext context, WidgetRef ref) {
  return showDialog(
    context: context,
    builder: (context) => _AddConsoleDialog(ref: ref),
  );
}

class _AddConsoleDialog extends HookWidget {
  final WidgetRef ref;

  const _AddConsoleDialog({required this.ref});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final textController = useTextEditingController();

    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> submit() async {
      errorMessage.value = null;

      if (formKey.currentState?.validate() != true) return;

      final url = parseValidatedUrl(
        textController.text,
        eagerParsing: true,
        onlyHttpProtocol: true,
      );
      if (url == null) return;

      isLoading.value = true;

      try {
        final service = ref.read(wanderSourceServiceProvider);
        final consoleUrl = await service.addConsoleFromUrl(url);

        if (!context.mounted) return;

        // Show the snackbar first so it's anchored to a still-mounted context;
        // popping the dialog afterwards deactivates this BuildContext.
        showInfoMessage(context, 'Added console ${consoleUrl.host}');
        Navigator.of(context).pop();
      } on Exception catch (e) {
        if (!context.mounted) return;
        isLoading.value = false;
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    }

    return AlertDialog(
      title: const Text('Add Console'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the URL of a Wander console. '
              'The URL can point to the site root or the /wander/ path.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                label: Text('URL'),
                hintText: 'https://example.com/wander/',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: textController,
              keyboardType: TextInputType.url,
              autofocus: true,
              enabled: !isLoading.value,
              validator: (value) => validateUrl(
                value,
                onlyHttpProtocol: true,
                eagerParsing: true,
              ),
            ),
            if (errorMessage.value != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage.value!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: isLoading.value ? null : submit,
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
