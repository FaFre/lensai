import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/entities/readerable_state.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/readerview/domain/providers/readerable.dart';

class ReaderAppearanceButton extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonVisible = ref.watch(
      appearanceButtonVisibilityProvider
          .select((value) => value.valueOrNull ?? false),
    );

    final readerabilityState = ref.watch(
      selectedTabStateProvider.select(
        (state) => state?.readerableState ?? ReaderableState.$default(),
      ),
    );

    return Visibility(
      visible: readerabilityState.active && buttonVisible,
      child: FloatingActionButton(
        onPressed: () async {
          await ref.read(readerableServiceProvider).onAppearanceButtonTap();
        },
        child: const Icon(MdiIcons.formatFont),
      ),
    );
  }
}
