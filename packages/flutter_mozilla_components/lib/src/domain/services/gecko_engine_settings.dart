/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoEngineSettingsApi();

class GeckoEngineSettingsService {
  final GeckoEngineSettingsApi _api;

  GeckoEngineSettingsService({GeckoEngineSettingsApi? api})
    : _api = api ?? _apiInstance;

  Future<void> setDefaultSettings(
    GeckoEngineSettings settings, {
    bool updateRuntime = true,
  }) {
    return updateRuntime
        ? _api.updateRuntimeSettings(settings)
        : _api.setDefaultSettings(settings);
  }

  Future<void> javascriptEnabled(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(javascriptEnabled: state),
    );
  }

  Future<void> trackingProtectionPolicy(
    TrackingProtectionPolicy state, {
    required ContentBlocking contentBlocking,
  }) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(
        trackingProtectionPolicy: state,
        contentBlocking: contentBlocking,
      ),
    );
  }

  /// Updates tracking protection policy with all custom settings.
  /// Use this when in CUSTOM mode and any custom setting changes.
  Future<void> customTrackingProtectionPolicy({
    required TrackingProtectionPolicy trackingProtectionPolicy,
    required ContentBlocking contentBlocking,
    bool? blockCookies,
    CustomCookiePolicy? customCookiePolicy,
    bool? blockTrackingContent,
    TrackingScope? trackingContentScope,
    bool? blockCryptominers,
    bool? blockFingerprinters,
    bool? blockRedirectTrackers,
    bool? blockSuspectedFingerprinters,
    TrackingScope? suspectedFingerprintersScope,
    bool? allowListBaseline,
    bool? allowListConvenience,
    bool? blockAdsAnalyticsSocialTrackers,
  }) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(
        trackingProtectionPolicy: trackingProtectionPolicy,
        contentBlocking: contentBlocking,
        blockCookies: blockCookies,
        customCookiePolicy: customCookiePolicy,
        blockTrackingContent: blockTrackingContent,
        trackingContentScope: trackingContentScope,
        blockCryptominers: blockCryptominers,
        blockFingerprinters: blockFingerprinters,
        blockRedirectTrackers: blockRedirectTrackers,
        blockSuspectedFingerprinters: blockSuspectedFingerprinters,
        suspectedFingerprintersScope: suspectedFingerprintersScope,
        allowListBaseline: allowListBaseline,
        allowListConvenience: allowListConvenience,
        blockAdsAnalyticsSocialTrackers: blockAdsAnalyticsSocialTrackers,
      ),
    );
  }

  Future<void> httpsOnlyMode(HttpsOnlyMode state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(httpsOnlyMode: state),
    );
  }

  Future<void> globalPrivacyControlEnabled(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(globalPrivacyControlEnabled: state),
    );
  }

  Future<void> preferredColorScheme(ColorScheme state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(preferredColorScheme: state),
    );
  }

  Future<void> contentBlocking(ContentBlocking state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(contentBlocking: state),
    );
  }

  Future<void> dohSettings(DohSettings state) {
    return _api.updateRuntimeSettings(GeckoEngineSettings(dohSettings: state));
  }

  Future<void> fingerprintingProtectionOverrides(String? state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(fingerprintingProtectionOverrides: state),
    );
  }

  // Web Content Settings
  Future<void> webFontsEnabled(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(webFontsEnabled: state),
    );
  }

  Future<void> automaticFontSizeAdjustment(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(automaticFontSizeAdjustment: state),
    );
  }

  Future<void> fontSizeFactor(double state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(fontSizeFactor: state),
    );
  }

  Future<void> fontInflationEnabled(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(fontInflationEnabled: state),
    );
  }

  Future<void> inputAutoZoomEnabled(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(inputAutoZoomEnabled: state),
    );
  }

  Future<void> forceUserScalableContent(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(forceUserScalableContent: state),
    );
  }

  // LNA Settings
  Future<void> lnaBlocking(bool? state) {
    return _api.updateRuntimeSettings(GeckoEngineSettings(lnaBlocking: state));
  }

  Future<void> lnaBlockTrackers(bool? state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(lnaBlockTrackers: state),
    );
  }

  Future<void> lnaEnabled(bool? state) {
    return _api.updateRuntimeSettings(GeckoEngineSettings(lnaEnabled: state));
  }

  Future<void> setScreenshotProtectionEnabled(bool enabled) {
    return _api.setScreenshotProtectionEnabled(enabled);
  }

  /// Lifts the secure-window restriction that private tabs apply by default,
  /// allowing system screenshots and screen recording of private tabs.
  /// [setScreenshotProtectionEnabled] still wins when both are enabled.
  Future<void> setAllowPrivateTabScreenshots(bool allow) {
    return _api.setAllowPrivateTabScreenshots(allow);
  }

  Future<void> setPullToRefreshEnabled(bool enabled) {
    return _api.setPullToRefreshEnabled(enabled);
  }

  /// Sets whether to use external download managers for downloads.
  /// When enabled, downloads are forwarded to third-party apps like ADM, 1DM, AB DM.
  Future<void> setUseExternalDownloadManager(bool enabled) {
    return _api.setUseExternalDownloadManager(enabled);
  }

  Future<bool> getUseExternalDownloadManager() {
    return _api.getUseExternalDownloadManager();
  }

  /// Sets the browser-wide default desktop mode (BrowserState.desktopMode).
  /// Newly opened tabs inherit this default; a per-tab requestDesktopSite still
  /// overrides it for that tab.
  ///
  /// Set [applyToExistingTabs] to true only for an explicit user toggle so the
  /// new value is also applied to currently open tabs. Leave it false during
  /// startup/replication restore to avoid clobbering per-tab overrides.
  Future<void> setGlobalDesktopMode(
    bool enable, {
    bool applyToExistingTabs = false,
  }) {
    return _api.setGlobalDesktopMode(enable, applyToExistingTabs);
  }

  Future<void> setReaderViewPureBlack(bool enabled) {
    return _api.setReaderViewPureBlack(enabled);
  }

  Future<void> setHistoryExclusions({
    required List<String> excludedTabIds,
    required List<String> knownTabIds,
    required List<String> excludedContextIds,
  }) {
    return _api.setHistoryExclusions(
      excludedTabIds,
      knownTabIds,
      excludedContextIds,
    );
  }
}
