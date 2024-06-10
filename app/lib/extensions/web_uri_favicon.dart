extension UriFavicon on Uri {
  Uri genericFavicon() =>
      Uri.parse('https://icons.duckduckgo.com/ip3/$host.ico');
}
