// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TabStateCWProxy {
  TabState parentId(String? parentId);

  TabState contextId(String? contextId);

  TabState url(Uri url);

  TabState title(String? title);

  TabState icon(EquatableImage? icon);

  TabState tabMode(TabMode tabMode);

  TabState hasContentState(bool hasContentState);

  TabState isFullScreen(bool isFullScreen);

  TabState isLoading(bool isLoading);

  TabState showToolbarAsExpanded(bool showToolbarAsExpanded);

  TabState securityInfoState(SecurityState securityInfoState);

  TabState readerableState(ReaderableState readerableState);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TabState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TabState(...).copyWith(id: 12, name: "My name")
  /// ```
  TabState call({
    String? parentId,
    String? contextId,
    Uri url,
    String? title,
    EquatableImage? icon,
    TabMode tabMode,
    bool hasContentState,
    bool isFullScreen,
    bool isLoading,
    bool showToolbarAsExpanded,
    SecurityState securityInfoState,
    ReaderableState readerableState,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTabState.copyWith(...)` or call `instanceOfTabState.copyWith.fieldName(value)` for a single field.
class _$TabStateCWProxyImpl implements _$TabStateCWProxy {
  const _$TabStateCWProxyImpl(this._value);

  final TabState _value;

  @override
  TabState parentId(String? parentId) => call(parentId: parentId);

  @override
  TabState contextId(String? contextId) => call(contextId: contextId);

  @override
  TabState url(Uri url) => call(url: url);

  @override
  TabState title(String? title) => call(title: title);

  @override
  TabState icon(EquatableImage? icon) => call(icon: icon);

  @override
  TabState tabMode(TabMode tabMode) => call(tabMode: tabMode);

  @override
  TabState hasContentState(bool hasContentState) =>
      call(hasContentState: hasContentState);

  @override
  TabState isFullScreen(bool isFullScreen) => call(isFullScreen: isFullScreen);

  @override
  TabState isLoading(bool isLoading) => call(isLoading: isLoading);

  @override
  TabState showToolbarAsExpanded(bool showToolbarAsExpanded) =>
      call(showToolbarAsExpanded: showToolbarAsExpanded);

  @override
  TabState securityInfoState(SecurityState securityInfoState) =>
      call(securityInfoState: securityInfoState);

  @override
  TabState readerableState(ReaderableState readerableState) =>
      call(readerableState: readerableState);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TabState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TabState(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  TabState call({
    Object? parentId = const $CopyWithPlaceholder(),
    Object? contextId = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
    Object? tabMode = const $CopyWithPlaceholder(),
    Object? hasContentState = const $CopyWithPlaceholder(),
    Object? isFullScreen = const $CopyWithPlaceholder(),
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? showToolbarAsExpanded = const $CopyWithPlaceholder(),
    Object? securityInfoState = const $CopyWithPlaceholder(),
    Object? readerableState = const $CopyWithPlaceholder(),
  }) {
    return TabState._(
      id: _value.id,
      parentId: parentId == const $CopyWithPlaceholder()
          ? _value.parentId
          // ignore: cast_nullable_to_non_nullable
          : parentId as String?,
      contextId: contextId == const $CopyWithPlaceholder()
          ? _value.contextId
          // ignore: cast_nullable_to_non_nullable
          : contextId as String?,
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as Uri,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as EquatableImage?,
      tabMode: tabMode == const $CopyWithPlaceholder() || tabMode == null
          ? _value.tabMode
          // ignore: cast_nullable_to_non_nullable
          : tabMode as TabMode,
      hasContentState:
          hasContentState == const $CopyWithPlaceholder() ||
              hasContentState == null
          ? _value.hasContentState
          // ignore: cast_nullable_to_non_nullable
          : hasContentState as bool,
      isFullScreen:
          isFullScreen == const $CopyWithPlaceholder() || isFullScreen == null
          ? _value.isFullScreen
          // ignore: cast_nullable_to_non_nullable
          : isFullScreen as bool,
      isLoading: isLoading == const $CopyWithPlaceholder() || isLoading == null
          ? _value.isLoading
          // ignore: cast_nullable_to_non_nullable
          : isLoading as bool,
      showToolbarAsExpanded:
          showToolbarAsExpanded == const $CopyWithPlaceholder() ||
              showToolbarAsExpanded == null
          ? _value.showToolbarAsExpanded
          // ignore: cast_nullable_to_non_nullable
          : showToolbarAsExpanded as bool,
      securityInfoState:
          securityInfoState == const $CopyWithPlaceholder() ||
              securityInfoState == null
          ? _value.securityInfoState
          // ignore: cast_nullable_to_non_nullable
          : securityInfoState as SecurityState,
      readerableState:
          readerableState == const $CopyWithPlaceholder() ||
              readerableState == null
          ? _value.readerableState
          // ignore: cast_nullable_to_non_nullable
          : readerableState as ReaderableState,
    );
  }
}

extension $TabStateCopyWith on TabState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTabState.copyWith(...)` or `instanceOfTabState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TabStateCWProxy get copyWith => _$TabStateCWProxyImpl(this);
}
