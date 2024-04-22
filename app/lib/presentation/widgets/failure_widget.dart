import 'package:flutter/material.dart';

class FailureWidget extends StatelessWidget {
  const FailureWidget({
    super.key,
    this.title,
    this.exception,
    this.onRetry,
    this.compact = false,
  });

  final String? title;
  final Object? exception;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(title ?? 'Something went wrong'),
            subtitle: exception != null
                ? Text(exception.runtimeType.toString())
                : null,
            trailing: compact && onRetry != null
                ? IconButton.outlined(
                    onPressed: onRetry,
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.refresh_outlined),
                  )
                : null,
            textColor: Theme.of(context).colorScheme.error,
          ),
          if (!compact && onRetry != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  label: const Text('Retry'),
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
