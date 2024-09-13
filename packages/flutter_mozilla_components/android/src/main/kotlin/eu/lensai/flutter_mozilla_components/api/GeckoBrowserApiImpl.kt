package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.pigeons.GeckoBrowserApi

class GeckoBrowserApiImpl(private val showFragmentCallback: () -> Unit) : GeckoBrowserApi {
    override fun showNativeFragment() {
        showFragmentCallback.invoke();
    }
}