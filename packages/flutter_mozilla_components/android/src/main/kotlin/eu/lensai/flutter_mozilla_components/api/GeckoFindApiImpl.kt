package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoFindApi
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.EngineSession

class GeckoFindApiImpl : GeckoFindApi {
    private val state: BrowserState by lazy { GlobalComponents.components!!.store.state }

    private fun sessionByTabId(tabId: String?) : EngineSession? {
        val loadSessionId = tabId
            ?: state.selectedTabId

        if (loadSessionId == null) {
            return null
        }

        val tab = state.findTabOrCustomTab(loadSessionId)
        return tab?.engineState?.engineSession
    }

    override fun findAll(tabId: String?, text: String) {
        val engineSession = sessionByTabId(tabId)
        engineSession?.findAll(text)
    }

    override fun findNext(tabId: String?, forward: Boolean) {
        val engineSession = sessionByTabId(tabId)
        engineSession?.findNext(forward)
    }

    override fun clearMatches(tabId: String?) {
        val engineSession = sessionByTabId(tabId)
        engineSession?.clearFindMatches()
    }
}