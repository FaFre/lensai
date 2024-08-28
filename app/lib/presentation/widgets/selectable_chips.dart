import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';

class _BadgeWrapper extends StatelessWidget {
  final Widget child;
  final int? count;

  const _BadgeWrapper({required this.child, this.count});

  @override
  Widget build(BuildContext context) {
    return count != null
        ? Badge.count(
            count: count!,
            child: child,
          )
        : child;
  }
}

class SelectableChips<T extends S, S, K> extends StatelessWidget {
  final List<T> availableItems;
  final S? selectedItem;
  final int maxCount;
  final bool deleteIcon;

  final K Function(S item) itemId;
  final Widget Function(T item) itemLabel;
  final Widget? Function(T item)? itemAvatar;
  final int? Function(T item)? itemBadgeCount;

  final void Function(T item)? onSelected;
  final void Function(T item)? onDeleted;

  const SelectableChips({
    required this.itemId,
    required this.itemLabel,
    this.itemAvatar,
    this.itemBadgeCount,
    required this.availableItems,
    this.selectedItem,
    this.maxCount = 25,
    this.deleteIcon = true,
    this.onSelected,
    this.onDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var items = availableItems.take(maxCount).toList();
    if (selectedItem case final T selectedItem) {
      final selectedIndex = items.indexWhere(
        (item) => itemId(item) == itemId(selectedItem),
      );
      if (selectedIndex < 0) {
        items = [
          selectedItem,
          ...items,
        ];
      } else {
        items = [
          items.removeAt(selectedIndex),
          ...items,
        ];
      }
    }

    return FadingScroll(
      fadingSize: 15,
      builder: (context, controller) {
        return ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _BadgeWrapper(
                count: itemBadgeCount?.call(item),
                child: FilterChip(
                  selected: selectedItem != null &&
                      itemId(item) == itemId(selectedItem as S),
                  showCheckmark: false,
                  onSelected: (value) {
                    if (value) {
                      onSelected?.call(item);
                    } else {
                      onDeleted?.call(item);
                    }
                  },
                  onDeleted: deleteIcon
                      ? () {
                          onDeleted?.call(item);
                        }
                      : null,
                  label: itemLabel.call(item),
                  avatar: itemAvatar?.call(item),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
