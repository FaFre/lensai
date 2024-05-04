import 'package:bang_navigator/domain/entities/web_page_info.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

part 'web_view_page.g.dart';

typedef PageHistory = ({bool canGoBack, bool canGoForward});

@CopyWith(constructor: '_')
class WebViewPage extends WebPageInfo with FastEquatable {
  @CopyWithField(immutable: true)
  final Key key;

  final InAppWebViewController? controller;

  // ignore: missing_field_in_equatable_props
  final SslError? sslError;
  final Uint8List? screenshot;
  final PageHistory pageHistory;

  WebViewPage({
    this.controller,
    required super.url,
    this.sslError,
    super.title,
    super.favicon,
    this.screenshot,
    this.pageHistory = (canGoBack: false, canGoForward: false),
  }) : key = GlobalKey();

  WebViewPage._({
    required this.key,
    required this.controller,
    required super.url,
    required this.sslError,
    required super.title,
    required super.favicon,
    required this.screenshot,
    required this.pageHistory,
  });

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        key,
        controller,
        url,
        sslError?.toString(),
        title,
        favicon?.toString(),
        screenshot,
        pageHistory,
      ];
}
