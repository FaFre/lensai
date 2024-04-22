import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

void useOnInitialization(FutureOr<void> Function() callback) {
  useEffect(
    () {
      Future.microtask(callback);
      return null;
    },
    [],
  );
}
