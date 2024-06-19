enum HostSource {
  stevenBlackUnified(
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts',
  ),
  stevenBlackFakeNews(
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts',
  ),
  stevenBlackSocial(
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social-only/hosts',
  ),
  stevenBlackGambling(
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts',
  ),
  stevenBlackPorn(
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts',
  );

  final String url;

  const HostSource(this.url);
}
