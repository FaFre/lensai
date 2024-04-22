import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebPageInfo {
  final Uri url;
  final String? title;
  final Favicon? favicon;

  WebPageInfo({
    required this.url,
    required this.title,
    required this.favicon,
  });

  factory WebPageInfo.fromJson(Map<String, dynamic> json) {
    return WebPageInfo(
      url: Uri.parse(json['url'] as String),
      title: json['title'] as String?,
      favicon: switch (json['favicon']) {
        final Map<String, dynamic> favicon => Favicon.fromMap(favicon),
        _ => null
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url.toString(),
      'title': title,
      'favicon': favicon?.toJson(),
    };
  }
}
