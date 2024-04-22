import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

@Riverpod()
class SessionService extends _$SessionService {
  final _cookieManager = CookieManager.instance();

  Future<void> setKagiSession(String session) async {
    await _cookieManager.setCookie(
      url: WebUri.uri(Uri.https('kagi.com')),
      name: 'kagi_session',
      value: session,
      domain: 'kagi.com',
      isHttpOnly: true,
      isSecure: true,
      sameSite: HTTPCookieSameSitePolicy.LAX,
    );
  }

  Future<void> clearAllData() async {
    await _cookieManager.deleteAllCookies();

    final webViewLoaded = Completer<void>();
    final headlessWebView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(
        //Clears all data on (just) Android
        incognito: true,
        //Clear other stuff
        clearCache: true,
        clearSessionCache: true,
      ),
      onWebViewCreated: (controller) {
        //wait until settings are applied for sure
        webViewLoaded.complete();
      },
    );

    unawaited(headlessWebView.run());

    await webViewLoaded.future.whenComplete(() => headlessWebView..dispose());
  }

  void initializationDone() {
    state = true;
  }

  @override
  bool build() => false;
}
