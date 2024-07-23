import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/utils/preference_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

typedef UpdateSettingsFunc = Settings Function(Settings currentSettings);

enum _StorageKeys {
  kagiSession('kagi_session'),
  showEarlyAccessFeatures('show_early_access_features'),
  incognito('enabe_incognito'),
  javascript('enable_js'),
  launchExternal('enable_launch_external'),
  contentBlocking('enable_content_blocking'),
  blockHttpProtocol('block_http'),
  enableHostList('enable_host_lists'),
  themeMode('theme_mode'),
  quickAction('enable_quick_action'),
  quickActionVoiceInput('enable_quick_action_voice_input'),
  enableReadability('enable_readability');

  final String key;

  const _StorageKeys(this.key);
}

@Riverpod(keepAlive: true)
class SettingsRepository extends _$SettingsRepository {
  final FlutterSecureStorage _flutterSecureStorage;
  final Future<SharedPreferences> _sharedPreferences;

  SettingsRepository()
      : _flutterSecureStorage = const FlutterSecureStorage(),
        _sharedPreferences = SharedPreferences.getInstance();

  Future<void> updateSettings(UpdateSettingsFunc updateWithCurrent) async {
    final sharedPreferences = await _sharedPreferences;
    final oldSettings = state.value!;
    final newSettings = updateWithCurrent(oldSettings);

    if (oldSettings != newSettings) {
      if (oldSettings.kagiSession != newSettings.kagiSession) {
        await _flutterSecureStorage.write(
          key: _StorageKeys.kagiSession.key,
          value: (newSettings.kagiSession?.isNotEmpty ?? false)
              ? newSettings.kagiSession
              : null,
        );
      }

      if (newSettings.showEarlyAccessFeatures !=
          oldSettings.showEarlyAccessFeatures) {
        await sharedPreferences.setBool(
          _StorageKeys.showEarlyAccessFeatures.key,
          newSettings.showEarlyAccessFeatures,
        );
      }

      if (newSettings.incognitoMode != oldSettings.incognitoMode) {
        await sharedPreferences.setBool(
          _StorageKeys.incognito.key,
          newSettings.incognitoMode,
        );
      }

      if (newSettings.enableJavascript != oldSettings.enableJavascript) {
        await sharedPreferences.setBool(
          _StorageKeys.javascript.key,
          newSettings.enableJavascript,
        );
      }

      if (newSettings.launchUrlExternal != oldSettings.launchUrlExternal) {
        await sharedPreferences.setBool(
          _StorageKeys.launchExternal.key,
          newSettings.launchUrlExternal,
        );
      }

      if (newSettings.enableContentBlocking !=
          oldSettings.enableContentBlocking) {
        await sharedPreferences.setBool(
          _StorageKeys.contentBlocking.key,
          newSettings.enableContentBlocking,
        );
      }

      if (newSettings.blockHttpProtocol != oldSettings.blockHttpProtocol) {
        await sharedPreferences.setBool(
          _StorageKeys.blockHttpProtocol.key,
          newSettings.blockHttpProtocol,
        );
      }

      if (!const DeepCollectionEquality.unordered().equals(
        newSettings.enableHostList,
        oldSettings.enableHostList,
      )) {
        await sharedPreferences.setStringList(
          _StorageKeys.enableHostList.key,
          newSettings.enableHostList.map((list) => list.name).toList(),
        );
      }

      if (newSettings.themeMode != oldSettings.themeMode) {
        await sharedPreferences.setInt(
          _StorageKeys.themeMode.key,
          newSettings.themeMode.index,
        );
      }

      if (newSettings.quickAction != oldSettings.quickAction) {
        final index = newSettings.quickAction?.index;
        if (index != null) {
          await sharedPreferences.setInt(
            _StorageKeys.quickAction.key,
            index,
          );
        } else {
          await sharedPreferences.remove(_StorageKeys.quickAction.key);
        }
      }

      if (newSettings.quickActionVoiceInput !=
          oldSettings.quickActionVoiceInput) {
        await sharedPreferences.setBool(
          _StorageKeys.quickActionVoiceInput.key,
          newSettings.quickActionVoiceInput,
        );
      }

      if (newSettings.enableReadability != oldSettings.enableReadability) {
        await sharedPreferences.setBool(
          _StorageKeys.enableReadability.key,
          newSettings.enableReadability,
        );
      }

      ref.invalidateSelf();
    }
  }

  @override
  FutureOr<Settings> build() async {
    final sharedPreferences = await _sharedPreferences;

    return Settings.withDefaults(
      kagiSession:
          await _flutterSecureStorage.read(key: _StorageKeys.kagiSession.key),
      showEarlyAccessFeatures:
          sharedPreferences.getBool(_StorageKeys.showEarlyAccessFeatures.key),
      incognitoMode: sharedPreferences.getBool(_StorageKeys.incognito.key),
      enableJavascript: sharedPreferences.getBool(_StorageKeys.javascript.key),
      launchUrlExternal:
          sharedPreferences.getBool(_StorageKeys.launchExternal.key),
      enableContentBlocking:
          sharedPreferences.getBool(_StorageKeys.contentBlocking.key),
      blockHttpProtocol:
          sharedPreferences.getBool(_StorageKeys.blockHttpProtocol.key),
      enableHostList: parseHostSources(
        sharedPreferences.getStringList(_StorageKeys.enableHostList.key),
      ),
      themeMode:
          parseThemeMode(sharedPreferences.getInt(_StorageKeys.themeMode.key)),
      quickAction:
          parseKagiTool(sharedPreferences.getInt(_StorageKeys.quickAction.key)),
      quickActionVoiceInput:
          sharedPreferences.getBool(_StorageKeys.quickActionVoiceInput.key),
      enableReadability:
          sharedPreferences.getBool(_StorageKeys.enableReadability.key),
    );
  }
}
