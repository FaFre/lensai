import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useCachedFuture<T>(
  Future<T> Function() valueBuilder,
) {
  // ignore: discarded_futures
  final cachedFuture = useMemoized(
    valueBuilder,
  );
  return useFuture(cachedFuture);
}
