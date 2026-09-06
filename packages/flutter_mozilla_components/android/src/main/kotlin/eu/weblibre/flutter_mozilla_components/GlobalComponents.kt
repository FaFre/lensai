/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.Intent
import androidx.core.content.edit
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.history.HistoryExclusions
import eu.weblibre.flutter_mozilla_components.pigeons.AddonCollection
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.BounceTrackingProtectionMode
import eu.weblibre.flutter_mozilla_components.pigeons.ContentBlocking
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettings
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAppLinkEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoGestureEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBookmarksEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHistoryEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GestureConfig
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import eu.weblibre.flutter_mozilla_components.services.PrivateTabsNotificationService
import eu.weblibre.flutter_mozilla_components.addons.AddonPrefs
import eu.weblibre.flutter_mozilla_components.addons.WebExtensionPromptHost
import eu.weblibre.flutter_mozilla_components.api.GeckoViewportApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoEngineSettingsApiImpl
import eu.weblibre.flutter_mozilla_components.feature.AppLifecycleFeature
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import eu.weblibre.flutter_mozilla_components.feature.GeckoBookmarksExtensionBridge
import eu.weblibre.flutter_mozilla_components.push.Push
import eu.weblibre.flutter_mozilla_components.startup.EngineWarmupSession
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.storage.sync.GlobalPlacesDependencyProvider
import mozilla.components.browser.session.storage.RecoverableBrowserState
import mozilla.components.browser.state.action.RestoreCompleteAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.feature.privatemode.notification.PrivateNotificationFeature
import mozilla.components.feature.addons.update.GlobalAddonDependencyProvider
import mozilla.components.support.base.facts.Facts
import mozilla.components.support.base.facts.processor.LogFactProcessor
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.base.log.sink.AndroidLogSink
import mozilla.components.support.webextensions.WebExtensionSupport
import java.io.File
import java.util.concurrent.TimeUnit

private const val HISTORY_METADATA_MAX_AGE_IN_MS = 14L * 24 * 60 * 60 * 1000 // 14 days
private const val DEFAULT_QUERY_PARAMETER_STRIPPING_STRIP_LIST =
    "__hsfp __hssc __hstc __s _bhlid _branch_match_id _branch_referrer _gl _hsenc _kx _openstat at_recipient_id at_recipient_list bbeml bsft_clkid bsft_uid dclid et_rid fb_action_ids fb_comment_id fbclid gbraid gclid guce_referrer guce_referrer_sig hsCtaTracking igshid irclickid mc_eid mkt_tok ml_subscriber ml_subscriber_hash msclkid mtm_cid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id pk_cid rb_clickid s_cid sc_customer sc_eh sc_uid sms_click sms_source sms_uph srsltid ss_email_id syclid ttclid twclid unicorn_click_id vero_conv vero_id vgo_ee wbraid wickedid yclid ymclid ysclid"
private const val UBLOCK_FILTER_LISTS_PREF = "browser.weblibre.uBO.filterLists"

object GlobalComponents {
    private var _components: Components? = null
    private var currentMode: ComponentsMode? = null
    private var privateTabsNotificationFeature:
        PrivateNotificationFeature<PrivateTabsNotificationService>? = null

    val components: Components?
        get() = _components

    internal val isExternalMode: Boolean
        get() = currentMode == ComponentsMode.EXTERNAL

    /** Resolve a live Push only when it belongs to the supplied profile context. */
    fun pushForProfile(context: Context): Push? {
        val profilePath = (context as? ProfileContext)?.relativePath ?: return null
        val current = _components ?: return null
        if (current.profileApplicationContext.relativePath != profilePath) return null
        return current.existingPush?.takeUnless { it.isClosed }
    }

    /**
     * The committed process context, or `null` while the process is undecided.
     *
     * Does not read `current_profile`: once the process has committed, that file is
     * next-start state and may already name a different profile.
     */
    fun resolveActiveProfileContext(context: Context): ProfileContext? =
        runCatching { ActiveProfile.resolveContext(context.applicationContext) }.getOrNull()

    fun closePush() {
        _components?.existingPush?.close()
    }

    fun tearDown() {
        // Normally already closed by the shutdown path, which has to do it
        // before the runtime goes away rather than after. Here for the case
        // where it is not.
        EngineWarmupSession.stop()
        _components?.existingPush?.close()
        _components = null
        currentMode = null

        // After the components, so it releases against the absence rather than
        // rebinding to the set being torn down.
        WebExtensionPromptHost.onComponentsChanged()
    }

    enum class ComponentsMode {
        FULL,
        EXTERNAL,
    }

    // Pull-to-refresh setting
    var pullToRefreshEnabled: Boolean = true
        set(value) {
            field = value
            onPullToRefreshEnabledChanged?.invoke(value)
        }

    var onPullToRefreshEnabledChanged: ((Boolean) -> Unit)? = null

    // Blocks system capture (screenshots, screen recording, the recents
    // preview) in every tab, private or not.
    var screenshotProtectionEnabled: Boolean = false
        set(value) {
            field = value
            onSecureWindowSettingsChanged?.invoke()
        }

    // Lifts the secure-window restriction that private tabs apply by default.
    // screenshotProtectionEnabled still wins when both are set, since it is
    // the app-wide block.
    var allowPrivateTabScreenshots: Boolean = false
        set(value) {
            field = value
            onSecureWindowSettingsChanged?.invoke()
        }

    // Invoked when any input of shouldSecureWindow changes, so the hosting
    // fragment can re-apply the flag without waiting for a store update.
    var onSecureWindowSettingsChanged: (() -> Unit)? = null

    // Whether the activity window must carry FLAG_SECURE for a tab with the
    // given privacy. Single source of truth for both enforcement points in
    // BaseBrowserFragment.
    fun shouldSecureWindow(isPrivate: Boolean): Boolean =
        screenshotProtectionEnabled || (isPrivate && !allowPrivateTabScreenshots)

    // Viewport events for keyboard visibility notifications
    var viewportEvents: GeckoViewportEvents? = null

    // Viewport API for applying pending settings when engineView becomes available
    var viewportApi: GeckoViewportApiImpl? = null

    // Engine settings API for managing engine-specific settings
    var engineSettingsApi: GeckoEngineSettingsApiImpl? = null

    // Touch-gesture recognition: event sink (Kotlin → Dart) and the current
    // configuration pushed from Dart. Read by the browser container's
    // GestureRecognizer on the UI thread.
    var gestureEvents: GeckoGestureEvents? = null

    // Native -> Dart history visit notifications, consumed by Core's history
    // delegate to forward the visit's WebLibre container. Null on the headless
    // path (no Flutter engine); the delegate still hard-excludes persisted
    // container contextIds but skips Dart relation emits.
    var historyEvents: GeckoHistoryEvents? = null

    // Native -> Dart progress for a running bookmark import. Null whenever no
    // import is in flight or Flutter is detached; progress is purely advisory,
    // so a missing sink only means the UI shows no percentage.
    var bookmarksEvents: GeckoBookmarksEvents? = null

    // Native -> Dart UnifiedPush registration lifecycle. Null when push events
    // arrive with no Flutter engine attached (the UnifiedPushReceiver cold-start
    // path), in which case failures are logged natively only.
    var pushEvents: GeckoPushEvents? = null

    // Native -> Dart availability signal for pending app-link prompts. Optimisation
    // only (no buffering/replay): null when Flutter is detached, in which case the
    // Flutter surface picks the prompt up on its next getPendingAppLinkPrompts query.
    var appLinkEvents: GeckoAppLinkEvents? = null

    @Volatile
    var gestureConfig: GestureConfig? = null

    /**
     * Set true when the in-flight touch sequence was recognized as a configured
     * gesture, so pull-to-refresh ([GestureAwareSwipeRefreshFeature]) can
     * suppress the otherwise-redundant reload for down-leading gestures started
     * at the top of the page. Reset on each ACTION_DOWN by the gesture
     * container. Read and written on the UI thread.
     */
    @Volatile
    var touchConsumedByGesture: Boolean = false

    // Current dynamic-toolbar viewport insets (physical px), tracked from the
    // viewport API so gesture edge-detection can exclude the bottom toolbar
    // area the engine view never receives touches in.
    @Volatile
    var dynamicToolbarMaxHeightPx: Int = 0

    @Volatile
    var verticalClippingPx: Int = 0

    /** Currently visible bottom inset: full toolbar height when shown, 0 when
     *  auto-hidden (clipping cancels it out). */
    val bottomViewportInsetPx: Int
        get() = (dynamicToolbarMaxHeightPx + verticalClippingPx).coerceAtLeast(0)

    // Listeners notified when [bottomViewportInsetPx] may have changed (i.e. when
    // the dynamic toolbar height or vertical clipping is updated). Lets native
    // views that align to the bottom chrome (e.g. the reader view controls bar)
    // re-apply their inset while visible, not only when first shown.
    private val bottomViewportInsetListeners =
        java.util.concurrent.CopyOnWriteArraySet<(Int) -> Unit>()

    fun addBottomViewportInsetListener(listener: (Int) -> Unit) {
        bottomViewportInsetListeners.add(listener)
    }

    fun removeBottomViewportInsetListener(listener: (Int) -> Unit) {
        bottomViewportInsetListeners.remove(listener)
    }

    fun notifyBottomViewportInsetChanged() {
        val inset = bottomViewportInsetPx
        bottomViewportInsetListeners.forEach { it(inset) }
    }

    // External download manager setting
    var useExternalDownloadManager: Boolean = false

    // Startup settings for builder-only GeckoRuntimeSettings (fission, process isolation, etc.)
    var startupSettings: GeckoEngineSettings? = null

    // Startup pref written before web extensions initialize.
    var startupUBlockFilterListsPref: String? = null
    var clearStartupUBlockFilterListsPref: Boolean = false

    private fun startPrivateTabsNotificationFeature(components: Components) {
        privateTabsNotificationFeature = PrivateNotificationFeature(
            components.profileApplicationContext,
            components.core.store,
            PrivateTabsNotificationService::class,
        ).also {
            it.start()
        }
    }

    fun stopPrivateTabsNotificationFeature() {
        val context = _components?.profileApplicationContext

        privateTabsNotificationFeature?.stop()
        privateTabsNotificationFeature = null

        context?.stopService(Intent(context, PrivateTabsNotificationService::class.java))
    }

    @DelicateCoroutinesApi
    private fun restoreBrowserState(
        newComponents: Components,
        restoreTabsWithoutResumingSelection: Boolean,
    ) =
        GlobalScope.launch(Dispatchers.Main) {
            if (restoreTabsWithoutResumingSelection) {
                val restoredState = newComponents.core.sessionStorage.restore { true }

                if (restoredState != null) {
                    newComponents.useCases.tabsUseCases.restore(
                        state = RecoverableBrowserState(
                            tabs = restoredState.tabs,
                            // Intentionally do not resume the previously selected tab during the
                            // first full setup. We restore the tab list, but let startup open in
                            // its neutral/default state instead of jumping back into prior content.
                            selectedTabId = null,
                            tabPartitions = restoredState.tabPartitions
                        ),
                        restoreLocation = TabListAction.RestoreAction.RestoreLocation.BEGINNING,
                    )
                }

                newComponents.core.store.dispatch(RestoreCompleteAction)
            } else {
                newComponents.useCases.tabsUseCases.restore(newComponents.core.sessionStorage)
            }

            newComponents.core.sessionStorage.autoSave(newComponents.core.store)
                .periodicallyInForeground(interval = 30, unit = TimeUnit.SECONDS)
                .whenGoingToBackground()
                .whenSessionsChange()
        }

    @DelicateCoroutinesApi
    private fun restoreDownloads(newComponents: Components) = GlobalScope.launch(Dispatchers.Main) {
        newComponents.useCases.downloadsUseCases.restoreDownloads()
    }

    // Submits the uBO managed-storage pref before web extensions register.
    // Called from setUp() on the main thread; we do not block awaiting the
    // ack callback because the engine dispatches it back to the main thread
    // (which is held by setUp), and waiting would deadlock. The underlying
    // GeckoView pref store accepts the new value before the callback fires,
    // so by the time WebExtensionSupport.initialize installs uBO and the
    // extension reads storage.managed, the pref is already present.
    @OptIn(ExperimentalAndroidComponentsApi::class)
    private fun applyStartupUBlockFilterListsPref(newComponents: Components) {
        if (!clearStartupUBlockFilterListsPref && startupUBlockFilterListsPref == null) {
            return
        }

        val onError: (Throwable) -> Unit = {
            Logger.warn("Failed applying startup uBlock filter list pref", it)
        }

        if (clearStartupUBlockFilterListsPref) {
            newComponents.core.engine.clearBrowserUserPref(
                pref = UBLOCK_FILTER_LISTS_PREF,
                onSuccess = {},
                onError = onError,
            )
        } else {
            newComponents.core.engine.setBrowserPref(
                UBLOCK_FILTER_LISTS_PREF,
                requireNotNull(startupUBlockFilterListsPref),
                Branch.USER,
                onSuccess = {},
                onError = onError,
            )
        }
    }

    @OptIn(DelicateCoroutinesApi::class)
    fun setUp(
        applicationContext: ProfileContext,
        flutterEvents: GeckoStateEvents,
        readerViewController: ReaderViewController,
        selectionAction: SelectionActionDelegate,
        addonEvents: GeckoAddonEvents,
        tabContentEvents: GeckoTabContentEvents,
        extensionEvents: BrowserExtensionEvents,
        syncStateEvents: GeckoSyncStateEvents?,
        logLevel: Log.Priority,
        contentBlocking: ContentBlocking,
        addonCollection: AddonCollection?,
        fxaServerOverride: String?,
        syncTokenServerOverride: String?,
        mode: ComponentsMode = ComponentsMode.FULL,
    ) {
        Logger.debug("Creating new components")

        // Reject a profile mismatch before anything observable happens — before
        // history exclusions load, before push state is touched, before a single
        // previous component is torn down. A mismatch here is not a switch to
        // perform: the process profile is decided once, and by the time components
        // are built the runtime is either bound to that profile or about to be.
        // The only correct response is to refuse and let the caller restart.
        val requestedProfileId = File(applicationContext.relativePath).name
            .removePrefix(PwaConstants.PROFILE_DIR_PREFIX)
            .lowercase()
        val committedProfileId = StartupArbiter.committedProfileId()
            ?: error("Refusing to create components before this process committed a profile")
        if (committedProfileId != requestedProfileId) {
            error(
                "Refusing to create components for $requestedProfileId; this process is " +
                    "committed to $committedProfileId and must restart to change that",
            )
        }

        val previousComponents = _components
        val previousMode = currentMode

        // Every setup in a process now targets the same profile, so a rebuild is a
        // mode change (external -> full) rather than a switch: custom tabs survive
        // it, and the outgoing push instance belongs to the same profile as the
        // incoming one.
        val previousCustomTabs =
            previousComponents?.core?.store?.state?.customTabs.orEmpty()

        previousComponents?.existingPush?.close()

        // Restore this profile's last routing before the engine — and with it the
        // proxy extension — exists. This runs on every setup, including a rebuild:
        // the extension blocks every request until it holds a snapshot, and on the
        // headless paths (external mode, no Flutter engine) Dart is never there to
        // push one. It only ever
        // takes effect while nothing has been pushed, so a full start still runs
        // on the live snapshot the moment Dart produces it.
        //
        // Only a full setup carries the Dart listener that reopens an assigned
        // site in the container it belongs to, so only a full setup may be
        // seeded with the assignments that cancel those navigations.
        ContainerProxyFeature.loadPersisted(
            applicationContext,
            canReopenAssignedSites = mode == ComponentsMode.FULL,
            // Only a full setup has the Dart half that pushes live routing over
            // the seed. Where it does, the extension holds requests the
            // endpoint-less seed would block for that push rather than turning
            // a startup window into an error page; where it does not, the seed
            // is final and blocking is immediate.
            expectsAppPush = mode == ComponentsMode.FULL,
        )

        val newComponents = Components(
            applicationContext,
            flutterEvents,
            readerViewController,
            selectionAction,
            logLevel,
            contentBlocking,
            addonCollection,
            fxaServerOverride,
            syncTokenServerOverride,
            addonEvents,
            tabContentEvents,
            extensionEvents,
            syncStateEvents,
        )
        _components = newComponents
        currentMode = mode

        previousComponents?.let {
            // Not `accountManager.close()`: that reaches through a lazy and would
            // build a whole account manager just to close it when the outgoing
            // components never used one. `close()` also flushes the account state.
            runCatching { it.backgroundServices.close() }
        }

        stopPrivateTabsNotificationFeature()

        // Process-scoped and idempotent: it resolves the current components on
        // every callback, so a rebuild must not re-register it.
        AppLifecycleFeature.install()

        // Hand web extension prompts to whichever window is in front. The
        // activity that is already resumed by now — the main window comes up long
        // before Dart calls `initialize()` — never reports another resume on its
        // own, and a rebuild would leave the running feature answering prompts on
        // the store this call just replaced.
        WebExtensionPromptHost.onComponentsChanged()

        // Hold a window open across startup. Gecko gates its delayed startup —
        // and with it every already-installed extension's background script —
        // on a chrome window existing, which nothing creates until a session is
        // opened. See [EngineWarmupSession].
        //
        // Dispatched, and deliberately not with `Main.immediate`. Opening a
        // session asserts the UI thread, and this runs off it on the external
        // path — `CustomTabsService` calls in on a binder thread — so it has to
        // be a dispatch either way. `immediate` would then run inline for
        // everyone already on the main thread, i.e. in the middle of this
        // function, and forcing the engine there would put the built-in
        // extensions in front of the uBO managed pref that is written for them
        // below. Posting keeps every ordering in this function as it was.
        GlobalScope.launch(Dispatchers.Main) {
            EngineWarmupSession.start(newComponents)
        }

        //newComponents.crashReporter.install(applicationContext)

        //Facts.registerProcessor(LogFactProcessor())

        val megazordNetworkSetup = MegazordSetup.setupMegazordNetwork(
            context = newComponents.profileApplicationContext,
            client = lazy { newComponents.core.client },
        )

        if (mode == ComponentsMode.FULL) {
            newComponents.core.engine.warmUp()
            applyStartupUBlockFilterListsPref(newComponents)
            startPrivateTabsNotificationFeature(newComponents)
        }

        fun restorePreviousCustomTabs() {
            if (previousCustomTabs.isEmpty()) return
            for (tab in previousCustomTabs) {
                val existing = newComponents.core.store.state.findCustomTab(tab.id)
                if (existing == null) {
                    newComponents.core.store.dispatch(
                        CustomTabListAction.AddCustomTabAction(tab)
                    )
                }
            }
        }

        if (mode == ComponentsMode.FULL) {
            if (!megazordNetworkSetup.isCompleted) {
                runBlocking {
                    megazordNetworkSetup.await()
                }
            }

            val isFirstFullSetup = previousMode != ComponentsMode.FULL
            val restoreJob = restoreBrowserState(
                newComponents,
                restoreTabsWithoutResumingSelection = isFirstFullSetup,
            )
            if (previousCustomTabs.isNotEmpty()) {
                restoreJob.invokeOnCompletion {
                    GlobalScope.launch(Dispatchers.Main) {
                        restorePreviousCustomTabs()
                    }
                }
            }
            restoreDownloads(newComponents)

            try {
                GlobalPlacesDependencyProvider.initialize(newComponents.core.historyStorage)

                newComponents.core.historyMetadataService.cleanup(
                    System.currentTimeMillis() - HISTORY_METADATA_MAX_AGE_IN_MS,
                )

                GlobalAddonDependencyProvider.initialize(
                    newComponents.core.addonManager,
                    newComponents.core.addonUpdater,
                )

                WebExtensionSupport.initialize(
                    newComponents.core.engine,
                    newComponents.core.store,
                    // Decides whether an extension popup opens in a private engine
                    // session, and whether extensions that aren't allowed in private
                    // browsing are suppressed at all. We have no app-wide browsing
                    // mode, so the selected tab stands in for it.
                    isInPrivateBrowsingMode = {
                        newComponents.core.store.state.selectedTab?.content?.private == true
                    },
                    onNewTabOverride = { _, engineSession, url, active, isPrivate ->
                        newComponents.useCases.tabsUseCases.addTab(
                            url,
                            selectTab = active,
                            engineSession = engineSession,
                            private = isPrivate
                        )
                    },
                    onCloseTabOverride = { _, sessionId ->
                        newComponents.useCases.tabsUseCases.removeTab(sessionId)
                    },
                    onSelectTabOverride = { _, sessionId ->
                        newComponents.useCases.tabsUseCases.selectTab(sessionId)
                    },
                    onUpdatePermissionRequest = newComponents.core.addonUpdater::onUpdatePermissionRequest,
                    onExtensionsLoaded = { extensions ->
                        val addonPrefs = AddonPrefs.get(applicationContext)
                        val autoUpdateEnabled =
                            addonPrefs.getBoolean(AddonPrefs.PREF_AUTO_UPDATE_ENABLED, true)
                        val autoUpdateDisabledAddonIds =
                            addonPrefs.getStringSet(AddonPrefs.PREF_AUTO_UPDATE_DISABLED_IDS, emptySet())
                                ?: emptySet()
                        val localFileAddonIds =
                            addonPrefs.getStringSet(AddonPrefs.PREF_LOCAL_FILE_ADDON_IDS, emptySet())
                                ?: emptySet()
                        if (autoUpdateEnabled) {
                            newComponents.core.addonUpdater.registerForFutureUpdates(
                                extensions.filterNot { extension ->
                                    autoUpdateDisabledAddonIds.contains(extension.id) ||
                                        localFileAddonIds.contains(extension.id)
                                },
                            )
                        }
                        newComponents.core.supportedAddonsChecker.registerForChecks()
                    },
                )
            } catch (e: UnsupportedOperationException) {
                // Web extension support is only available for engine gecko
                Logger.error("Failed to initialize web extension support", e)
            }

            // Answer browser.bookmarks requests from extensions (e.g. floccus)
            // out of the shared application-services Places store.
            GeckoBookmarksExtensionBridge.register()

            GlobalScope.launch(Dispatchers.IO) {
                newComponents.core.fileUploadsDirCleaner.cleanUploadsDirectory()
            }

            // Eagerly initialize account manager so sync starts
            newComponents.backgroundServices.accountManager

            // Start FxA web channel feature for OAuth redirect handling
            newComponents.services.fxaWebChannelFeature.start()
        } else {
            restorePreviousCustomTabs()
        }

        newComponents.push.initialize()
    }

    @Synchronized
    fun ensureExternalComponents(
        baseContext: Context,
        logLevel: Log.Priority = Log.Priority.WARN,
    ): Boolean {
        if (_components != null) {
            return true
        }

        // Arbitrated, not re-read from disk. This used to parse `current_profile`
        // itself, which meant a headless start could bind a different profile than
        // the one the process had already committed to.
        //
        // Resolve-only, deliberately: building an engine is not a reason to settle
        // the profile question. Callers that legitimately may bind the candidate go
        // through [bindCandidateAndEnsureExternalComponents]; everything else — an
        // FxA callback, an already-classified custom tab — refuses here rather than
        // committing a profile nobody chose.
        val profileContext = ActiveProfile.resolveContext(baseContext) ?: return false
        val messenger = NoopBinaryMessenger()

        HistoryExclusions.loadPersisted(baseContext.applicationContext)
        historyEvents = null

        val selectionActionEvents = GeckoSelectionActionEvents(messenger)
        val selectionActionDelegate = DefaultSelectionActionDelegate(selectionActionEvents) { actions ->
            val processTextAction = "android.intent.action.PROCESS_TEXT"
            val withoutProcessText = actions.filter { it != processTextAction }.toTypedArray()
            val processTextActions = actions.filter { it == processTextAction }.toTypedArray()
            withoutProcessText + processTextActions
        }

        val contentBlocking = ContentBlocking(
            queryParameterStripping = QueryParameterStripping.ENABLED,
            queryParameterStrippingAllowList = "",
            queryParameterStrippingStripList = DEFAULT_QUERY_PARAMETER_STRIPPING_STRIP_LIST,
            bounceTrackingProtectionMode = BounceTrackingProtectionMode.ENABLED,
        )

        setUp(
            applicationContext = profileContext,
            flutterEvents = GeckoStateEvents(messenger),
            readerViewController = ReaderViewController(messenger),
            selectionAction = selectionActionDelegate,
            addonEvents = GeckoAddonEvents(messenger),
            tabContentEvents = GeckoTabContentEvents(messenger),
            extensionEvents = BrowserExtensionEvents(messenger),
            syncStateEvents = null,
            logLevel = logLevel,
            contentBlocking = contentBlocking,
            addonCollection = null,
            fxaServerOverride = null,
            syncTokenServerOverride = null,
            mode = ComponentsMode.EXTERNAL,
        )

        engineSettingsApi = GeckoEngineSettingsApiImpl(baseContext.applicationContext)
        return true
    }

    /**
     * Commits the startup candidate, then creates the headless component set.
     *
     * For entry points that legitimately have no profile of their own to name — a
     * custom tab, a share-as-custom-tab, a queued push delivery. They may bind the
     * *candidate*, never a profile of their own choosing, and only while the process
     * is still unresolved; anything else returns `false` so the caller retries or
     * fails safely.
     */
    fun bindCandidateAndEnsureExternalComponents(
        baseContext: Context,
        logLevel: Log.Priority = Log.Priority.WARN,
    ): Boolean {
        if (components != null) return true
        if (ActiveProfile.resolveOrCommitContext(baseContext) == null) return false
        return ensureExternalComponents(baseContext, logLevel)
    }
}
