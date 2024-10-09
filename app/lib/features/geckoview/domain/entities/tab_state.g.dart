// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TabStateCWProxy {
  TabState contextId(String? contextId);

  TabState url(Uri url);

  TabState title(String title);

  TabState icon(EquatableImage? icon);

  TabState thumbnail(EquatableImage? thumbnail);

  TabState progress(int progress);

  TabState isPrivate(bool isPrivate);

  TabState isFullScreen(bool isFullScreen);

  TabState isLoading(bool isLoading);

  TabState securityInfoState(SecurityState securityInfoState);

  TabState historyState(HistoryState historyState);

  TabState readerableState(ReaderableState readerableState);

  TabState findResultState(FindResultState findResultState);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TabState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TabState(...).copyWith(id: 12, name: "My name")
  /// ````
  TabState call({
    String? contextId,
    Uri? url,
    String? title,
    EquatableImage? icon,
    EquatableImage? thumbnail,
    int? progress,
    bool? isPrivate,
    bool? isFullScreen,
    bool? isLoading,
    SecurityState? securityInfoState,
    HistoryState? historyState,
    ReaderableState? readerableState,
    FindResultState? findResultState,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTabState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTabState.copyWith.fieldName(...)`
class _$TabStateCWProxyImpl implements _$TabStateCWProxy {
  const _$TabStateCWProxyImpl(this._value);

  final TabState _value;

  @override
  TabState contextId(String? contextId) => this(contextId: contextId);

  @override
  TabState url(Uri url) => this(url: url);

  @override
  TabState title(String title) => this(title: title);

  @override
  TabState icon(EquatableImage? icon) => this(icon: icon);

  @override
  TabState thumbnail(EquatableImage? thumbnail) => this(thumbnail: thumbnail);

  @override
  TabState progress(int progress) => this(progress: progress);

  @override
  TabState isPrivate(bool isPrivate) => this(isPrivate: isPrivate);

  @override
  TabState isFullScreen(bool isFullScreen) => this(isFullScreen: isFullScreen);

  @override
  TabState isLoading(bool isLoading) => this(isLoading: isLoading);

  @override
  TabState securityInfoState(SecurityState securityInfoState) =>
      this(securityInfoState: securityInfoState);

  @override
  TabState historyState(HistoryState historyState) =>
      this(historyState: historyState);

  @override
  TabState readerableState(ReaderableState readerableState) =>
      this(readerableState: readerableState);

  @override
  TabState findResultState(FindResultState findResultState) =>
      this(findResultState: findResultState);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TabState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TabState(...).copyWith(id: 12, name: "My name")
  /// ````
  TabState call({
    Object? contextId = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
    Object? thumbnail = const $CopyWithPlaceholder(),
    Object? progress = const $CopyWithPlaceholder(),
    Object? isPrivate = const $CopyWithPlaceholder(),
    Object? isFullScreen = const $CopyWithPlaceholder(),
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? securityInfoState = const $CopyWithPlaceholder(),
    Object? historyState = const $CopyWithPlaceholder(),
    Object? readerableState = const $CopyWithPlaceholder(),
    Object? findResultState = const $CopyWithPlaceholder(),
  }) {
    return TabState(
      id: _value.id,
      contextId: contextId == const $CopyWithPlaceholder()
          ? _value.contextId
          // ignore: cast_nullable_to_non_nullable
          : contextId as String?,
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as Uri,
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as EquatableImage?,
      thumbnail: thumbnail == const $CopyWithPlaceholder()
          ? _value.thumbnail
          // ignore: cast_nullable_to_non_nullable
          : thumbnail as EquatableImage?,
      progress: progress == const $CopyWithPlaceholder() || progress == null
          ? _value.progress
          // ignore: cast_nullable_to_non_nullable
          : progress as int,
      isPrivate: isPrivate == const $CopyWithPlaceholder() || isPrivate == null
          ? _value.isPrivate
          // ignore: cast_nullable_to_non_nullable
          : isPrivate as bool,
      isFullScreen:
          isFullScreen == const $CopyWithPlaceholder() || isFullScreen == null
              ? _value.isFullScreen
              // ignore: cast_nullable_to_non_nullable
              : isFullScreen as bool,
      isLoading: isLoading == const $CopyWithPlaceholder() || isLoading == null
          ? _value.isLoading
          // ignore: cast_nullable_to_non_nullable
          : isLoading as bool,
      securityInfoState: securityInfoState == const $CopyWithPlaceholder() ||
              securityInfoState == null
          ? _value.securityInfoState
          // ignore: cast_nullable_to_non_nullable
          : securityInfoState as SecurityState,
      historyState:
          historyState == const $CopyWithPlaceholder() || historyState == null
              ? _value.historyState
              // ignore: cast_nullable_to_non_nullable
              : historyState as HistoryState,
      readerableState: readerableState == const $CopyWithPlaceholder() ||
              readerableState == null
          ? _value.readerableState
          // ignore: cast_nullable_to_non_nullable
          : readerableState as ReaderableState,
      findResultState: findResultState == const $CopyWithPlaceholder() ||
              findResultState == null
          ? _value.findResultState
          // ignore: cast_nullable_to_non_nullable
          : findResultState as FindResultState,
    );
  }
}

extension $TabStateCopyWith on TabState {
  /// Returns a callable class that can be used as follows: `instanceOfTabState.copyWith(...)` or like so:`instanceOfTabState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TabStateCWProxy get copyWith => _$TabStateCWProxyImpl(this);
}
