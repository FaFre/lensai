import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:lensai/core/http_error_handler.dart';
import 'package:lensai/domain/entities/web_page_info.dart';
import 'package:lensai/extensions/web_uri_favicon.dart';
import 'package:lensai/features/web_view/utils/favicon_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_io/io.dart';

part 'generic_website.g.dart';

@Riverpod(keepAlive: true)
class GenericWebsiteService extends _$GenericWebsiteService {
  late http.Client _client;
  final Map<String, bool> _httpsCache;

  GenericWebsiteService() : _httpsCache = {};

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
        final response =
            await _client.get(url).timeout(const Duration(seconds: 10));
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
            return _client
                .get(info.favicon!.url)
                .timeout(const Duration(seconds: 10))
                .then((response) {
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

  Future<Uri?> tryUpgradeToHttps(Uri httpUri) async {
    if (httpUri.isScheme('https')) {
      return httpUri;
    } else if (httpUri.isScheme('http')) {
      final cached = _httpsCache[httpUri.host];
      if (cached != null) {
        return cached ? httpUri.replace(scheme: 'https') : null;
      }

      var sslAvailable = false;

      try {
        final context = SecurityContext.defaultContext;

        final socket = await SecureSocket.connect(
          httpUri.host,
          443,
          context: context,
          timeout: const Duration(seconds: 3),
        );

        await socket.close();

        sslAvailable = true;
      } catch (_) {
        sslAvailable = false;
      }

      _httpsCache[httpUri.host] = sslAvailable;

      if (sslAvailable) {
        return httpUri.replace(scheme: 'https');
      }
    }

    return null;
  }
}
