package eu.lensai.flutter_mozilla_components.integration

import android.content.Context
import android.graphics.drawable.Drawable
import androidx.core.content.ContextCompat
import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.api.ReaderViewEventsImpl
import eu.lensai.flutter_mozilla_components.api.ReaderViewControllerListener
import eu.lensai.flutter_mozilla_components.pigeons.ReaderViewController
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.feature.readerview.ReaderViewFeature
import mozilla.components.feature.readerview.view.ReaderViewControlsView
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.base.feature.UserInteractionHandler

@Suppress("UndocumentedPublicClass")
class ReaderViewIntegration(
    context: Context,
    engine: Engine,
    store: BrowserStore,
    view: ReaderViewControlsView,
    readerViewEvents: ReaderViewEventsImpl,
    readerViewController: ReaderViewController
) : LifecycleAwareFeature, UserInteractionHandler {

    private val controllerListener = object : ReaderViewControllerListener {
        override fun onReaderViewToggled(enabled: Boolean) {
            if (enabled) {
                feature.showReaderView()

                readerViewController.appearanceButtonVisibility(true) { _ -> };
            } else {
                feature.hideReaderView()
                feature.hideControls()

                readerViewController.appearanceButtonVisibility(false) { _ -> };
            }
        }

        override fun onAppearanceButtonTap() {
            feature.showControls()
        }
    }

    init {
        readerViewEvents.addListener(controllerListener)
    }

    private val feature = ReaderViewFeature(context, engine, store, view)
    // Will be event based in flutter
//    { available, active ->
//        readerViewButtonVisible = available
//        readerViewButton.setSelected(active)
//
//        if (active) readerViewAppearanceButton.show() else readerViewAppearanceButton.hide()
//        toolbar.invalidateActions()
//    }

    override fun start() {
        feature.start()
    }

    override fun stop() {
        feature.stop()
    }

    override fun onBackPressed(): Boolean {
        return feature.onBackPressed()
    }
}
