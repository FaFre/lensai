import 'package:html/parser.dart' as html_parser;
import 'package:markdown/markdown.dart' as md;

String markdownToText(String markdown) {
  final html = md.markdownToHtml(markdown);
  final document = html_parser.parse(html);

  return document.body?.text ?? '';
}
