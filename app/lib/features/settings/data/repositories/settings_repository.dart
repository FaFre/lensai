import 'package:bang_navigator/features/settings/data/models/settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

typedef UpdateSettingsFunc = Settings Function(Settings currentSettings);

@Riverpod(keepAlive: true)
class SettingsRepository extends _$SettingsRepository {
  static const _sessionStorageKey = 'b4ng_kagi_session';
  static const _incognitoStorageKey = 'b4ng_settings_incognito';
  static const _javascriptStorageKey = 'b4ng_settings_js';
  static const _launchExternalStorageKey = 'b4ng_settings_launch_external';

  final FlutterSecureStorage _flutterSecureStorage;
  final Future<SharedPreferences> _sharedPreferences;

  SettingsRepository()
      : _flutterSecureStorage = const FlutterSecureStorage(),
        _sharedPreferences = SharedPreferences.getInstance();

  Future<void> updateSettings(UpdateSettingsFunc updateWithCurrent) async {
    final oldSettings = state.value!;
    final newSettings = updateWithCurrent(oldSettings);

    if (oldSettings != newSettings) {
      if (oldSettings.kagiSession != newSettings.kagiSession) {
        await _flutterSecureStorage.write(
          key: _sessionStorageKey,
          value: (newSettings.kagiSession?.isNotEmpty ?? false)
              ? newSettings.kagiSession
              : null,
        );
      }

      if (newSettings.incognitoMode != oldSettings.incognitoMode) {
        await _sharedPreferences.then(
          (s) => s.setBool(_incognitoStorageKey, newSettings.incognitoMode),
        );
      }

      if (newSettings.enableJavascript != oldSettings.enableJavascript) {
        await _sharedPreferences.then(
          (s) => s.setBool(_javascriptStorageKey, newSettings.enableJavascript),
        );
      }

      if (newSettings.launchUrlExternal != oldSettings.launchUrlExternal) {
        await _sharedPreferences.then(
          (s) => s.setBool(
            _launchExternalStorageKey,
            newSettings.launchUrlExternal,
          ),
        );
      }

      ref.invalidateSelf();
    }
  }

  @override
  FutureOr<Settings> build() async {
    final sharedPreferences = await _sharedPreferences;

    return Settings.withDefaults(
      kagiSession: await _flutterSecureStorage.read(key: _sessionStorageKey),
      incognitoMode: sharedPreferences.getBool(_incognitoStorageKey),
      enableJavascript: sharedPreferences.getBool(_javascriptStorageKey),
      launchUrlExternal: sharedPreferences.getBool(_launchExternalStorageKey),
    );
  }
}
