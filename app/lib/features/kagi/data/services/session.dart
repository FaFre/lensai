import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

@Riverpod()
class KagiSessionService extends _$KagiSessionService {
  final _cookieManager = GeckoCookieService();

  Future<void> setKagiSession(String session) async {
    await _cookieManager.setCookie(
      url: Uri.https('kagi.com'),
      name: 'kagi_session',
      value: session,
      domain: Uri.https('kagi.com'),
      httpOnly: true,
      secure: true,
      sameSite: CookieSameSiteStatus.lax,
    );
  }

  @override
  void build() {}
}
