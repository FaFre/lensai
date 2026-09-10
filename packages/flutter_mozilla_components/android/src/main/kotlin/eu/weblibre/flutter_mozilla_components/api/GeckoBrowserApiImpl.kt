/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.app.Activity
import android.content.Intent
import android.view.View
import androidx.fragment.app.FragmentActivity
import eu.weblibre.flutter_mozilla_components.AddonPopupViewFactory
import eu.weblibre.flutter_mozilla_components.AddonSettingsViewFactory
import eu.weblibre.flutter_mozilla_components.BrowserFragment
import eu.weblibre.flutter_mozilla_components.GeckoViewFactory
import eu.weblibre.flutter_mozilla_components.EngineProvider
import eu.weblibre.flutter_mozilla_components.EngineViewVisibility
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.activities.ExternalAppBrowserActivity
import eu.weblibre.flutter_mozilla_components.activities.NotificationActivity
import eu.weblibre.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import eu.weblibre.flutter_mozilla_components.pointer.PointerInputRouter
import eu.weblibre.flutter_mozilla_components.pigeons.AddonCollection
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.ContentBlocking
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettings
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAppLinksApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBookmarksApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserExtensionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoContainerProxyApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoCookieApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoDeleteBrowsingDataController
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoDownloadsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFetchApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFindApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHistoryApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoIconsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPublicSuffixListApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSitePermissionsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoGestureApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoGestureEvents
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.startup.EngineWarmupSession
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTrackingProtectionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoLogging
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoMlApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPwaApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionController
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAppLinkEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBookmarksEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHistoryEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSessionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportEvents
import eu.weblibre.flutter_mozilla_components.pigeons.LogLevel
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewEvents
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.SystemAction
import mozilla.components.browser.state.state.CustomTabConfig
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.feature.addons.logger
import mozilla.components.support.base.ext.getStacktraceAsString
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.sink.LogSink
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import org.mozilla.geckoview.BuildConfig as GeckoViewBuildConfig
import java.io.File
import mozilla.appservices.places.BookmarkRoot

class PriorityAwareLogSink(
    private val minLogPriority: Log.Priority,
    private val geckoLogging: GeckoLogging
) : LogSink {

    override fun log(
        priority: Log.Priority,
        tag: String?,
        throwable: Throwable?,
        message: String,
    ) {
        if (priority < minLogPriority) {
            return
        }

        val level = when (priority) {
            Log.Priority.DEBUG -> LogLevel.DEBUG
            Log.Priority.INFO -> LogLevel.INFO
            Log.Priority.WARN -> LogLevel.WARN
            Log.Priority.ERROR -> LogLevel.ERROR
        };

        val logMessage: String = if (throwable != null) {
            "$message\n${throwable.getStacktraceAsString()}"
        } else {
            message
        }

        runOnUiThread {
            geckoLogging.onLog(level, logMessage) { _ -> }
        }
    }
}

/**
 * Implementation of GeckoBrowserApi that handles browser-related operations
 * @param showFragmentCallback Callback function to show native fragment
 */
class GeckoBrowserApiImpl : GeckoBrowserApi {
    companion object {
        private const val TAG = "GeckoBrowserApiImpl"
        private const val FRAGMENT_CONTAINER_ID = 0xBEEF
        private const val REQUEST_CODE_BROWSER_ROLE = 1

        private var isGeckoInitialized = false
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private var activity: Activity? = null
    private var isPlatformViewRegistered = false
    private var pushApi: GeckoPushApiImpl? = null
    private var containerProxyApi: GeckoContainerProxyApiImpl? = null
    private var engineViewVisibility: EngineViewVisibility? = null

    private lateinit var _flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    private lateinit var _flutterEvents: GeckoStateEvents

    fun attachBinding(flutterPluginBinding: FlutterPluginBinding, pointerRouter: PointerInputRouter) {
        _flutterPluginBinding = flutterPluginBinding
        _flutterEvents = GeckoStateEvents(_flutterPluginBinding.binaryMessenger)

        // Register platform view factory once per engine binding.
        // The factory resolves the current activity lazily via activityProvider,
        // so it always uses the latest activity after recreation/config changes.
        _flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "eu.weblibre/gecko", GeckoViewFactory(
                activityProvider = { this.activity },
                FRAGMENT_CONTAINER_ID,
                _flutterEvents,
                pointerRouter,
            )
        )
        _flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "eu.weblibre/addon_settings",
            AddonSettingsViewFactory(activityProvider = { this.activity }, pointerRouter),
        )
        _flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "eu.weblibre/addon_popup",
            AddonPopupViewFactory(activityProvider = { this.activity }, pointerRouter),
        )
        isPlatformViewRegistered = true

        // Shares the container id with the factory above: what it hides is the
        // very view the browser fragment is attached to.
        engineViewVisibility?.dispose()
        engineViewVisibility = EngineViewVisibility(
            flutterPluginBinding.binaryMessenger,
            activityProvider = { this.activity },
            FRAGMENT_CONTAINER_ID,
        )

        isGeckoInitialized = false
    }

    fun disposeEngineViewVisibility() {
        engineViewVisibility?.dispose()
        engineViewVisibility = null
    }

    fun attachActivity(activity: Activity) {
        this.activity = activity
    }

    fun disposePushApi() {
        pushApi?.dispose()
        pushApi = null
    }

    fun disposeContainerProxyApi() {
        val api = containerProxyApi
        containerProxyApi = null
        api?.dispose()
        if (::_flutterPluginBinding.isInitialized) {
            GeckoContainerProxyApi.setUp(_flutterPluginBinding.binaryMessenger, null)
        }
    }

    /**
     * Puts a fresh container-proxy API on the channel, replacing whatever is
     * there.
     *
     * Its own method because [setupGeckoEngine] is not the only caller that
     * needs it, and is the one place a second caller cannot borrow it from:
     * [initialize] does nothing once [isGeckoInitialized] is true, which it
     * stays for the life of the process.
     */
    private fun installContainerProxyApi() {
        disposeContainerProxyApi()

        val containerProxyApiImpl = GeckoContainerProxyApiImpl()
        GeckoContainerProxyApi.setUp(
            _flutterPluginBinding.binaryMessenger,
            containerProxyApiImpl
        )
        containerProxyApi = containerProxyApiImpl
    }

    /**
     * Hands the container-proxy API to a replacement isolate, after a hot
     * restart.
     *
     * The instance left behind holds the dead isolate's `nextRoutingDemand`
     * waiter, which would take the next launch's demand off the queue and answer
     * an isolate that cannot hear it. Disposing it alone is not enough: nothing
     * else would register the channel again short of destroying the engine, so
     * every routing push and demand poll the replacement makes would land on a
     * channel with no handler — Gecko is already initialized, and `initialize`
     * is the call that would otherwise have set this up.
     *
     * A restart before the engine was ever set up is left alone: an unregistered
     * channel is exactly what a cold start has until [initialize], and this API
     * speaks for an extension that does not exist yet.
     */
    fun reinstallContainerProxyApi() {
        if (containerProxyApi == null) return

        installContainerProxyApi()
    }

    fun detachActivity() {
        this.activity = null
    }

    override fun getGeckoVersion(): String {
        return GeckoViewBuildConfig.MOZ_APP_VERSION + "-" + GeckoViewBuildConfig.MOZ_APP_BUILDID
    }

    override fun initialize(
        profileFolder: String,
        logLevel: LogLevel,
        contentBlocking: ContentBlocking,
        addonCollection: AddonCollection?,
        fxaServerOverride: String?,
        syncTokenServerOverride: String?,
        startupSettings: GeckoEngineSettings?,
        startupUBlockFilterListsPref: String?,
        clearStartupUBlockFilterListsPref: Boolean,
    ) {
        synchronized(this) {
            if (!isGeckoInitialized) {
                val geckoLogging = GeckoLogging(_flutterPluginBinding.binaryMessenger)

                val level = when (logLevel) {
                    LogLevel.DEBUG -> Log.Priority.DEBUG
                    LogLevel.INFO -> Log.Priority.INFO
                    LogLevel.WARN -> Log.Priority.WARN
                    LogLevel.ERROR -> Log.Priority.ERROR
                };

                Log.addSink(PriorityAwareLogSink(level, geckoLogging))

                // Store startup settings before runtime creation
                GlobalComponents.startupSettings = startupSettings
                GlobalComponents.startupUBlockFilterListsPref = startupUBlockFilterListsPref
                GlobalComponents.clearStartupUBlockFilterListsPref =
                    clearStartupUBlockFilterListsPref

                setupGeckoEngine(
                    profileFolder,
                    level,
                    contentBlocking,
                    addonCollection,
                    fxaServerOverride,
                    syncTokenServerOverride,
                )
                isGeckoInitialized = true
            }
        }
    }

    override fun showNativeFragment(): Boolean {
        try {
            return showFragmentCallback()
        } catch (e: Exception) {
            logger.error("Failed to show native fragment", e)
        }

        return false
    }

    /**
     * Binds this process to the profile Dart activated.
     *
     * A mismatch throws instead of rebinding: GeckoView allows one runtime per
     * process and `GeckoRuntime.shutdown()` does not clear GeckoView's static
     * runtime, so "just switch" is not a thing this process can do. Failing here
     * is loud but recoverable; binding Gecko to one profile while Dart writes
     * another's databases is neither.
     */
    /**
     * Verifies that the profile Dart activated is the one this process committed.
     *
     * This is no longer a commit point. Dart calls `GeckoProfileApi.beginStartup`
     * and commits through the arbiter before it opens a database, so by the time
     * the engine is built the decision is made and `current_profile` is written.
     * What remains is the disagreement check: binding Gecko to a folder other
     * than the committed one would leave Dart state and the engine on different
     * profiles, and the runtime cannot be re-pointed afterwards.
     */
    private fun assertProcessProfile(profileFolder: String) {
        val profileId = File(profileFolder).name
            .removePrefix(PwaConstants.PROFILE_DIR_PREFIX)
            .lowercase()

        val committed = StartupArbiter.committedProfileId()
            ?: error(
                "Refusing to start the engine before this process committed a " +
                    "profile (Dart asked for $profileId)",
            )

        if (committed != profileId) {
            error("Dart activated $profileId but this process is committed to $committed")
        }
    }

    private fun setupGeckoEngine(
        profileFolder: String,
        logLevel: Log.Priority,
        contentBlocking: ContentBlocking,
        addonCollection: AddonCollection?,
        fxaServerOverride: String?,
        syncTokenServerOverride: String?,
    ) {
        assertProcessProfile(profileFolder)

        val profileApplicationContext = ProfileContext(_flutterPluginBinding.applicationContext, profileFolder)

        val selectionActionEvents =
            GeckoSelectionActionEvents(_flutterPluginBinding.binaryMessenger)

        val selectionActionDelegate =
            DefaultSelectionActionDelegate(selectionActionEvents) { actions ->
                val processTextAction = "android.intent.action.PROCESS_TEXT"
                val withoutProcessText = actions.filter { it != processTextAction }.toTypedArray()
                val processTextActions = actions.filter { it == processTextAction }.toTypedArray()

                withoutProcessText + processTextActions
            }

        val readerViewController =
            ReaderViewController(_flutterPluginBinding.binaryMessenger)

        val extensionEvents = BrowserExtensionEvents(_flutterPluginBinding.binaryMessenger)

        val addonEvents = GeckoAddonEvents(_flutterPluginBinding.binaryMessenger)
        val tabContentEvents = GeckoTabContentEvents(_flutterPluginBinding.binaryMessenger)

        val suggestionEvents = GeckoSuggestionEvents(_flutterPluginBinding.binaryMessenger)
        GeckoSuggestionApi.setUp(
            _flutterPluginBinding.binaryMessenger,
            GeckoSuggestionApiImpl(suggestionEvents)
        )

        val syncStateEvents = GeckoSyncStateEvents(_flutterPluginBinding.binaryMessenger)

        // Set before GlobalComponents.setUp (which lazily builds the engine and
        // its history delegate) so Core can wrap the delegate to forward the
        // visit's WebLibre container to Dart.
        GlobalComponents.historyEvents =
            GeckoHistoryEvents(_flutterPluginBinding.binaryMessenger)

        // Progress sink for long-running bookmark imports.
        GlobalComponents.bookmarksEvents =
            GeckoBookmarksEvents(_flutterPluginBinding.binaryMessenger)

        // Availability signal for pending app-link prompts (Flutter-owned prompts).
        GlobalComponents.appLinkEvents =
            GeckoAppLinkEvents(_flutterPluginBinding.binaryMessenger)

        // Also set before GlobalComponents.setUp, which calls push.initialize() and can therefore
        // surface a registration failure before this sink would otherwise exist.
        GlobalComponents.pushEvents = GeckoPushEvents(_flutterPluginBinding.binaryMessenger)

        GlobalComponents.setUp(
            profileApplicationContext,
            _flutterEvents,
            readerViewController,
            selectionActionDelegate,
            addonEvents,
            tabContentEvents,
            extensionEvents,
            syncStateEvents,
            logLevel,
            contentBlocking,
            addonCollection,
            fxaServerOverride,
            syncTokenServerOverride,
        )

        // GeckoEngineSettingsApi was already registered at plugin-attach time
        // (FlutterMozillaComponentsPlugin.onAttachedToEngine) so the startup
        // history-exclusion push lands before the engine starts. Reuse that
        // instance; only register a fresh one if attach somehow did not run.
        if (GlobalComponents.engineSettingsApi == null) {
            val engineSettingsApiImpl = GeckoEngineSettingsApiImpl(
                _flutterPluginBinding.applicationContext,
            )
            GeckoEngineSettingsApi.setUp(
                _flutterPluginBinding.binaryMessenger,
                engineSettingsApiImpl
            )
            GlobalComponents.engineSettingsApi = engineSettingsApiImpl
        }
        GeckoAddonsApi.setUp(
            _flutterPluginBinding.binaryMessenger,
            GeckoAddonsApiImpl(profileApplicationContext)
        )
        GeckoSessionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSessionApiImpl())
        GeckoTabsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoTabsApiImpl())
        GeckoIconsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoIconsApiImpl())
        GeckoCookieApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoCookieApiImpl())
        GeckoMlApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoMlApiImpl(_flutterPluginBinding.binaryMessenger, _flutterEvents))
        GeckoPrefApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoPrefApiImpl())
        installContainerProxyApi()
        GeckoFindApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoFindApiImpl())
        GeckoSelectionActionController.setUp(
            _flutterPluginBinding.binaryMessenger, GeckoSelectionActionControllerImpl(
                selectionActionDelegate
            )
        )
        GeckoDeleteBrowsingDataController.setUp(
            _flutterPluginBinding.binaryMessenger,
            GeckoDeleteBrowsingDataControllerImpl()
        )
        GeckoDownloadsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoDownloadsApiImpl())
        GeckoBrowserExtensionApi.setUp(
            _flutterPluginBinding.binaryMessenger,
            GeckoBrowserExtensionApiImpl()
        )
        GeckoHistoryApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoHistoryApiImpl())
        GeckoFetchApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoFetchApiImpl())
        GeckoBookmarksApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoBookmarksApiImpl())
        GeckoSitePermissionsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSitePermissionsApiImpl())
        GeckoPublicSuffixListApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoPublicSuffixListApiImpl(profileApplicationContext))
        GeckoTrackingProtectionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoTrackingProtectionApiImpl())
        GeckoAppLinksApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoAppLinksApiImpl(profileApplicationContext))
        GeckoSyncApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSyncApiImpl())

        // PWA API for web app installation and management
        GeckoPwaApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoPwaApiImpl(profileApplicationContext))

        // Viewport API for dynamic toolbar and keyboard handling
        val viewportEvents = GeckoViewportEvents(_flutterPluginBinding.binaryMessenger)
        val viewportApi = GeckoViewportApiImpl()
        GeckoViewportApi.setUp(
            _flutterPluginBinding.binaryMessenger,
            viewportApi
        )
        // Store viewport events and API for keyboard feature and pending settings
        GlobalComponents.viewportEvents = viewportEvents
        GlobalComponents.viewportApi = viewportApi

        // Touch-gesture recognition: event sink (Kotlin → Dart) + config API
        GlobalComponents.gestureEvents =
            GeckoGestureEvents(_flutterPluginBinding.binaryMessenger)
        GeckoGestureApi.setUp(
            _flutterPluginBinding.binaryMessenger,
            GeckoGestureApiImpl()
        )

        // UnifiedPush distributor management. The event sink was installed above, before
        // GlobalComponents.setUp initialized push.
        pushApi?.dispose()
        pushApi = GeckoPushApiImpl()
        GeckoPushApi.setUp(
            _flutterPluginBinding.binaryMessenger,
            pushApi
        )

        ReaderViewEvents.setUp(
            _flutterPluginBinding.binaryMessenger,
            components.events.readerViewEvents
        )

        val intent =
            Intent(profileApplicationContext, NotificationActivity::class.java)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        profileApplicationContext.startActivity(intent)

        reportEngineReady()
    }

    /**
     * Tells Dart the engine is usable.
     *
     * This is the moment components exist and every API above is registered —
     * it has nothing to do with tabs. It used to be inferred from a reader-view
     * action, which only ever fires once a tab is selected, so a start that
     * landed on the home surface never reported ready at all and every
     * `syncEvents` catch-up waited out a timeout instead.
     *
     * Reported once per [setupGeckoEngine]. `GeckoPlatformView` reports it
     * again on every Flutter view attach, over that view's own event sink,
     * because a Dart half that restarted has lost the one it was told here.
     */
    private fun reportEngineReady() {
        if (!::_flutterEvents.isInitialized) return

        GlobalComponents.components?.engineReportedInitialized = true
        runOnUiThread {
            _flutterEvents.onEngineReadyStateChange(EventSequence.next(), true) { _ -> }
        }
    }

    private fun showFragmentCallback(): Boolean {
        if (!isPlatformViewRegistered) {
            return false
        }

        val fragmentActivity = activity as? FragmentActivity ?: return false

        if (fragmentActivity.isFinishing || fragmentActivity.isDestroyed) {
            return false
        }

        fragmentActivity.findViewById<View>(FRAGMENT_CONTAINER_ID) ?: return false

        val fm = fragmentActivity.supportFragmentManager

        if (fm.isStateSaved) {
            return false
        }

        val existingFragment = fm.findFragmentById(FRAGMENT_CONTAINER_ID)
        if (existingFragment is BrowserFragment) {
            // Check if fragment needs engine refresh instead of full replacement
            if (!isFragmentCorrupted(existingFragment)) {
                return true
            }
        }

        val nativeFragment = BrowserFragment.create()
        fm.beginTransaction()
            .replace(FRAGMENT_CONTAINER_ID, nativeFragment)
            .commitNow()

        return true
    }

    private fun isFragmentCorrupted(fragment: BrowserFragment): Boolean {
        if (!fragment.isAdded || fragment.isDetached || fragment.isRemoving) {
            return true
        }

        val view = fragment.view ?: return true
        if (view.visibility != View.VISIBLE || view.width == 0 || view.height == 0) {
            return true
        }

        if (!view.isAttachedToWindow) {
            return true
        }

        return false
    }

    override fun onTrimMemory(level: Long) {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }

        logger.debug("$TAG: onTrimMemory called with level: $level")

        with(GlobalComponents.components!!) {
            try {
                core.store.dispatch(SystemAction.LowMemoryAction(level.toInt()))
                core.icons.onTrimMemory(level.toInt())
            } catch (e: Exception) {
                logger.error("$TAG: Failed to handle memory trim", e)
            }
        }
    }

    override fun openInCustomTab(url: String, `private`: Boolean, contextId: String?) {
        val currentActivity = requireNotNull(activity) { "Activity not attached" }

        val customTabConfig = CustomTabConfig()

        val tab = createCustomTab(
            url = url,
            contextId = contextId,
            config = customTabConfig,
            source = SessionState.Source.Internal.CustomTab,
            private = `private`,
        )

        components.core.store.dispatch(
            CustomTabListAction.AddCustomTabAction(tab)
        )

        components.useCases.sessionUseCases.loadUrl(url, tab.id)

        val intent = ExternalAppBrowserActivity.createIntent(
            context = currentActivity,
            customTabSessionId = tab.id,
            // The window decides what routing this launch needs from the intent,
            // not from the session (`LaunchRouting.contextIdFor`), and the
            // fallback to the ordinary browser reopens the URL from it as well.
            // Left off, a tab created for a container is served — and recovered —
            // as if it belonged to no container at all.
            pwaContextId = contextId,
            isPrivate = `private`,
        )
        currentActivity.startActivity(intent)

        logger.debug("$TAG: Opened custom tab ${tab.id} for $url (private=$`private`)")
    }

    override fun isDefaultBrowser(): Boolean {
        val currentActivity = requireNotNull(activity) { "Activity not attached" }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            val roleManager = currentActivity.getSystemService(android.app.role.RoleManager::class.java)
            return roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_BROWSER)
        }
        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW, android.net.Uri.parse("http://"))
        val resolveInfo = currentActivity.packageManager.resolveActivity(intent, android.content.pm.PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName == currentActivity.packageName
    }

    override fun requestDefaultBrowser() {
        val currentActivity = requireNotNull(activity) { "Activity not attached" }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            val roleManager = currentActivity.getSystemService(android.app.role.RoleManager::class.java)
            if (roleManager.isRoleAvailable(android.app.role.RoleManager.ROLE_BROWSER) &&
                !roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_BROWSER)) {
                currentActivity.startActivityForResult(
                    roleManager.createRequestRoleIntent(android.app.role.RoleManager.ROLE_BROWSER),
                    REQUEST_CODE_BROWSER_ROLE
                )
                return
            }
        }
        val intent = android.content.Intent(android.provider.Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
        currentActivity.startActivity(intent)
    }

    override fun shutdown() {
        logger.debug("$TAG: Shutting down GeckoView engine")

        // 1. Remove the browser fragment so its onDestroyView runs while the
        //    runtime is still alive. This tears down EngineView, features, and
        //    clears component references cleanly.
        try {
            val fragmentActivity = activity as? FragmentActivity
            if (fragmentActivity != null && !fragmentActivity.isFinishing && !fragmentActivity.isDestroyed) {
                val fm = fragmentActivity.supportFragmentManager
                if (!fm.isStateSaved) {
                    val existing = fm.findFragmentById(FRAGMENT_CONTAINER_ID)
                    if (existing != null) {
                        fm.beginTransaction().remove(existing).commitNow()
                        logger.debug("$TAG: Browser fragment removed")
                    }
                }
            }
        } catch (e: Exception) {
            logger.error("$TAG: Error removing browser fragment", e)
        }

        // 2. Stop component-level services
        try {
            GlobalComponents.stopPrivateTabsNotificationFeature()
            disposeContainerProxyApi()
            disposePushApi()
            GlobalComponents.closePush()

            GlobalComponents.components?.let { components ->
                // Stop the FxA web channel feature
                runCatching { components.services.fxaWebChannelFeature.stop() }

                // Closes the account manager *and* forces its state to disk. The
                // quit path ends in `exit(0)`, which skips the flush the framework
                // would otherwise do — and an account state left in memory reads back
                // as signed out.
                runCatching { components.backgroundServices.close() }
            }
        } catch (e: Exception) {
            logger.error("$TAG: Error during component shutdown", e)
        }

        // 3. Give back the warm-up window, if this process is still holding
        //    one. Has to happen before the runtime goes, not with the rest of
        //    the components in tearDown() below.
        runCatching { EngineWarmupSession.stop() }
            .onFailure { logger.error("$TAG: Error closing the engine warm-up session", it) }

        // 4. Shutdown GeckoRuntime (safe now that no views reference it)
        try {
            EngineProvider.shutdown()
        } catch (e: Exception) {
            logger.error("$TAG: Error shutting down GeckoRuntime", e)
        } finally {
            GlobalComponents.tearDown()
        }

        isGeckoInitialized = false
    }

}
