// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_page_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebPageInfoCWProxy {
  WebPageInfo url(Uri url);

  WebPageInfo title(String? title);

  WebPageInfo favicon(BrowserIcon? favicon);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebPageInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebPageInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  WebPageInfo call({
    Uri? url,
    String? title,
    BrowserIcon? favicon,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWebPageInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWebPageInfo.copyWith.fieldName(...)`
class _$WebPageInfoCWProxyImpl implements _$WebPageInfoCWProxy {
  const _$WebPageInfoCWProxyImpl(this._value);

  final WebPageInfo _value;

  @override
  WebPageInfo url(Uri url) => this(url: url);

  @override
  WebPageInfo title(String? title) => this(title: title);

  @override
  WebPageInfo favicon(BrowserIcon? favicon) => this(favicon: favicon);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebPageInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebPageInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  WebPageInfo call({
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? favicon = const $CopyWithPlaceholder(),
  }) {
    return WebPageInfo(
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as Uri,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      favicon: favicon == const $CopyWithPlaceholder()
          ? _value.favicon
          // ignore: cast_nullable_to_non_nullable
          : favicon as BrowserIcon?,
    );
  }
}

extension $WebPageInfoCopyWith on WebPageInfo {
  /// Returns a callable class that can be used as follows: `instanceOfWebPageInfo.copyWith(...)` or like so:`instanceOfWebPageInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebPageInfoCWProxy get copyWith => _$WebPageInfoCWProxyImpl(this);
}
