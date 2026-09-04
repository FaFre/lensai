/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import android.content.SharedPreferences
import android.os.Environment
import androidx.core.content.ContextCompat
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.ColorSchemePreference
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.interceptor.AppRequestInterceptor
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import eu.weblibre.flutter_mozilla_components.EngineProvider
import eu.weblibre.flutter_mozilla_components.EngineProvider.getOrCreateRuntime
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.history.FallbackHistoryDelegate
import eu.weblibre.flutter_mozilla_components.middleware.HistoryDelegateBindingMiddleware
import eu.weblibre.flutter_mozilla_components.PermissionStorage
import eu.weblibre.flutter_mozilla_components.services.MediaSessionService
import eu.weblibre.flutter_mozilla_components.activities.NotificationActivity
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkStores
import eu.weblibre.flutter_mozilla_components.middleware.AppLinkNavigationMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.CrashRecoveryMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.FlutterEventMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.HistoryMetadataMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.HistoryMetadataService
import eu.weblibre.flutter_mozilla_components.middleware.SandboxCaptureMiddleware
import eu.weblibre.flutter_mozilla_components.middleware.SaveToPDFMiddleware
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.push.WebNotificationDrainCoordinator
import kotlinx.coroutines.FlowPreview
import mozilla.components.browser.engine.gecko.permission.GeckoSitePermissionsStorage
import mozilla.components.browser.engine.gecko.util.EngineDownloadDelegate
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.session.storage.SessionStorage
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.engine.middleware.SessionPrioritizationMiddleware
import mozilla.components.browser.state.engine.middleware.TranslationsMiddleware
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.browser.storage.sync.PlacesBookmarksStorage
import mozilla.components.browser.storage.sync.PlacesHistoryStorage
import mozilla.components.browser.storage.sync.RemoteTabsStorage
import mozilla.components.browser.thumbnails.ThumbnailsMiddleware
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.engine.DefaultSettings
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy
import mozilla.components.concept.fetch.Client
import mozilla.components.feature.addons.AddonManager
import mozilla.components.feature.addons.amo.AMOAddonsProvider
import mozilla.components.feature.addons.migration.DefaultSupportedAddonsChecker
import mozilla.components.feature.addons.update.DefaultAddonUpdater
import mozilla.components.feature.customtabs.store.CustomTabsServiceStore
import mozilla.components.feature.pwa.ManifestStorage
import mozilla.components.feature.pwa.WebAppShortcutManager
import mozilla.components.feature.downloads.DownloadMiddleware
import mozilla.components.feature.media.MediaSessionFeature
import mozilla.components.feature.media.middleware.LastMediaAccessMiddleware
import mozilla.components.feature.media.middleware.RecordingDevicesMiddleware
import mozilla.components.feature.prompts.PromptMiddleware
import mozilla.components.feature.prompts.file.FileUploadsDirCleaner
import mozilla.components.feature.prompts.file.FileUploadsDirCleanerMiddleware
import mozilla.components.feature.readerview.ReaderViewMiddleware
import mozilla.components.concept.engine.history.HistoryTrackingDelegate
import mozilla.components.feature.session.HistoryDelegate
import mozilla.components.feature.session.middleware.LastAccessMiddleware
import mozilla.components.feature.session.middleware.undo.UndoMiddleware
import mozilla.components.feature.sitepermissions.OnDiskSitePermissionsStorage
import mozilla.components.feature.webnotifications.WebNotificationFeature
import mozilla.components.concept.base.crash.Breadcrumb
import mozilla.components.concept.base.crash.CrashReporting
import mozilla.components.support.base.worker.Frequency
import org.mozilla.geckoview.GeckoRuntime
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.Job
import mozilla.components.support.utils.DefaultDownloadFileUtils
import java.util.concurrent.TimeUnit

private const val AMO_COLLECTION_MAX_CACHE_AGE = 24 * 60L

class Core(
    private val context: Context,
    private val components: Components,
    private val flutterEvents: GeckoStateEvents,
    private val extensionEvents: BrowserExtensionEvents
) {
    private val noOpCrashReporter = object : CrashReporting {
        override fun submitCaughtException(throwable: Throwable): Job = Job()

        override fun recordCrashBreadcrumb(breadcrumb: Breadcrumb) = Unit
    }

    val prefs by lazy {
        PreferenceManager.getDefaultSharedPreferences(context)
    }

    val engineSettings by lazy {
        DefaultSettings(
            requestInterceptor = requestInterceptor,
            // Engine-wide fallback only. Every session in the store is given its
            // own TabScopedHistoryDelegate by HistoryDelegateBindingMiddleware,
            // which is what enforces exclude-from-history and tags visits with
            // their container. The fallback covers sessions that have no binding
            // (yet) and, unable to identify them, refuses to record while any
            // exclusion is active — see FallbackHistoryDelegate.
            historyTrackingDelegate = FallbackHistoryDelegate(historyStorageDelegate),
            testingModeEnabled = false,
            remoteDebuggingEnabled = false,
            automaticFontSizeAdjustment = true,
            fontInflationEnabled = true,
            suspendMediaWhenInactive = false,
            getDesktopMode = {
                store.state.desktopMode
            },
            enterpriseRootsEnabled = false,
            emailTrackerBlockingPrivateBrowsing = true,
//            clearColor = ContextCompat.getColor(
//                context,
//                R.color.fx_mobile_layer_color_1,
//            ),

            trackingProtectionPolicy = createTrackingProtectionPolicy(TrackingProtectionPolicy.strict()),
            //FP Protection is handled by trackingPolicy
            //fingerprintingProtection
            //fingerprintingProtectionPrivateBrowsing
            httpsOnlyMode = Engine.HttpsOnlyMode.ENABLED,
            globalPrivacyControlEnabled = true,
            // Resolve the last persisted choice so cold-started Custom Tab / PWA
            // sessions report the correct `prefers-color-scheme` before Flutter
            // (the source of truth) runs. Defaults to System. See issue #436.
            preferredColorScheme = ColorSchemePreference.read(prefs),
            downloadDelegate = EngineDownloadDelegate(
                context = context,
                downloadLocation = {
                    Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_DOWNLOADS,
                    ).path
                },
            ),
            useContentBlockingDatabase =
                GlobalComponents.startupSettings?.useContentBlockingDatabase ?: true
        )
    }

    val runtime: GeckoRuntime by lazy {
        getOrCreateRuntime(context)
    }

    val engine: Engine by lazy {
        EngineProvider.createEngine(context, engineSettings, extensionEvents, flutterEvents)
    }

    /**
     * The [Client] implementation (`concept-fetch`) used for HTTP requests.
     */
    val client: Client by lazy {
        EngineProvider.createClient(context)
    }

    val thumbnailStorage by lazy { ThumbnailStorage(context) }

    val icons by lazy { BrowserIcons(context, client) }

    /**
     * A storage component for site permissions.
     */
    val geckoSitePermissionsStorage by lazy {
        val geckoRuntime = EngineProvider.getOrCreateRuntime(context)
        GeckoSitePermissionsStorage(geckoRuntime, OnDiskSitePermissionsStorage(context))
    }

    // Addons
    val addonManager by lazy {
        AddonManager(store, engine, addonsProvider, addonUpdater)
    }

    val addonUpdater by lazy {
        DefaultAddonUpdater(
            context,
            Frequency(12, TimeUnit.HOURS),
            components.notificationsDelegate
        )
    }

    val addonsProvider by lazy {
        if (components.addonCollection != null)
            AMOAddonsProvider(
                context,
                client,
                serverURL = components.addonCollection.serverURL,
                collectionUser = components.addonCollection.collectionUser,
                collectionName = components.addonCollection.collectionName,
                maxCacheAgeInMinutes = AMO_COLLECTION_MAX_CACHE_AGE
            ) else
            AMOAddonsProvider(
                context,
                client,
                maxCacheAgeInMinutes = AMO_COLLECTION_MAX_CACHE_AGE
            )
    }

    val supportedAddonsChecker by lazy {
        DefaultSupportedAddonsChecker(
            context,
            Frequency(12, TimeUnit.HOURS)
        )
    }

    val fileUploadsDirCleaner: FileUploadsDirCleaner by lazy {
        FileUploadsDirCleaner { context.cacheDir }
    }

    val historyMetadataService by lazy {
        HistoryMetadataService(storage = historyStorage)
    }

    // Wraps the WebNotificationFeature delegate so headless push deliveries can
    // wait for the service worker to actually post its notification before the
    // process loses foreground priority. Installed when [store] is created.
    val webNotificationDrainCoordinator = WebNotificationDrainCoordinator()

    @OptIn(FlowPreview::class)
    val store by lazy {
        BrowserStore(
            middleware = listOf(
                // Must run before any engine middleware so we can rewrite
                // sandbox new-tab URLs before Gecko issues a request.
                SandboxCaptureMiddleware,
                // WebLibre-owned app-link pending-request invalidation + suppression clearing.
                AppLinkNavigationMiddleware(
                    PendingAppLinkStores.forProfile(
                        components.profileApplicationContext.relativePath,
                    ),
                ),
                HistoryMetadataMiddleware(historyMetadataService),
                // Must run before the engine middleware: it swaps each session's
                // history delegate for a tab-scoped one before that session is
                // linked and starts loading.
                HistoryDelegateBindingMiddleware(historyStorageDelegate),
                // Android Components deliberately parks a crashed tab until the
                // app asks for it back; nothing else here ever would.
                CrashRecoveryMiddleware(),
                FlutterEventMiddleware(flutterEvents),
                DownloadMiddleware(
                    applicationContext = context,
                    downloadServiceClass = DownloadService::class.java,
                    deleteFileFromStorage = { false },
                    downloadFileUtils = DefaultDownloadFileUtils(
                        context = context,
                        downloadLocation = {
                            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path
                        },
                    ),
                ),
                ThumbnailsMiddleware(thumbnailStorage),
                ReaderViewMiddleware(),
                UndoMiddleware(),
                LastAccessMiddleware(),
                SessionPrioritizationMiddleware(),
                RecordingDevicesMiddleware(context, components.notificationsDelegate),
                PromptMiddleware(),
                SaveToPDFMiddleware(),
                FileUploadsDirCleanerMiddleware(fileUploadsDirCleaner),
                LastMediaAccessMiddleware(),
                // Keep parity with Fenix: do not initialize translations on store init.
                // EngineObserver will dispatch InitTranslationsBrowserState after first completed page load.
                TranslationsMiddleware(
                    engine,
                    MainScope(),
                    false,
                    isTranslationsEnabled = { true }),
            ) + EngineMiddleware.create(
                engine,
                // We are disabling automatic suspending of engine sessions under memory pressure.
                // Instead we solely rely on GeckoView and the Android system to reclaim memory
                // when needed. For details, see:
                // https://bugzilla.mozilla.org/show_bug.cgi?id=1752594
                // https://github.com/mozilla-mobile/fenix/issues/12731
                // https://github.com/mozilla-mobile/android-components/issues/11300
                // https://github.com/mozilla-mobile/android-components/issues/11653
                trimMemoryAutomatically = false,
            )
        ).apply {
            components.events.registerFlowEvents(this)

            icons.install(engine, this)

            // WebNotificationFeature self-registers as the engine's notification
            // delegate in its init; immediately wrap it with the drain
            // coordinator so headless deliveries observe onShowNotification while
            // notifications still display exactly as before.
            val webNotificationFeature = WebNotificationFeature(
                context,
                engine,
                icons,
                R.drawable.ic_launcher_foreground,
                geckoSitePermissionsStorage,
                NotificationActivity::class.java,
                notificationsDelegate = components.notificationsDelegate,
            )
            webNotificationDrainCoordinator.delegate = webNotificationFeature
            engine.registerWebNotificationDelegate(webNotificationDrainCoordinator)

            MediaSessionFeature(context, MediaSessionService::class.java, this).start()
        }
    }

    /**
     * The [CustomTabsServiceStore] holds global custom tabs related data.
     */
    val customTabsStore by lazy { CustomTabsServiceStore() }

    val webAppManifestStorage by lazy { ManifestStorage(context) }

    val webAppShortcutManager by lazy {
        WebAppShortcutManager(context, client, webAppManifestStorage)
    }

    /**
     * The storage component for persisting browser tab sessions.
     */
    val sessionStorage: SessionStorage by lazy {
        SessionStorage(context, engine)
    }

    /**
     * The storage component to persist browsing history (with the exception of
     * private sessions).
     */
    val lazyHistoryStorage = lazy { PlacesHistoryStorage(context) }

    /**
     * Writes visits to Places. Wrapped per session by [TabScopedHistoryDelegate]
     * so exclude-from-history and container tagging can be decided from the tab
     * that produced the visit.
     */
    val historyStorageDelegate: HistoryTrackingDelegate by lazy {
        HistoryDelegate(lazyHistoryStorage)
    }

    val lazyBookmarksStorage = lazy { PlacesBookmarksStorage(context) }
    val lazyRemoteTabsStorage = lazy { RemoteTabsStorage(context, noOpCrashReporter) }

    /**
     * A convenience accessor to the [PlacesHistoryStorage].
     */
    val historyStorage by lazy { lazyHistoryStorage.value }
    val bookmarksStorage by lazy { lazyBookmarksStorage.value }
    val remoteTabsStorage by lazy { lazyRemoteTabsStorage.value }

    val permissionStorage by lazy { PermissionStorage(geckoSitePermissionsStorage) }

    val requestInterceptor = AppRequestInterceptor(context)

    /**
     * Constructs a [TrackingProtectionPolicy] based on current preferences.
     *
     * @param prefs the shared preferences to use when reading tracking
     * protection settings.
     * @param normalMode whether or not tracking protection should be enabled
     * in normal browsing mode, defaults to the current preference value.
     * @param privateMode whether or not tracking protection should be enabled
     * in private browsing mode, default to the current preference value.
     * @return the constructed tracking protection policy based on preferences.
     */
    private fun createTrackingProtectionPolicy(
        trackingPolicy: EngineSession.TrackingProtectionPolicyForSessionTypes,
        normalMode: Boolean = true,
        privateMode: Boolean = true,
    ): TrackingProtectionPolicy {
        return when {
            normalMode && privateMode -> trackingPolicy
            normalMode && !privateMode -> trackingPolicy.forRegularSessionsOnly()
            !normalMode && privateMode -> trackingPolicy.forPrivateSessionsOnly()
            else -> TrackingProtectionPolicy.none()
        }
    }

}
