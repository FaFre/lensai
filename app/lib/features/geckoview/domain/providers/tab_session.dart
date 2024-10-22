import 'dart:typed_data';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_session.g.dart';

@Riverpod()
class TabSession extends _$TabSession {
  late GeckoSessionService _sessionService;

  Future<void> loadUrl({
    required Uri url,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Map<String, String>? additionalHeaders,
  }) {
    return _sessionService.loadUrl(
      url: url,
      flags: flags,
      additionalHeaders: additionalHeaders,
    );
  }

  Future<void> reload() {
    return _sessionService.reload();
  }

  Future<void> goBack() {
    return _sessionService.goBack();
  }

  Future<void> goForward() {
    return _sessionService.goForward();
  }

  Future<void> exitFullscreen() {
    return _sessionService.exitFullscreen();
  }

  Future<Uint8List?> requestScreenshot() {
    return _sessionService.requestScreenshot();
  }

  @override
  void build(String? tabId) {
    _sessionService = (tabId != null)
        ? GeckoSessionService(tabId: tabId)
        : GeckoSessionService.forActiveTab();
  }
}
