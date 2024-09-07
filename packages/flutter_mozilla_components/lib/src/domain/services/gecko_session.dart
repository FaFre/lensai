import 'package:flutter_mozilla_components/src/data/models/load_url_flags.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

class GeckoSessionService {
  final String? tabId;
  final GeckoSessionApi _api;

  GeckoSessionService.forCurrentTab({GeckoSessionApi? api})
      : _api = api ?? GeckoSessionApi(),
        tabId = null;

  GeckoSessionService({required String this.tabId, GeckoSessionApi? api})
      : _api = api ?? GeckoSessionApi();

  Future<void> loadUrl({
    required Uri url,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Map<String, String>? additionalHeaders,
  }) {
    return _api.loadUrl(
      tabId: tabId,
      url: url.toString(),
      flags: flags.toValue(),
      additionalHeaders: additionalHeaders,
    );
  }

  Future<void> loadData({
    required String data,
    required String mimeType,
    String encoding = "UTF-8",
  }) {
    return _api.loadData(
      tabId: tabId,
      data: data,
      mimeType: mimeType,
      encoding: encoding,
    );
  }

  Future<void> reload({LoadUrlFlags flags = LoadUrlFlags.NONE}) {
    return _api.reload(
      tabId: tabId,
      flags: flags.toValue(),
    );
  }

  Future<void> stopLoading() {
    return _api.stopLoading(tabId: tabId);
  }

  Future<void> goBack({bool userInteraction = true}) {
    return _api.goBack(
      tabId: tabId,
      userInteraction: userInteraction,
    );
  }

  Future<void> goForward({bool userInteraction = true}) {
    return _api.goForward(
      tabId: tabId,
      userInteraction: userInteraction,
    );
  }

  Future<void> goToHistoryIndex({required int index}) {
    return _api.goToHistoryIndex(
      index: index,
      tabId: tabId,
    );
  }

  Future<void> requestDesktopSite({required bool enable}) {
    return _api.requestDesktopSite(
      enable: enable,
      tabId: tabId,
    );
  }

  Future<void> exitFullscreen() {
    return _api.exitFullscreen(tabId: tabId);
  }

  Future<void> saveToPdf() {
    return _api.saveToPdf(tabId: tabId);
  }

  Future<void> printContent() {
    return _api.printContent(tabId: tabId);
  }

  Future<void> translate({
    required String fromLanguage,
    required String toLanguage,
    TranslationOptions? options,
  }) {
    return _api.translate(
      tabId: tabId,
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
      options: options,
    );
  }

  Future<void> translateRestore() {
    return _api.translateRestore(tabId: tabId);
  }

  Future<void> crashRecovery({
    List<String>? tabIds,
  }) {
    return _api.crashRecovery(tabIds: tabIds);
  }

  Future<void> purgeHistory() {
    return _api.purgeHistory();
  }

  Future<void> updateLastAccess({
    String? tabId, //If null = current tab
    DateTime? lastAccess, //If null datetime.now
  }) {
    return _api.updateLastAccess(
      tabId: tabId,
      lastAccess: (lastAccess ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }
}
