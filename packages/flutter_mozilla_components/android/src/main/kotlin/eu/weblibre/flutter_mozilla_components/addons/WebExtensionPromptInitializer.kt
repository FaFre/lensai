/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import androidx.startup.Initializer

/**
 * Registers [WebExtensionPromptHost] at process start.
 *
 * The host has to be tracking activities *before the first one resumes*:
 * `Application.registerActivityLifecycleCallbacks` never reports the activity
 * that is already up, and components are built from Dart's `initialize()` long
 * after the main window has resumed. Registering from `GlobalComponents.setUp`,
 * where every other process-scoped feature installs itself, would therefore miss
 * it — and would never run at all in a process that fronts a custom tab without
 * ever building a Flutter engine.
 *
 * An initializer is what makes that automatic rather than something each host app
 * has to remember: forgetting it costs no error, just extension installs that
 * hang on an unanswered permission prompt.
 *
 * Safe this early, and deliberately the only thing done here: `InitializationProvider`
 * runs between `Application.attachBaseContext` and `Application.onCreate`, so it is
 * after the profile arbiter is installed but before anything may touch a
 * profile-sensitive preference — and registering a lifecycle listener touches no
 * preference, no profile and no component. It also runs in Gecko's child
 * processes, where it stays inert: they have no activities, and the host binds
 * nothing until components exist.
 */
class WebExtensionPromptInitializer : Initializer<Unit> {
    override fun create(context: Context) {
        WebExtensionPromptHost.install(context)
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}
