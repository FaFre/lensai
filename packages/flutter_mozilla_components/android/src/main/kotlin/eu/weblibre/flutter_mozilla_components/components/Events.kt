/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.api.ReaderViewEventsImpl
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.feature.ReaderViewAppearanceFeature
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.ExternalApplicationResource
import eu.weblibre.flutter_mozilla_components.pigeons.FindResultState
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.PwaIcon
import eu.weblibre.flutter_mozilla_components.pigeons.PwaManifest
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryItem
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryState
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderableState
import eu.weblibre.flutter_mozilla_components.pigeons.SecurityInfoState
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTarget
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTargetFiles
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTargetParams
import eu.weblibre.flutter_mozilla_components.pigeons.TabContentState
import eu.weblibre.flutter_mozilla_components.pigeons.TabTranslationStateData
import eu.weblibre.flutter_mozilla_components.pigeons.TranslationEngineStateData
import eu.weblibre.flutter_mozilla_components.pigeons.TranslationLanguage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull
import kotlinx.coroutines.launch
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.feature.addons.logger
import mozilla.components.lib.state.Store
import mozilla.components.lib.state.ext.flowScoped
import kotlinx.coroutines.flow.distinctUntilChangedBy
import mozilla.components.support.ktx.kotlinx.coroutines.flow.filterChanged
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged

/**
 * Emits every tab whose [selector] values differ from the values last emitted
 * for *that* tab.
 *
 * This replaces `filterChanged { … }.ifAnyChanged { … }.debounce(n)`, which
 * flattens the tab list into a single stream of tabs and then filters that
 * stream as though consecutive emissions belonged to the same tab. Both stages
 * therefore drop other tabs' updates:
 *
 *  - `ifAnyChanged` holds one previous tuple for the whole stream, so a tab
 *    whose values happen to equal those of the tab emitted just before it is
 *    discarded outright. Two freshly created `about:blank` tabs in one snapshot
 *    are enough, which is why this reproduces for some users and never for
 *    others.
 *  - `debounce` keeps only the last tab of each window and drops every other
 *    tab that changed in the same burst — a whole session restore collapses to
 *    a single tab.
 *
 * Either drop is permanent: the store reports changes, not state, so a tab
 * whose only update was swallowed is never mentioned to Flutter again. Diffing
 * per tab id makes both impossible, and it is stricter than `filterChanged` as
 * well, which reads a change to any *other* field of the session (its last
 * access time, say) as a change to the values being watched.
 *
 * A tab is always emitted the first time it is seen, and a tab that leaves the
 * store is forgotten, so one that comes back is reported afresh.
 */
internal fun Flow<BrowserState>.changedTabsBy(
    windowMillis: Long = 0L,
    selector: (TabSessionState) -> List<Any?>,
): Flow<TabSessionState> {
    val states = this
    val changed = flow {
        var previous = emptyMap<String, List<Any?>>()
        states.collect { state ->
            val current = state.tabs.associate { tab -> tab.id to selector(tab) }
            state.tabs.forEach { tab ->
                if (previous[tab.id] != current[tab.id]) {
                    emit(tab)
                }
            }
            previous = current
        }
    }

    return if (windowMillis > 0L) changed.conflatedByTab(windowMillis) else changed
}

/**
 * Emits at most one state per tab per [windowMillis], keeping the newest state
 * of every tab that changed inside the window.
 *
 * The rate limit the debounce used to give, without the drops it came with.
 * Each event carries a tab's whole state rather than a change to it, so a value
 * that was overtaken inside the window never needed sending; what may not
 * happen is a tab going unmentioned, which is what conflating *per tab id*
 * rules out. A page load reports its progress a percent at a time, and every
 * one of those crosses the channel and is awaited on the Flutter side, so a
 * session restore is a burst of hundreds of them without this.
 *
 * The first change after a quiet period goes straight out, so a single event
 * is never delayed; only a burst is batched, and the burst's last word arrives
 * within one window of it being said.
 *
 * Confined to the single thread it is collected on — [Dispatchers.Main] here —
 * which is what lets the window and the collector share `held` plainly.
 */
internal fun Flow<TabSessionState>.conflatedByTab(
    windowMillis: Long,
): Flow<TabSessionState> = channelFlow {
    val held = LinkedHashMap<String, TabSessionState>()
    var window: Job? = null

    collect { tab ->
        if (window?.isActive == true) {
            held[tab.id] = tab
            return@collect
        }

        send(tab)
        window = launch {
            while (true) {
                delay(windowMillis)
                if (held.isEmpty()) {
                    // A window nobody wrote in closes the burst, and the next
                    // change is a leading edge again.
                    return@launch
                }

                val due = held.values.toList()
                held.clear()
                due.forEach { send(it) }
            }
        }
    }

    // Upstream is finished, so a later window is not coming to carry these.
    window?.cancelAndJoin()
    held.values.forEach { send(it) }
}

class Events(
    private val flutterEvents: GeckoStateEvents,
) {
    val readerViewEvents by lazy { ReaderViewEventsImpl() }

    @OptIn(FlowPreview::class)
    fun registerFlowEvents(stateFlow: Store<BrowserState, BrowserAction>) {
        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.map { state -> state.selectedTabId }
                .distinctUntilChanged()
                // Make sure this is sent after tabadded action and tab list change
                .debounce { 50 }
                .collect { tabId ->
                    flutterEvents.onSelectedTabChange(
                        EventSequence.next(),
                        tabId
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.map { state -> state.restoreComplete }
                .distinctUntilChanged()
                .collect { restoreComplete ->
                    flutterEvents.onRestoreCompleteChange(
                        EventSequence.next(),
                        restoreComplete
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            var previousTabs = emptySet<String>()
            flow.mapNotNull { state -> state.tabs.map { tab -> tab.id } }
                .distinctUntilChanged()
                // Make sure this is sent after tabadded action
                .debounce { 25 }
                .collect { tabs ->
                    val currentTabs = tabs.toSet()
                    if (previousTabs.isNotEmpty()) {
                        val removedTabs = previousTabs - currentTabs
                        if (removedTabs.isNotEmpty()) {
                            removedTabs.forEach { tabId ->
                                flutterEvents.onManifestUpdate(
                                    EventSequence.next(),
                                    tabId,
                                    null
                                ) { _ -> }
                            }
                        }
                    }
                    previousTabs = currentTabs
                    flutterEvents.onTabListChange(EventSequence.next(), tabs) { _ -> }
                }
        }

        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.changedTabsBy(windowMillis = 15) { listOf(it.content.icon) }
                .collect { tab ->
                    val iconBytes = tab.content.icon?.toWebPBytes()
                    flutterEvents.onIconChange(
                        EventSequence.next(),
                        tab.id,
                        iconBytes
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.changedTabsBy(windowMillis = 15) { listOf(it.content.securityInfo) }
                .collect { tab ->
                    flutterEvents.onSecurityInfoStateChange(
                        EventSequence.next(),
                        tab.id,
                        SecurityInfoState(
                            tab.content.securityInfo.isSecure,
                            tab.content.securityInfo.host,
                            tab.content.securityInfo.issuer,
                        )
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.changedTabsBy(windowMillis = 25) {
                listOf(
                    it.readerState.readerable,
                    it.readerState.active,
                )
            }
                .collect { tab ->
                    flutterEvents.onReaderableStateChange(
                        EventSequence.next(),
                        tab.id,
                        ReaderableState(
                            tab.readerState.readerable,
                            tab.readerState.active,
                        )
                    ) { _ -> }
                }
        }

        // Register the WebLibre "pure black" appearance content port whenever a
        // tab's reader view becomes active. Store-driven (rather than the user's
        // reader toggle) so it also covers reader views restored on app start.
        //
        // Keyed on both readerState.active AND the engine session: a restored
        // reader tab can already be active before its engine session is linked,
        // and the active flag never changes afterwards — so we must also react to
        // the session becoming available to register on the right session.
        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged { it.readerState.active to it.engineState.engineSession }
                .collect { tab ->
                    if (tab.readerState.active) {
                        tab.engineState.engineSession?.let { session ->
                            ReaderViewAppearanceFeature.registerSession(session)
                        }
                    }
                }
        }

        // Keep the reader appearance (font/settings) button in sync with the
        // selected tab's actual reader-active state. Driven by the store rather
        // than the user's reader toggle (ReaderViewIntegration) so the button
        // also appears for reader views restored on app start ("resume last tab"),
        // which never go through an explicit toggle.
        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.map { state -> state.selectedTab?.readerState?.active ?: false }
                .distinctUntilChanged()
                .collect { active ->
                    GlobalComponents.components?.readerViewController?.appearanceButtonVisibility(
                        EventSequence.next(),
                        active,
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.changedTabsBy(windowMillis = 15) {
                listOf(
                    it.content.history,
                    it.content.canGoBack,
                    it.content.canGoForward,
                )
            }
                .collect { tab ->
                    flutterEvents.onHistoryStateChange(
                        EventSequence.next(),
                        tab.id,
                        HistoryState(
                            items = tab.content.history.items.map { item ->
                                HistoryItem(
                                    url = item.uri,
                                    title = item.title
                                )
                            },
                            currentIndex = tab.content.history.currentIndex.toLong(),
                            canGoBack = tab.content.canGoBack,
                            canGoForward = tab.content.canGoForward,
                        )
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.changedTabsBy(windowMillis = 15) {
                listOf(
                    it.parentId,
                    it.contextId,
                    it.content.url,
                    it.content.title,
                    it.content.private,
                    it.content.fullScreen,
                    it.content.progress,
                    it.content.loading,
                    it.content.showToolbarAsExpanded,
                )
            }
                .collect { tab ->
                    flutterEvents.onTabContentStateChange(
                        EventSequence.next(),
                        TabContentState(
                            id = tab.id,
                            parentId = tab.parentId,
                            contextId = tab.contextId,
                            url = tab.content.url,
                            title = tab.content.title,
                            progress = tab.content.progress.toLong(),
                            isPrivate = tab.content.private,
                            isFullScreen = tab.content.fullScreen,
                            isLoading = tab.content.loading,
                            showToolbarAsExpanded = tab.content.showToolbarAsExpanded,
                        )
                    ) { _ -> }

                    // Reset showToolbarAsExpanded after forwarding to Flutter,
                    // mirroring Fenix ToolbarBehaviorController behavior.
                    // This ensures subsequent expand events trigger a new state change.
                    if (tab.content.showToolbarAsExpanded) {
                        stateFlow.dispatch(
                            ContentAction.UpdateExpandedToolbarStateAction(tab.id, false)
                        )
                    }
                }
        }

        // Translation engine state (browser-level)
        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.map { state -> state.translationEngine }
                .distinctUntilChanged { old, new ->
                    old.isEngineSupported == new.isEngineSupported &&
                        old.supportedLanguages == new.supportedLanguages
                }
                .debounce(50)
                .collect { translationEngine ->
                    val fromLanguages = translationEngine.supportedLanguages?.fromLanguages?.map { lang ->
                        TranslationLanguage(code = lang.code, localizedDisplayName = lang.localizedDisplayName ?: lang.code)
                    }
                    val toLanguages = translationEngine.supportedLanguages?.toLanguages?.map { lang ->
                        TranslationLanguage(code = lang.code, localizedDisplayName = lang.localizedDisplayName ?: lang.code)
                    }

                    flutterEvents.onTranslationEngineStateChange(
                        EventSequence.next(),
                        TranslationEngineStateData(
                            isEngineSupported = translationEngine.isEngineSupported,
                            fromLanguages = fromLanguages,
                            toLanguages = toLanguages,
                        )
                    ) { _ -> }
                }
        }

        // Per-tab translation state
        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.changedTabsBy(windowMillis = 25) {
                listOf(
                    it.translationsState.isTranslated,
                    it.translationsState.isTranslateProcessing,
                    it.translationsState.isOfferTranslate,
                    it.translationsState.isExpectedTranslate,
                    it.translationsState.translationEngineState,
                    it.translationsState.translationError,
                )
            }
                .collect { tab ->
                    val ts = tab.translationsState
                    flutterEvents.onTabTranslationStateChange(
                        EventSequence.next(),
                        TabTranslationStateData(
                            tabId = tab.id,
                            isTranslated = ts.isTranslated,
                            isTranslateProcessing = ts.isTranslateProcessing,
                            isOfferTranslate = ts.isOfferTranslate,
                            isExpectedTranslate = ts.isExpectedTranslate,
                            detectedLanguageCode = ts.translationEngineState?.detectedLanguages?.documentLangTag,
                            userPreferredLanguageCode = ts.translationEngineState?.detectedLanguages?.userPreferredLangTag,
                            requestedFromLanguage = ts.translationEngineState?.requestedTranslationPair?.fromLanguage,
                            requestedToLanguage = ts.translationEngineState?.requestedTranslationPair?.toLanguage,
                            translationErrorName = ts.translationError?.errorName,
                            displayError = ts.translationError?.displayError,
                        )
                    ) { _ -> }
                }
        }

        // PWA manifest availability events - following Fenix MenuPresenter pattern
        stateFlow.flowScoped(dispatcher = Dispatchers.Main) { flow ->
            flow.mapNotNull { state -> state.selectedTab }
                .ifAnyChanged { tab ->
                    arrayOf(
                        tab.content.loading,
                        tab.content.canGoBack,
                        tab.content.canGoForward,
                        tab.content.webAppManifest,
                    )
                }
                .collect { tab ->
                    val manifest = tab.content.webAppManifest
                    val currentUrl = tab.content.url

                    // If manifest is null, clear PWA state for this tab
                    if (manifest == null) {
                        flutterEvents.onManifestUpdate(
                            EventSequence.next(),
                            tab.id,
                            null
                        ) { _ -> }
                        return@collect
                    }

                    val pwaManifest = PwaManifest(
                        startUrl = manifest.startUrl,
                        currentUrl = currentUrl,
                        name = manifest.name,
                        shortName = manifest.shortName,
                        display = manifest.display?.name?.lowercase()?.replace("_", "-"),
                        themeColor = manifest.themeColor?.let { String.format("#%06X", 0xFFFFFF and it) },
                        backgroundColor = manifest.backgroundColor?.let { String.format("#%06X", 0xFFFFFF and it) },
                        scope = manifest.scope,
                        description = manifest.description,
                        icons = manifest.icons.map { icon ->
                            PwaIcon(
                                src = icon.src,
                                sizes = icon.sizes?.joinToString(" ") { "${it.width}x${it.height}" },
                                type = icon.type,
                            )
                        },
                        dir = manifest.dir?.name?.lowercase(),
                        lang = manifest.lang,
                        orientation = manifest.orientation?.name?.lowercase(),
                        relatedApplications = manifest.relatedApplications.map { app ->
                            ExternalApplicationResource(
                                platform = app.platform,
                                url = app.url,
                                id = app.id,
                                minVersion = app.minVersion,
                            )
                        },
                        preferRelatedApplications = manifest.preferRelatedApplications,
                        shareTarget = manifest.shareTarget?.let { target ->
                            ShareTarget(
                                action = target.action,
                                method = target.method?.name,
                                encType = target.encType?.type,
                                params = target.params?.let { params ->
                                    ShareTargetParams(
                                        title = params.title,
                                        text = params.text,
                                        url = params.url,
                                        files = params.files.map { file ->
                                            ShareTargetFiles(
                                                name = file.name,
                                                accept = file.accept,
                                            )
                                        },
                                    )
                                },
                            )
                        },
                    )

                    flutterEvents.onManifestUpdate(
                        EventSequence.next(),
                        tab.id,
                        pwaManifest
                    ) { _ -> }
                }
        }
    }
}
