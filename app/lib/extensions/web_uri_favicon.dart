extension WebUriFavicon on Uri {
  Uri guessFavicon() => removeFragment().replace(
        path: 'favicon.ico',
        queryParameters: {},
      );
}
