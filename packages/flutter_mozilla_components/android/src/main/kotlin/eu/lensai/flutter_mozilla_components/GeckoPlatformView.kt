package eu.lensai.flutter_mozilla_components

import android.view.View
import android.app.Activity
import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class GeckoViewFactory(private val activity: Activity, private val containerId: Int) : PlatformViewFactory(
    StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        return NativeFragmentView(this.activity, this.containerId)
    }
}

private class NativeFragmentView(
    private val activity: Activity?,
    private val containerId: Int
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

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        // Clean up if needed
    }
}