package eu.lensai.flutter_mozilla_components

import android.view.View
import android.app.Activity
import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class GeckoViewFactory(
    private val activity: Activity,
    private val containerId: Int,
    private val flutterEvents: GeckoStateEvents
    ) : PlatformViewFactory(
    StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        return NativeFragmentView(this.activity, this.containerId, this.flutterEvents)
    }
}

private class NativeFragmentView(
    activity: Activity?,
    containerId: Int,
    private val flutterEvents: GeckoStateEvents
) : PlatformView {
    private val container: View

    init {
        val vParams: ViewGroup.LayoutParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
            )
        container = FrameLayout(activity!!)
        container.layoutParams = vParams
        container.id = containerId
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)

        GlobalComponents.components!!.engineReportedInitialized = false;
        flutterEvents.onViewReadyStateChange(System.currentTimeMillis(),true) { _ -> }
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        // Clean up if needed
    }
}