package eu.lensai.flutter_mozilla_components

import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.base.crash.CrashReporting
import mozilla.components.feature.media.service.AbstractMediaSessionService
import mozilla.components.support.base.android.NotificationsDelegate

/**
 * See [AbstractMediaSessionService].
 */
class MediaSessionService : AbstractMediaSessionService() {
    override val crashReporter: CrashReporting? by lazy { GlobalComponents.components!!.crashReporter }
    override val store: BrowserStore by lazy { GlobalComponents.components!!.store }
    override val notificationsDelegate: NotificationsDelegate by lazy { GlobalComponents.components!!.notificationsDelegate }
}