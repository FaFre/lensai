import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lensai/core/uuid.dart';
import 'package:lensai/domain/entities/web_page_info.dart';
import 'package:lensai/features/web_view/domain/entities/abstract/tab.dart';

part 'web_view_page.g.dart';

typedef PageHistory = ({bool canGoBack, bool canGoForward});

@CopyWith(constructor: '_')
class WebViewPage extends WebPageInfo with FastEquatable implements ITab {
  @CopyWithField(immutable: true)
  final Key key;

  @override
  @CopyWithField(immutable: true)
  final String id;

  final InAppWebViewController? controller;

  // ignore: missing_field_in_equatable_props
  final SslError? sslError;

  @override
  final Uint8List? screenshot;

  final PageHistory pageHistory;

  WebViewPage({
    String? id,
    this.controller,
    required super.url,
    this.sslError,
    super.title,
    super.favicon,
    this.screenshot,
    this.pageHistory = (canGoBack: false, canGoForward: false),
  })  : key = GlobalKey(),
        id = id ?? uuid.v7();

  WebViewPage._({
    required this.key,
    required this.id,
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
        id,
        controller,
        super.url,
        sslError?.toString(),
        title,
        favicon?.toString(),
        screenshot,
        pageHistory,
      ];
}
