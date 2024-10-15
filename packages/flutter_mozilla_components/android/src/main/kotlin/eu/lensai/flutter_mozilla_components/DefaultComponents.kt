package eu.lensai.flutter_mozilla_components


import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import androidx.core.app.NotificationManagerCompat
import eu.lensai.flutter_mozilla_components.api.ReaderViewEventsImpl
import eu.lensai.flutter_mozilla_components.ext.toWebPBytes
import eu.lensai.flutter_mozilla_components.middleware.FlutterEventMiddleware
import eu.lensai.flutter_mozilla_components.pigeons.FindResultState
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.lensai.flutter_mozilla_components.pigeons.HistoryItem
import eu.lensai.flutter_mozilla_components.pigeons.HistoryState
import eu.lensai.flutter_mozilla_components.pigeons.ReaderViewController
import eu.lensai.flutter_mozilla_components.pigeons.ReaderableState
import eu.lensai.flutter_mozilla_components.pigeons.SecurityInfoState
import eu.lensai.flutter_mozilla_components.pigeons.SelectionAction
import eu.lensai.flutter_mozilla_components.pigeons.TabContentState
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.engine.gecko.GeckoEngine
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.session.storage.SessionStorage
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.engine.middleware.SessionPrioritizationMiddleware
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.browser.thumbnails.ThumbnailsMiddleware
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.base.crash.Breadcrumb
import mozilla.components.concept.engine.DefaultSettings
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineView
import mozilla.components.concept.engine.mediaquery.PreferredColorScheme
import mozilla.components.concept.fetch.Client
import mozilla.components.feature.addons.AddonManager
import mozilla.components.feature.addons.amo.AMOAddonsProvider
import mozilla.components.feature.addons.logger
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
open class DefaultComponents(
    private val applicationContext: Context,
    val flutterEvents: GeckoStateEvents,
    val readerViewController: ReaderViewController,
    val selectionAction: SelectionAction,
) {
    companion object {
        const val SAMPLE_BROWSER_PREFERENCES = "sample_browser_preferences"
        const val PREF_LAUNCH_EXTERNAL_APP = "sample_browser_launch_external_app"
        const val PREF_GLOBAL_PRIVACY_CONTROL = "sample_browser_global_privacy_control"
    }

    var engineView: EngineView? = null

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

    @OptIn(FlowPreview::class)
    val store by lazy {
        BrowserStore(
            middleware = listOf(
                FlutterEventMiddleware(flutterEvents),
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
                flow.map { state -> state.selectedTabId }
                    .distinctUntilChanged()
                    .collect { tabId ->
                        flutterEvents.onSelectedTabChange(
                            tabId
                        ) { _ -> }
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs }
                    .filterChanged {
                        it.content
                    }
                    .ifAnyChanged { arrayOf (it.content.icon) }
                    .debounce { 50 }
                    .collect { tab ->
                        val iconBytes = tab.content.icon?.toWebPBytes()
                        flutterEvents.onIconChange(
                            tab.id,
                            iconBytes
                        ) { _ -> }
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs }
                    .filterChanged {
                        it.content.securityInfo
                    }
                    .debounce { 50 }
                    .collect { tab ->
                        flutterEvents.onSecurityInfoStateChange(
                            tab.id,
                            SecurityInfoState(
                                tab.content.securityInfo.secure,
                                tab.content.securityInfo.host,
                                tab.content.securityInfo.issuer,
                            )
                        ) { _ -> }
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs }
                    .filterChanged {
                        it.readerState
                    }
                    .ifAnyChanged { arrayOf(
                            it.readerState.readerable,
                            it.readerState.active,
                        )
                    }
                    .debounce { 50 }
                    .collect { tab ->
                        flutterEvents.onReaderableStateChange(
                            tab.id,
                            ReaderableState(
                                tab.readerState.readerable,
                                tab.readerState.active,
                            )
                        ) { _ -> }
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs }
                    .filterChanged {
                        it.content
                    }
                    .ifAnyChanged { arrayOf(
                        it.content.history,
                        it.content.canGoBack,
                        it.content.canGoForward,
                        )
                    }
                    .debounce { 50 }
                    .collect { tab ->
                        flutterEvents.onHistoryStateChange(
                            tab.id,
                            HistoryState(
                                items = tab.content.history.items.map { item -> HistoryItem(
                                    url = item.uri,
                                    title = item.title
                                ) },
                                currentIndex = tab.content.history.currentIndex.toLong(),
                                canGoBack = tab.content.canGoBack,
                                canGoForward = tab.content.canGoForward,
                            )
                        ) { _ -> }
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs.map {tab -> tab.id} }
                    .distinctUntilChanged()
                    .collect { tabs ->
                        flutterEvents.onTabListChange(tabs) { _ -> }
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs }
                    .filterChanged {
                        it.content
                    }
                    .ifAnyChanged { arrayOf(
                        it.content.url,
                        it.content.title,
                        it.content.private,
                        it.content.fullScreen,
                        it.content.progress,
                        it.content.loading)
                    }
                    .debounce { 50 }
                    .collect { tab ->
                        logger.info("title: ${tab.content.title} ${tab.content.url}")
                        flutterEvents.onTabContentStateChange(
                            TabContentState(
                                id = tab.id,
                                contextId = tab.contextId,
                                url = tab.content.url,
                                title = tab.content.title,
                                progress = tab.content.progress.toLong(),
                                isPrivate = tab.content.private,
                                isFullScreen = tab.content.fullScreen,
                                isLoading = tab.content.loading
                            )
                        ) { _ -> }
                    }
            }

            this.flowScoped { flow ->
                flow.mapNotNull { state -> state.tabs }
                    .filterChanged {
                        it.content.findResults
                    }
                    .distinctUntilChanged()
                    .collect { tab ->
                        tab.content.findResults
                        flutterEvents.onFindResults(
                            tab.id,
                            tab.content.findResults.map { result -> FindResultState(
                                activeMatchOrdinal = result.activeMatchOrdinal.toLong(),
                                numberOfMatches = result.numberOfMatches.toLong(),
                                isDoneCounting = result.isDoneCounting,
                            ) }
                        ) { _ -> }
                    }
            }

            icons.install(engine, this)

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

    val readerViewEvents by lazy { ReaderViewEventsImpl() }

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
