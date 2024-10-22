package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.pigeons.GeckoTabsApi
import eu.lensai.flutter_mozilla_components.pigeons.HistoryMetadataKey as PigeonHistoryMetadataKey
import eu.lensai.flutter_mozilla_components.pigeons.LoadUrlFlagsValue
import eu.lensai.flutter_mozilla_components.pigeons.RecoverableBrowserState as PigeonRecoverableBrowserState
import eu.lensai.flutter_mozilla_components.pigeons.RestoreLocation as PigeonRestoreLocation
import eu.lensai.flutter_mozilla_components.pigeons.RecoverableTab as PigeonRecoverableTab
import eu.lensai.flutter_mozilla_components.pigeons.SourceValue
import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.ext.toWebPBytes
import eu.lensai.flutter_mozilla_components.pigeons.FindResultState
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.lensai.flutter_mozilla_components.pigeons.HistoryItem
import eu.lensai.flutter_mozilla_components.pigeons.HistoryState
import eu.lensai.flutter_mozilla_components.pigeons.ReaderableState
import eu.lensai.flutter_mozilla_components.pigeons.RestoreLocation
import eu.lensai.flutter_mozilla_components.pigeons.SecurityInfoState
import eu.lensai.flutter_mozilla_components.pigeons.TabContentState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.icons.IconRequest
import mozilla.components.browser.session.storage.RecoverableBrowserState
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.LastMediaAccessState
import mozilla.components.browser.state.state.ReaderState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.recover.RecoverableTab
import mozilla.components.browser.state.state.recover.TabState
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.base.images.ImageLoadRequest
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.storage.HistoryMetadataKey
import mozilla.components.feature.tabs.TabsUseCases
import org.json.JSONObject
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

class GeckoTabsApiImpl() : GeckoTabsApi {
    private val tabsUseCases: TabsUseCases by lazy { GlobalComponents.components!!.tabsUseCases }
    private val engine: Engine by lazy { GlobalComponents.components!!.engine }
    private val state: BrowserState by lazy { GlobalComponents.components!!.store.state }
    private val thumbnailStorage: ThumbnailStorage by lazy { GlobalComponents.components!!.thumbnailStorage }
    private val icons: BrowserIcons by lazy { GlobalComponents.components!!.icons }
    private val events: GeckoStateEvents by lazy { GlobalComponents.components!!.flutterEvents }

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

    override fun syncEvents(
        onSelectedTabChange: Boolean,
        onTabListChange: Boolean,
        onTabContentStateChange: Boolean,
        onIconChange: Boolean,
        onSecurityInfoStateChange: Boolean,
        onReaderableStateChange: Boolean,
        onHistoryStateChange: Boolean,
        onFindResults: Boolean,
        onThumbnailChange: Boolean,
    ) {
        val tabs = state.tabs.map { x -> x.copy() }.toList()
        val selectedTab = state.selectedTabId

        if(onSelectedTabChange) {
            events.onSelectedTabChange(
                System.currentTimeMillis(),
                selectedTab
            ) { _ -> }
        }

        if(onTabListChange) {
            events.onTabListChange(
                System.currentTimeMillis(),
                tabs.map {tab -> tab.id}
            ) { _ -> }
        }

        if(onTabContentStateChange) {
            tabs.forEach { tab ->
                events.onTabContentStateChange(
                    System.currentTimeMillis(),
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

        if(onIconChange) {
            tabs.forEach { tab ->
                if(tab.content.icon != null) {
                    val iconBytes = tab.content.icon?.toWebPBytes()
                    events.onIconChange(
                        System.currentTimeMillis(),
                        tab.id,
                        iconBytes
                    ) { _ -> }
                } else {
                    CoroutineScope(Dispatchers.Default).launch {
                        val result = icons.loadIcon(IconRequest(url = tab.content.url)).await()
                        val iconBytes = result.bitmap.toWebPBytes()
                        runOnUiThread {
                            events.onIconChange(
                                System.currentTimeMillis(),
                                tab.id,
                                iconBytes
                            ) { _ -> }
                        }
                    }

                }
            }
        }

        if(onSecurityInfoStateChange) {
            tabs.forEach { tab ->
                events.onSecurityInfoStateChange(
                    System.currentTimeMillis(),
                    tab.id,
                    SecurityInfoState(
                        tab.content.securityInfo.secure,
                        tab.content.securityInfo.host,
                        tab.content.securityInfo.issuer,
                    )
                ) { _ -> }
            }
        }

        if(onReaderableStateChange) {
            tabs.forEach { tab ->
                events.onReaderableStateChange(
                    System.currentTimeMillis(),
                    tab.id,
                    ReaderableState(
                        tab.readerState.readerable,
                        tab.readerState.active,
                    )
                ) { _ -> }
            }
        }

        if(onHistoryStateChange) {
            tabs.forEach { tab ->
                events.onHistoryStateChange(
                    System.currentTimeMillis(),
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

        if(onFindResults) {
            tabs.forEach { tab ->
                events.onFindResults(
                    System.currentTimeMillis(),
                    tab.id,
                    tab.content.findResults.map { result -> FindResultState(
                        activeMatchOrdinal = result.activeMatchOrdinal.toLong(),
                        numberOfMatches = result.numberOfMatches.toLong(),
                        isDoneCounting = result.isDoneCounting,
                    ) }
                ) { _ -> }
            }
        }

        if(onThumbnailChange) {
            tabs.forEach { tab ->
                CoroutineScope(Dispatchers.Default).launch {
                    val bitmap = thumbnailStorage.loadThumbnail(
                        ImageLoadRequest(
                            id = tab.id,
                            //TODO: make this configurable
                            size = 1024,
                            isPrivate = tab.content.private
                        )
                    ).await()

                    if(bitmap != null) {
                        val bytes = bitmap.toWebPBytes()
                        runOnUiThread {
                            events.onThumbnailChange(System.currentTimeMillis(), tab.id, bytes) { _ -> }
                        }
                    }
                }
            }
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