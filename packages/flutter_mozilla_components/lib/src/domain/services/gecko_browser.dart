import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

class GeckoBrowserService {
  final GeckoBrowserApi _api;

  GeckoBrowserService({GeckoBrowserApi? api}) : _api = api ?? GeckoBrowserApi();

  Future<void> showNativeFragment() {
    return _api.showNativeFragment();
  }
}
