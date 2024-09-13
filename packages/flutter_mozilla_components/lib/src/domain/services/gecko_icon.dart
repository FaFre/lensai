import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoIconsApi();

class GeckoIconService {
  final GeckoIconsApi _api;

  GeckoIconService({GeckoIconsApi? api}) : _api = api ?? _apiInstance;

  Future<IconResult> loadIcon(
      {required Uri url, List<Resource> resources = const []}) async {
    return _api.loadIcon(IconRequest(
      url: url.toString(),
      size: IconSize.defaultSize,
      resources: resources,
      isPrivate: false,
      waitOnNetworkLoad: true,
    ));
  }
}
