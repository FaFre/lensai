import 'package:flutter/material.dart';

class ErrorContainer extends StatelessWidget {
  final Widget content;

  const ErrorContainer({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.warning,
              size: 36,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }
}
