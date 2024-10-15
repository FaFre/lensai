import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/entities/readerable_state.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:lensai/presentation/widgets/animate_gradient_shader.dart';

class ReaderButton extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final readerChanging = ref.watch(readerableScreenControllerProvider);

    final readerabilityState = ref.watch(
      selectedTabStateProvider.select(
        (state) => state?.readerableState ?? ReaderableState.$default(),
      ),
    );

    final icon = useMemoized(
      () => readerabilityState.active
          ? Icon(
              MdiIcons.bookOpen,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(
              MdiIcons.bookOpenOutline,
              color: Colors.white,
            ),
      [readerabilityState.active],
    );

    return Visibility(
      visible: readerabilityState.readerable,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 8.0,
        ),
        child: readerChanging.when(
          data: (_) => Visibility(
            visible: readerabilityState.readerable,
            child: InkWell(
              onTap: readerChanging.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(readerableScreenControllerProvider.notifier)
                          .toggleReaderView(!readerabilityState.active);
                    },
              child: icon,
            ),
          ),
          error: (error, stackTrace) => SizedBox.shrink(),
          loading: () => AnimateGradientShader(
            duration: const Duration(milliseconds: 500),
            primaryEnd: Alignment.bottomLeft,
            secondaryEnd: Alignment.topRight,
            primaryColors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
            secondaryColors: [
              colorScheme.secondary,
              colorScheme.secondaryContainer,
            ],
            child: icon,
          ),
        ),
      ),
    );
  }
}
