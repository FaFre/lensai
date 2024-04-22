Uri? tryParseUrl(String? input) {
  if (input != null) {
    final uri = Uri.tryParse(input);
    if (uri != null &&
        uri.hasAuthority &&
        (uri.isScheme('http') || uri.isScheme('https') || !uri.hasScheme)) {
      return uri;
    }
  }

  return null;
}
