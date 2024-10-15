package eu.lensai.flutter_mozilla_components.api

import android.util.Log
import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.ext.toWebPBytes
import eu.lensai.flutter_mozilla_components.pigeons.GeckoSessionApi
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.lensai.flutter_mozilla_components.pigeons.LoadUrlFlagsValue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.selector.selectedTab
import eu.lensai.flutter_mozilla_components.pigeons.TranslationOptions as PigeonTranslationOptions
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.base.images.ImageLoadRequest
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.concept.engine.translate.TranslationOptions
import mozilla.components.feature.session.SessionUseCases
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

class GeckoSessionApiImpl : GeckoSessionApi {
    private val sessionUseCases: SessionUseCases by lazy { GlobalComponents.components!!.sessionUseCases }
    private val store: BrowserStore by lazy { GlobalComponents.components!!.store }
    private val state: BrowserState by lazy { GlobalComponents.components!!.store.state }
    private val thumbnailStorage: ThumbnailStorage by lazy { GlobalComponents.components!!.thumbnailStorage }
    private val events: GeckoStateEvents by lazy { GlobalComponents.components!!.flutterEvents }
    private val engineView: EngineView? by lazy { GlobalComponents.components!!.engineView }

    override fun loadUrl(
        tabId: String?,
        url: String,
        flags: LoadUrlFlagsValue,
        additionalHeaders: Map<String, String>?
    ) {
        sessionUseCases.loadUrl(
            url = url,
            sessionId = tabId,
            flags = EngineSession.LoadUrlFlags.select(flags.value.toInt()),
            additionalHeaders = additionalHeaders
        )
    }

    override fun loadData(tabId: String?, data: String, mimeType: String, encoding: String) {
        sessionUseCases.loadData(
            data = data,
            tabId = tabId ?: state.selectedTabId,
            mimeType = mimeType,
            encoding = encoding
        )
    }

    override fun reload(tabId: String?, flags: LoadUrlFlagsValue) {
        sessionUseCases.reload(
            tabId = tabId ?: state.selectedTabId,
            flags = EngineSession.LoadUrlFlags.select(flags.value.toInt())
        )
    }

    override fun stopLoading(tabId: String?) {
        sessionUseCases.stopLoading(tabId = tabId ?: state.selectedTabId)
    }

    override fun goBack(tabId: String?, userInteraction: Boolean) {
        sessionUseCases.goBack(
            tabId = tabId ?: state.selectedTabId,
            userInteraction = userInteraction
        )
    }

    override fun goForward(tabId: String?, userInteraction: Boolean) {
        sessionUseCases.goForward(
            tabId = tabId ?: state.selectedTabId,
            userInteraction = userInteraction
        )
    }

    override fun goToHistoryIndex(index: Long, tabId: String?) {
        sessionUseCases.goToHistoryIndex(
            tabId = tabId ?: state.selectedTabId,
            index = index.toInt()
        )
    }

    override fun requestDesktopSite(tabId: String?, enable: Boolean) {
        sessionUseCases.requestDesktopSite(
            tabId = tabId ?: state.selectedTabId,
            enable = enable
        )
    }

    override fun exitFullscreen(tabId: String?) {
        sessionUseCases.exitFullscreen(tabId = tabId ?: state.selectedTabId)
    }

    override fun saveToPdf(tabId: String?) {
        sessionUseCases.saveToPdf(tabId = tabId ?: state.selectedTabId)
    }

    override fun printContent(tabId: String?) {
        sessionUseCases.printContent(tabId = tabId ?: state.selectedTabId)
    }

    override fun translate(
        tabId: String?,
        fromLanguage: String,
        toLanguage: String,
        options: PigeonTranslationOptions?
    ) {
        sessionUseCases.translate(
            tabId = tabId ?: state.selectedTabId,
            fromLanguage = fromLanguage,
            toLanguage = toLanguage,
            options = options?.let { TranslationOptions(downloadModel = it.downloadModel) }
        )
    }

    override fun translateRestore(tabId: String?) {
        sessionUseCases.translateRestore(tabId = tabId ?: state.selectedTabId)
    }

    override fun crashRecovery(tabIds: List<String>?) {
        if (tabIds != null) {
            sessionUseCases.crashRecovery.invoke(tabIds = tabIds)
        } else {
            sessionUseCases.crashRecovery.invoke()
        }
    }

    override fun purgeHistory() {
        sessionUseCases.purgeHistory()
    }

    override fun updateLastAccess(tabId: String?, lastAccess: Long?) {
        sessionUseCases.updateLastAccess(
            tabId = tabId ?: state.selectedTabId,
            lastAccess = lastAccess ?: System.currentTimeMillis()
        )
    }

    override fun requestScreenshot(callback: (Result<ByteArray?>) -> Unit) {
        val tab = state.selectedTab
        if (tab != null) {
            engineView?.captureThumbnail { bitmap ->
                if (bitmap != null) {
                    store.dispatch(ContentAction.UpdateThumbnailAction(tab.id, bitmap))
                    val compressed = bitmap.toWebPBytes()
                    callback(Result.success(compressed))
                } else {
                    callback(Result.success(null))
                }
            }
        } else {
            callback(Result.failure(Exception("No selected tab for screenshot")))
        }
    }
}
