import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:lensai/features/geckoview/domain/entities/tab_state.dart';
import 'package:text_scroll/text_scroll.dart';

class AppBarTitle extends StatelessWidget {
  final TabState tab;

  final void Function()? onTap;

  const AppBarTitle({required this.tab, this.onTap, super.key});

  Icon _securityStatusIcon(BuildContext context) {
    if (tab.url.isScheme('http')) {
      return Icon(
        MdiIcons.lockOff,
        color: Theme.of(context).colorScheme.error,
        size: 14,
      );
    } else if (!tab.securityInfoState.secure) {
      return Icon(
        MdiIcons.lockAlert,
        color: Theme.of(context).colorScheme.errorContainer,
        size: 14,
      );
    } else {
      return const Icon(
        MdiIcons.lock,
        size: 14,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          RawImage(
            image: tab.icon?.value,
            height: 16,
            width: 16,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextScroll(
                  key: ValueKey(tab.title),
                  tab.title,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurface),
                  // mode: TextScrollMode.bouncing,
                  velocity: const Velocity(pixelsPerSecond: Offset(75, 0)),
                  delayBefore: const Duration(milliseconds: 500),
                  pauseBetween: const Duration(milliseconds: 5000),
                  fadedBorder: true,
                  fadeBorderSide: FadeBorderSide.right,
                  fadedBorderWidth: 0.05,
                  intervalSpaces: 4,
                  numberOfReps: 2,
                ),
                Row(
                  children: [
                    _securityStatusIcon(context),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text(
                        tab.url.authority,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
