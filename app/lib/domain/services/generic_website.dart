import 'package:bang_navigator/core/http_error_handler.dart';
import 'package:bang_navigator/domain/entities/web_page_info.dart';
import 'package:bang_navigator/extensions/web_uri_favicon.dart';
import 'package:bang_navigator/features/web_view/utils/favicon_helper.dart';
import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generic_website.g.dart';

@Riverpod(keepAlive: true)
class GenericWebsiteService extends _$GenericWebsiteService {
  late http.Client _client;

  @override
  void build() {
    _client = http.Client();
  }

  static Iterable<Favicon> _extractFavicons(Uri url, Document document) sync* {
    final links = document.querySelectorAll(
      'link[rel="icon"], link[rel="shortcut icon"], link[rel="apple-touch-icon"]',
    );

    for (final link in links) {
      final href = link.attributes['href'];
      if (href != null) {
        // Attempt to parse height and width if available
        int? height;
        int? width;
        if (link.attributes['sizes'] case final String sizes) {
          final dimensions = sizes.split('x');
          if (dimensions.length == 2) {
            height = int.tryParse(dimensions[0]);
            width = int.tryParse(dimensions[1]);
          }
        }

        yield Favicon(
          url: WebUri.uri(url.resolve(href)),
          rel: link.attributes['rel'],
          width: width,
          height: height,
        );
      }
    }
  }

  Future<Result<WebPageInfo>> getInfo(Uri url) async {
    return Result.fromAsync(
      () async {
        final response = await _client.get(url);
        return await compute(
          (args) {
            final document = html_parser.parse(args[0]);
            final url = Uri.parse(args[1]);

            final title = document.querySelector('title')?.text;
            final favicon = choseFavicon(_extractFavicons(url, document)) ??
                //In case the icon can not get extracted, we use the resolver
                //of duckduckgo
                Favicon(
                  url: WebUri.uri(url.genericFavicon()),
                );

            return WebPageInfo(url: url, title: title, favicon: favicon)
                .toJson();
          },
          [response.body, url.toString()],
        ).then(WebPageInfo.fromJson);
      },
      exceptionHandler: handleHttpError,
    );
  }

  Future<Result<Uint8List?>> getFaviconBytes(Uri url) {
    return getInfo(url).then(
      (result) => result.flatMapAsync(
        (info) async {
          if (info.favicon != null) {
            return _client.get(info.favicon!.url).then((response) {
              if (response.statusCode == 200) {
                return response.bodyBytes;
              } else {
                return null;
              }
            });
          }

          return null;
        },
        exceptionHandler: handleHttpError,
      ),
    );
  }
}
