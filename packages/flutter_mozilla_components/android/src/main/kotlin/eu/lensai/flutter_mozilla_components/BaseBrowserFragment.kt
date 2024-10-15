package eu.lensai.flutter_mozilla_components


import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.annotation.CallSuper
import androidx.fragment.app.Fragment
import eu.lensai.flutter_mozilla_components.databinding.FragmentBrowserBinding
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.app.links.AppLinksFeature
import mozilla.components.feature.downloads.DownloadsFeature
import mozilla.components.feature.downloads.manager.FetchDownloadManager
import mozilla.components.feature.privatemode.feature.SecureWindowFeature
import mozilla.components.feature.prompts.PromptFeature
import mozilla.components.feature.session.SessionFeature
import mozilla.components.feature.session.SwipeRefreshFeature
import mozilla.components.feature.sitepermissions.SitePermissionsFeature
import mozilla.components.feature.sitepermissions.SitePermissionsRules
import mozilla.components.feature.sitepermissions.SitePermissionsRules.AutoplayAction
import mozilla.components.support.base.feature.ActivityResultHandler
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.feature.ViewBoundFeatureWrapper
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.arch.lifecycle.addObservers
import mozilla.components.support.locale.ActivityContextWrapper
import mozilla.components.support.utils.ext.requestInPlacePermissions

/**
 * Base fragment extended by [BrowserFragment] and [ExternalAppBrowserFragment].
 * This class only contains shared code focused on the main browsing content.
 * UI code specific to the app or to custom tabs can be found in the subclasses.
 */
@SuppressWarnings("LargeClass")
abstract class BaseBrowserFragment : Fragment(), UserInteractionHandler, ActivityResultHandler {
    private val sessionFeature = ViewBoundFeatureWrapper<SessionFeature>()
    private val downloadsFeature = ViewBoundFeatureWrapper<DownloadsFeature>()
    private val appLinksFeature = ViewBoundFeatureWrapper<AppLinksFeature>()
    private val promptFeature = ViewBoundFeatureWrapper<PromptFeature>()
    private val sitePermissionsFeature = ViewBoundFeatureWrapper<SitePermissionsFeature>()
    private val swipeRefreshFeature = ViewBoundFeatureWrapper<SwipeRefreshFeature>()

    protected val sessionId: String?
        get() = arguments?.getString(SESSION_ID_KEY)

    private val activityResultHandler: List<ViewBoundFeatureWrapper<*>> = listOf(
        promptFeature,
    )

    private var _engineView: EngineView? = null
    private var _binding: FragmentBrowserBinding? = null
    private var _components: Components? = null

    val binding get() = _binding!!
    val components get() = _components!!
    val engineView get() = _engineView!!

    protected abstract fun createEngine(components: Components) : EngineView

    @CallSuper
    @Suppress("LongMethod")
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBrowserBinding.inflate(inflater, container, false)
        _components = GlobalComponents.components

        _engineView = createEngine(components)
        _components?.engineView = _engineView

        val engineNativeView = engineView.asView()
        // Set layout parameters
        val layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        engineNativeView.layoutParams = layoutParams

        binding.swipeToRefresh.addView(engineNativeView)

        val originalContext = ActivityContextWrapper.getOriginalContext(requireActivity())
        engineView.setActivityContext(originalContext)

        sessionFeature.set(
            feature = SessionFeature(
                components.store,
                components.sessionUseCases.goBack,
                components.sessionUseCases.goForward,
                engineView,
                sessionId,
            ),
            owner = this,
            view = binding.root,
        )

        swipeRefreshFeature.set(
            feature = SwipeRefreshFeature(
                components.store,
                components.sessionUseCases.reload,
                binding.swipeToRefresh,
            ),
            owner = this,
            view = binding.root,
        )

        downloadsFeature.set(
            feature = DownloadsFeature(
                requireContext().applicationContext,
                store = components.store,
                useCases = components.downloadsUseCases,
                fragmentManager = childFragmentManager,
                onDownloadStopped = { download, id, status ->
                    Logger.debug("Download done. ID#$id $download with status $status")
                },
                downloadManager = FetchDownloadManager(
                    requireContext().applicationContext,
                    components.store,
                    DownloadService::class,
                    notificationsDelegate = components.notificationsDelegate,
                ),
                tabId = sessionId,
                onNeedToRequestPermissions = { permissions ->
                    requestInPlacePermissions(REQUEST_KEY_DOWNLOAD_PERMISSIONS, permissions) { result ->
                        downloadsFeature.get()?.onPermissionsResult(
                            result.keys.toTypedArray(),
                            result.values.map {
                                when (it) {
                                    true -> PackageManager.PERMISSION_GRANTED
                                    false -> PackageManager.PERMISSION_DENIED
                                }
                            }.toIntArray(),
                        )
                    }
                },
            ),
            owner = this,
            view = binding.root,
        )

        appLinksFeature.set(
            feature = AppLinksFeature(
                context = requireContext(),
                store = components.store,
                sessionId = sessionId,
                fragmentManager = parentFragmentManager,
                launchInApp = { components.preferences.getBoolean(DefaultComponents.PREF_LAUNCH_EXTERNAL_APP, false) },
                loadUrlUseCase = components.sessionUseCases.loadUrl,
            ),
            owner = this,
            view = binding.root,
        )

        promptFeature.set(
            feature = PromptFeature(
                fragment = this,
                store = components.store,
                customTabId = sessionId,
                tabsUseCases = components.tabsUseCases,
                fragmentManager = parentFragmentManager,
                fileUploadsDirCleaner = components.fileUploadsDirCleaner,
                onNeedToRequestPermissions = { permissions ->
                    requestInPlacePermissions(REQUEST_KEY_PROMPT_PERMISSIONS, permissions) { result ->
                        promptFeature.get()?.onPermissionsResult(
                            result.keys.toTypedArray(),
                            result.values.map {
                                when (it) {
                                    true -> PackageManager.PERMISSION_GRANTED
                                    false -> PackageManager.PERMISSION_DENIED
                                }
                            }.toIntArray(),
                        )
                    }
                },
            ),
            owner = this,
            view = binding.root,
        )

        sitePermissionsFeature.set(
            feature = SitePermissionsFeature(
                context = requireContext(),
                sessionId = sessionId,
                storage = components.permissionStorage,
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
                ),
                onNeedToRequestPermissions = { permissions ->
                    requestInPlacePermissions(REQUEST_KEY_SITE_PERMISSIONS, permissions) { result ->
                        sitePermissionsFeature.get()?.onPermissionsResult(
                            result.keys.toTypedArray(),
                            result.values.map {
                                when (it) {
                                    true -> PackageManager.PERMISSION_GRANTED
                                    false -> PackageManager.PERMISSION_DENIED
                                }
                            }.toIntArray(),
                        )
                    }
                },
                onShouldShowRequestPermissionRationale = { shouldShowRequestPermissionRationale(it) },
                store = components.store,
            ),
            owner = this,
            view = binding.root,
        )

        val secureWindowFeature = SecureWindowFeature(
            window = requireActivity().window,
            store = components.store,
            customTabId = sessionId,
        )

        // Observe the lifecycle for supported features
        lifecycle.addObservers(
            secureWindowFeature,
        )

        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
//        consumeFlow(components.store) { flow ->
//            flow.mapNotNull { state -> state.findCustomTabOrSelectedTab(sessionId) }
//                .ifAnyChanged { tab ->
//                    arrayOf(
//                        tab.content.loading,
//                        tab.content.canGoBack,
//                        tab.content.canGoForward,
//                    )
//                }
//                .collect {
//                    binding.toolbar.invalidateActions()
//                }
//        }
    }

    @CallSuper
    override fun onBackPressed(): Boolean =
        listOf(sessionFeature).any { it.onBackPressed() }

    @CallSuper
    override fun onActivityResult(requestCode: Int, data: Intent?, resultCode: Int): Boolean {
        return activityResultHandler.any { it.onActivityResult(requestCode, data, resultCode) }
    }

    companion object {
        private const val SESSION_ID_KEY = "session_id"

        private const val REQUEST_KEY_DOWNLOAD_PERMISSIONS = "downloadFeature"
        private const val REQUEST_KEY_PROMPT_PERMISSIONS = "promptFeature"
        private const val REQUEST_KEY_SITE_PERMISSIONS = "sitePermissionsFeature"

        @JvmStatic
        protected fun Bundle.putSessionId(sessionId: String?) {
            putString(SESSION_ID_KEY, sessionId)
        }
    }
    override fun onDestroyView() {
        super.onDestroyView()
        engineView.setActivityContext(null)
        _binding = null
    }
}
