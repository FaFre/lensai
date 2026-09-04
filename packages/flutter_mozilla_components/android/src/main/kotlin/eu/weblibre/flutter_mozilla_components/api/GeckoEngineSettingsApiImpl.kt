/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import eu.weblibre.flutter_mozilla_components.ColorSchemePreference
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.feature.ReaderViewAppearanceFeature
import eu.weblibre.flutter_mozilla_components.history.HistoryExclusions
import eu.weblibre.flutter_mozilla_components.pigeons.BounceTrackingProtectionMode as PigeonBounceTrackingProtectionMode
import eu.weblibre.flutter_mozilla_components.pigeons.ColorScheme
import eu.weblibre.flutter_mozilla_components.pigeons.CustomCookiePolicy
import eu.weblibre.flutter_mozilla_components.pigeons.DohSettingsMode
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettings
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.HttpsOnlyMode
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingScope
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.DefaultDesktopModeAction
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy.TrackingCategory
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy.CookiePolicy
import mozilla.components.concept.engine.mediaquery.PreferredColorScheme
import mozilla.components.feature.addons.logger
import mozilla.components.feature.session.SettingsUseCases
import mozilla.components.feature.session.TrackingProtectionUseCases

internal fun PigeonBounceTrackingProtectionMode.toEngineBounceTrackingProtectionMode():
    EngineSession.BounceTrackingProtectionMode =
    when (this) {
        PigeonBounceTrackingProtectionMode.ENABLED ->
            EngineSession.BounceTrackingProtectionMode.ENABLED
        PigeonBounceTrackingProtectionMode.DISABLED ->
            EngineSession.BounceTrackingProtectionMode.DISABLED
        PigeonBounceTrackingProtectionMode.ENABLED_STANDBY ->
            EngineSession.BounceTrackingProtectionMode.ENABLED_STANDBY
        PigeonBounceTrackingProtectionMode.ENABLED_DRY_RUN ->
            EngineSession.BounceTrackingProtectionMode.ENABLED_DRY_RUN
    }

internal fun TrackingProtectionPolicy.withBounceTrackingProtectionMode(
    bounceTrackingProtectionMode: PigeonBounceTrackingProtectionMode,
): TrackingProtectionPolicy {
    val updatedPolicy = TrackingProtectionPolicy.select(
        trackingCategories = trackingCategories,
        cookiePolicy = cookiePolicy,
        cookiePolicyPrivateMode = cookiePolicyPrivateMode,
        strictSocialTrackingProtection = strictSocialTrackingProtection,
        cookiePurging = cookiePurging,
        bounceTrackingProtectionMode =
            bounceTrackingProtectionMode.toEngineBounceTrackingProtectionMode(),
        allowListBaselineTrackingProtection = allowListBaselineTrackingProtection,
        allowListConvenienceTrackingProtection = allowListConvenienceTrackingProtection,
    )

    return when {
        useForPrivateSessions && !useForRegularSessions -> updatedPolicy.forPrivateSessionsOnly()
        !useForPrivateSessions && useForRegularSessions -> updatedPolicy.forRegularSessionsOnly()
        else -> updatedPolicy
    }
}

/**
 * Implementation of GeckoEngineSettingsApi that manages engine-specific settings
 */
class GeckoEngineSettingsApiImpl(
    private val applicationContext: Context? = null,
) : GeckoEngineSettingsApi {
    companion object {
        private const val TAG = "GeckoEngineSettingsApi"
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    /**
     * Updates fingerprinting protection settings based on the tracking protection policy.
     * For CUSTOM mode, uses the settings from GeckoEngineSettings to determine the behavior.
     */
    private fun updateFingerprintingProtection(
        trackingProtectionPolicy: eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy,
        settings: GeckoEngineSettings? = null
    ) {
        when(trackingProtectionPolicy) {
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.STRICT -> {
                components.core.engineSettings.fingerprintingProtection = true
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.RECOMMENDED -> {
                components.core.engineSettings.fingerprintingProtection = false
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.CUSTOM -> {
                // Handle suspected fingerprinters (separate from FINGERPRINTING category)
                if (settings?.blockSuspectedFingerprinters == true) {
                    when (settings.suspectedFingerprintersScope) {
                        TrackingScope.ALL -> {
                            components.core.engineSettings.fingerprintingProtection = true
                            components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
                        }
                        TrackingScope.PRIVATE_ONLY, null -> {
                            components.core.engineSettings.fingerprintingProtection = false
                            components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
                        }
                    }
                } else {
                    components.core.engineSettings.fingerprintingProtection = false
                    components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = false
                }
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.NONE -> {
                components.core.engineSettings.fingerprintingProtection = false
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = false
            }
        }
    }

    /**
     * Creates a custom tracking protection policy based on user settings.
     */
    private fun createCustomTrackingProtectionPolicy(settings: GeckoEngineSettings): TrackingProtectionPolicy {
        val categories = mutableListOf<TrackingCategory>()

        if (settings.blockAdsAnalyticsSocialTrackers != false) {
            categories.add(TrackingCategory.AD)
            categories.add(TrackingCategory.ANALYTICS)
            categories.add(TrackingCategory.SOCIAL)
            categories.add(TrackingCategory.MOZILLA_SOCIAL)
        }

        // Add configurable categories
        if (settings.blockTrackingContent == true) {
            categories.add(TrackingCategory.SCRIPTS_AND_SUB_RESOURCES)
        }

        if (settings.blockFingerprinters == true) {
            categories.add(TrackingCategory.FINGERPRINTING)
        }

        if (settings.blockCryptominers == true) {
            categories.add(TrackingCategory.CRYPTOMINING)
        }

        // Determine cookie policy
        val cookiePolicy = if (settings.blockCookies != true) {
            CookiePolicy.ACCEPT_ALL
        } else {
            when (settings.customCookiePolicy) {
                CustomCookiePolicy.TOTAL_PROTECTION -> CookiePolicy.ACCEPT_FIRST_PARTY_AND_ISOLATE_OTHERS
                CustomCookiePolicy.CROSS_SITE_TRACKERS -> CookiePolicy.ACCEPT_NON_TRACKERS
                CustomCookiePolicy.UNVISITED -> CookiePolicy.ACCEPT_VISITED
                CustomCookiePolicy.THIRD_PARTY -> CookiePolicy.ACCEPT_ONLY_FIRST_PARTY
                CustomCookiePolicy.ALL_COOKIES -> CookiePolicy.ACCEPT_NONE
                null -> CookiePolicy.ACCEPT_FIRST_PARTY_AND_ISOLATE_OTHERS // default
            }
        }

        // Build policy
        val policy = TrackingProtectionPolicy.select(
            trackingCategories = categories.toTypedArray(),
            cookiePolicy = cookiePolicy,
            cookiePurging = settings.blockRedirectTrackers ?: true,
            strictSocialTrackingProtection = settings.blockTrackingContent ?: true,
            allowListBaselineTrackingProtection = settings.allowListBaseline ?: true,
            allowListConvenienceTrackingProtection = settings.allowListConvenience ?: false,
        )

        // Apply scope for tracking content
        return if (settings.trackingContentScope == TrackingScope.PRIVATE_ONLY) {
            policy.forPrivateSessionsOnly()
        } else {
            policy
        }
    }

    override fun setDefaultSettings(settings: GeckoEngineSettings) {
        if(settings.javascriptEnabled != null) {
            components.core.engineSettings.javascriptEnabled = settings.javascriptEnabled;
        }
        if(settings.trackingProtectionPolicy != null) {
            components.core.engineSettings.trackingProtectionPolicy = when(settings.trackingProtectionPolicy) {
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.NONE -> TrackingProtectionPolicy.none()
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.RECOMMENDED -> TrackingProtectionPolicy.recommended()
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.STRICT -> TrackingProtectionPolicy.strict()
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.CUSTOM -> createCustomTrackingProtectionPolicy(settings)
            }

            updateFingerprintingProtection(settings.trackingProtectionPolicy, settings)
        }
        if(settings.httpsOnlyMode != null) {
            components.core.engineSettings.httpsOnlyMode = when(settings.httpsOnlyMode) {
                HttpsOnlyMode.DISABLED -> Engine.HttpsOnlyMode.DISABLED
                HttpsOnlyMode.PRIVATE_ONLY -> Engine.HttpsOnlyMode.ENABLED_PRIVATE_ONLY
                HttpsOnlyMode.ENABLED -> Engine.HttpsOnlyMode.ENABLED
            }
        }
        if(settings.globalPrivacyControlEnabled != null) {
            components.core.engineSettings.globalPrivacyControlEnabled = settings.globalPrivacyControlEnabled;
        }
        if(settings.preferredColorScheme != null) {
            components.core.engineSettings.preferredColorScheme = when(settings.preferredColorScheme) {
                ColorScheme.SYSTEM -> PreferredColorScheme.System
                ColorScheme.LIGHT -> PreferredColorScheme.Light
                ColorScheme.DARK -> PreferredColorScheme.Dark
            }
        }
        if(settings.userAgent != null) {
            components.core.engineSettings.userAgentString = settings.userAgent;
        }
        if(settings.contentBlocking != null) {
            components.core.engineSettings.queryParameterStripping = when(settings.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> false
            }
            components.core.engineSettings.queryParameterStrippingPrivateBrowsing = when(settings.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> true
            }
            components.core.engineSettings.queryParameterStrippingAllowList = settings.contentBlocking.queryParameterStrippingAllowList
            components.core.engineSettings.queryParameterStrippingStripList = settings.contentBlocking.queryParameterStrippingStripList
            components.core.engineSettings.trackingProtectionPolicy =
                (components.core.engineSettings.trackingProtectionPolicy
                    ?: TrackingProtectionPolicy.select()).withBounceTrackingProtectionMode(
                    settings.contentBlocking.bounceTrackingProtectionMode,
                )
        }
        if(settings.enterpriseRootsEnabled != null) {
            components.core.engineSettings.enterpriseRootsEnabled = settings.enterpriseRootsEnabled;
        }
        if(settings.dohSettings != null) {
            components.core.engineSettings.dohSettingsMode = when(settings.dohSettings.dohSettingsMode) {
                DohSettingsMode.GECKO_DEFAULT -> Engine.DohSettingsMode.DEFAULT
                DohSettingsMode.INCREASED -> Engine.DohSettingsMode.INCREASED
                DohSettingsMode.MAX -> Engine.DohSettingsMode.MAX
                DohSettingsMode.OFF -> Engine.DohSettingsMode.OFF
            }
            components.core.engineSettings.dohProviderUrl = settings.dohSettings.dohProviderUrl
            components.core.engineSettings.dohDefaultProviderUrl = settings.dohSettings.dohDefaultProviderUrl
            components.core.engineSettings.dohExceptionsList = settings.dohSettings.dohExceptionsList
        }
        if(settings.fingerprintingProtectionOverrides != null) {
            components.core.engineSettings.fingerprintingProtectionOverrides = settings.fingerprintingProtectionOverrides
        }
        if(settings.locales != null) {
//            components.core.engineSettings.automaticLanguageAdjustment = false
            components.core.runtime.settings.locales = settings.locales.toTypedArray()
        }

        // Web Content Settings
        if(settings.webFontsEnabled != null) {
            components.core.engineSettings.webFontsEnabled = settings.webFontsEnabled
        }
        if(settings.automaticFontSizeAdjustment != null) {
            components.core.engineSettings.automaticFontSizeAdjustment = settings.automaticFontSizeAdjustment
        }
        if(settings.fontSizeFactor != null && settings.automaticFontSizeAdjustment != true) {
            components.core.engineSettings.fontSizeFactor = settings.fontSizeFactor.toFloat()
        }
        if(settings.fontInflationEnabled != null && settings.automaticFontSizeAdjustment != true) {
            components.core.engineSettings.fontInflationEnabled = settings.fontInflationEnabled
        }
        if(settings.inputAutoZoomEnabled != null) {
            components.core.runtime.settings.inputAutoZoomEnabled = settings.inputAutoZoomEnabled
        }
        if(settings.forceUserScalableContent != null) {
            components.core.engineSettings.forceUserScalableContent = settings.forceUserScalableContent
        }

        // LNA Settings
        if(settings.lnaBlocking != null) {
            components.core.engineSettings.lnaBlockingEnabled = settings.lnaBlocking
        }
        if(settings.lnaBlockTrackers != null) {
            components.core.engineSettings.lnaTrackerBlockingEnabled = settings.lnaBlockTrackers
        }
        if(settings.lnaEnabled != null) {
            components.core.engineSettings.lnaFeatureEnabled = settings.lnaEnabled
        }
    }

    override fun updateRuntimeSettings(settings: GeckoEngineSettings) {
        //First parse and set default values
        setDefaultSettings(settings);

        var reloadSession = false

        //Then copy default settings into runtime
        if(settings.javascriptEnabled != null) {
            components.core.engine.settings.javascriptEnabled = components.core.engineSettings.javascriptEnabled
            reloadSession = true
        }
        if(settings.trackingProtectionPolicy != null) {
            components.useCases.settingsUseCases.updateTrackingProtection(components.core.engineSettings.trackingProtectionPolicy!!)
            components.core.engine.settings.fingerprintingProtection = components.core.engineSettings.fingerprintingProtection
            components.core.engine.settings.fingerprintingProtectionPrivateBrowsing = components.core.engineSettings.fingerprintingProtectionPrivateBrowsing
            reloadSession = true
        }
        if(settings.httpsOnlyMode != null) {
            components.core.engine.settings.httpsOnlyMode = components.core.engineSettings.httpsOnlyMode
        }
        if(settings.globalPrivacyControlEnabled != null) {
            components.core.engine.settings.globalPrivacyControlEnabled = components.core.engineSettings.globalPrivacyControlEnabled
        }
        if(settings.preferredColorScheme != null) {
            components.core.engine.settings.preferredColorScheme = components.core.engineSettings.preferredColorScheme
            // Persist so cold-started Custom Tab / PWA sessions resolve the right
            // scheme before Flutter runs. Only done here (the runtime path driven by
            // the app theme), not in setDefaultSettings, so the vestigial engine
            // settings payload can't clobber the real theme. See issue #436.
            components.core.engineSettings.preferredColorScheme?.let { scheme ->
                ColorSchemePreference.write(components.core.prefs, scheme)
            }
            reloadSession = true
        }
        if(settings.userAgent != null) {
            components.core.engine.settings.userAgentString = components.core.engineSettings.userAgentString
            reloadSession = true
        }
        if(settings.contentBlocking != null) {
            components.core.engine.settings.queryParameterStripping = components.core.engineSettings.queryParameterStripping
            components.core.engine.settings.queryParameterStrippingPrivateBrowsing = components.core.engineSettings.queryParameterStrippingPrivateBrowsing
            components.core.engine.settings.queryParameterStrippingAllowList = components.core.engineSettings.queryParameterStrippingAllowList
            components.core.engine.settings.queryParameterStrippingStripList = components.core.engineSettings.queryParameterStrippingStripList
            reloadSession = true
        }
        if(settings.enterpriseRootsEnabled != null) {
            components.core.engine.settings.enterpriseRootsEnabled = components.core.engineSettings.enterpriseRootsEnabled
            reloadSession = true
        }
        if(settings.dohSettings != null) {
            components.core.engine.settings.dohSettingsMode = components.core.engineSettings.dohSettingsMode
            components.core.engine.settings.dohProviderUrl = components.core.engineSettings.dohProviderUrl
            components.core.engine.settings.dohDefaultProviderUrl = components.core.engineSettings.dohDefaultProviderUrl
            components.core.engine.settings.dohExceptionsList = components.core.engineSettings.dohExceptionsList
        }
        if(settings.fingerprintingProtectionOverrides != null) {
            components.core.engine.settings.fingerprintingProtectionOverrides = components.core.engineSettings.fingerprintingProtectionOverrides
        }

        // Web Content runtime settings
        if(settings.webFontsEnabled != null) {
            components.core.engine.settings.webFontsEnabled = components.core.engineSettings.webFontsEnabled
            reloadSession = true
        }
        if(settings.automaticFontSizeAdjustment != null) {
            components.core.engine.settings.automaticFontSizeAdjustment = components.core.engineSettings.automaticFontSizeAdjustment
        }
        if(settings.fontSizeFactor != null) {
            components.core.engine.settings.fontSizeFactor = components.core.engineSettings.fontSizeFactor
            reloadSession = true
        }
        if(settings.fontInflationEnabled != null) {
            components.core.engine.settings.fontInflationEnabled = components.core.engineSettings.fontInflationEnabled
            reloadSession = true
        }
        if(settings.forceUserScalableContent != null) {
            components.core.engine.settings.forceUserScalableContent = components.core.engineSettings.forceUserScalableContent
        }
        // LNA settings
        if(settings.lnaEnabled != null) {
            components.core.engine.settings.lnaFeatureEnabled = components.core.engineSettings.lnaFeatureEnabled
            reloadSession = true
        }
        if(settings.lnaBlocking != null) {
            components.core.engine.settings.lnaBlockingEnabled = components.core.engineSettings.lnaBlockingEnabled
            reloadSession = true
        }
        if(settings.lnaBlockTrackers != null) {
            components.core.engine.settings.lnaTrackerBlockingEnabled = components.core.engineSettings.lnaTrackerBlockingEnabled
            reloadSession = true
        }

        if(reloadSession) {
            components.useCases.sessionUseCases.reload()
        }
    }

    override fun setPullToRefreshEnabled(enabled: Boolean) {
        GlobalComponents.pullToRefreshEnabled = enabled
    }

    override fun setScreenshotProtectionEnabled(enabled: Boolean) {
        GlobalComponents.screenshotProtectionEnabled = enabled
    }

    override fun setAllowPrivateTabScreenshots(allow: Boolean) {
        GlobalComponents.allowPrivateTabScreenshots = allow
    }

    override fun setUseExternalDownloadManager(enabled: Boolean) {
        GlobalComponents.useExternalDownloadManager = enabled
    }

    override fun getUseExternalDownloadManager(): Boolean {
        return GlobalComponents.useExternalDownloadManager
    }

    override fun setGlobalDesktopMode(enable: Boolean, applyToExistingTabs: Boolean) {
        val store = components.core.store

        // Updates BrowserState.desktopMode, the browser-wide default applied to
        // newly created tabs/engine sessions.
        store.dispatch(DefaultDesktopModeAction.DesktopModeUpdated(enable))

        // Only an explicit user toggle should rewrite existing tabs. Skipping this
        // on the initial replication fire (startup / service rebuild) avoids
        // clobbering per-tab desktop/mobile overrides and reloading loaded tabs.
        if (!applyToExistingTabs) {
            return
        }

        // Apply the new value to all existing regular tabs so the change takes
        // effect immediately instead of only on tabs opened afterwards.
        store.state.tabs.forEach { tab ->
            if (tab.content.desktopMode == enable) return@forEach

            if (tab.engineState.engineSession != null) {
                // Loaded tab: toggle the engine session's desktop mode and reload
                // it so the page re-renders with the new user agent / viewport.
                components.useCases.sessionUseCases.requestDesktopSite(enable, tab.id)
            } else {
                // Suspended tab (no engine session yet): only update the content
                // state so the value is applied when the tab is next loaded,
                // without force-creating a session and waking the tab now.
                store.dispatch(ContentAction.UpdateTabDesktopMode(tab.id, enable))
            }
        }
    }

    override fun setReaderViewPureBlack(enabled: Boolean) {
        // Push to every tab whose reader view is currently active so the change
        // applies live, without depending on a single tracked session.
        val activeReaderSessions = components.core.store.state.tabs
            .filter { it.readerState.active }
            .mapNotNull { it.engineState.engineSession }

        ReaderViewAppearanceFeature.setPureBlack(
            enabled,
            components.core.prefs,
            activeReaderSessions,
        )
    }

    override fun setHistoryExclusions(
        excludedTabIds: List<String>,
        knownTabIds: List<String>,
        excludedContextIds: List<String>,
    ) {
        HistoryExclusions.update(
            context = applicationContext,
            excludedTabIds = excludedTabIds,
            knownTabIds = knownTabIds,
            excludedContextIds = excludedContextIds,
        )
    }
}
