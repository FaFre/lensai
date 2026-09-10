/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.app.Activity
import android.content.Context
// import android.util.Log
import android.view.MotionEvent
import androidx.core.view.WindowInsetsCompat
import eu.weblibre.flutter_mozilla_components.pointer.PointerInputRouter
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.feature.GestureRecognizer
import kotlin.math.abs

/**
 * Root container for the embedded browser fragment.
 *
 * Why: Flutter's platform-view motion-event pipeline does not reliably forward
 * ACTION_CANCEL when the Android system claims a back gesture mid-stream. On
 * affected devices (notably Samsung One UI) GeckoView's APZ receives the
 * leading touches of the back gesture and produces a short, unwanted page
 * scroll before the gesture is recognized.
 *
 * This view watches every touch in dispatchTouchEvent (rather than
 * onInterceptTouchEvent — NestedGeckoView calls requestDisallowInterceptTouchEvent
 * on ACTION_DOWN, which would suppress the intercept hook for the rest of the
 * gesture). When a horizontal drag begins inside the system back-gesture inset
 * and the gesture becomes unambiguous (horizontal travel exceeds touch slop and
 * dominates over vertical travel), it dispatches a synthetic ACTION_CANCEL to
 * children and swallows the remainder of the gesture. APZ resets cleanly on
 * the cancel.
 *
 * Taps and vertical drags that originate in the inset still reach the engine
 * view, so links and vertical scrolling continue to work at the edges.
 *
 * This container is also the single observation point for configurable touch
 * gestures: every event is fed to a [GestureRecognizer] before the back-gesture
 * filter runs. Recognition is purely observational (events are never consumed
 * for gestures), so pages scroll and tap normally; a recognized multi-stroke
 * gesture is reported to Dart on touch-up via [GlobalComponents.gestureEvents].
 */
class BackGestureFilterFrameLayout(
    context: Context,
    private val activity: Activity,
    platformViewId: Int,
    pointerRouter: PointerInputRouter,
) : PointerInputFrameLayout(context, platformViewId, pointerRouter) {
    private var downX = 0f
    private var downY = 0f
    private var startedInEdgeZone = false
    private var hasIntercepted = false

    private val gestureRecognizer = GestureRecognizer()
    private val gestureTimeoutRunnable = Runnable { cancelGesture() }

    /**
     * Whether the live feedback overlay is currently being shown for an
     * in-progress stroke. Tracked so a reset is reported to Dart only after a
     * progress event, keeping plain taps and scrolls off the platform channel.
     */
    private var gestureFeedbackActive = false

    init {
        // A new direction arrow was registered: restart the idle-timeout (the
        // reference add-on restarts only on a new arrow, not on every move) and
        // forward the partial stroke to the live feedback overlay.
        gestureRecognizer.onProgress = { partialKey ->
            val config = GlobalComponents.gestureConfig
            if (config != null && config.enabled) {
                removeCallbacks(gestureTimeoutRunnable)
                postDelayed(gestureTimeoutRunnable, config.timeoutMs)
                gestureFeedbackActive = true
                GlobalComponents.gestureEvents
                    ?.onGestureProgress(EventSequence.next(), partialKey) { }
            }
        }
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        feedGestureRecognizer(ev)

        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                downX = ev.x
                downY = ev.y
                hasIntercepted = false
                val (left, right) = currentGestureInsets()
                startedInEdgeZone = isInEdgeZone(ev.x, left, right)
            }

            MotionEvent.ACTION_MOVE -> {
                if (hasIntercepted) {
                    return true
                }
                if (startedInEdgeZone) {
                    val dx = abs(ev.x - downX)
                    val dy = abs(ev.y - downY)
                    when {
                        // Horizontal-dominant: this is a back-gesture pan. The OS will
                        // CANCEL shortly, but APZ's internal pan threshold is smaller
                        // than Android's touchSlop, so even the small leading MOVEs
                        // already scrolled the page. Cancel APZ now and swallow the rest.
                        dx > dy + 1 -> {
                            hasIntercepted = true
                            // The stream now belongs to the system back gesture;
                            // discard any partial touch gesture so it can't fire.
                            cancelGesture()
                            // Log.d(TAG, "INTERCEPT dx=$dx dy=$dy")
                            dispatchSyntheticCancel(ev)
                            return true
                        }
                        // Vertical-dominant: the gesture is a real in-page scroll;
                        // stop watching so subsequent MOVEs pass through.
                        dy > dx + 1 -> {
                            startedInEdgeZone = false
                        }
                    }
                }
            }

            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL -> {
                val wasIntercepted = hasIntercepted
                resetGestureState()
                if (wasIntercepted) {
                    return true
                }
            }
        }
        return super.dispatchTouchEvent(ev)
    }

    /**
     * Observes every touch event for configurable gestures. Reads the latest
     * config pushed from Dart, drives the idle-timeout, and reports a matched
     * gesture key on touch-up. Runs on the UI thread (dispatchTouchEvent), so
     * the event sink can be invoked directly.
     */
    private fun feedGestureRecognizer(ev: MotionEvent) {
        val config = GlobalComponents.gestureConfig
        gestureRecognizer.config = config

        val key = gestureRecognizer.feed(
            ev,
            width,
            height,
            GlobalComponents.bottomViewportInsetPx,
        )

        when (ev.actionMasked) {
            // Start the idle window on touch-down; subsequent restarts happen
            // only when the recognizer reports a new arrow (see onProgress).
            MotionEvent.ACTION_DOWN -> {
                // New touch: clear any gesture claim so pull-to-refresh is only
                // suppressed when this stroke actually matches a gesture.
                GlobalComponents.touchConsumedByGesture = false
                if (config != null && config.enabled) {
                    removeCallbacks(gestureTimeoutRunnable)
                    postDelayed(gestureTimeoutRunnable, config.timeoutMs)
                }
            }

            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL -> {
                removeCallbacks(gestureTimeoutRunnable)
                emitGestureReset()
            }
        }

        if (key != null) {
            // Mark this touch as gesture-handled before the event propagates to
            // the swipe-refresh layout's own ACTION_UP handling, so a redundant
            // pull-to-refresh reload is suppressed (see
            // GestureAwareSwipeRefreshFeature).
            GlobalComponents.touchConsumedByGesture = true
            GlobalComponents.gestureEvents
                ?.onGestureRecognized(EventSequence.next(), key) { }
        }
    }

    /** Discards any in-progress gesture and clears its feedback overlay. */
    private fun cancelGesture() {
        removeCallbacks(gestureTimeoutRunnable)
        gestureRecognizer.cancel()
        emitGestureReset()
    }

    /** Tells Dart to hide the live feedback overlay, if one is showing. */
    private fun emitGestureReset() {
        if (!gestureFeedbackActive) return
        gestureFeedbackActive = false
        GlobalComponents.gestureEvents
            ?.onGestureReset(EventSequence.next()) { }
    }

    private fun dispatchSyntheticCancel(source: MotionEvent) {
        val cancel = MotionEvent.obtain(source).apply {
            action = MotionEvent.ACTION_CANCEL
        }
        super.dispatchTouchEvent(cancel)
        cancel.recycle()
    }

    private fun resetGestureState() {
        startedInEdgeZone = false
        hasIntercepted = false
    }

    private fun currentGestureInsets(): Pair<Int, Int> {
        val rawInsets = activity.window.decorView.rootWindowInsets ?: return 0 to 0
        val gestureInsets = WindowInsetsCompat.toWindowInsetsCompat(rawInsets)
            .getInsets(WindowInsetsCompat.Type.systemGestures())
        return gestureInsets.left to gestureInsets.right
    }

    private fun isInEdgeZone(x: Float, left: Int, right: Int): Boolean {
        if (left == 0 && right == 0) {
            // 3-button navigation (or unknown): no system back gesture to defend
            // against, so all edge touches must reach the engine view normally.
            return false
        }
        return x <= left || x >= width - right
    }

    // companion object {
    //     private const val TAG = "BackGestureFilter"
    // }
}
