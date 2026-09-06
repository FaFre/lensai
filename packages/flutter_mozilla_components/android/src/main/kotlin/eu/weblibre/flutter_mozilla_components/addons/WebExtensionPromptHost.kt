/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.fragment.app.FragmentActivity
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ProfileContext
import java.lang.ref.WeakReference
import mozilla.components.support.base.log.logger.Logger

/**
 * Keeps one [WebExtensionPromptFeature] running against whichever activity is in
 * front of the user.
 *
 * Installing an extension blocks in Gecko until the permission prompt is
 * answered: `ExtensionPromptObserver.permissionPromptRequest` awaits the response
 * before the install ends, so nothing calls back — not `AddonManager`'s
 * `onSuccess`, not the Pigeon callback, not the Dart future — until something
 * consumes the `webExtensionPromptRequest` the store is holding.
 *
 * That consumer used to be created in `BaseBrowserFragment.onViewCreated`, bound
 * to the fragment's view. The fragment only exists once the GeckoView platform
 * view has been *painted* (hybrid composition inserts its container on first
 * composite), and the home surface keeps the engine `Offstage`. A start that
 * never showed a tab therefore had no consumer at all, and every install hung
 * until the user opened one — at which point the retained prompt was re-emitted
 * and the dialog finally appeared. See
 * https://github.com/FaFre/WebLibre/issues/557 for the attach mechanics.
 *
 * An activity is the right owner instead: it is what the dialog needs, it exists
 * whether or not a tab was ever shown, and it covers `ExternalAppBrowserActivity`
 * — a plain `AppCompatActivity`, outside the Flutter plugin's activity binding —
 * on the same path as the main window.
 *
 * **Exactly one instance may run.** Two collectors would both answer the same
 * prompt, and `DialogFragment.show()` commits asynchronously, so the second
 * would not see the first's dialog through `findFragmentByTag` and the user
 * would get two. Binding to the *resumed* activity is what guarantees the single
 * instance; a started-scoped binding would overlap during activity transitions.
 *
 * The tracker holds one activity, so under multi-resume (split screen, freeform)
 * the most recently resumed window wins and pausing it leaves the other
 * unbound until it is resumed again. That is the behaviour every prompt already
 * had, and the retained request means nothing is lost — only deferred.
 */
object WebExtensionPromptHost : Application.ActivityLifecycleCallbacks {
    private val logger = Logger("WebExtensionPromptHost")

    private var registered = false

    /** The resumed activity, whether or not components existed to bind it to. */
    private var resumedActivity: WeakReference<FragmentActivity>? = null

    private var boundActivity: WeakReference<FragmentActivity>? = null
    private var feature: WebExtensionPromptFeature? = null

    /**
     * Starts tracking activities for the life of the process.
     *
     * Called from `WebExtensionPromptInitializer`, i.e. before the first activity
     * is created, rather than from `GlobalComponents.setUp` where the other
     * process-scoped features install themselves: callbacks registered at setUp
     * would miss the activity that is *already* resumed, since components are
     * built from Dart's `initialize()` long after the main window came up.
     * [onComponentsChanged] closes the other half — an activity resumed before
     * there was a store to bind it to.
     *
     * Takes a plain [Context] and resolves the application from it. Note that
     * `ProfileContext.getApplicationContext()` returns *itself*, so one of those
     * would resolve to no application at all; the initializer hands us the real
     * one, before any profile context exists.
     */
    fun install(context: Context) {
        val application = context.applicationContext as? Application ?: return

        onMainThread {
            if (registered) {
                return@onMainThread
            }

            registered = true
            application.registerActivityLifecycleCallbacks(this)
        }
    }

    /**
     * Re-binds the resumed activity to whatever components now exist.
     *
     * Covers the cold start, where the window is up before the store exists; the
     * external-to-full rebuild, which replaces the store under a feature that
     * would otherwise keep answering prompts on the outgoing one; and the
     * teardown, after which there is nothing left to answer them with.
     */
    fun onComponentsChanged() {
        onMainThread {
            val activity = resumedActivity?.get()
            if (activity == null) unbind() else bind(activity)
        }
    }

    override fun onActivityResumed(activity: Activity) {
        val fragmentActivity = activity as? FragmentActivity ?: return

        // The translucent entry points — `IntentReceiverActivity` and friends —
        // finish from `onCreate` and still report a resume on the way out. Hosting
        // a prompt there would show the dialog into a window that is already going
        // away, and the request would only be re-shown on the next resume anyway.
        if (fragmentActivity.isFinishing) {
            return
        }

        resumedActivity = WeakReference(fragmentActivity)
        bind(fragmentActivity)
    }

    override fun onActivityPaused(activity: Activity) {
        if (resumedActivity?.get() === activity) {
            resumedActivity = null
        }

        if (boundActivity?.get() === activity) {
            unbind()
        }
    }

    override fun onActivityDestroyed(activity: Activity) {
        // A paused activity has already released the binding; this only drops the
        // weak references for one that never reported a pause.
        onActivityPaused(activity)
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit
    override fun onActivityStarted(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit

    private fun bind(activity: FragmentActivity) {
        // Released first, and unconditionally, even when [activity] is already the
        // bound one: this also runs for a rebuilt component set, and the running
        // feature would be holding the store that was replaced.
        unbind()

        val components = GlobalComponents.components ?: return

        val feature = WebExtensionPromptFeature(
            store = components.core.store,
            // The activity, wrapped the way `BaseBrowserFragment` wrapped it, so
            // the dialogs keep the window's theme and resolve profile-scoped
            // state the same way they always did.
            context = ProfileContext(
                activity,
                components.profileApplicationContext.relativePath,
            ),
            fragmentManager = activity.supportFragmentManager,
            addonManager = components.core.addonManager,
            addonEvents = components.addonEvents,
        )

        // Starting re-emits the store's current state, so a prompt raised while
        // nothing was bound — an install begun on the home surface, or before
        // this window existed — is picked up here rather than waiting for the
        // next one.
        feature.start()

        this.feature = feature
        boundActivity = WeakReference(activity)

        logger.debug("Bound web extension prompts to ${activity.javaClass.simpleName}")
    }

    private fun unbind() {
        feature?.stop()
        feature = null
        boundActivity = null
    }

    /**
     * Components can be built off the main thread on the headless paths, and both
     * the fragment manager and the store subscription are main-thread only.
     */
    private fun onMainThread(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            Handler(Looper.getMainLooper()).post { block() }
        }
    }
}
