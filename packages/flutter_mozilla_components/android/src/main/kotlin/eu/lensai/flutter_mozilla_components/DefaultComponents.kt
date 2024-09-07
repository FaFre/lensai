package eu.lensai.flutter_mozilla_components


import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import eu.lensai.flutter_mozilla_components.middleware.FlutterEventMiddleware
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.distinctUntilChangedBy
import kotlinx.coroutines.flow.mapNotNull
import kotlinx.coroutines.launch
import mozilla.components.browser.engine.gecko.GeckoEngine
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.session.storage.SessionStorage
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.engine.middleware.SessionPrioritizationMiddleware
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.browser.thumbnails.ThumbnailsMiddleware
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.base.crash.Breadcrumb
import mozilla.components.concept.engine.DefaultSettings
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.mediaquery.PreferredColorScheme
import mozilla.components.concept.fetch.Client
import mozilla.components.feature.addons.AddonManager
import mozilla.components.feature.addons.amo.AMOAddonsProvider
import mozilla.components.feature.addons.migration.DefaultSupportedAddonsChecker
import mozilla.components.feature.addons.update.DefaultAddonUpdater
import mozilla.components.feature.app.links.AppLinksInterceptor
import mozilla.components.feature.app.links.AppLinksUseCases
import mozilla.components.feature.downloads.DownloadMiddleware
import mozilla.components.feature.downloads.DownloadsUseCases
import mozilla.components.feature.media.MediaSessionFeature
import mozilla.components.feature.media.middleware.RecordingDevicesMiddleware
import mozilla.components.feature.prompts.PromptMiddleware
import mozilla.components.feature.prompts.file.FileUploadsDirCleaner
import mozilla.components.feature.readerview.ReaderViewMiddleware
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.feature.session.middleware.LastAccessMiddleware
import mozilla.components.feature.session.middleware.undo.UndoMiddleware
import mozilla.components.feature.sitepermissions.OnDiskSitePermissionsStorage
import mozilla.components.feature.webnotifications.WebNotificationFeature
import mozilla.components.lib.crash.Crash
import mozilla.components.lib.crash.CrashReporter
import mozilla.components.lib.crash.service.CrashReporterService
import mozilla.components.lib.dataprotect.SecureAbove22Preferences
import mozilla.components.lib.fetch.httpurlconnection.HttpURLConnectionClient
import mozilla.components.lib.publicsuffixlist.PublicSuffixList
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.service.digitalassetlinks.local.StatementApi
import mozilla.components.service.digitalassetlinks.local.StatementRelationChecker
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.worker.Frequency
import mozilla.components.support.ktx.kotlinx.coroutines.flow.filterChanged
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged
import java.util.concurrent.TimeUnit

private const val DAY_IN_MINUTES = 24 * 60L

@SuppressLint("NewApi")
@Suppress("LargeClass")
open class DefaultComponents(private val applicationContext: Context) {
    companion object {
        const val SAMPLE_BROWSER_PREFERENCES = "sample_browser_preferences"
        const val PREF_LAUNCH_EXTERNAL_APP = "sample_browser_launch_external_app"
        const val PREF_GLOBAL_PRIVACY_CONTROL = "sample_browser_global_privacy_control"
    }

    val preferences: SharedPreferences =
        applicationContext.getSharedPreferences(SAMPLE_BROWSER_PREFERENCES, Context.MODE_PRIVATE)

    private val securePreferences by lazy { SecureAbove22Preferences(applicationContext, "key_store") }

    val publicSuffixList by lazy { PublicSuffixList(applicationContext) }

    // Engine Settings
    val engineSettings by lazy {
        DefaultSettings().apply {
            //historyTrackingDelegate = HistoryDelegate(lazyHistoryStorage)
            requestInterceptor = AppRequestInterceptor(applicationContext)
            remoteDebuggingEnabled = true
            supportMultipleWindows = true
            preferredColorScheme = PreferredColorScheme.Dark
            httpsOnlyMode = Engine.HttpsOnlyMode.ENABLED
            globalPrivacyControlEnabled = preferences.getBoolean(
                PREF_GLOBAL_PRIVACY_CONTROL,
                false,
            )
        }
    }

    private val notificationManagerCompat = NotificationManagerCompat.from(applicationContext)

    val notificationsDelegate: NotificationsDelegate by lazy {
        NotificationsDelegate(
            notificationManagerCompat,
        )
    }

    val addonUpdater =
        DefaultAddonUpdater(applicationContext, Frequency(1, TimeUnit.DAYS), notificationsDelegate)

    // Engine
    open val engine: Engine by lazy {
        GeckoEngine(applicationContext, engineSettings)
    }

    val icons by lazy { BrowserIcons(applicationContext, client) }

    open val client: Client by lazy { HttpURLConnectionClient() }

    // Storage
    //private val lazyHistoryStorage = lazy { PlacesHistoryStorage(applicationContext) }
    //val historyStorage by lazy { lazyHistoryStorage.value }

    val sessionStorage by lazy { SessionStorage(applicationContext, engine) }

    val permissionStorage by lazy { OnDiskSitePermissionsStorage(applicationContext) }

    val thumbnailStorage by lazy { ThumbnailStorage(applicationContext) }

    val fileUploadsDirCleaner: FileUploadsDirCleaner by lazy {
        FileUploadsDirCleaner { applicationContext.cacheDir }
    }

    val store by lazy {
        BrowserStore(
            middleware = listOf(
                FlutterEventMiddleware(),
                DownloadMiddleware(applicationContext, DownloadService::class.java),
                ReaderViewMiddleware(),
                ThumbnailsMiddleware(thumbnailStorage),
                UndoMiddleware(),
                RecordingDevicesMiddleware(applicationContext, notificationsDelegate),
                LastAccessMiddleware(),
                PromptMiddleware(),
                SessionPrioritizationMiddleware(),
            ) + EngineMiddleware.create(engine),
        ).apply {
            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.selectedTab }
                    .distinctUntilChangedBy {
                        it.content.url
                    }
                    .collect { tab ->
                        Log.d("URL_CHANGE", tab.content.url)
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs }
                    .filterChanged {
                        it.content
                    }
                    .ifAnyChanged { arrayOf(it.content.url) }
                    .collect { tab ->
                        Log.d("URL_CHANGE2", tab.content.url)
                    }
            }

            WebNotificationFeature(
                applicationContext,
                engine,
                icons,
                R.drawable.ic_launcher_foreground,
                permissionStorage,
                NotificationActivity::class.java,
                notificationsDelegate = notificationsDelegate,
            )

            MediaSessionFeature(applicationContext, MediaSessionService::class.java, this).start()
        }
    }

    val sessionUseCases by lazy { SessionUseCases(store) }
    val tabsUseCases by lazy { TabsUseCases(store) }

    // Addons
    val addonManager by lazy {
        AddonManager(store, engine, addonsProvider, addonUpdater)
    }

    val addonsProvider by lazy {
        AMOAddonsProvider(
            applicationContext,
            client,
            collectionName = "7dfae8669acc4312a65e8ba5553036",
            maxCacheAgeInMinutes = DAY_IN_MINUTES,
        )
    }

    val supportedAddonsChecker by lazy {
        DefaultSupportedAddonsChecker(applicationContext, Frequency(1, TimeUnit.DAYS))
    }

    val appLinksUseCases by lazy { AppLinksUseCases(applicationContext) }

    val appLinksInterceptor by lazy {
        AppLinksInterceptor(
            applicationContext,
            interceptLinkClicks = true,
            launchInApp = {
                preferences.getBoolean(PREF_LAUNCH_EXTERNAL_APP, false)
            },
        )
    }

    // Digital Asset Links checking
    val relationChecker by lazy {
        StatementRelationChecker(StatementApi(client))
    }

    val downloadsUseCases: DownloadsUseCases by lazy { DownloadsUseCases(store) }

    val crashReporter: CrashReporter by lazy {
        CrashReporter(
            applicationContext,
            services = listOf(
                object : CrashReporterService {
                    override val id: String
                        get() = "xxx"
                    override val name: String
                        get() = "Test"

                    override fun createCrashReportUrl(identifier: String): String? {
                        return null
                    }

                    override fun report(crash: Crash.UncaughtExceptionCrash): String? {
                        return null
                    }

                    override fun report(crash: Crash.NativeCodeCrash): String? {
                        return null
                    }

                    override fun report(
                        throwable: Throwable,
                        breadcrumbs: ArrayList<Breadcrumb>,
                    ): String? {
                        return null
                    }
                },
            ),
            notificationsDelegate = notificationsDelegate,
        ).install(applicationContext)
    }
}
