/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'engine_settings.g.dart';

typedef UpdateEngineSettingsFunc =
    EngineSettings Function(EngineSettings currentSettings);

@Riverpod(keepAlive: true)
class EngineSettingsRepository extends _$EngineSettingsRepository {
  final _partitionKey = 'engine';

  EngineSettings _deserializeSettings(
    List<MapEntry<String, DriftAny?>> entries,
  ) {
    final db = ref.read(userDatabaseProvider);
    final settings = Map.fromEntries(entries);

    return EngineSettings.fromJson({
      'incognitoMode': settings['incognitoMode']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'javascriptEnabled': settings['javascriptEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'trackingProtectionPolicy': settings['trackingProtectionPolicy']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'httpsOnlyMode': settings['httpsOnlyMode']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'globalPrivacyControlEnabled': settings['globalPrivacyControlEnabled']
          ?.readAs(DriftSqlType.bool, db.typeMapping),
      'userAgent': settings['userAgent']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'queryParameterStripping': settings['queryParameterStripping']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'bounceTrackingProtectionMode': settings['bounceTrackingProtectionMode']
          ?.readAs(DriftSqlType.string, db.typeMapping),
      'enterpriseRootsEnabled': settings['enterpriseRootsEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'addonCollection': settings['addonCollection']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'ublockFilterListSettings': settings['ublockFilterListSettings']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohSettingsMode': settings['dohSettingsMode']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohProviderUrl': settings['dohProviderUrl']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohDefaultProviderUrl': settings['dohDefaultProviderUrl']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohExceptionsList': settings['dohExceptionsList']
          ?.readAs(DriftSqlType.string, db.typeMapping)
          .mapNotNull(jsonDecode),
      'customDohProviders': settings['customDohProviders']
          ?.readAs(DriftSqlType.string, db.typeMapping)
          .mapNotNull(jsonDecode),
      'fingerprintingProtectionOverrides':
          settings['fingerprintingProtectionOverrides']?.readAs(
            DriftSqlType.string,
            db.typeMapping,
          ),
      'enablePdfJs': settings['enablePdfJs']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'safeBrowsingMalwareEnabled': settings['safeBrowsingMalwareEnabled']
          ?.readAs(DriftSqlType.bool, db.typeMapping),
      'safeBrowsingPhishingEnabled': settings['safeBrowsingPhishingEnabled']
          ?.readAs(DriftSqlType.bool, db.typeMapping),
      'locales': settings['locales']
          ?.readAs(DriftSqlType.string, db.typeMapping)
          .mapNotNull(jsonDecode),
      'useContentBlockingDatabase': settings['useContentBlockingDatabase']
          ?.readAs(DriftSqlType.bool, db.typeMapping),
      // Custom Tracking Protection
      'blockCookies': settings['blockCookies']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'customCookiePolicy': settings['customCookiePolicy']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'blockTrackingContent': settings['blockTrackingContent']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'trackingContentScope': settings['trackingContentScope']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'blockCryptominers': settings['blockCryptominers']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'blockFingerprinters': settings['blockFingerprinters']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'blockRedirectTrackers': settings['blockRedirectTrackers']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'blockSuspectedFingerprinters': settings['blockSuspectedFingerprinters']
          ?.readAs(DriftSqlType.bool, db.typeMapping),
      'suspectedFingerprintersScope': settings['suspectedFingerprintersScope']
          ?.readAs(DriftSqlType.string, db.typeMapping),
      'allowListBaseline': settings['allowListBaseline']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'allowListConvenience': settings['allowListConvenience']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'blockAdsAnalyticsSocialTrackers':
          settings['blockAdsAnalyticsSocialTrackers']?.readAs(
            DriftSqlType.bool,
            db.typeMapping,
          ),
      // Web Content Settings
      'webFontsEnabled': settings['webFontsEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'automaticFontSizeAdjustment': settings['automaticFontSizeAdjustment']
          ?.readAs(DriftSqlType.bool, db.typeMapping),
      'fontSizeFactor': settings['fontSizeFactor']?.readAs(
        DriftSqlType.double,
        db.typeMapping,
      ),
      'fontInflationEnabled': settings['fontInflationEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'displayDensityOverride': settings['displayDensityOverride']?.readAs(
        DriftSqlType.double,
        db.typeMapping,
      ),
      'screenWidthOverride': settings['screenWidthOverride']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
      'screenHeightOverride': settings['screenHeightOverride']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
      'inputAutoZoomEnabled': settings['inputAutoZoomEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'forceUserScalableContent': settings['forceUserScalableContent']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      // Process Isolation Settings
      'fissionEnabled': settings['fissionEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'isolatedProcessEnabled': settings['isolatedProcessEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'appZygoteProcessEnabled': settings['appZygoteProcessEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'extensionsWebAPIEnabled': settings['extensionsWebAPIEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      // LNA Settings
      'lnaBlocking': settings['lnaBlocking']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'lnaBlockTrackers': settings['lnaBlockTrackers']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'lnaEnabled': settings['lnaEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
    });
  }

  Future<void> updateSettings(
    UpdateEngineSettingsFunc updateWithCurrent,
  ) async {
    final db = ref.read(userDatabaseProvider);

    final current = await fetchSettings();

    final oldJson = current.toJson();
    final newJson = updateWithCurrent(current).toJson();

    return db.transaction(() async {
      for (final MapEntry(:key, :value) in newJson.entries) {
        if (oldJson[key] != value) {
          await db.settingDao.updateSetting(key, _partitionKey, value);
        }
      }
    });
  }

  Future<EngineSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  @override
  Stream<EngineSettings> build() {
    final db = ref.watch(userDatabaseProvider);

    return db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .map((entries) {
          return _deserializeSettings(entries);
        });
  }
}

@Riverpod()
EngineSettings engineSettingsWithDefaults(Ref ref) {
  return ref.watch(
    engineSettingsRepositoryProvider.select(
      (value) => value.value ?? EngineSettings.withDefaults(),
    ),
  );
}
