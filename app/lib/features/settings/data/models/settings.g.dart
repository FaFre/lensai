// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingsCWProxy {
  Settings kagiSession(String? kagiSession);

  Settings showEarlyAccessFeatures(bool showEarlyAccessFeatures);

  Settings incognitoMode(bool incognitoMode);

  Settings enableJavascript(bool enableJavascript);

  Settings launchUrlExternal(bool launchUrlExternal);

  Settings blockHttpProtocol(bool blockHttpProtocol);

  Settings themeMode(ThemeMode themeMode);

  Settings quickAction(KagiTool? quickAction);

  Settings quickActionVoiceInput(bool quickActionVoiceInput);

  Settings enableReadability(bool enableReadability);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({
    String? kagiSession,
    bool? showEarlyAccessFeatures,
    bool? incognitoMode,
    bool? enableJavascript,
    bool? launchUrlExternal,
    bool? blockHttpProtocol,
    ThemeMode? themeMode,
    KagiTool? quickAction,
    bool? quickActionVoiceInput,
    bool? enableReadability,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSettings.copyWith.fieldName(...)`
class _$SettingsCWProxyImpl implements _$SettingsCWProxy {
  const _$SettingsCWProxyImpl(this._value);

  final Settings _value;

  @override
  Settings kagiSession(String? kagiSession) => this(kagiSession: kagiSession);

  @override
  Settings showEarlyAccessFeatures(bool showEarlyAccessFeatures) =>
      this(showEarlyAccessFeatures: showEarlyAccessFeatures);

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
  Settings blockHttpProtocol(bool blockHttpProtocol) =>
      this(blockHttpProtocol: blockHttpProtocol);

  @override
  Settings themeMode(ThemeMode themeMode) => this(themeMode: themeMode);

  @override
  Settings quickAction(KagiTool? quickAction) => this(quickAction: quickAction);

  @override
  Settings quickActionVoiceInput(bool quickActionVoiceInput) =>
      this(quickActionVoiceInput: quickActionVoiceInput);

  @override
  Settings enableReadability(bool enableReadability) =>
      this(enableReadability: enableReadability);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({
    Object? kagiSession = const $CopyWithPlaceholder(),
    Object? showEarlyAccessFeatures = const $CopyWithPlaceholder(),
    Object? incognitoMode = const $CopyWithPlaceholder(),
    Object? enableJavascript = const $CopyWithPlaceholder(),
    Object? launchUrlExternal = const $CopyWithPlaceholder(),
    Object? blockHttpProtocol = const $CopyWithPlaceholder(),
    Object? themeMode = const $CopyWithPlaceholder(),
    Object? quickAction = const $CopyWithPlaceholder(),
    Object? quickActionVoiceInput = const $CopyWithPlaceholder(),
    Object? enableReadability = const $CopyWithPlaceholder(),
  }) {
    return Settings(
      kagiSession: kagiSession == const $CopyWithPlaceholder()
          ? _value.kagiSession
          // ignore: cast_nullable_to_non_nullable
          : kagiSession as String?,
      showEarlyAccessFeatures:
          showEarlyAccessFeatures == const $CopyWithPlaceholder() ||
                  showEarlyAccessFeatures == null
              ? _value.showEarlyAccessFeatures
              // ignore: cast_nullable_to_non_nullable
              : showEarlyAccessFeatures as bool,
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
      blockHttpProtocol: blockHttpProtocol == const $CopyWithPlaceholder() ||
              blockHttpProtocol == null
          ? _value.blockHttpProtocol
          // ignore: cast_nullable_to_non_nullable
          : blockHttpProtocol as bool,
      themeMode: themeMode == const $CopyWithPlaceholder() || themeMode == null
          ? _value.themeMode
          // ignore: cast_nullable_to_non_nullable
          : themeMode as ThemeMode,
      quickAction: quickAction == const $CopyWithPlaceholder()
          ? _value.quickAction
          // ignore: cast_nullable_to_non_nullable
          : quickAction as KagiTool?,
      quickActionVoiceInput:
          quickActionVoiceInput == const $CopyWithPlaceholder() ||
                  quickActionVoiceInput == null
              ? _value.quickActionVoiceInput
              // ignore: cast_nullable_to_non_nullable
              : quickActionVoiceInput as bool,
      enableReadability: enableReadability == const $CopyWithPlaceholder() ||
              enableReadability == null
          ? _value.enableReadability
          // ignore: cast_nullable_to_non_nullable
          : enableReadability as bool,
    );
  }
}

extension $SettingsCopyWith on Settings {
  /// Returns a callable class that can be used as follows: `instanceOfSettings.copyWith(...)` or like so:`instanceOfSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SettingsCWProxy get copyWith => _$SettingsCWProxyImpl(this);
}
