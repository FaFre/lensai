/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.fragment.app.FragmentActivity
import eu.weblibre.flutter_mozilla_components.addons.FlutterAddonSettingsFragment
import eu.weblibre.flutter_mozilla_components.pointer.PointerInputRouter
import eu.weblibre.flutter_mozilla_components.widget.PointerInputFrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

private const val OPTIONS_PAGE_URL_KEY = "optionsPageUrl"

class AddonSettingsViewFactory(
    private val activityProvider: () -> Activity?,
    private val pointerRouter: PointerInputRouter,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        val activity = activityProvider()
            ?: throw IllegalStateException("No activity available when creating AddonSettingsView")
        val optionsPageUrl = (args as? Map<*, *>)?.get(OPTIONS_PAGE_URL_KEY) as? String
            ?: throw IllegalArgumentException("Missing optionsPageUrl creation param")

        return NativeAddonSettingsView(activity, optionsPageUrl, id, pointerRouter)
    }
}

private class NativeAddonSettingsView(
    activity: Activity,
    private val optionsPageUrl: String,
    platformViewId: Int,
    pointerRouter: PointerInputRouter,
) : PlatformView {
    private val fragmentActivity = activity as? FragmentActivity
        ?: throw IllegalStateException("Addon settings view requires a FragmentActivity host")
    private val containerId = View.generateViewId()
    private val fragmentTag = "addon_settings_$containerId"
    private var disposed = false
    private val container = PointerInputFrameLayout(activity, platformViewId, pointerRouter).apply {
        id = containerId
        layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT,
        )
    }
    private val attachStateListener = object : View.OnAttachStateChangeListener {
        override fun onViewAttachedToWindow(view: View) {
            container.removeOnAttachStateChangeListener(this)
            container.post { attachFragment() }
        }

        override fun onViewDetachedFromWindow(view: View) = Unit
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        container.attachPointerInput(flutterView)

        if (container.isAttachedToWindow) {
            container.post { attachFragment() }
        } else {
            container.removeOnAttachStateChangeListener(attachStateListener)
            container.addOnAttachStateChangeListener(attachStateListener)
        }
    }

    override fun onFlutterViewDetached() {
        container.detachPointerInput()
    }

    override fun getView(): View = container

    override fun dispose() {
        disposed = true
        container.removeOnAttachStateChangeListener(attachStateListener)
        container.detachPointerInput()
        val fm = fragmentActivity.supportFragmentManager
        if (!fragmentActivity.isFinishing && !fragmentActivity.isDestroyed && !fm.isStateSaved) {
            fm.findFragmentByTag(fragmentTag)?.let { fragment ->
                fm.beginTransaction().remove(fragment).commitNowAllowingStateLoss()
            }
        }
    }

    private fun attachFragment() {
        if (disposed || fragmentActivity.isFinishing || fragmentActivity.isDestroyed) {
            return
        }

        val fm = fragmentActivity.supportFragmentManager
        if (fm.isStateSaved) {
            return
        }

        if (fragmentActivity.findViewById<View>(containerId) == null) {
            return
        }

        val existingFragment = fm.findFragmentByTag(fragmentTag)
        if (existingFragment is FlutterAddonSettingsFragment) {
            return
        }

        fm.beginTransaction()
            .replace(containerId, FlutterAddonSettingsFragment.create(optionsPageUrl), fragmentTag)
            .commitNow()
    }
}
