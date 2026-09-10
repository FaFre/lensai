/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.app.Activity
import android.view.SurfaceView
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.StandardMethodCodec
import java.nio.ByteBuffer
import kotlin.test.assertEquals
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class EngineViewVisibilityTest {
    /** Enough of the messenger to hand the channel's own handler back. */
    private class FakeMessenger : BinaryMessenger {
        val handlers = mutableMapOf<String, BinaryMessenger.BinaryMessageHandler>()

        override fun send(channel: String, message: ByteBuffer?) = Unit

        override fun send(
            channel: String,
            message: ByteBuffer?,
            callback: BinaryMessenger.BinaryReply?,
        ) = Unit

        override fun setMessageHandler(
            channel: String,
            handler: BinaryMessenger.BinaryMessageHandler?,
        ) {
            if (handler == null) handlers.remove(channel) else handlers[channel] = handler
        }
    }

    private val activity: Activity =
        Robolectric.buildActivity(Activity::class.java).setup().get()
    private val messenger = FakeMessenger()

    private val container = FrameLayout(activity).apply { id = CONTAINER_ID }
    private val surface = SurfaceView(activity)

    private val visibility = EngineViewVisibility(
        messenger,
        activityProvider = { activity },
        containerId = CONTAINER_ID,
    )

    init {
        container.addView(surface)
        activity.setContentView(container)
    }

    /** Drives the plugin the way Dart does, through the channel it registered. */
    private fun setVisible(visible: Boolean) {
        val handler = messenger.handlers.getValue(CHANNEL)
        val message = StandardMethodCodec.INSTANCE
            .encodeMethodCall(MethodCall("setEngineViewVisible", visible))
        message.rewind()
        handler.onMessage(message, BinaryMessenger.BinaryReply { })
    }

    @After
    fun tearDown() = visibility.dispose()

    @Test
    fun `hiding takes the surface off the window and showing puts it back`() {
        setVisible(false)
        assertEquals(View.INVISIBLE, container.visibility)
        assertEquals(View.INVISIBLE, surface.visibility)

        setVisible(true)
        assertEquals(View.VISIBLE, container.visibility)
        assertEquals(View.VISIBLE, surface.visibility)
    }

    @Test
    fun `a surface someone else hid is not lifted by showing`() {
        // Gecko released the session while the route above was covering it.
        surface.visibility = View.INVISIBLE

        setVisible(false)
        setVisible(true)

        assertEquals(View.VISIBLE, container.visibility)
        assertEquals(
            View.INVISIBLE,
            surface.visibility,
            "showing again may only lift what this hid",
        )
    }

    @Test
    fun `a surface attached while hidden is hidden too, and lifted with the rest`() {
        setVisible(false)

        // A session swapped in behind the covering route brings its own surface,
        // attached visible. The layout pass that causes is what drives this.
        val swapped = SurfaceView(activity)
        container.addView(swapped)
        visibility.refreshWhileHidden()

        assertEquals(View.INVISIBLE, swapped.visibility)

        setVisible(true)
        assertEquals(View.VISIBLE, swapped.visibility)
        assertEquals(View.VISIBLE, surface.visibility)
    }

    @Test
    fun `hiding twice still restores in one showing`() {
        setVisible(false)
        setVisible(false)
        setVisible(true)

        assertEquals(View.VISIBLE, container.visibility)
        assertEquals(View.VISIBLE, surface.visibility)
    }

    @Test
    fun `a surface attached after showing is left alone`() {
        setVisible(false)
        setVisible(true)

        val later = SurfaceView(activity)
        container.addView(later)
        visibility.refreshWhileHidden()

        assertEquals(View.VISIBLE, later.visibility)
    }

    private companion object {
        const val CONTAINER_ID = 4242
        const val CHANNEL = "eu.weblibre.flutter_mozilla_components/engine_view"
    }
}
