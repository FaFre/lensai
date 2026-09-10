/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.view.View
import android.app.Activity
import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pointer.PointerInputRouter
import eu.weblibre.flutter_mozilla_components.widget.BackGestureFilterFrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class GeckoViewFactory(
    private val activityProvider: () -> Activity?,
    private val containerId: Int,
    private val flutterEvents: GeckoStateEvents,
    private val pointerRouter: PointerInputRouter,
    ) : PlatformViewFactory(
    StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        val activity = activityProvider()
            ?: throw IllegalStateException("No activity available when creating GeckoView platform view")
        return NativeFragmentView(activity, this.containerId, this.flutterEvents, id, pointerRouter)
    }
}

private class NativeFragmentView(
    activity: Activity?,
    containerId: Int,
    private val flutterEvents: GeckoStateEvents,
    platformViewId: Int,
    pointerRouter: PointerInputRouter,
) : PlatformView {
    private val container: BackGestureFilterFrameLayout

    /**
     * Reports whether the container is reachable through [Activity.findViewById], which is what
     * `GeckoBrowserApiImpl.showFragmentCallback` needs before it can attach the browser fragment.
     *
     * Hybrid composition (and HC++) only insert the platform view into the Flutter view hierarchy
     * the first time its layer is composited — `PlatformViewsController#onDisplayPlatformView` ->
     * `initializePlatformViewIfNeeded` -> `flutterView.addView(parentView)`. A widget that lays the
     * view out but does not paint it (an `Offstage` ancestor, for instance) therefore keeps the
     * container out of the hierarchy indefinitely, and every attach attempt made in the meantime
     * fails.
     *
     * [onFlutterViewAttached] is no signal for this: Flutter calls it while constructing the
     * platform view, so reporting readiness from there claims the container is usable long before
     * it is. The container's own attach state is the fact that matters, so it is what gets
     * reported. See https://github.com/FaFre/WebLibre/issues/557.
     */
    private val attachStateListener = object : View.OnAttachStateChangeListener {
        override fun onViewAttachedToWindow(v: View) {
            flutterEvents.onViewReadyStateChange(EventSequence.next(), true) { _ -> }
        }

        override fun onViewDetachedFromWindow(v: View) {
            flutterEvents.onViewReadyStateChange(EventSequence.next(), false) { _ -> }
        }
    }

    init {
        val vParams: ViewGroup.LayoutParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
            )

        // Ensure activity is not null before creating the container
        if (activity == null) {
            throw IllegalStateException("Activity cannot be null when creating NativeFragmentView")
        }

        container = BackGestureFilterFrameLayout(activity, activity, platformViewId, pointerRouter)
        container.layoutParams = vParams
        container.id = containerId
        container.addOnAttachStateChangeListener(attachStateListener)
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        container.attachPointerInput(flutterView)

        // A Dart half that restarted has lost the ready state it was told when
        // components came up, and nothing else would tell it again: the engine
        // is initialized once per process, not once per Flutter view. Re-assert
        // it rather than clearing the latch and waiting for something to
        // rediscover it.
        //
        // Only when there is something to assert it about: with no components
        // the engine is not up, and saying otherwise would send Dart off to
        // call APIs that do not exist yet.
        val components = GlobalComponents.components ?: return
        components.engineReportedInitialized = true
        flutterEvents.onEngineReadyStateChange(EventSequence.next(), true) { _ -> }
    }

    override fun onFlutterViewDetached() {
        container.detachPointerInput()
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        container.detachPointerInput()
        container.removeOnAttachStateChangeListener(attachStateListener)

        // Removing the listener suppresses the detach callback that tearing the view down would
        // otherwise deliver, so report the container gone explicitly. Dart must not keep believing
        // an attach is possible against a container that no longer exists.
        flutterEvents.onViewReadyStateChange(EventSequence.next(), false) { _ -> }
    }
}
