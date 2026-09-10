/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.pointer.PointerInputRouter

/**
 * The root of a platform view whose mouse input is arbitrated against the
 * Flutter tree drawn over it. See [PointerInputRouter] for why that is needed.
 *
 * Only generic mouse input goes through the router; touch and accessibility
 * keep Android's ordinary dispatch, which Flutter already routes for itself.
 */
open class PointerInputFrameLayout(
    context: Context,
    platformViewId: Int,
    private val router: PointerInputRouter,
) : FrameLayout(context) {
    /** Long because that is how Dart names this surface back over the channel. */
    internal val platformViewId = platformViewId.toLong()

    /**
     * The Flutter view this surface is composited into, which is both the
     * coordinate space hit tests are asked in and where input Flutter wins is
     * handed to. Null while the platform view is detached.
     */
    internal var pointerFlutterView: View? = null
        private set

    fun attachPointerInput(flutterView: View) {
        if (pointerFlutterView !== flutterView) detachPointerInput()
        pointerFlutterView = flutterView
        router.register(platformViewId, this)
    }

    fun detachPointerInput() {
        router.unregister(platformViewId, this)
        pointerFlutterView = null
    }

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean =
        router.intercept(this, event) || super.dispatchGenericMotionEvent(event)
}
