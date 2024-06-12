import 'package:flutter/material.dart';

class ButtonListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? content;

  final Widget button;

  const ButtonListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.content,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                if (content != null) content!,
              ],
            ),
          ),
          button,
        ],
      ),
    );
  }
}
