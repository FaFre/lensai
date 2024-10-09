package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import mozilla.components.concept.engine.Engine

class GeckoEngineSettingsApiImpl : GeckoEngineSettingsApi {
    private val engine: Engine by lazy { GlobalComponents.components!!.engine }

    override fun javaScriptEnabled(state: Boolean) {
        engine.settings.javascriptEnabled = state
    }
}