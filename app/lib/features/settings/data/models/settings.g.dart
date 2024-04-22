// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingsCWProxy {
  Settings kagiSession(String? kagiSession);

  Settings incognitoMode(bool incognitoMode);

  Settings enableJavascript(bool enableJavascript);

  Settings launchUrlExternal(bool launchUrlExternal);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({
    String? kagiSession,
    bool? incognitoMode,
    bool? enableJavascript,
    bool? launchUrlExternal,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSettings.copyWith.fieldName(...)`
class _$SettingsCWProxyImpl implements _$SettingsCWProxy {
  const _$SettingsCWProxyImpl(this._value);

  final Settings _value;

  @override
  Settings kagiSession(String? kagiSession) => this(kagiSession: kagiSession);

  @override
  Settings incognitoMode(bool incognitoMode) =>
      this(incognitoMode: incognitoMode);

  @override
  Settings enableJavascript(bool enableJavascript) =>
      this(enableJavascript: enableJavascript);

  @override
  Settings launchUrlExternal(bool launchUrlExternal) =>
      this(launchUrlExternal: launchUrlExternal);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({
    Object? kagiSession = const $CopyWithPlaceholder(),
    Object? incognitoMode = const $CopyWithPlaceholder(),
    Object? enableJavascript = const $CopyWithPlaceholder(),
    Object? launchUrlExternal = const $CopyWithPlaceholder(),
  }) {
    return Settings(
      kagiSession: kagiSession == const $CopyWithPlaceholder()
          ? _value.kagiSession
          // ignore: cast_nullable_to_non_nullable
          : kagiSession as String?,
      incognitoMode:
          incognitoMode == const $CopyWithPlaceholder() || incognitoMode == null
              ? _value.incognitoMode
              // ignore: cast_nullable_to_non_nullable
              : incognitoMode as bool,
      enableJavascript: enableJavascript == const $CopyWithPlaceholder() ||
              enableJavascript == null
          ? _value.enableJavascript
          // ignore: cast_nullable_to_non_nullable
          : enableJavascript as bool,
      launchUrlExternal: launchUrlExternal == const $CopyWithPlaceholder() ||
              launchUrlExternal == null
          ? _value.launchUrlExternal
          // ignore: cast_nullable_to_non_nullable
          : launchUrlExternal as bool,
    );
  }
}

extension $SettingsCopyWith on Settings {
  /// Returns a callable class that can be used as follows: `instanceOfSettings.copyWith(...)` or like so:`instanceOfSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SettingsCWProxy get copyWith => _$SettingsCWProxyImpl(this);
}
