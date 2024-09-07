package eu.lensai.flutter_mozilla_components.api

import GeckoSessionApi
import LoadUrlFlagsValue
import android.util.Log
import eu.lensai.flutter_mozilla_components.GlobalComponents
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.translate.TranslationOptions
import TranslationOptions as PigeonTranslationOptions
import mozilla.components.feature.session.SessionUseCases

class GeckoSessionApiImpl() : GeckoSessionApi {
    private val sessionUseCases: SessionUseCases by lazy { GlobalComponents.components!!.sessionUseCases }
    private val state: BrowserState by lazy { GlobalComponents.components!!.store.state }

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
            encoding = encoding,
        )
    }

    override fun reload(tabId: String?, flags: LoadUrlFlagsValue) {
        sessionUseCases.reload(
            tabId = tabId ?: state.selectedTabId,
            flags = EngineSession.LoadUrlFlags.select(flags.value.toInt()),
        )
    }

    override fun stopLoading(tabId: String?) {
        sessionUseCases.stopLoading(
            tabId = tabId
        )
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
            enable = enable,
        )
    }

    override fun exitFullscreen(tabId: String?) {
        sessionUseCases.exitFullscreen(
            tabId = tabId ?: state.selectedTabId,
        )
    }

    override fun saveToPdf(tabId: String?) {
        sessionUseCases.saveToPdf(
            tabId = tabId ?: state.selectedTabId,
        )
    }

    override fun printContent(tabId: String?) {
        sessionUseCases.printContent(
            tabId = tabId ?: state.selectedTabId,
        )
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
            options = if (options != null) TranslationOptions(downloadModel = options.downloadModel) else null,
        )
    }

    override fun translateRestore(tabId: String?) {
        sessionUseCases.translateRestore(
            tabId = tabId ?: state.selectedTabId,
        )
    }

    override fun crashRecovery(tabIds: List<String>?) {
        if(tabIds != null) {
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
}