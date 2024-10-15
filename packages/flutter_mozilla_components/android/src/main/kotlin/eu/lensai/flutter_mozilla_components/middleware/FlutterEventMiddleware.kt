/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package eu.lensai.flutter_mozilla_components.middleware

import android.graphics.Bitmap
import android.util.Log
import eu.lensai.flutter_mozilla_components.ext.toWebPBytes
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.MiddlewareContext
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import java.io.ByteArrayOutputStream



/**
 * [Middleware] implementation for handling [ContentAction.UpdateThumbnailAction] and storing
 * the thumbnail to the disk cache.
 */
class FlutterEventMiddleware(private val flutterEvents: GeckoStateEvents) : Middleware<BrowserState, BrowserAction> {
    @Suppress("ComplexMethod")
    override fun invoke(
        context: MiddlewareContext<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is ContentAction.UpdateThumbnailAction -> {
                val bytes = action.thumbnail.toWebPBytes()
                runOnUiThread {
                    flutterEvents.onThumbnailChange(action.sessionId, bytes) { _ -> }
                }
            }
            else -> {
                // no-op
            }
        }
        next(action)
    }
}
