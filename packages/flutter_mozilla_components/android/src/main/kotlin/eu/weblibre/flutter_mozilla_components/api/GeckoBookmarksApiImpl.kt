package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.feature.GeckoBookmarksExtensionBridge
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkImportNode
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkInfo
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkInsertTreeResult
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkNode
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkNodeType
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBookmarksApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.storage.BookmarkInfo as MozillaBookmarkInfo
import mozilla.components.concept.storage.bookmarks.InsertableBookmarkTreeNode
import mozilla.components.concept.storage.bookmarks.InsertableBookmarkTreeRoot

class GeckoBookmarksApiImpl() : GeckoBookmarksApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

        /**
         * Name of the short-lived folder that loose top-level nodes pass through
         * during an import. Only visible if an import is interrupted partway.
         */
        private const val SCRATCH_FOLDER_TITLE = "Importing bookmarks…"

        /** Bookmarks written between progress reports. */
        private const val PROGRESS_STEP = 64L

        /**
         * Largest subtree handed to storage as a single insertion.
         *
         * Bounds how long the import can run without reporting anything. Raise
         * it for fewer, larger writes; lower it for a smoother progress bar.
         */
        private const val BULK_INSERT_THRESHOLD = 1000L
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    fun mozilla.components.concept.storage.BookmarkNode.toPigeonBookmarkNode(): BookmarkNode {
        return BookmarkNode(
            type = when (this.type) {
                mozilla.components.concept.storage.BookmarkNodeType.ITEM -> BookmarkNodeType.ITEM
                mozilla.components.concept.storage.BookmarkNodeType.FOLDER -> BookmarkNodeType.FOLDER
                mozilla.components.concept.storage.BookmarkNodeType.SEPARATOR -> BookmarkNodeType.SEPARATOR
            },
            guid = this.guid,
            parentGuid = this.parentGuid,
            position = this.position?.toLong(),
            title = this.title,
            url = this.url,
            dateAdded = this.dateAdded,
            lastModified = this.lastModified,
            children = this.children?.map { it.toPigeonBookmarkNode() }
        )
    }

    fun BookmarkNode.toConceptStorageBookmarkNode(): mozilla.components.concept.storage.BookmarkNode {
        return mozilla.components.concept.storage.BookmarkNode(
            type = when (this.type) {
                BookmarkNodeType.ITEM -> mozilla.components.concept.storage.BookmarkNodeType.ITEM
                BookmarkNodeType.FOLDER -> mozilla.components.concept.storage.BookmarkNodeType.FOLDER
                BookmarkNodeType.SEPARATOR -> mozilla.components.concept.storage.BookmarkNodeType.SEPARATOR
            },
            guid = this.guid,
            parentGuid = this.parentGuid,
            position = this.position?.toUInt(),
            title = this.title,
            url = this.url,
            dateAdded = this.dateAdded,
            lastModified = this.lastModified,
            children = this.children?.map { it.toConceptStorageBookmarkNode() }
        )
    }


    override fun getTree(
        guid: String,
        recursive: Boolean,
        callback: (Result<BookmarkNode?>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val node = components.core.bookmarksStorage.getTree(guid, recursive)
                node.fold(
                    { node ->
                        callback(Result.success(node?.toPigeonBookmarkNode()))
                    },
                    { e -> callback(Result.failure(e)) })
            }
        }

    }

    override fun getBookmark(
        guid: String,
        callback: (Result<BookmarkNode?>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.getBookmark(guid).fold(
                    { node -> callback(Result.success(node?.toPigeonBookmarkNode())) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun getBookmarksWithUrl(
        url: String,
        callback: (Result<List<BookmarkNode>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.getBookmarksWithUrl(url).fold(
                    { nodes -> callback(Result.success(nodes.map { it.toPigeonBookmarkNode() })) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun getRecentBookmarks(
        limit: Long,
        maxAge: Long?,
        currentTime: Long,
        callback: (Result<List<BookmarkNode>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.getRecentBookmarks(
                    limit = limit.toInt(),
                    maxAge = maxAge
                ).fold(
                    { nodes -> callback(Result.success(nodes.map { it.toPigeonBookmarkNode() })) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun searchBookmarks(
        query: String,
        limit: Long,
        callback: (Result<List<BookmarkNode>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.searchBookmarks(query, limit.toInt()).fold(
                    { nodes -> callback(Result.success(nodes.map { it.toPigeonBookmarkNode() })) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun addItem(
        parentGuid: String,
        url: String,
        title: String,
        position: Long?,
        callback: (Result<String>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val result =
                    components.core.bookmarksStorage.addItem(parentGuid, url, title, position?.toUInt())
                result.fold(
                    { guid -> callback(Result.success(guid)) },
                    { e -> callback(Result.failure(e)) }
                )
                emitCreated(result.getOrNull())
            }
        }
    }

    override fun addFolder(
        parentGuid: String,
        title: String,
        position: Long?,
        callback: (Result<String>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val result =
                    components.core.bookmarksStorage.addFolder(parentGuid, title, position?.toUInt())
                result.fold(
                    { guid -> callback(Result.success(guid)) },
                    { e -> callback(Result.failure(e)) }
                )
                emitCreated(result.getOrNull())
            }
        }
    }

    override fun updateNode(
        guid: String,
        info: BookmarkInfo,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val conceptInfo = mozilla.components.concept.storage.BookmarkInfo(
                    parentGuid = info.parentGuid,
                    position = info.position?.toUInt(),
                    title = info.title,
                    url = info.url
                )
                val oldNode = components.core.bookmarksStorage.getBookmark(guid).getOrNull()
                val result = components.core.bookmarksStorage.updateNode(guid, conceptInfo)
                result.fold(
                    { callback(Result.success(Unit)) },
                    { e -> callback(Result.failure(e)) }
                )
                if (result.isSuccess) {
                    components.core.bookmarksStorage.getBookmark(guid).getOrNull()?.let { node ->
                        if (info.title != null || info.url != null) {
                            GeckoBookmarksExtensionBridge.emitChanged(node, oldNode)
                        }
                        if (info.parentGuid != null || info.position != null) {
                            GeckoBookmarksExtensionBridge.emitMoved(node, oldNode)
                        }
                    }
                }
            }
        }
    }

    override fun deleteNode(
        guid: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val node = components.core.bookmarksStorage.getBookmark(guid).getOrNull()
                components.core.bookmarksStorage.deleteNode(guid).fold(
                    { deleted ->
                        callback(Result.success(deleted))
                        if (deleted && node != null) {
                            GeckoBookmarksExtensionBridge.emitRemoved(node)
                        }
                    },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun insertTree(
        parentGuid: String,
        children: List<BookmarkImportNode>,
        callback: (Result<BookmarkInsertTreeResult>) -> Unit
    ) {
        coroutineScope.launch {
            // Imports can carry tens of thousands of nodes, so the whole batch runs
            // off the main thread. Only the callback returns to it, because Pigeon
            // replies must be delivered on the platform thread.
            val result = withContext(Dispatchers.IO) {
                runCatching { insertImportNodes(parentGuid, children) }
            }
            callback(result)
        }
    }

    /**
     * Appends [nodes] underneath [parentGuid].
     *
     * `insertTree` is the only storage call that carries timestamps, and it can
     * only create a *folder*. Loose items and separators would therefore lose
     * their `ADD_DATE` if inserted with `addItem`/`addSeparator`, which have no
     * timestamp parameters — so they pass through a scratch folder instead. See
     * [insertLooseChunk].
     *
     * A failing node is counted and skipped rather than aborting the whole
     * import, matching the per-node importer this replaced. Deliberately does
     * not emit `bookmarks.onCreated`: one event per imported node would flood
     * every installed WebExtension.
     */
    private suspend fun insertImportNodes(
        parentGuid: String,
        nodes: List<BookmarkImportNode>
    ): BookmarkInsertTreeResult {
        val state = InsertState(ImportProgressReporter())

        insertChildren(parentGuid, nodes, state)

        state.progress.reportFinal(state.insertedItemCount)

        return BookmarkInsertTreeResult(state.insertedItemCount, state.failedNodeCount)
    }

    /** Running totals for one import, shared across the recursion. */
    private class InsertState(val progress: ImportProgressReporter) {
        var insertedItemCount = 0L
        var failedNodeCount = 0L
    }

    /**
     * Writes [nodes] underneath [parentGuid], in order.
     *
     * Folders are written one at a time; runs of consecutive loose nodes are
     * written in chunks. Every write appends, so walking the nodes strictly in
     * order reproduces the file's order, and merging into a folder that already
     * has children leaves those in place.
     */
    private suspend fun insertChildren(
        parentGuid: String,
        nodes: List<BookmarkImportNode>,
        state: InsertState
    ) {
        var index = 0

        while (index < nodes.size) {
            if (nodes[index].type == BookmarkNodeType.FOLDER) {
                insertFolder(parentGuid, nodes[index], state).fold(
                    { count -> state.insertedItemCount += count },
                    { state.failedNodeCount += 1 }
                )
                state.progress.report(state.insertedItemCount)
                index++
                continue
            }

            // Take the whole run of loose nodes so they keep their place
            // relative to the folders around them.
            var end = index
            while (end < nodes.size && nodes[end].type != BookmarkNodeType.FOLDER) {
                end++
            }

            for (chunk in nodes.subList(index, end).chunked(BULK_INSERT_THRESHOLD.toInt())) {
                insertLooseChunk(parentGuid, chunk, state)
            }

            index = end
        }
    }

    /**
     * Writes a chunk of loose items and separators, then moves them into place.
     *
     * `insertTree` is the only call that carries timestamps and it can only
     * create a folder, so loose nodes are written into a scratch folder and
     * reparented out of it. Doing that for the whole file at once left the
     * progress bar at zero for the entire bulk write, so it happens a chunk at
     * a time and the moves report as they go.
     */
    private suspend fun insertLooseChunk(
        parentGuid: String,
        chunk: List<BookmarkImportNode>,
        state: InsertState
    ) {
        val storage = components.core.bookmarksStorage

        val staged = ArrayList<BookmarkImportNode>(chunk.size)
        val insertable = ArrayList<InsertableBookmarkTreeNode>(chunk.size)
        for (node in chunk) {
            // Positions come from the surviving order so dropping an unusable
            // node leaves no gap.
            val converted = node.toInsertableNode(insertable.size.toUInt())
            if (converted == null) {
                state.failedNodeCount += 1
                continue
            }
            insertable.add(converted)
            staged.add(node)
        }

        if (staged.isEmpty()) return

        val scratch = InsertableBookmarkTreeNode.Folder(
            title = SCRATCH_FOLDER_TITLE,
            dateAddedTimestamp = 0L,
            lastModifiedTimestamp = 0L,
            position = null,
            children = insertable
        )

        val scratchGuid = storage.insertTree(InsertableBookmarkTreeRoot(parentGuid, scratch))
            .getOrElse {
                state.failedNodeCount += staged.size
                return
            }

        // Read the assigned guids back in position order, which is the order
        // the nodes were handed to insertTree.
        val written = storage.getTree(scratchGuid, false).getOrNull()?.children.orEmpty()

        for ((position, node) in staged.withIndex()) {
            val guid = written.getOrNull(position)?.guid
            if (guid == null) {
                state.failedNodeCount += 1
                continue
            }

            // A null field means "leave unchanged"; appending (null position)
            // keeps the file's order as the caller walks the level.
            val move = MozillaBookmarkInfo(
                parentGuid = parentGuid,
                position = null,
                title = null,
                url = null
            )

            storage.updateNode(guid, move).fold(
                {
                    if (node.type == BookmarkNodeType.ITEM) {
                        state.insertedItemCount += 1
                    }
                },
                { state.failedNodeCount += 1 }
            )

            state.progress.report(state.insertedItemCount)
        }

        // Deleting cascades to children, so anything that failed to move is
        // left behind in a visible folder rather than being silently destroyed.
        val remaining = storage.getTree(scratchGuid, false).getOrNull()?.children
        if (remaining.isNullOrEmpty()) {
            storage.deleteNode(scratchGuid)
        }
    }

    /**
     * Writes one folder and everything under it.
     *
     * Storage inserts a tree as a single indivisible operation with no way to
     * observe it, so a whole import handed over in one call reports nothing
     * until it has finished — a bookmark file whose top level is a single
     * folder, which is what Firefox exports look like, would leave the progress
     * bar at zero for the entire run.
     *
     * Subtrees up to [BULK_INSERT_THRESHOLD] items therefore go in whole, which
     * is the fast path, while anything larger is split: the folder itself is
     * created empty — keeping its own timestamps — and its children are written
     * one level down. That trades some batching for a progress bar that moves.
     */
    private suspend fun insertFolder(
        parentGuid: String,
        node: BookmarkImportNode,
        state: InsertState
    ): Result<Long> {
        val storage = components.core.bookmarksStorage
        val folder = node.toInsertableFolder(position = null)
        val itemCount = folder.itemCount()

        if (itemCount <= BULK_INSERT_THRESHOLD) {
            return storage.insertTree(InsertableBookmarkTreeRoot(parentGuid, folder))
                .map { itemCount }
        }

        val shell = folder.copy(children = emptyList())
        val guid = storage.insertTree(InsertableBookmarkTreeRoot(parentGuid, shell))
            .getOrElse { return Result.failure(it) }

        insertChildren(guid, node.children, state)

        // The recursion already counted everything it wrote.
        return Result.success(0L)
    }

    /**
     * Forwards insertion progress to Dart, throttled.
     *
     * A flat bookmark file has every entry as a top-level node, so the caller
     * ticks once per bookmark — tens of thousands of times. Only every
     * [PROGRESS_STEP]th tick crosses the channel, plus a final exact figure, so
     * the reporting cannot itself become the bottleneck.
     */
    private inner class ImportProgressReporter {
        private var lastReported = 0L

        fun report(insertedItemCount: Long) {
            if (insertedItemCount - lastReported < PROGRESS_STEP) return
            lastReported = insertedItemCount
            emit(insertedItemCount)
        }

        fun reportFinal(insertedItemCount: Long) {
            if (insertedItemCount == lastReported) return
            lastReported = insertedItemCount
            emit(insertedItemCount)
        }

        private fun emit(insertedItemCount: Long) {
            val events = GlobalComponents.bookmarksEvents ?: return
            // Pigeon callbacks must be dispatched from the platform thread.
            coroutineScope.launch {
                events.onImportProgress(insertedItemCount) {}
            }
        }
    }

    override fun countBookmarksInTrees(
        guids: List<String>,
        callback: (Result<Long>) -> Unit
    ) {
        coroutineScope.launch {
            val result = withContext(Dispatchers.IO) {
                runCatching {
                    components.core.bookmarksStorage.countBookmarksInTrees(guids).toLong()
                }
            }
            callback(result)
        }
    }

    private fun BookmarkImportNode.toInsertableFolder(position: UInt?) =
        InsertableBookmarkTreeNode.Folder(
            title = this.title,
            dateAddedTimestamp = this.dateAdded,
            lastModifiedTimestamp = this.lastModified,
            position = position,
            children = this.children.toInsertableNodes()
        )

    /**
     * Converts children to their insertable form, dropping unusable nodes and
     * assigning positions from the surviving order so no gaps are left behind.
     */
    private fun List<BookmarkImportNode>.toInsertableNodes(): List<InsertableBookmarkTreeNode> {
        val converted = ArrayList<InsertableBookmarkTreeNode>(this.size)
        for (node in this) {
            converted.add(node.toInsertableNode(converted.size.toUInt()) ?: continue)
        }
        return converted
    }

    private fun BookmarkImportNode.toInsertableNode(position: UInt): InsertableBookmarkTreeNode? =
        when (this.type) {
            BookmarkNodeType.FOLDER -> this.toInsertableFolder(position)

            BookmarkNodeType.ITEM -> this.url?.takeIf { it.isNotEmpty() }?.let { url ->
                InsertableBookmarkTreeNode.Item(
                    title = this.title,
                    url = url,
                    dateAddedTimestamp = this.dateAdded,
                    lastModifiedTimestamp = this.lastModified,
                    position = position
                )
            }

            BookmarkNodeType.SEPARATOR -> InsertableBookmarkTreeNode.Separator(
                dateAddedTimestamp = this.dateAdded,
                lastModifiedTimestamp = this.lastModified,
                position = position
            )
        }

    /** Number of bookmark items in this subtree, excluding folders and separators. */
    private fun InsertableBookmarkTreeNode.itemCount(): Long = when (this) {
        is InsertableBookmarkTreeNode.Item -> 1L
        is InsertableBookmarkTreeNode.Folder -> this.children.sumOf { it.itemCount() }
        is InsertableBookmarkTreeNode.Separator -> 0L
    }

    /**
     * Notifies extension `bookmarks.onCreated` listeners about a node created
     * through the app UI, so extensions (e.g. floccus) observe app-side edits to
     * the shared store.
     */
    private suspend fun emitCreated(guid: String?) {
        if (guid == null) {
            return
        }
        components.core.bookmarksStorage.getBookmark(guid).getOrNull()?.let {
            GeckoBookmarksExtensionBridge.emitCreated(it)
        }
    }

}
