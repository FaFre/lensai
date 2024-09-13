// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_view_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebViewPageCWProxy {
  WebViewPage controller(InvalidType controller);

  WebViewPage url(Uri url);

  WebViewPage sslError(InvalidType sslError);

  WebViewPage title(String? title);

  WebViewPage topicId(String? topicId);

  WebViewPage favicon(BrowserIcon? favicon);

  WebViewPage screenshot(Uint8List? screenshot);

  WebViewPage pageHistory(({bool canGoBack, bool canGoForward}) pageHistory);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebViewPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebViewPage(...).copyWith(id: 12, name: "My name")
  /// ````
  WebViewPage call({
    InvalidType? controller,
    Uri? url,
    InvalidType? sslError,
    String? title,
    String? topicId,
    BrowserIcon? favicon,
    Uint8List? screenshot,
    ({bool canGoBack, bool canGoForward})? pageHistory,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWebViewPage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWebViewPage.copyWith.fieldName(...)`
class _$WebViewPageCWProxyImpl implements _$WebViewPageCWProxy {
  const _$WebViewPageCWProxyImpl(this._value);

  final WebViewPage _value;

  @override
  WebViewPage controller(InvalidType controller) =>
      this(controller: controller);

  @override
  WebViewPage url(Uri url) => this(url: url);

  @override
  WebViewPage sslError(InvalidType sslError) => this(sslError: sslError);

  @override
  WebViewPage title(String? title) => this(title: title);

  @override
  WebViewPage topicId(String? topicId) => this(topicId: topicId);

  @override
  WebViewPage favicon(BrowserIcon? favicon) => this(favicon: favicon);

  @override
  WebViewPage screenshot(Uint8List? screenshot) => this(screenshot: screenshot);

  @override
  WebViewPage pageHistory(({bool canGoBack, bool canGoForward}) pageHistory) =>
      this(pageHistory: pageHistory);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebViewPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebViewPage(...).copyWith(id: 12, name: "My name")
  /// ````
  WebViewPage call({
    Object? controller = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? sslError = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? topicId = const $CopyWithPlaceholder(),
    Object? favicon = const $CopyWithPlaceholder(),
    Object? screenshot = const $CopyWithPlaceholder(),
    Object? pageHistory = const $CopyWithPlaceholder(),
  }) {
    return WebViewPage(
      id: _value.id,
      controller:
          controller == const $CopyWithPlaceholder() || controller == null
              ? _value.controller
              // ignore: cast_nullable_to_non_nullable
              : controller as InvalidType,
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as Uri,
      sslError: sslError == const $CopyWithPlaceholder() || sslError == null
          ? _value.sslError
          // ignore: cast_nullable_to_non_nullable
          : sslError as InvalidType,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      topicId: topicId == const $CopyWithPlaceholder()
          ? _value.topicId
          // ignore: cast_nullable_to_non_nullable
          : topicId as String?,
      favicon: favicon == const $CopyWithPlaceholder()
          ? _value.favicon
          // ignore: cast_nullable_to_non_nullable
          : favicon as BrowserIcon?,
      screenshot: screenshot == const $CopyWithPlaceholder()
          ? _value.screenshot
          // ignore: cast_nullable_to_non_nullable
          : screenshot as Uint8List?,
      pageHistory:
          pageHistory == const $CopyWithPlaceholder() || pageHistory == null
              ? _value.pageHistory
              // ignore: cast_nullable_to_non_nullable
              : pageHistory as ({bool canGoBack, bool canGoForward}),
    );
  }
}

extension $WebViewPageCopyWith on WebViewPage {
  /// Returns a callable class that can be used as follows: `instanceOfWebViewPage.copyWith(...)` or like so:`instanceOfWebViewPage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebViewPageCWProxy get copyWith => _$WebViewPageCWProxyImpl(this);
}
