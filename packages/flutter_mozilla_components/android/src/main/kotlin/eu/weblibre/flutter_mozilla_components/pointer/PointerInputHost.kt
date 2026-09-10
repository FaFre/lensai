/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.pointer

import eu.weblibre.flutter_mozilla_components.pigeons.PointerHitTest
import eu.weblibre.flutter_mozilla_components.pigeons.PointerInputFlutterApi
import io.flutter.plugin.common.BinaryMessenger

/**
 * What [PointerInputRouter] needs from the Dart half.
 *
 * Behind an interface because the router's whole reason to exist is that these
 * answers are asynchronous: its tests have to be able to answer out of order,
 * late, or not at all, which a live channel cannot be made to do.
 */
internal interface PointerInputHost {
    /**
     * Asks which surface owns [x]/[y], in physical pixels local to the Flutter
     * view. Answers `null` when Dart could not be reached at all, which the
     * router must never read as "Flutter owns it".
     */
    fun hitTest(x: Double, y: Double, tracksHover: Boolean, onResult: (PointerHitTest?) -> Unit)

    /** Tells Dart the cursor left every registered surface. */
    fun pointerExit()
}

/** The production host: the generated pigeon channel. */
internal class PigeonPointerInputHost(messenger: BinaryMessenger) : PointerInputHost {
    private val api = PointerInputFlutterApi(messenger)

    override fun hitTest(
        x: Double,
        y: Double,
        tracksHover: Boolean,
        onResult: (PointerHitTest?) -> Unit,
    ) {
        // A messenger whose engine is going away throws rather than calling
        // back, and the retained event still has to reach somebody.
        try {
            api.hitTest(x, y, tracksHover) { onResult(it.getOrNull()) }
        } catch (_: RuntimeException) {
            onResult(null)
        }
    }

    override fun pointerExit() {
        try {
            api.pointerExit {}
        } catch (_: RuntimeException) {
            // Nothing to recover: Dart's hover watch stops with its isolate.
        }
    }
}
