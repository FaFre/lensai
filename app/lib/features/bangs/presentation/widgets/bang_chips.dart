import 'package:flutter/material.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_icon.dart';

class BangChips extends StatelessWidget {
  final List<BangData> availableBangs;
  final BangData? selectedBang;
  final int maxBangCount;

  final void Function(String trigger)? onSelected;
  final void Function(String trigger)? onDeleted;

  const BangChips({
    required this.availableBangs,
    this.selectedBang,
    this.maxBangCount = 25,
    this.onSelected,
    this.onDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var bangs = availableBangs.take(maxBangCount).toList();
    if (selectedBang != null) {
      final selectedIndex =
          bangs.indexWhere((bang) => bang.trigger == selectedBang?.trigger);
      if (selectedIndex < 0) {
        bangs = [
          selectedBang!,
          ...bangs,
        ];
      } else {
        bangs = [
          bangs.removeAt(selectedIndex),
          ...bangs,
        ];
      }
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: bangs.length,
      itemBuilder: (context, index) {
        final bang = bangs[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            selected: bang.trigger == selectedBang?.trigger,
            showCheckmark: false,
            onSelected: (value) {
              if (value) {
                onSelected?.call(bang.trigger);
              } else {
                onDeleted?.call(bang.trigger);
              }
            },
            onDeleted: () {
              onDeleted?.call(bang.trigger);
            },
            avatar: BangIcon(bang, iconSize: 20),
            label: Text(bang.websiteName),
          ),
        );
      },
    );
  }
}
