package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoBrowserApi
import mozilla.components.browser.state.action.SystemAction
import mozilla.components.feature.addons.logger

class GeckoBrowserApiImpl(private val showFragmentCallback: () -> Unit) : GeckoBrowserApi {
    override fun showNativeFragment() {
        showFragmentCallback.invoke();
    }

    override fun onTrimMemory(level: Long) {
        logger.debug("onTrimMemory: $level")

        val components = GlobalComponents.components!!

        components.store.dispatch(SystemAction.LowMemoryAction(level.toInt()))
        components.icons.onTrimMemory(level.toInt())
    }
}