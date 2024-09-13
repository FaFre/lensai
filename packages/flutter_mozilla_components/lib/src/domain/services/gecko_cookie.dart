import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoCookieApi();

class GeckoCookieService {
  final GeckoCookieApi _api;

  GeckoCookieService({GeckoCookieApi? api}) : _api = api ?? _apiInstance;

  Future<Cookie> getCookie({
    Uri? firstPartyDomain,
    required String name,
    String? partitionKey,
    String? storeId,
    required Uri url,
  }) {
    return _api.getCookie(
      firstPartyDomain?.host,
      name,
      (partitionKey != null)
          ? CookiePartitionKey(topLevelSite: partitionKey)
          : null,
      storeId,
      url.toString(),
    );
  }

  Future<List<Cookie>> getAllCookies({
    Uri? domain,
    Uri? firstPartyDomain,
    String? name,
    String? partitionKey,
    String? storeId,
    required Uri url,
  }) {
    return _api
        .getAllCookies(
          domain?.host,
          firstPartyDomain?.host,
          name,
          (partitionKey != null)
              ? CookiePartitionKey(topLevelSite: partitionKey)
              : null,
          storeId,
          url.toString(),
        )
        .then((value) => value.nonNulls.toList());
  }

  Future<void> setCookie({
    Uri? domain,
    int? expirationDate,
    Uri? firstPartyDomain,
    bool? httpOnly,
    String? name,
    String? partitionKey,
    String? path,
    CookieSameSiteStatus? sameSite,
    bool? secure,
    String? storeId,
    required Uri url,
    String? value,
  }) {
    return _api.setCookie(
      domain?.host,
      expirationDate,
      firstPartyDomain?.host,
      httpOnly,
      name,
      (partitionKey != null)
          ? CookiePartitionKey(topLevelSite: partitionKey)
          : null,
      path,
      sameSite,
      secure,
      storeId,
      url.toString(),
      value,
    );
  }

  Future<void> removeCookie({
    Uri? firstPartyDomain,
    required String name,
    String? partitionKey,
    String? storeId,
    required Uri url,
  }) {
    return _api.removeCookie(
      firstPartyDomain?.host,
      name,
      (partitionKey != null)
          ? CookiePartitionKey(topLevelSite: partitionKey)
          : null,
      storeId,
      url.toString(),
    );
  }
}
