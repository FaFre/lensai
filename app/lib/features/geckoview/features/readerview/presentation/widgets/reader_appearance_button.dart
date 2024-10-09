import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/readerview/domain/providers/readerable.dart';

class ReaderAppearanceButton extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonVisible = ref.watch(
      appearanceButtonVisibilityProvider
          .select((value) => value.valueOrNull ?? false),
    );

    return FloatingActionButton(
      onPressed: buttonVisible
          ? () async {
              await ref.read(readerableServiceProvider).onAppearanceButtonTap();
            }
          : null,
      child: const Icon(MdiIcons.formatFont),
    );
  }
}
