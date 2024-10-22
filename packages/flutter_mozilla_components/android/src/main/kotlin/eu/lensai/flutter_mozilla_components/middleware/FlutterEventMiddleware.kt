/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package eu.lensai.flutter_mozilla_components.middleware

import android.graphics.Bitmap
import android.util.Log
import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.ext.resize
import eu.lensai.flutter_mozilla_components.ext.toWebPBytes
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.LastAccessAction
import mozilla.components.browser.state.action.ReaderAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.feature.addons.logger
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.MiddlewareContext
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import java.io.ByteArrayOutputStream
import kotlin.reflect.typeOf


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
                val resized = action.thumbnail.resize(maxWidth = 640, maxHeight = 480);
                val bytes = resized.toWebPBytes()

                runOnUiThread {
                    flutterEvents.onThumbnailChange(System.currentTimeMillis(), action.sessionId, bytes) { _ -> }
                }
            }
            //UpdateReaderConnectRequiredAction seems to be the only event that is called predictable
            //after a hot reload
            is ReaderAction.UpdateReaderConnectRequiredAction -> {
                if(!GlobalComponents.components!!.engineReportedInitialized) {
                    runOnUiThread {
                        flutterEvents.onEngineReadyStateChange(
                            System.currentTimeMillis(),
                            true
                        ) { _ -> }
                    }

                    GlobalComponents.components!!.engineReportedInitialized = true
                }
            }
            is TabListAction.AddTabAction -> {
                runOnUiThread {
                    flutterEvents.onTabAdded(
                        System.currentTimeMillis(),
                        action.tab.id
                    ) { _ -> }
                }
            }
            else -> {
                //logger.debug("Event fired: " + action.javaClass.name)
            }
        }
        next(action)
    }
}
