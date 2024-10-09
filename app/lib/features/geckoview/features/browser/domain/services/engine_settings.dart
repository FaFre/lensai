import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'engine_settings.g.dart';

@Riverpod(keepAlive: true)
GeckoEngineSettingsService engineSettingsService(EngineSettingsServiceRef ref) {
  return GeckoEngineSettingsService();
}
