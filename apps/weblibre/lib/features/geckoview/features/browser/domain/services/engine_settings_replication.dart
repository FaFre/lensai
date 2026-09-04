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
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_observer.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'engine_settings_replication.g.dart';

const _safeBrowsingMalwarePref = 'browser.safebrowsing.malware.enabled';
const _safeBrowsingPhishingPref = 'browser.safebrowsing.phishing.enabled';
const ublockFilterListsPref = 'browser.weblibre.uBO.filterLists';

/// Checks if any Custom ETP setting changed between two EngineSettings instances.
bool _customEtpSettingsChanged(
  GeckoEngineSettings? previous,
  GeckoEngineSettings current,
) {
  if (previous == null) return true;
  return previous.blockCookies != current.blockCookies ||
      previous.customCookiePolicy != current.customCookiePolicy ||
      previous.blockTrackingContent != current.blockTrackingContent ||
      previous.trackingContentScope != current.trackingContentScope ||
      previous.blockCryptominers != current.blockCryptominers ||
      previous.blockFingerprinters != current.blockFingerprinters ||
      previous.blockRedirectTrackers != current.blockRedirectTrackers ||
      previous.blockSuspectedFingerprinters !=
          current.blockSuspectedFingerprinters ||
      previous.suspectedFingerprintersScope !=
          current.suspectedFingerprintersScope ||
      previous.allowListBaseline != current.allowListBaseline ||
      previous.allowListConvenience != current.allowListConvenience ||
      previous.blockAdsAnalyticsSocialTrackers !=
          current.blockAdsAnalyticsSocialTrackers;
}

Future<void> syncUBlockFilterLists(
  PreferenceFixator fixator,
  EngineSettings settings,
) async {
  if (!settings.ublockFilterListSettings.enabled) {
    await fixator.unregister(ublockFilterListsPref);
    await GeckoPrefService().resetPrefs([ublockFilterListsPref]);
    return;
  }

  await fixator.register(
    ublockFilterListsPref,
    jsonEncode(settings.ublockFilterListSettings.resolveFinalList()),
  );
}

@Riverpod(keepAlive: true)
class EngineSettingsReplicationService
    extends _$EngineSettingsReplicationService {
  final _service = GeckoEngineSettingsService();

  @override
  void build() {
    var initialSettingsSent = false;

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.themeMode,
      ),
      (previous, next) async {
        final theme = switch (next) {
          ThemeMode.system => ColorScheme.system,
          ThemeMode.light => ColorScheme.light,
          ThemeMode.dark => ColorScheme.dark,
        };

        await _service.preferredColorScheme(theme);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to generalSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.pureBlack,
      ),
      (previous, next) async {
        await _service.setReaderViewPureBlack(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to pureBlack',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.screenshotProtectionEnabled,
      ),
      (previous, next) async {
        await _service.setScreenshotProtectionEnabled(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to screenshotProtectionEnabled',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.allowPrivateTabScreenshots,
      ),
      (previous, next) async {
        await _service.setAllowPrivateTabScreenshots(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to allowPrivateTabScreenshots',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.pullToRefreshEnabled,
      ),
      (previous, next) async {
        await _service.setPullToRefreshEnabled(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to pullToRefreshEnabled',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.useExternalDownloadManager,
      ),
      (previous, next) async {
        await _service.setUseExternalDownloadManager(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to useExternalDownloadManager',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.globalDesktopMode,
      ),
      (previous, next) async {
        // Only an actual toggle (not the initial startup fire) should rewrite
        // existing tabs; the initial fire just sets the default for new tabs.
        final isUserToggle = previous != null;

        await _service.setGlobalDesktopMode(
          next,
          applyToExistingTabs: isUserToggle,
        );

        if (isUserToggle) {
          // The native side applied the new value to all existing tabs.
          // Invalidate the per-tab desktop-mode notifiers so their menu
          // checkboxes re-seed and reflect it.
          ref.invalidate(desktopModeProvider);
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to globalDesktopMode',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      engineSettingsRepositoryProvider,
      (previous, next) async {
        final settings = next.value;

        if (settings != null) {
          if (initialSettingsSent && previous != null) {
            if (previous.value?.javascriptEnabled !=
                settings.javascriptEnabled) {
              await _service.javascriptEnabled(settings.javascriptEnabled);
            }
            // Check if tracking protection policy mode changed OR any custom ETP setting changed
            final policyModeChanged =
                previous.value?.trackingProtectionPolicy !=
                settings.trackingProtectionPolicy;
            final customSettingsChanged =
                settings.trackingProtectionPolicy ==
                    TrackingProtectionPolicy.custom &&
                _customEtpSettingsChanged(previous.value, settings);

            if (policyModeChanged || customSettingsChanged) {
              // Always send full custom settings when in CUSTOM mode
              if (settings.trackingProtectionPolicy ==
                  TrackingProtectionPolicy.custom) {
                await _service.customTrackingProtectionPolicy(
                  trackingProtectionPolicy: settings.trackingProtectionPolicy,
                  contentBlocking: settings.contentBlocking,
                  blockCookies: settings.blockCookies,
                  customCookiePolicy: settings.customCookiePolicy,
                  blockTrackingContent: settings.blockTrackingContent,
                  trackingContentScope: settings.trackingContentScope,
                  blockCryptominers: settings.blockCryptominers,
                  blockFingerprinters: settings.blockFingerprinters,
                  blockRedirectTrackers: settings.blockRedirectTrackers,
                  blockSuspectedFingerprinters:
                      settings.blockSuspectedFingerprinters,
                  suspectedFingerprintersScope:
                      settings.suspectedFingerprintersScope,
                  allowListBaseline: settings.allowListBaseline,
                  allowListConvenience: settings.allowListConvenience,
                  blockAdsAnalyticsSocialTrackers:
                      settings.blockAdsAnalyticsSocialTrackers,
                );
              } else {
                await _service.trackingProtectionPolicy(
                  settings.trackingProtectionPolicy,
                  contentBlocking: settings.contentBlocking,
                );
              }
            }
            if (previous.value?.httpsOnlyMode != settings.httpsOnlyMode) {
              await _service.httpsOnlyMode(settings.httpsOnlyMode);
            }
            if (previous.value?.globalPrivacyControlEnabled !=
                settings.globalPrivacyControlEnabled) {
              await _service.globalPrivacyControlEnabled(
                settings.globalPrivacyControlEnabled,
              );
            }
            // Note: preferredColorScheme is intentionally NOT replicated from the
            // engine settings here. The app theme (generalSettings.themeMode) is the
            // sole source of truth for the color scheme; see the themeMode listener
            // above. EngineSettings.preferredColorScheme is vestigial and always
            // `system`, so replicating it would clobber the real theme (issue #436).
            if (previous.value?.contentBlocking != settings.contentBlocking) {
              await _service.contentBlocking(settings.contentBlocking);
            }
            if (previous.value?.dohSettings != settings.dohSettings) {
              await _service.dohSettings(settings.dohSettings);
            }
            if (previous.value?.fingerprintingProtectionOverrides !=
                settings.fingerprintingProtectionOverrides) {
              await _service.fingerprintingProtectionOverrides(
                settings.fingerprintingProtectionOverrides,
              );
            }
            if (previous.value?.enablePdfJs != settings.enablePdfJs) {
              await ref
                  .read(preferenceFixatorProvider.notifier)
                  .register('pdfjs.disabled', !settings.enablePdfJs);
            }
            if (previous.value?.safeBrowsingMalwareEnabled !=
                settings.safeBrowsingMalwareEnabled) {
              await ref
                  .read(preferenceFixatorProvider.notifier)
                  .register(
                    _safeBrowsingMalwarePref,
                    settings.safeBrowsingMalwareEnabled,
                  );
            }
            if (previous.value?.safeBrowsingPhishingEnabled !=
                settings.safeBrowsingPhishingEnabled) {
              await ref
                  .read(preferenceFixatorProvider.notifier)
                  .register(
                    _safeBrowsingPhishingPref,
                    settings.safeBrowsingPhishingEnabled,
                  );
            }
            if (!const DeepCollectionEquality.unordered().equals(
              previous.value?.locales,
              settings.locales,
            )) {
              await ref
                  .read(preferenceFixatorProvider.notifier)
                  .register(
                    'intl.accept_languages',
                    settings.locales.join(','),
                  );
            }
            // Web Content Settings
            if (previous.value?.webFontsEnabled != settings.webFontsEnabled) {
              await _service.webFontsEnabled(settings.webFontsEnabled);
            }
            if (previous.value?.automaticFontSizeAdjustment !=
                settings.automaticFontSizeAdjustment) {
              await _service.automaticFontSizeAdjustment(
                settings.automaticFontSizeAdjustment,
              );
            }
            if (previous.value?.fontSizeFactor != settings.fontSizeFactor) {
              await _service.fontSizeFactor(settings.fontSizeFactor);
            }
            if (previous.value?.fontInflationEnabled !=
                settings.fontInflationEnabled) {
              await _service.fontInflationEnabled(
                settings.fontInflationEnabled,
              );
            }
            if (previous.value?.inputAutoZoomEnabled !=
                settings.inputAutoZoomEnabled) {
              await _service.inputAutoZoomEnabled(
                settings.inputAutoZoomEnabled,
              );
            }
            if (previous.value?.forceUserScalableContent !=
                settings.forceUserScalableContent) {
              await _service.forceUserScalableContent(
                settings.forceUserScalableContent,
              );
            }
            // LNA Settings
            if (previous.value?.lnaBlocking != settings.lnaBlocking) {
              await _service.lnaBlocking(settings.lnaBlocking);
            }
            if (previous.value?.lnaBlockTrackers != settings.lnaBlockTrackers) {
              await _service.lnaBlockTrackers(settings.lnaBlockTrackers);
            }
            if (previous.value?.lnaEnabled != settings.lnaEnabled) {
              await _service.lnaEnabled(settings.lnaEnabled);
            }
            if (previous.value?.ublockFilterListSettings !=
                settings.ublockFilterListSettings) {
              await syncUBlockFilterLists(
                ref.read(preferenceFixatorProvider.notifier),
                settings,
              );
            }
          } else {
            await _service.setDefaultSettings(settings);
            await ref
                .read(startupPreferenceEnforcementServiceProvider.notifier)
                .apply();
            await ref
                .read(preferenceFixatorProvider.notifier)
                .register('pdfjs.disabled', !settings.enablePdfJs);
            await ref
                .read(preferenceFixatorProvider.notifier)
                .register(
                  _safeBrowsingMalwarePref,
                  settings.safeBrowsingMalwareEnabled,
                );
            await ref
                .read(preferenceFixatorProvider.notifier)
                .register(
                  _safeBrowsingPhishingPref,
                  settings.safeBrowsingPhishingEnabled,
                );
            await ref
                .read(preferenceFixatorProvider.notifier)
                .register('intl.accept_languages', settings.locales.join(','));
            await syncUBlockFilterLists(
              ref.read(preferenceFixatorProvider.notifier),
              settings,
            );

            // Initialize unsigned extensions fixator from Gecko pref
            await ref.read(allowUnsignedExtensionsProvider.future);

            initialSettingsSent = true;
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }
}
