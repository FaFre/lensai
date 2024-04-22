import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useOnDispose(VoidCallback onDispose) {
  useEffect(
    () {
      return onDispose;
    },
    const [],
  );
}
