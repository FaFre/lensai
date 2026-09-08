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
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';

/// Matches the fixed itemExtent used by the main tab list
/// (`tab_list_view.dart`'s `_itemHeight`).
const double _itemExtent = 86.0;

/// Outcome of the parent picker sheet. Mirrors the
/// `ContainerSelectionResult` shape so the sheet can pop a discriminated
/// value rather than relying on sentinels or string conventions.
sealed class _ParentPickerSelection {
  const _ParentPickerSelection();
}

class _ParentPickerDetach extends _ParentPickerSelection {
  const _ParentPickerDetach();
}

class _ParentPickerSelected extends _ParentPickerSelection {
  final String parentTabId;
  const _ParentPickerSelected(this.parentTabId);
}

/// Modal bottom sheet that lets the user pick a new parent for [tabId],
/// or detach it from its current parent.
///
/// Candidates are all tabs in the moving tab's container, minus the moving
/// tab itself and its descendants (cycle guard). Tapping the persistent
/// "Make standalone" entry detaches the tab.
Future<void> showTabParentPicker({
  required BuildContext context,
  required WidgetRef ref,
  required String tabId,
}) async {
  // Capture the notifier synchronously: by the time the modal pops,
  // the calling widget (and its `ref`) may have unmounted, but the
  // Riverpod notifier itself is keepAlive and safe to use post-await.
  final repo = ref.read(tabDataRepositoryProvider.notifier);

  final selection = await showModalBottomSheet<_ParentPickerSelection>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _TabParentPickerSheet(tabId: tabId),
  );

  switch (selection) {
    case null:
      return;
    case _ParentPickerDetach():
      await repo.setTabParent(tabId: tabId, newParentId: null);
    case _ParentPickerSelected(:final parentTabId):
      await repo.setTabParent(tabId: tabId, newParentId: parentTabId);
  }
}

class _TabParentPickerSheet extends HookConsumerWidget {
  final String tabId;

  const _TabParentPickerSheet({required this.tabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movingTabAsync = ref.watch(watchTabDbDataProvider(tabId));
    final descendantsAsync = ref.watch(watchTabDescendantsProvider(tabId));

    return PointerScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return movingTabAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (movingTab) {
            if (movingTab == null) {
              return const Center(child: Text('Tab no longer exists'));
            }
            return descendantsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (descendants) {
                final excluded = descendants.keys.toSet()..add(tabId);
                final containerId = movingTab.containerId;
                final candidatesAsync = ref.watch(
                  watchContainerTabsDataProvider(containerId),
                );
                return candidatesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (tabs) {
                    final candidates = tabs
                        .where((t) => !excluded.contains(t.id))
                        .toList();
                    return CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        const SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Choose a parent tab',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: ListTile(
                            leading: const Icon(MdiIcons.fileTreeOutline),
                            title: const Text('Make standalone'),
                            subtitle: const Text('Detach from current parent'),
                            enabled: movingTab.parentId != null,
                            onTap: () => Navigator.of(
                              context,
                            ).pop(const _ParentPickerDetach()),
                          ),
                        ),
                        const SliverToBoxAdapter(child: Divider(height: 1)),
                        if (candidates.isEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No candidate tabs in this container.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          // Match the tab list view's fixed itemExtent.
                          // `ListTabPreview` has no intrinsic height — its
                          // thumbnail variant uses `BoxFit.fitHeight`, which
                          // needs a bounded parent or it sizes to the
                          // image's native dimensions and overflows.
                          SliverFixedExtentList.builder(
                            itemExtent: _itemExtent,
                            itemCount: candidates.length,
                            itemBuilder: (context, index) {
                              final candidate = candidates[index];
                              // `isActive` highlights the current parent
                              // with the same accent the tab list uses for
                              // the selected tab — semantically "this is
                              // the one you're currently nested under".
                              return ListTabPreview(
                                tabId: candidate.id,
                                isActive: candidate.id == movingTab.parentId,
                                onTap: () => Navigator.of(
                                  context,
                                ).pop(_ParentPickerSelected(candidate.id)),
                              );
                            },
                          ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 16),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
