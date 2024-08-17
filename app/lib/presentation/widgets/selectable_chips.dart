import 'package:flutter/material.dart';

class SelectableChips<T, K> extends StatelessWidget {
  final List<T> available;
  final T? selected;
  final int maxCount;

  final K Function(T item) itemId;
  final Widget Function(T item) itemLabel;
  final Widget Function(T item)? itemAvatar;

  final void Function(T item)? onSelected;
  final void Function(T item)? onDeleted;

  const SelectableChips({
    required this.itemId,
    required this.itemLabel,
    this.itemAvatar,
    required this.available,
    this.selected,
    this.maxCount = 25,
    this.onSelected,
    this.onDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var items = available.take(maxCount).toList();
    if (selected != null) {
      final selectedIndex = items.indexWhere(
          (item) => selected != null && itemId(item) == itemId(selected!));
      if (selectedIndex < 0) {
        items = [
          selected!,
          ...items,
        ];
      } else {
        items = [
          items.removeAt(selectedIndex),
          ...items,
        ];
      }
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            selected: selected != null && itemId(item) == itemId(selected!),
            showCheckmark: false,
            onSelected: (value) {
              if (value) {
                onSelected?.call(item);
              } else {
                onDeleted?.call(item);
              }
            },
            onDeleted: () {
              onDeleted?.call(item);
            },
            label: itemLabel.call(item),
            avatar: itemAvatar?.call(item),
          ),
        );
      },
    );
  }
}
