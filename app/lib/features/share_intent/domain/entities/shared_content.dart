import 'package:kagi_bang_bang/utils/uri_parser.dart' as uri_parser;

sealed class SharedContent {
  const SharedContent();

  factory SharedContent.parse(String content) {
    if (uri_parser.tryParseUrl(content) case final Uri uri) {
      return SharedUrl(uri);
    } else {
      return SharedText(content);
    }
  }
}

final class SharedUrl extends SharedContent {
  final Uri url;

  const SharedUrl(this.url);

  @override
  String toString() => url.toString();
}

final class SharedText extends SharedContent {
  final String text;

  const SharedText(this.text);

  @override
  String toString() => text;
}
