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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

final List<ContainerIconOption> _mdiContainerIconOptions = List.unmodifiable([
  for (final iconData in MdiIcons.values)
    if (iconData.mdiMetadata case final metadata?)
      ContainerIconOption(
        iconData: iconData,
        name: metadata.name,
        searchText: [
          metadata.name,
          ...?metadata.tags,
          ...?metadata.styles,
        ].join(' ').toLowerCase(),
      ),
]);

class ContainerIconPickerSheet extends HookWidget {
  const ContainerIconPickerSheet({
    required this.selectedColor,
    required this.selectedIcon,
    required this.onSelected,
    this.useCustomColor = false,
    super.key,
  });

  final Color selectedColor;
  final IconData selectedIcon;
  final bool useCustomColor;
  final ValueChanged<IconData> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = ContainerColors.palette(
      context,
      selectedColor,
      useCustomColor: useCustomColor,
    );
    final searchController = useTextEditingController();
    useListenable(searchController);

    final query = searchController.text.trim().toLowerCase();
    final filteredIcons = useMemoized(() {
      if (query.isEmpty) {
        return _mdiContainerIconOptions;
      }

      return _mdiContainerIconOptions
          .where((icon) => icon.searchText.contains(query))
          .toList(growable: false);
    }, [query]);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              const SheetDragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Icon',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '${filteredIcons.length} mdi icons',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: palette.avatarBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: palette.outlineColor,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        selectedIcon,
                        color: palette.avatarForegroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBar(
                  controller: searchController,
                  hintText: 'Search MDI icons',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: searchController.clear,
                        icon: const Icon(Icons.close),
                      ),
                  ],
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.surfaceContainerHigh,
                  ),
                ),
              ),
              Expanded(
                child: filteredIcons.isEmpty
                    ? Center(
                        child: Text(
                          'No icons found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final columnCount = (constraints.maxWidth / 76)
                              .floor()
                              .clamp(4, 7);

                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: filteredIcons.length,
                            itemBuilder: (context, index) {
                              final option = filteredIcons[index];
                              final isSelected =
                                  option.iconData == selectedIcon;

                              return Tooltip(
                                message: option.name,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => onSelected(option.iconData),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? palette.surfaceHighColor
                                            : theme
                                                  .colorScheme
                                                  .surfaceContainer,
                                        borderRadius: BorderRadius.circular(18),
                                        border: isSelected
                                            ? Border.all(
                                                color: palette.outlineColor,
                                                width: 2,
                                              )
                                            : Border.all(
                                                color: theme
                                                    .colorScheme
                                                    .outlineVariant
                                                    .withValues(alpha: 0.35),
                                              ),
                                      ),
                                      child: Icon(
                                        option.iconData,
                                        color: isSelected
                                            ? palette.avatarForegroundColor
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
