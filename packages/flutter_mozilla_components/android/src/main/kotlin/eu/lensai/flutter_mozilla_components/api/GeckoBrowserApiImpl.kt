package eu.lensai.flutter_mozilla_components.api

import GeckoBrowserApi

class GeckoBrowserApiImpl(
    private val showFragmentCallback: () -> Unit
) : GeckoBrowserApi {
    override fun showNativeFragment() {
        showFragmentCallback.invoke();
    }
}