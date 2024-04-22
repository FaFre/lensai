String? extractKagiSession(Uri uri) {
  if (uri.authority == 'kagi.com') {
    return uri.queryParameters['token'];
  }

  return null;
}
