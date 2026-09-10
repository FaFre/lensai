/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.app.Activity
import android.util.Log
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/**
 * Takes the engine's surface off the window when Flutter stops painting the
 * platform view, because nothing else does.
 *
 * Hiding a view does not retire a [SurfaceView]'s compositor layer, and that
 * layer is what the page is drawn into. Measured on Android 13 while the
 * previous page was still covering the route that replaced it, the embedder had
 * done its part perfectly: the `FlutterMutatorView` wrapper was `GONE`, the
 * container reported `isShown == false`, and the page was on screen regardless
 * — over Flutter's base surface, under the overlay views, which is why the
 * chrome kept working while the route underneath it was the one that vanished.
 * A surface view reconciles its layer from its own `updateSurface`, so the
 * visibility has to be set on the surface view itself, which is what this walks
 * down to do.
 *
 * [View.INVISIBLE] rather than [View.GONE] because the browser fragment is
 * attached to the container and its view has to keep being measured and laid
 * out: an attach against a zero-sized container is one of the failures
 * `GeckoView._showNativeFragment` retries against.
 */
class EngineViewVisibility(
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
    private val containerId: Int,
) {
    private val channel = MethodChannel(messenger, CHANNEL).apply {
        setMethodCallHandler(::onMethodCall)
    }

    /** The views this hid, so that showing again lifts those and nothing else. */
    private val hidden = mutableListOf<WeakReference<View>>()

    /** The container being kept hidden, and the observer watching it. */
    private var watching: WeakReference<View>? = null
    private var observer: ViewTreeObserver? = null
    private val onGlobalLayout = ViewTreeObserver.OnGlobalLayoutListener { refreshWhileHidden() }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setEngineViewVisible" -> {
                val visible = call.arguments as? Boolean
                if (visible == null) {
                    result.error(
                        "invalid_argument",
                        "setEngineViewVisible expects a boolean",
                        null,
                    )
                    return
                }

                setVisible(visible)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Applies [visible] to the container and to the engine's surface views.
     *
     * Never conditional on the container looking hidden already. `isShown` was
     * false every single time the page was still on the window, so a guard on
     * it skips exactly the case this exists for.
     *
     * Showing again lifts what this hid, and only that. A surface someone else
     * took out of the hierarchy's view — Gecko releasing a session, say — was
     * not hidden here and is not this class's to put back, so the views that
     * were actually changed are the ones remembered and restored.
     */
    private fun setVisible(visible: Boolean) {
        val container = activityProvider()?.findViewById<View>(containerId) ?: return

        Log.i(
            TAG,
            "setEngineViewVisible($visible): container was " +
                "${describe(container)}, wrapper ${describe(container.parent as? View)}",
        )

        if (visible) {
            stopWatching()
            hidden.forEach { reference ->
                val view = reference.get() ?: return@forEach
                if (view.visibility == View.INVISIBLE) {
                    view.visibility = View.VISIBLE
                }
            }
            hidden.clear()
            return
        }

        hideTree(container)
        startWatching(container)
    }

    /** Hides [container] and every surface under it, remembering each one. */
    private fun hideTree(container: View) {
        hide(container)
        forEachSurfaceView(container) { hide(it) }
    }

    private fun hide(view: View) {
        if (view.visibility != View.VISIBLE) {
            return
        }

        view.visibility = View.INVISIBLE
        hidden += WeakReference(view)
    }

    private fun forEachSurfaceView(view: View, action: (SurfaceView) -> Unit) {
        if (view is SurfaceView) {
            action(view)
            return
        }

        if (view !is ViewGroup) {
            return
        }

        for (i in 0 until view.childCount) {
            forEachSurfaceView(view.getChildAt(i), action)
        }
    }

    /**
     * Re-hides the subtree while it is meant to be hidden.
     *
     * A session swapped in behind a covering route brings its own surface view,
     * attached visible, painting the page over Flutter again — the very
     * symptom, arriving after the hide that was supposed to prevent it. A
     * layout pass is what a new surface causes, so that is what this hangs off.
     *
     * Idempotent by construction: [hide] only touches views that are visible,
     * so a pass that changes nothing requests no layout and cannot feed itself.
     */
    internal fun refreshWhileHidden() {
        val container = watching?.get() ?: return
        hideTree(container)
    }

    private fun startWatching(container: View) {
        if (observer != null) {
            return
        }

        val treeObserver = container.viewTreeObserver
        if (!treeObserver.isAlive) {
            return
        }

        treeObserver.addOnGlobalLayoutListener(onGlobalLayout)
        observer = treeObserver
        watching = WeakReference(container)
    }

    private fun stopWatching() {
        val treeObserver = observer ?: return
        observer = null
        watching = null

        // A dead observer has already dropped its listeners, and the live one
        // the container holds now is not the one this registered on.
        if (treeObserver.isAlive) {
            treeObserver.removeOnGlobalLayoutListener(onGlobalLayout)
        }
    }

    /**
     * One line per change, kept in release builds: the state this reports is
     * the whole diagnosis of a page that outstays its frame, and it only costs
     * a line per navigation.
     */
    private fun describe(view: View?): String {
        if (view == null) {
            return "null"
        }

        val visibility = when (view.visibility) {
            View.VISIBLE -> "VISIBLE"
            View.INVISIBLE -> "INVISIBLE"
            else -> "GONE"
        }

        return "${view.javaClass.simpleName} $visibility ${view.width}x${view.height} " +
            "shown=${view.isShown} attached=${view.isAttachedToWindow}"
    }

    fun dispose() {
        stopWatching()
        hidden.clear()
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "EngineViewVisibility"
        private const val CHANNEL = "eu.weblibre.flutter_mozilla_components/engine_view"
    }
}
