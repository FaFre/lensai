package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.pigeons.GeckoTabsApi
import eu.lensai.flutter_mozilla_components.pigeons.HistoryMetadataKey as PigeonHistoryMetadataKey
import eu.lensai.flutter_mozilla_components.pigeons.LoadUrlFlagsValue
import eu.lensai.flutter_mozilla_components.pigeons.RecoverableBrowserState as PigeonRecoverableBrowserState
import eu.lensai.flutter_mozilla_components.pigeons.RestoreLocation as PigeonRestoreLocation
import eu.lensai.flutter_mozilla_components.pigeons.RecoverableTab as PigeonRecoverableTab
import eu.lensai.flutter_mozilla_components.pigeons.SourceValue
import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.pigeons.RestoreLocation
import mozilla.components.browser.session.storage.RecoverableBrowserState
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.LastMediaAccessState
import mozilla.components.browser.state.state.ReaderState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.recover.RecoverableTab
import mozilla.components.browser.state.state.recover.TabState
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.storage.HistoryMetadataKey
import mozilla.components.feature.tabs.TabsUseCases
import org.json.JSONObject

class GeckoTabsApiImpl() : GeckoTabsApi {
    private val tabsUseCases: TabsUseCases by lazy { GlobalComponents.components!!.tabsUseCases }
    private val engine: Engine by lazy { GlobalComponents.components!!.engine }
    private val state: BrowserState by lazy { GlobalComponents.components!!.store.state }

    private fun restoreSource(source: SourceValue ) : SessionState.Source {
        return SessionState.Source.restore(
            source.id.toInt(),
            source.caller?.packageId,
            source.caller?.category?.value?.toInt()
        )
    }
    private fun mapTab(t: PigeonRecoverableTab) : RecoverableTab {
        return RecoverableTab(
            engineSessionState = if(t.engineSessionStateJson != null)
                engine.createSessionState(JSONObject(t.engineSessionStateJson))
            else
                null,
            state = TabState(
                id = t.state.id,
                url = t.state.url,
                parentId = t.state.parentId,
                title = t.state.title,
                searchTerm = t.state.searchTerm,
                contextId = t.state.contextId,
                readerState = ReaderState(
                    readerable = t.state.readerState.readerable,
                    active = t.state.readerState.active,
                    checkRequired = t.state.readerState.checkRequired,
                    connectRequired = t.state.readerState.connectRequired,
                    baseUrl = t.state.readerState.baseUrl,
                    activeUrl = t.state.readerState.activeUrl,
                    scrollY = t.state.readerState.scrollY?.toInt(),
                ),
                lastAccess = t.state.lastAccess,
                createdAt = t.state.createdAt,
                lastMediaAccessState = LastMediaAccessState(
                    lastMediaUrl = t.state.lastMediaAccessState.lastMediaUrl,
                    lastMediaAccess = t.state.lastMediaAccessState.lastMediaAccess,
                    mediaSessionActive = t.state.lastMediaAccessState.mediaSessionActive
                ),
                private = t.state.private,
                historyMetadata = if(t.state.historyMetadata != null)
                    HistoryMetadataKey(
                        url = t.state.historyMetadata.url,
                        searchTerm = t.state.historyMetadata.searchTerm,
                        referrerUrl = t.state.historyMetadata.referrerUrl
                    )
                else null,
                source = restoreSource(t.state.source),
                index = t.state.index.toInt(),
                hasFormData = t.state.hasFormData,
            )
        )
    }

    private fun mapRestoreLocation(t: PigeonRestoreLocation) : TabListAction.RestoreAction.RestoreLocation {
        return when(t) {
            RestoreLocation.BEGINNING -> TabListAction.RestoreAction.RestoreLocation.BEGINNING
            RestoreLocation.END -> TabListAction.RestoreAction.RestoreLocation.END
            RestoreLocation.AT_INDEX -> TabListAction.RestoreAction.RestoreLocation.AT_INDEX
        }
    }

    override fun selectTab(tabId: String) {
        tabsUseCases.selectTab(tabId = tabId)
    }

    override fun removeTab(tabId: String) {
        tabsUseCases.removeTab(tabId = tabId)
    }

    override fun addTab(
        url: String,
        selectTab: Boolean,
        startLoading: Boolean,
        parentId: String?,
        flags: LoadUrlFlagsValue,
        contextId: String?,
        source: SourceValue,
        private: Boolean,
        historyMetadata: PigeonHistoryMetadataKey?,
        additionalHeaders: Map<String, String>?
    ): String {
        return tabsUseCases.addTab(
            url = url,
            selectTab = selectTab,
            startLoading = startLoading,
            parentId = parentId,
            flags = EngineSession.LoadUrlFlags.select(flags.value.toInt()),
            contextId = contextId,
            source = restoreSource(source),
            private = private,
            historyMetadata = if(historyMetadata != null)
                HistoryMetadataKey(
                    url = historyMetadata.url,
                    searchTerm = historyMetadata.searchTerm,
                    referrerUrl = historyMetadata.referrerUrl
                )
                else null,
            additionalHeaders = additionalHeaders
        )
    }

    override fun removeAllTabs(recoverable: Boolean) {
        tabsUseCases.removeAllTabs(recoverable = recoverable)
    }

    override fun removeTabs(ids: List<String>) {
        tabsUseCases.removeTabs(ids = ids)
    }

    override fun removeNormalTabs() {
        tabsUseCases.removeNormalTabs()
    }

    override fun removePrivateTabs() {
        tabsUseCases.removePrivateTabs()
    }

    override fun undo() {
        tabsUseCases.undo()
    }

    override fun restoreTabsByList(
        tabs: List<PigeonRecoverableTab>,
        selectTabId: String?,
        restoreLocation: PigeonRestoreLocation
    ) {
        tabsUseCases.restore(
            tabs = tabs.map { t -> mapTab(t) },
            restoreLocation = mapRestoreLocation(restoreLocation),
            selectTabId = selectTabId,
        )
    }

    override fun restoreTabsByBrowserState(
        state: PigeonRecoverableBrowserState,
        restoreLocation: PigeonRestoreLocation
    ) {
        tabsUseCases.restore(
            state = RecoverableBrowserState(
                selectedTabId =  state.selectedTabId,
                tabs = state.tabs.filterNotNull().map { t -> mapTab(t) },
            ),
            restoreLocation = mapRestoreLocation(restoreLocation),
        )
    }

    override fun selectOrAddTabByHistory(url: String, historyMetadata: PigeonHistoryMetadataKey): String {
        return tabsUseCases.selectOrAddTab(
            url = url,
            historyMetadata = HistoryMetadataKey(
                url = historyMetadata.url,
                searchTerm = historyMetadata.searchTerm,
                referrerUrl = historyMetadata.referrerUrl
            ),
        )
    }

    override fun selectOrAddTabByUrl(
        url: String,
        private: Boolean,
        source: SourceValue,
        flags: LoadUrlFlagsValue,
        ignoreFragment: Boolean
    ): String {
        return tabsUseCases.selectOrAddTab(
            url = url,
            private = private,
            source = restoreSource(source),
            flags = EngineSession.LoadUrlFlags.select(flags.value.toInt()),
            ignoreFragment = ignoreFragment,
        )
    }

    override fun duplicateTab(selectTabId: String?, selectNewTab: Boolean): String {
        val tabState = if(selectTabId != null) state.findTab(selectTabId) else null

        return tabsUseCases.duplicateTab(
            tab = tabState!!,
            selectNewTab = selectNewTab,
        )
    }

    override fun moveTabs(tabIds: List<String>, targetTabId: String, placeAfter: Boolean) {
        tabsUseCases.moveTabs(
            tabIds = tabIds,
            targetTabId = targetTabId,
            placeAfter = placeAfter,
        )
    }

    override fun migratePrivateTabUseCase(tabId: String, alternativeUrl: String?): String {
        return tabsUseCases.migratePrivateTabUseCase(
            tabId = tabId,
            alternativeUrl = alternativeUrl
        )
    }
}