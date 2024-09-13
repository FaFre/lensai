import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:lensai/core/uuid.dart';
import 'package:lensai/data/models/web_page_info.dart';

part 'web_view_page.g.dart';

typedef PageHistory = ({bool canGoBack, bool canGoForward});

@CopyWith()
class WebViewPage extends WebPageInfo with FastEquatable implements ITab {
  @override
  @CopyWithField(immutable: true)
  final String id;

  final InAppWebViewController? controller;

  // ignore: missing_field_in_equatable_props
  final SslError? sslError;

  @override
  final String? topicId;

  @override
  final Uint8List? screenshot;

  final PageHistory pageHistory;

  WebViewPage({
    required this.id,
    required this.controller,
    required super.url,
    required this.sslError,
    required super.title,
    required this.topicId,
    required super.favicon,
    required this.screenshot,
    required this.pageHistory,
  });

  WebViewPage.create({
    String? id,
    this.controller,
    required super.url,
    this.sslError,
    super.title,
    this.topicId,
    super.favicon,
    this.screenshot,
    this.pageHistory = (canGoBack: false, canGoForward: false),
  }) : id = id ?? uuid.v7();

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        id,
        controller,
        super.url,
        sslError?.toString(),
        title,
        topicId,
        favicon?.toString(),
        screenshot,
        pageHistory,
      ];
}
