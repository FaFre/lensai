// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

/// Describes a combination of flags provided to the engine when loading a URL.
class LoadUrlFlags {
  final int value;

  const LoadUrlFlags._(this.value);

  LoadUrlFlagsValue toValue() {
    return LoadUrlFlagsValue(value: value);
  }

  static const LoadUrlFlags NONE = LoadUrlFlags._(0);
  static const LoadUrlFlags BYPASS_CACHE = LoadUrlFlags._(1 << 0);
  static const LoadUrlFlags BYPASS_PROXY = LoadUrlFlags._(1 << 1);
  static const LoadUrlFlags EXTERNAL = LoadUrlFlags._(1 << 2);
  static const LoadUrlFlags ALLOW_POPUPS = LoadUrlFlags._(1 << 3);
  static const LoadUrlFlags BYPASS_CLASSIFIER = LoadUrlFlags._(1 << 4);
  static const LoadUrlFlags LOAD_FLAGS_FORCE_ALLOW_DATA_URI =
      LoadUrlFlags._(1 << 5);
  static const LoadUrlFlags LOAD_FLAGS_REPLACE_HISTORY = LoadUrlFlags._(1 << 6);
  static const LoadUrlFlags LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE =
      LoadUrlFlags._(1 << 7);
  static const LoadUrlFlags ALLOW_ADDITIONAL_HEADERS = LoadUrlFlags._(1 << 15);
  static const LoadUrlFlags ALLOW_JAVASCRIPT_URL = LoadUrlFlags._(1 << 16);

  static LoadUrlFlags ALL = LoadUrlFlags._(
    BYPASS_CACHE.value |
        BYPASS_PROXY.value |
        EXTERNAL.value |
        ALLOW_POPUPS.value |
        BYPASS_CLASSIFIER.value |
        LOAD_FLAGS_FORCE_ALLOW_DATA_URI.value |
        LOAD_FLAGS_REPLACE_HISTORY.value |
        LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE.value |
        ALLOW_ADDITIONAL_HEADERS.value |
        ALLOW_JAVASCRIPT_URL.value,
  );

  factory LoadUrlFlags.select(List<LoadUrlFlags> flags) {
    final combinedValue = flags.fold(0, (sum, flag) => sum | flag.value);
    return LoadUrlFlags._(combinedValue);
  }
}
