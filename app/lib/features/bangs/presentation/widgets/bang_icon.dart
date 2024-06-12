import 'package:bang_navigator/features/bangs/data/models/bang_data.dart';
import 'package:bang_navigator/features/bangs/domain/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BangIcon extends HookConsumerWidget {
  final double iconSize;
  final BangData bangData;

  const BangIcon(this.bangData, {this.iconSize = 34.0, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangAsync = ref.watch(bangDataEnsureIconProvider(bangData));
    final bang = bangAsync.valueOrNull ?? bangData;

    return Skeletonizer(
      enabled: bangAsync.isLoading,
      child: SizedBox.square(
        dimension: iconSize,
        child: (bang.iconData != null)
            ? Image.memory(
                bang.iconData!,
                height: iconSize,
                width: iconSize,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    MdiIcons.web,
                    size: iconSize,
                  );
                },
              )
            : Icon(
                MdiIcons.web,
                size: iconSize,
              ),
      ),
    );
  }
}
