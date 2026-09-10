/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ext

import android.graphics.Matrix
import android.view.MotionEvent
import android.view.View

/**
 * Rewrites this event's position from [from]'s coordinate space into [to]'s.
 *
 * Only the position moves. Wheel axes, precision, button and tool state all
 * describe the input device rather than where it pointed, and a target that
 * reads them has to see exactly what the system reported.
 *
 * `View.transformMatrixToGlobal`/`transformMatrixToLocal` do this, but are only
 * public from API 29 and the plugin ships to 24.
 */
internal fun MotionEvent.transformPosition(from: View, to: View) {
    val transform = from.globalTransform()
    val inverse = Matrix()
    to.globalTransform().invert(inverse)
    transform.postConcat(inverse)

    val point = floatArrayOf(x, y)
    transform.mapPoints(point)
    setLocation(point[0], point[1])
}

/** Maps this view's own coordinates onto the window's. */
private fun View.globalTransform(): Matrix {
    val transform = Matrix()
    var current: View? = this
    while (current != null) {
        val parent = current.parent as? View
        transform.postConcat(current.matrix)
        transform.postTranslate(
            (current.left - (parent?.scrollX ?: 0)).toFloat(),
            (current.top - (parent?.scrollY ?: 0)).toFloat(),
        )
        current = parent
    }
    return transform
}
