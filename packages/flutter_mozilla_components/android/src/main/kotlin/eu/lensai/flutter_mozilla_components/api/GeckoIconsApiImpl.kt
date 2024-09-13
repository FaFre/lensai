package eu.lensai.flutter_mozilla_components.api

import android.graphics.Bitmap
import android.os.Build
import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.ext.toWebPBytes
import eu.lensai.flutter_mozilla_components.pigeons.*
import kotlinx.coroutines.*
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.icons.Icon
import mozilla.components.concept.engine.manifest.Size as HtmlSize
import java.io.ByteArrayOutputStream

typealias MozillaIconRequest = mozilla.components.browser.icons.IconRequest
typealias MozillaIconSize = mozilla.components.browser.icons.IconRequest.Size
typealias MozillaIconResource = mozilla.components.browser.icons.IconRequest.Resource
typealias MozillaIconResourceType = mozilla.components.browser.icons.IconRequest.Resource.Type

class GeckoIconsApiImpl() : GeckoIconsApi {
    private val icons: BrowserIcons by lazy { GlobalComponents.components!!.icons }

    override fun loadIcon(request: IconRequest, callback: (Result<IconResult>) -> Unit) {
        CoroutineScope(Dispatchers.Default).launch {
            runCatching {
                loadIconAsync(request.toMozillaIconRequest())
            }.fold(
                onSuccess = { result ->
                    withContext(Dispatchers.Main) {
                        callback(Result.success(result))
                    }
                },
                onFailure = { error ->
                    withContext(Dispatchers.Main) {
                        callback(Result.failure(error))
                    }
                }
            )
        }
    }

    private suspend fun loadIconAsync(request: MozillaIconRequest): IconResult {
        val result = icons.loadIcon(request).await()
        val imageBytes = result.bitmap.toWebPBytes()
        return IconResult(
            image = imageBytes,
            maskable = result.maskable,
            color = result.color?.toLong(),
            source = result.source.toApiSource()
        )
    }

    private fun IconRequest.toMozillaIconRequest(): MozillaIconRequest =
        MozillaIconRequest(
            url = url,
            size = size.toMozillaSize(),
            color = color?.toInt(),
            waitOnNetworkLoad = waitOnNetworkLoad,
            isPrivate = isPrivate,
            resources = resources.filterNotNull().map { it.toMozillaResource() }
        )

    private fun IconSize.toMozillaSize(): MozillaIconSize = when (this) {
        IconSize.DEFAULT_SIZE -> MozillaIconSize.DEFAULT
        IconSize.LAUNCHER -> MozillaIconSize.LAUNCHER
        IconSize.LAUNCHER_ADAPTIVE -> MozillaIconSize.LAUNCHER_ADAPTIVE
    }

    private fun Resource.toMozillaResource(): MozillaIconResource =
        MozillaIconResource(
            url = url,
            mimeType = mimeType,
            maskable = maskable,
            type = type.toMozillaType(),
            sizes = sizes.filterNotNull().map { HtmlSize(it.height.toInt(), it.width.toInt()) }
        )

    private fun IconType.toMozillaType(): MozillaIconResourceType = when (this) {
        IconType.FAVICON -> MozillaIconResourceType.FAVICON
        IconType.APPLE_TOUCH_ICON -> MozillaIconResourceType.APPLE_TOUCH_ICON
        IconType.FLUID_ICON -> MozillaIconResourceType.FLUID_ICON
        IconType.IMAGE_SRC -> MozillaIconResourceType.IMAGE_SRC
        IconType.OPEN_GRAPH -> MozillaIconResourceType.OPENGRAPH
        IconType.TWITTER -> MozillaIconResourceType.TWITTER
        IconType.MICROSOFT_TILE -> MozillaIconResourceType.MICROSOFT_TILE
        IconType.TIPPY_TOP -> MozillaIconResourceType.TIPPY_TOP
        IconType.MANIFEST_ICON -> MozillaIconResourceType.MANIFEST_ICON
    }

    private fun Icon.Source.toApiSource(): Source = when (this) {
        Icon.Source.GENERATOR -> Source.GENERATOR
        Icon.Source.DOWNLOAD -> Source.DOWNLOAD
        Icon.Source.INLINE -> Source.INLINE
        Icon.Source.MEMORY -> Source.MEMORY
        Icon.Source.DISK -> Source.DISK
    }
}
