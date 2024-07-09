import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final bool enabled;

  final String title;
  final String subtitle;
  final Widget? content;

  final Widget? prefix;
  final Widget? suffix;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.content,
    this.prefix,
    this.suffix,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleTextTheme = theme.textTheme.bodyMedium!
        .copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          if (prefix != null) prefix!,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: enabled
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.disabledColor),
                ),
                Text(
                  subtitle,
                  style: enabled
                      ? subtitleTextTheme
                      : theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.disabledColor),
                ),
                if (content != null) content!,
              ],
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
