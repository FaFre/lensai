/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.components

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.ContentState
import mozilla.components.browser.state.state.TabSessionState

/** The field set the tab content event carries, as [Events] selects it. */
private fun Flow<BrowserState>.contentChanges(): Flow<TabSessionState> = changedTabsBy {
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

class EventsTabChangesTest {
    @Test
    fun `every identical blank tab is emitted, including later additions`() = runBlocking {
        val first = TabSessionState(id = "first", content = ContentState("about:blank"))
        val second = first.copy(id = "second")
        val third = first.copy(id = "third")

        val events = flowOf(
            BrowserState(),
            BrowserState(tabs = listOf(first, second)),
            BrowserState(tabs = listOf(first, second, third)),
        ).contentChanges().toList()

        assertEquals(listOf("first", "second", "third"), events.map { it.id })
    }

    @Test
    fun `a burst preserves every tab's update even when their payloads match`() = runBlocking {
        val first = TabSessionState(id = "first", content = ContentState("about:blank"))
        val second = first.copy(id = "second")
        val loading = first.content.copy(url = "https://example.test", loading = true, progress = 50)
        val finished = loading.copy(loading = false, progress = 100, title = "Finished")

        val events = flowOf(
            BrowserState(tabs = listOf(first, second)),
            BrowserState(tabs = listOf(first.copy(content = loading), second.copy(content = loading))),
            BrowserState(tabs = listOf(first.copy(content = finished), second.copy(content = loading))),
            BrowserState(tabs = listOf(first.copy(content = finished), second.copy(content = finished))),
        ).contentChanges().toList()

        assertEquals(listOf("first", "second", "first", "second", "first", "second"), events.map { it.id })
        assertEquals(listOf(0, 0, 50, 50, 100, 100), events.map { it.content.progress })
        assertEquals(listOf(false, false, true, true, false, false), events.map { it.content.loading })
    }

    @Test
    fun `unselected fields and reordering do not emit`() = runBlocking {
        val first = TabSessionState(id = "first", content = ContentState("https://first.test"))
        val second = first.copy(id = "second", content = ContentState("https://second.test"))
        val initial = BrowserState(tabs = listOf(first, second))
        val unselected = first.copy(
            lastAccess = 123L,
            content = first.content.copy(searchTerms = "query", canGoBack = true),
        )

        val events = flowOf(
            initial,
            initial,
            initial.copy(selectedTabId = second.id),
            initial.copy(tabs = listOf(unselected, second)),
            initial.copy(tabs = listOf(second, unselected)),
        ).contentChanges().toList()

        assertEquals(listOf("first", "second"), events.map { it.id })
    }

    @Test
    fun `parent and context changes emit without any content change`() = runBlocking {
        val tab = TabSessionState(id = "tab", content = ContentState("about:blank"))
        val parented = tab.copy(parentId = "parent")
        val contextual = parented.copy(contextId = "container")

        val events = flowOf(
            BrowserState(tabs = listOf(tab)),
            BrowserState(tabs = listOf(parented)),
            BrowserState(tabs = listOf(contextual)),
            BrowserState(tabs = listOf(tab)),
        ).contentChanges().toList()

        assertEquals(listOf(null, "parent", "parent", null), events.map { it.parentId })
        assertEquals(listOf(null, null, "container", null), events.map { it.contextId })
    }

    @Test
    fun `every selected field is observed and a repeated value emits again`() = runBlocking {
        val tab = TabSessionState(id = "tab", content = ContentState("about:blank"))
        val contents = listOf(
            tab.content.copy(url = "https://example.test"),
            tab.content.copy(title = "Title"),
            tab.content.copy(progress = 42),
            tab.content.copy(private = true),
            tab.content.copy(fullScreen = true),
            tab.content.copy(loading = true),
            tab.content.copy(showToolbarAsExpanded = true),
        )
        // Change one field at a time, returning to the baseline in between, then
        // repeat the last change: the toolbar expansion is reset by the collector
        // and has to be reportable a second time.
        val snapshots = contents.flatMap { content ->
            listOf(BrowserState(tabs = listOf(tab)), BrowserState(tabs = listOf(tab.copy(content = content))))
        } + listOf(
            BrowserState(tabs = listOf(tab)),
            BrowserState(tabs = listOf(tab.copy(content = contents.last()))),
        )

        val events = flowOf(*snapshots.toTypedArray()).contentChanges().toList()

        assertEquals(snapshots.size, events.size)
        assertEquals("https://example.test", events[1].content.url)
        assertEquals("Title", events[3].content.title)
        assertEquals(42, events[5].content.progress)
        assertEquals(true, events[7].content.private)
        assertEquals(true, events[9].content.fullScreen)
        assertEquals(true, events[11].content.loading)
        assertEquals(listOf(true, false, true), events.takeLast(3).map { it.content.showToolbarAsExpanded })
    }

    @Test
    fun `a closed tab is forgotten and every collector starts from scratch`() = runBlocking {
        val tab = TabSessionState(id = "tab", content = ContentState("about:blank"))
        val changes = flowOf(
            BrowserState(tabs = listOf(tab)),
            BrowserState(),
            BrowserState(tabs = listOf(tab)),
        ).contentChanges()

        assertEquals(listOf("tab", "tab"), changes.toList().map { it.id })
        assertEquals(listOf("tab", "tab"), changes.toList().map { it.id })
    }
}
