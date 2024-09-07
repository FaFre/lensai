package eu.lensai.flutter_mozilla_components

import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.downloads.AbstractFetchDownloadService
import mozilla.components.support.base.android.NotificationsDelegate

class DownloadService : AbstractFetchDownloadService() {
    override val httpClient by lazy { GlobalComponents.components!!.client }
    override val store: BrowserStore by lazy { GlobalComponents.components!!.store }
    override val notificationsDelegate: NotificationsDelegate by lazy { GlobalComponents.components!!.notificationsDelegate }
}