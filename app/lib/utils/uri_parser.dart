Uri? tryParseUrl(String? input, {bool eagerParsing = false}) {
  if (input != null) {
    var uri = Uri.tryParse(input);
    if (uri != null) {
      if (uri.authority.isEmpty && eagerParsing) {
        //When there is no scheme, there will be no authority/host and all becomes a path
        //so we make sure there are at least 2 segments where the first one looks like a domain
        if (uri.pathSegments.length > 1 &&
            RegExp(r'.[a-z]{2,}$').hasMatch(uri.pathSegments.first)) {
          uri = Uri.tryParse('https://$input');
        }
      }

      if (uri != null &&
          uri.authority.isNotEmpty &&
          (uri.isScheme('http') || uri.isScheme('https') || !uri.hasScheme)) {
        return uri;
      }
    }
  }
  return null;
}
