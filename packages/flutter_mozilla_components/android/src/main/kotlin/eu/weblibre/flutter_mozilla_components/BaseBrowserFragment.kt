/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.SystemClock
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager.LayoutParams.FLAG_SECURE
import android.widget.FrameLayout
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.CallSuper
import androidx.core.content.edit
import androidx.fragment.app.Fragment
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.databinding.FragmentBrowserBinding
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import eu.weblibre.flutter_mozilla_components.ext.toPigeonDownloadState
import eu.weblibre.flutter_mozilla_components.feature.AppLifecycleFeature
import eu.weblibre.flutter_mozilla_components.feature.BrowserHandlingScrollFeature
import eu.weblibre.flutter_mozilla_components.feature.GestureAwareSwipeRefreshFeature
import eu.weblibre.flutter_mozilla_components.feature.KeyboardVisibilityFeature
import eu.weblibre.flutter_mozilla_components.feature.ReadabilityExtractFeature
import eu.weblibre.flutter_mozilla_components.feature.WebExtensionToolbarFeature
import eu.weblibre.flutter_mozilla_components.integration.ReaderViewIntegration
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import eu.weblibre.flutter_mozilla_components.applinks.AppLinkRuntime
import eu.weblibre.flutter_mozilla_components.applinks.NativeAppLinkPromptFeature
import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkStores
import io.flutter.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.distinctUntilChangedBy
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.state.selector.findCustomTabOrSelectedTab
import mozilla.components.browser.state.selector.findTabOrCustomTabOrSelectedTab
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.WebExtensionState
import mozilla.components.browser.thumbnails.BrowserThumbnails
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.accounts.FxaCapability
import mozilla.components.feature.accounts.FxaWebChannelFeature
import mozilla.components.feature.downloads.DownloadsFeature
import mozilla.components.feature.downloads.manager.FetchDownloadManager
import mozilla.components.feature.downloads.temporary.CopyDownloadFeature
import mozilla.components.feature.downloads.temporary.ShareResourceFeature
import mozilla.components.feature.media.fullscreen.MediaSessionFullscreenFeature
import mozilla.components.feature.privatemode.feature.SecureWindowFeature
import mozilla.components.feature.prompts.PromptFeature
import mozilla.components.feature.prompts.file.AndroidPhotoPicker
import mozilla.components.feature.session.FullScreenFeature
import mozilla.components.feature.session.PictureInPictureFeature
import mozilla.components.feature.session.SessionFeature
import mozilla.components.feature.sitepermissions.SitePermissionsFeature
import mozilla.components.feature.sitepermissions.SitePermissionsRules
import mozilla.components.feature.sitepermissions.SitePermissionsRules.AutoplayAction
import mozilla.components.feature.tabs.WindowFeature
import mozilla.components.feature.webauthn.WebAuthnFeature
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.ActivityResultHandler
import mozilla.components.support.base.feature.PermissionsFeature
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.view.enterImmersiveMode
import mozilla.components.support.ktx.android.view.exitImmersiveMode
import mozilla.components.support.locale.ActivityContextWrapper
import mozilla.components.support.utils.DefaultDownloadFileUtils
import mozilla.components.support.webextensions.WebExtensionPopupObserver

/**
 * Base fragment extended by [BrowserFragment] and [ExternalAppBrowserFragment].
 * This class only contains shared code focused on the main browsing content.
 * UI code specific to the app or to custom tabs can be found in the subclasses.
 */
@SuppressWarnings("LargeClass")
abstract class BaseBrowserFragment : Fragment(), UserInteractionHandler, ActivityResultHandler {
    protected val sessionFeature = ViewBoundFeatureWrapper<SessionFeature>()
    private val shareResourceFeature = ViewBoundFeatureWrapper<ShareResourceFeature>()
    private val copyDownloadFeature = ViewBoundFeatureWrapper<CopyDownloadFeature>()
    private val downloadsFeature = ViewBoundFeatureWrapper<DownloadsFeature>()
    // Native prompt for Custom Tab sessions with no Flutter engine.
    private val nativeAppLinkPromptFeature = ViewBoundFeatureWrapper<NativeAppLinkPromptFeature>()
    private val promptFeature = ViewBoundFeatureWrapper<PromptFeature>()
    // Web extension prompts are deliberately *not* bound here: this fragment only
    // exists once the engine has been painted, so a start that never showed a tab
    // had nothing to answer an install prompt with. `WebExtensionPromptHost` owns
    // them against the resumed activity instead.
    private val sitePermissionsFeature = ViewBoundFeatureWrapper<SitePermissionsFeature>()
    private val swipeRefreshFeature = ViewBoundFeatureWrapper<GestureAwareSwipeRefreshFeature>()
    private val secureWindowFeature = ViewBoundFeatureWrapper<SecureWindowFeature>()
    private val fullScreenFeature = ViewBoundFeatureWrapper<FullScreenFeature>()
    private val mediaSessionFullscreenFeature =
        ViewBoundFeatureWrapper<MediaSessionFullscreenFeature>()

    private val webAuthnFeature = ViewBoundFeatureWrapper<WebAuthnFeature>()
    private val fxaWebChannelFeature = ViewBoundFeatureWrapper<FxaWebChannelFeature>()

    private var pictureInPictureFeature: PictureInPictureFeature? = null

    private val windowFeature = ViewBoundFeatureWrapper<WindowFeature>()
    private val thumbnailsFeature = ViewBoundFeatureWrapper<BrowserThumbnails>()
    val readerViewFeature = ViewBoundFeatureWrapper<ReaderViewIntegration>()
    private val readabilityExtractFeature = ViewBoundFeatureWrapper<ReadabilityExtractFeature>()
    private val webExtensionPopupObserver = ViewBoundFeatureWrapper<WebExtensionPopupObserver>()
    private val webExtToolbarFeature = ViewBoundFeatureWrapper<WebExtensionToolbarFeature>()

    // Keyboard visibility detection feature
    private var keyboardVisibilityFeature: KeyboardVisibilityFeature? = null

    // Browser scroll-handling detection feature
    private var browserHandlingScrollFeature: BrowserHandlingScrollFeature? = null

    protected open val shouldStartBrowserHandlingScrollFeature: Boolean = true

    // Registers a photo picker activity launcher in single-select mode.
    private val singleMediaPicker =
        AndroidPhotoPicker.singleMediaPicker(
            { this },
            { promptFeature.get() },
        )

    // Registers a photo picker activity launcher in multi-select mode.
    private val multipleMediaPicker =
        AndroidPhotoPicker.multipleMediaPicker(
            { this },
            { promptFeature.get() },
        )

    private val sessionId: String?
        get() = arguments?.getString(SESSION_ID_KEY)

    private var _binding: FragmentBrowserBinding? = null

    /** Pending tick of the components wait, so [onDestroyView] can cancel it. */
    private var componentsWait: Runnable? = null
    val binding get() = _binding!!

    protected val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private val backButtonHandler: List<ViewBoundFeatureWrapper<*>> = listOf(
        fullScreenFeature,
        sessionFeature,
    )

    private val activityResultHandler: List<ViewBoundFeatureWrapper<*>> = listOf(
        promptFeature,
        webAuthnFeature
    )

    protected abstract fun createEngine(components: Components): EngineView

    // Track this fragment's EngineView instance to reassign singleton when fragment becomes active
    private var fragmentEngineView: EngineView? = null

    private lateinit var requestDownloadPermissionsLauncher: ActivityResultLauncher<Array<String>>
    private lateinit var requestSitePermissionsLauncher: ActivityResultLauncher<Array<String>>
    private lateinit var requestPromptsPermissionsLauncher: ActivityResultLauncher<Array<String>>

    private fun updateSecureWindowState() {
        val tab = components.core.store.state.findCustomTabOrSelectedTab(sessionId)
        val shouldSecure = GlobalComponents.shouldSecureWindow(tab?.content?.private == true)

        if (shouldSecure) {
            requireActivity().window.addFlags(FLAG_SECURE)
        } else {
            requireActivity().window.clearFlags(FLAG_SECURE)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestDownloadPermissionsLauncher =
            registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { results ->
                val permissions = results.keys.toTypedArray()
                val grantResults =
                    results.values.map {
                        if (it) PackageManager.PERMISSION_GRANTED else PackageManager.PERMISSION_DENIED
                    }.toIntArray()
                downloadsFeature.withFeature {
                    it.onPermissionsResult(permissions, grantResults)
                }
            }

        requestSitePermissionsLauncher =
            registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { results ->
                val permissions = results.keys.toTypedArray()
                val grantResults =
                    results.values.map {
                        if (it) PackageManager.PERMISSION_GRANTED else PackageManager.PERMISSION_DENIED
                    }.toIntArray()
                sitePermissionsFeature.withFeature {
                    it.onPermissionsResult(permissions, grantResults)
                }
            }

        requestPromptsPermissionsLauncher =
            registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { results ->
                val permissions = results.keys.toTypedArray()
                val grantResults =
                    results.values.map {
                        if (it) PackageManager.PERMISSION_GRANTED else PackageManager.PERMISSION_DENIED
                    }.toIntArray()
                promptFeature.withFeature {
                    it.onPermissionsResult(permissions, grantResults)
                }
            }
    }

    @CallSuper
    @Suppress("LongMethod")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        scheduleComponentsWait(view, SystemClock.elapsedRealtime(), delayMs = 0)
    }

    /**
     * Queues the next tick of the components wait, keeping it cancellable.
     *
     * The handle matters: `postDelayed` outlives detachment — a pending
     * runnable is held in the view's action queue and replayed on the next
     * attach — so an uncancelled tick can run after `onDestroyView` has torn
     * the binding down, against a view that is no longer the fragment's.
     */
    private fun scheduleComponentsWait(view: View, startedAt: Long, delayMs: Long) {
        val tick = Runnable { awaitComponentsThenSetupEngine(view, startedAt) }
        componentsWait = tick
        view.postDelayed(tick, delayMs)
    }

    /**
     * Polls for [GlobalComponents] and builds the engine as soon as they exist.
     *
     * A single short retry is not enough on the headless launch path: a Custom
     * Tab or PWA started into a fresh process shows this fragment while the app
     * half is still booting Flutter, and `GlobalComponents.setUp` runs a couple
     * of seconds later — longer under the jank of a cold start. Building the
     * engine before that throws, and the failure used to restart the whole app
     * into the main browser, which is a far worse outcome than waiting.
     *
     * The deadline bounds the wait so a genuinely absent set-up still resolves
     * rather than leaving a blank window forever.
     */
    private fun awaitComponentsThenSetupEngine(view: View, startedAt: Long) {
        componentsWait = null

        // The window can be gone by the time a queued tick runs, and every step
        // below needs a live view: `binding` throws once `onDestroyView` has
        // nulled it.
        if (_binding == null) return

        if (GlobalComponents.components != null) {
            // Only signal availability when the engine was actually built.
            // `createAndSetupEngine` races components a second time and calls
            // `onComponentsUnavailable` when it loses, and firing both hooks
            // would have a subclass tearing this window down and installing
            // features into it at once.
            if (createAndSetupEngine(view)) {
                onComponentsAvailable(view)
            }
            return
        }

        val waited = SystemClock.elapsedRealtime() - startedAt
        if (waited >= COMPONENTS_WAIT_TIMEOUT_MS) {
            Log.w(
                "EngineCreation",
                "Components still not initialized after ${waited}ms; giving up on this window",
            )
            // Deliberately not a restart: the process is healthy, this window
            // just has nothing to render into. Leave it to the activity, which
            // knows whether it can fall back to the browser.
            onComponentsUnavailable()
            return
        }

        scheduleComponentsWait(view, startedAt, COMPONENTS_WAIT_INTERVAL_MS)
    }

    /**
     * Called once [GlobalComponents] exist and the engine has been built.
     *
     * Subclasses install their own component-dependent features here rather
     * than posting a second, shorter wait of their own — which would give up
     * silently on exactly the cold start this wait exists for.
     */
    protected open fun onComponentsAvailable(view: View) = Unit

    /**
     * Called when [GlobalComponents] never arrived within the deadline.
     *
     * Subclasses that can do something better than an empty window — an
     * external-app window can hand the launch to the main browser — override
     * this.
     */
    protected open fun onComponentsUnavailable() = Unit

    private fun restartApp(context: Context) {
        val packageManager = context.packageManager
        val intent = packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)

        if (context is Activity) {
            context.finish()
        }

        Runtime.getRuntime().exit(0)
    }

    private fun createAndSetupEngine(view: View): Boolean {
        try {
            // Set layout parameters
            val layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )

            val profileContext =
                ProfileContext(requireContext(), components.profileApplicationContext.relativePath)

            val engineView = createEngine(components)
            fragmentEngineView = engineView  // Track for lifecycle management
            val originalContext =
                ActivityContextWrapper.getOriginalContext(requireActivity()) ?: requireActivity()
            val engineNativeView = engineView.asView()
            engineNativeView.layoutParams = layoutParams

            engineView.setActivityContext(originalContext)

            binding.swipeToRefresh.addView(engineNativeView)

            components.activeEngineView = engineView

            sessionFeature.set(
                feature = SessionFeature(
                    components.core.store,
                    components.useCases.sessionUseCases.goBack,
                    components.useCases.sessionUseCases.goForward,
                    engineView,
                    sessionId,
                ),
                owner = this,
                view = view,
            )

            swipeRefreshFeature.set(
                feature = GestureAwareSwipeRefreshFeature(
                    components.core.store,
                    components.useCases.sessionUseCases.reload,
                    binding.swipeToRefresh,
                ),
                owner = this,
                view = view,
            )

            // Apply pull-to-refresh setting
            binding.swipeToRefresh.isEnabled = GlobalComponents.pullToRefreshEnabled
            GlobalComponents.onPullToRefreshEnabledChanged = { enabled ->
                _binding?.swipeToRefresh?.isEnabled = enabled
            }
            GlobalComponents.onSecureWindowSettingsChanged = {
                updateSecureWindowState()
            }
            updateSecureWindowState()

            shareResourceFeature.set(
                ShareResourceFeature(
                    context = components.profileApplicationContext,
                    httpClient = components.core.client,
                    store = components.core.store,
                    tabId = sessionId,
                ),
                owner = this,
                view = view,
            )

            copyDownloadFeature.set(
                CopyDownloadFeature(
                    context = components.profileApplicationContext,
                    httpClient = components.core.client,
                    store = components.core.store,
                    tabId = sessionId,
                    onCopyConfirmation = {},
                ),
                owner = this,
                view = view,
            )

            downloadsFeature.set(
                feature = DownloadsFeature(
                    components.profileApplicationContext,
                    store = components.core.store,
                    useCases = components.useCases.downloadsUseCases,
                    fragmentManager = childFragmentManager,
                    onDownloadStopped = { download, id, status ->
                        Logger.debug("Download done. ID#$id $download with status $status")
                        if (
                            status == mozilla.components.browser.state.state.content.DownloadState.Status.COMPLETED ||
                            status == mozilla.components.browser.state.state.content.DownloadState.Status.FAILED
                        ) {
                            components.flutterEvents.onDownloadStopped(
                                EventSequence.next(),
                                download.toPigeonDownloadState(status),
                            ) { _ -> }
                        }
                    },
                    downloadFileUtils = DefaultDownloadFileUtils(
                        context = components.profileApplicationContext,
                        downloadLocation = {
                            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path
                        },
                    ),
                    downloadManager = FetchDownloadManager(
                        components.profileApplicationContext,
                        components.core.store,
                        DownloadService::class,
                        notificationsDelegate = components.notificationsDelegate,
                    ),
                    tabId = sessionId,
                    onNeedToRequestPermissions = { permissions ->
                        requestDownloadPermissionsLauncher.launch(permissions)
                    },
                    shouldForwardToThirdParties = {
                        GlobalComponents.useExternalDownloadManager
                    },
                ),
                owner = this,
                view = view,
            )

            // App-link prompting: browser tabs are prompted by Flutter's AppLinkPromptHost, so only
            // native Custom Tab sessions (no Flutter engine) install a native prompt feature here.
            val nativeTabId = sessionId
            if (this is ExternalAppBrowserFragment && nativeTabId != null) {
                nativeAppLinkPromptFeature.set(
                    feature = NativeAppLinkPromptFeature(
                        context = profileContext,
                        tabId = nativeTabId,
                        store = PendingAppLinkStores.forProfile(
                            components.profileApplicationContext.relativePath,
                        ),
                        browserStore = components.core.store,
                        launcher = AppLinkRuntime.get(profileContext).launcher,
                        sessionUseCases = components.useCases.sessionUseCases,
                    ),
                    owner = this,
                    view = view,
                )
            }

            promptFeature.set(
                feature = PromptFeature(
                    fragment = this,
                    store = components.core.store,
                    customTabId = sessionId,
                    tabsUseCases = components.useCases.tabsUseCases,
                    fragmentManager = parentFragmentManager,
                    fileUploadsDirCleaner = components.core.fileUploadsDirCleaner,
                    onNeedToRequestPermissions = { permissions ->
                        requestPromptsPermissionsLauncher.launch(permissions)
                    },
                    androidPhotoPicker = AndroidPhotoPicker(
                        profileContext,
                        singleMediaPicker,
                        multipleMediaPicker,
                    ),
                ),
                owner = this,
                view = view,
            )

            sitePermissionsFeature.set(
                feature = SitePermissionsFeature(
                    context = profileContext,
                    sessionId = sessionId,
                    storage = components.core.geckoSitePermissionsStorage,
                    fragmentManager = parentFragmentManager,
                    sitePermissionsRules = SitePermissionsRules(
                        autoplayAudible = AutoplayAction.BLOCKED,
                        autoplayInaudible = AutoplayAction.BLOCKED,
                        camera = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        location = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        notification = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        microphone = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        persistentStorage = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        mediaKeySystemAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        crossOriginStorageAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        localDeviceAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                        localNetworkAccess = SitePermissionsRules.Action.ASK_TO_ALLOW,
                    ),
                    onNeedToRequestPermissions = { permissions ->
                        requestSitePermissionsLauncher.launch(permissions)
                    },
                    onShouldShowRequestPermissionRationale = {
                        shouldShowRequestPermissionRationale(
                            it
                        )
                    },
                    store = components.core.store,
                ),
                owner = this,
                view = view,
            )

            fullScreenFeature.set(
                feature = FullScreenFeature(
                    store = components.core.store,
                    sessionUseCases = components.useCases.sessionUseCases,
                    tabId = sessionId,
                    fullScreenChanged = ::fullScreenChanged,
                    viewportFitChanged = ::viewportFitChanged
                ),
                owner = this,
                view = binding.root,
            )

            components.core.store.flowScoped(viewLifecycleOwner, Dispatchers.Main) { flow ->
                flow.mapNotNull { state -> state.findTabOrCustomTabOrSelectedTab(sessionId) }
                    .distinctUntilChangedBy { tab -> tab.content.pictureInPictureEnabled }
                    .collect { tab -> pipModeChanged(tab) }
            }

            mediaSessionFullscreenFeature.set(
                feature = MediaSessionFullscreenFeature(
                    requireActivity(),
                    components.core.store,
                    sessionId,
                ),
                owner = this,
                view = binding.root,
            )

            pictureInPictureFeature = PictureInPictureFeature(
                store = components.core.store,
                activity = requireActivity(),
                tabId = sessionId,
            )

            secureWindowFeature.set(
                feature = SecureWindowFeature(
                    window = requireActivity().window,
                    store = components.core.store,
                    customTabId = sessionId,
                    isSecure = { session ->
                        GlobalComponents.shouldSecureWindow(session.content.private)
                    },
                    clearFlagOnStop = false,
                ),
                owner = this,
                view = binding.root,
            )

            webAuthnFeature.set(
                feature = WebAuthnFeature(
                    engine = components.core.engine,
                    activity = requireActivity(),
                    exitFullScreen = components.useCases.sessionUseCases.exitFullscreen::invoke,
                    currentTab = { components.core.store.state.selectedTabId },
                ),
                owner = this,
                view = view
            )

            fxaWebChannelFeature.set(
                feature = FxaWebChannelFeature(
                    customTabSessionId = sessionId,
                    runtime = components.core.engine,
                    store = components.core.store,
                    accountManager = components.backgroundServices.accountManager,
                    serverConfig = components.backgroundServices.serverConfig,
                    fxaCapabilities = setOf(FxaCapability.CHOOSE_WHAT_TO_SYNC),
                ),
                owner = this,
                view = view,
            )

            readerViewFeature.set(
                feature = ReaderViewIntegration(
                    profileContext,
                    components.core.engine,
                    components.core.store,
                    binding.readerViewBar,
                    components.events.readerViewEvents,
                    components.readerViewController,
                ),
                owner = this,
                view = view,
            )

            readabilityExtractFeature.set(
                feature = components.features.readabilityExtractFeature,
                owner = this,
                view = view,
            )

            windowFeature.set(
                feature = WindowFeature(components.core.store, components.useCases.tabsUseCases),
                owner = this,
                view = view,
            )

            thumbnailsFeature.set(
                feature = BrowserThumbnails(
                    profileContext,
                    engineView,
                    components.core.store
                ),
                owner = this,
                view = view,
            )

            webExtensionPopupObserver.set(
                feature = WebExtensionPopupObserver(components.core.store, ::openPopup),
                owner = this,
                view = view,
            )

            webExtToolbarFeature.set(
                feature = components.features.webExtensionToolbarFeature,
                owner = this,
                view = view,
            )

            components.core.historyStorage.registerStorageMaintenanceWorker()

            // Start keyboard visibility detection if viewport events are available
            GlobalComponents.viewportEvents?.let { viewportEvents ->
                keyboardVisibilityFeature = KeyboardVisibilityFeature(viewportEvents).also {
                    it.start(binding.root)
                    binding.root.post { it.checkKeyboardState() }
                }

                if (shouldStartBrowserHandlingScrollFeature) {
                    browserHandlingScrollFeature = BrowserHandlingScrollFeature(viewportEvents).also {
                        it.start()
                    }
                }
            }

            onEngineSetupComplete()

            return true
        } catch (e: Exception) {
            Log.e("EngineCreation", "Failed to create engine: ${e.message}", e)

            // Components disappearing between the check above and here is a
            // race, not a broken install, and it is not worth killing the
            // process over — that lands the user in the main browser with no
            // explanation, which is exactly what an unserved PWA launch used to
            // do. Anything else really is unrecoverable for this window.
            if (GlobalComponents.components == null) {
                onComponentsUnavailable()
                return false
            }

            context?.let { restartApp(it) }
            return false
        }
    }

    /**
     * Called after the engine view is fully set up and added to the view hierarchy.
     * Subclasses can override to perform additional setup that requires an attached engine view.
     */
    protected open fun onEngineSetupComplete() {}

    private fun openPopup(webExtensionState: WebExtensionState) {
        components.addonEvents.onWebExtensionPopupRequested(
            webExtensionState.id,
            webExtensionState.name ?: "",
        ) {}
    }

    @CallSuper
    @Suppress("LongMethod")
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentBrowserBinding.inflate(inflater, container, false)
        return binding.root
    }

    private fun fullScreenChanged(enabled: Boolean) {
        if (enabled) {
            activity?.enterImmersiveMode()
        } else {
            activity?.exitImmersiveMode()
        }
    }

    private fun viewportFitChanged(viewportFit: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            activity?.window?.attributes?.layoutInDisplayCutoutMode = viewportFit
        }
    }

    @CallSuper
    override fun onBackPressed(): Boolean {
        return backButtonHandler.any { it.onBackPressed() }
    }

    final override fun onHomePressed(): Boolean = pictureInPictureFeature?.onHomePressed() ?: false

    override fun onPictureInPictureModeChanged(enabled: Boolean) {
        pictureInPictureFeature?.onPictureInPictureModeChanged(enabled)
    }

    private fun pipModeChanged(session: SessionState) {
        if (!session.content.pictureInPictureEnabled && session.content.fullScreen && isAdded) {
            onBackPressed()
            fullScreenChanged(false)
        }
    }

    @Suppress("OVERRIDE_DEPRECATION")
    final override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        val feature: PermissionsFeature? = when (requestCode) {
            REQUEST_CODE_DOWNLOAD_PERMISSIONS -> downloadsFeature.get()
            REQUEST_CODE_PROMPT_PERMISSIONS -> promptFeature.get()
            REQUEST_CODE_APP_PERMISSIONS -> sitePermissionsFeature.get()
            else -> null
        }
        feature?.onPermissionsResult(permissions, grantResults)
    }

    @CallSuper
    override fun onActivityResult(requestCode: Int, data: Intent?, resultCode: Int): Boolean {
        return activityResultHandler.any { it.onActivityResult(requestCode, data, resultCode) }
    }

    companion object {
        private const val SESSION_ID_KEY = "session_id"

        /** How often to re-check for [GlobalComponents] while waiting. */
        private const val COMPONENTS_WAIT_INTERVAL_MS = 100L

        /**
         * How long a window waits for components before giving up.
         *
         * Sized for the headless launch path: the app half has to start the
         * Flutter engine, open four databases and run `GeckoBrowserService
         * .initialize` before `GlobalComponents.setUp` returns, which is
         * seconds on a cold start.
         */
        private const val COMPONENTS_WAIT_TIMEOUT_MS = 20_000L

        private const val REQUEST_CODE_DOWNLOAD_PERMISSIONS = 1
        private const val REQUEST_CODE_PROMPT_PERMISSIONS = 2
        private const val REQUEST_CODE_APP_PERMISSIONS = 3

        @JvmStatic
        protected fun Bundle.putSessionId(sessionId: String?) {
            putString(SESSION_ID_KEY, sessionId)
        }
    }

    override fun onResume() {
        super.onResume()
        // Reassign active engine view to this fragment's EngineView when fragment becomes active
        fragmentEngineView?.let {
            components.activeEngineView = it
        }
        // Whichever fragment resumed last is the one in front, so it owns the
        // session the process should keep prioritised when it goes to background.
        AppLifecycleFeature.setVisibleSession(this, sessionId)
        keyboardVisibilityFeature?.checkKeyboardState()
    }

    @CallSuper
    override fun onStop() {
        super.onStop()

        // Through `GlobalComponents`, not the `components` lazy: a window shown
        // during a cold headless launch can be stopped while it is still
        // waiting for set-up, and the lazy throws "Components not initialized"
        // there. No components means no session to leave fullscreen anyway.
        GlobalComponents.components
            ?.core
            ?.store
            ?.state
            ?.findTabOrCustomTabOrSelectedTab(sessionId)
            ?.let { session ->
                if (!session.content.pictureInPictureEnabled && fullScreenFeature.onBackPressed()) {
                    fullScreenChanged(false)
                }
            }
    }

    override fun onDestroyView() {
        super.onDestroyView()

        componentsWait?.let { view?.removeCallbacks(it) }
        componentsWait = null

        // Stop keyboard visibility detection
        keyboardVisibilityFeature?.stop()
        keyboardVisibilityFeature = null

        // Stop browser scroll-handling detection
        browserHandlingScrollFeature?.stop()
        browserHandlingScrollFeature = null

        // Holds the Activity, so it must not outlive the view it was created with.
        pictureInPictureFeature = null

        AppLifecycleFeature.clearVisibleSession(this)

        GlobalComponents.onPullToRefreshEnabledChanged = null
        GlobalComponents.onSecureWindowSettingsChanged = null
        val engineView = fragmentEngineView
        engineView?.setActivityContext(null)
        // Read through `GlobalComponents` rather than the `components` lazy:
        // a window that gave up waiting is destroyed without components ever
        // existing, and the lazy throws "Components not initialized" there.
        GlobalComponents.components?.let { components ->
            if (components.activeEngineView == engineView) {
                components.activeEngineView = null
            }
        }
        _binding = null
        fragmentEngineView = null
    }
}
