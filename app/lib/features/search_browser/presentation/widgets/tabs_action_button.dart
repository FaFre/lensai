import 'package:bang_navigator/features/web_view/domain/repositories/web_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TabsActionButton extends HookConsumerWidget {
  final VoidCallback onTap;

  const TabsActionButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabCount =
        ref.watch(webViewRepositoryProvider.select((tabs) => tabs.length));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          top: 15.0,
          right: 10.0,
          bottom: 15.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(5.0),
          ),
          constraints: const BoxConstraints(minWidth: 25.0),
          child: Center(
            child: Text(
              tabCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
