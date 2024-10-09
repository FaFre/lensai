import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoEngineSettingsApi();

class GeckoEngineSettingsService {
  final GeckoEngineSettingsApi _api;

  GeckoEngineSettingsService({GeckoEngineSettingsApi? api})
      : _api = api ?? _apiInstance;

  Future<void> javaScriptEnabled(bool state) {
    return _api.javaScriptEnabled(state);
  }
}
