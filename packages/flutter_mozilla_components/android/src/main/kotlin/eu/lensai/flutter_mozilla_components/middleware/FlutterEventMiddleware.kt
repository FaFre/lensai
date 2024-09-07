/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package eu.lensai.flutter_mozilla_components.middleware

import android.util.Log
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.MiddlewareContext

/**
 * [Middleware] implementation for handling [ContentAction.UpdateThumbnailAction] and storing
 * the thumbnail to the disk cache.
 */
class FlutterEventMiddleware() : Middleware<BrowserState, BrowserAction> {
    @Suppress("ComplexMethod")
    override fun invoke(
        context: MiddlewareContext<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is ContentAction.UpdateThumbnailAction -> {
                Log.d("UpdateThumbnailAction", action.sessionId)
            }
            is ContentAction.UpdateTitleAction -> {
                Log.d("UpdateTitleAction", action.title)
            }
            else -> {
                // no-op
            }
        }
        next(action)
    }
}
