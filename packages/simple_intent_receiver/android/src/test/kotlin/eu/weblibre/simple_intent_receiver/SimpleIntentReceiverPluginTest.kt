/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.simple_intent_receiver

import android.app.Activity
import android.content.Intent
import android.net.Uri
import eu.weblibre.simple_intent_receiver.pigeons.IntentEvents
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import java.lang.reflect.Proxy
import java.nio.ByteBuffer
import kotlin.test.assertEquals
import kotlin.test.assertNull
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import eu.weblibre.simple_intent_receiver.pigeons.Intent as PigeonIntent

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class SimpleIntentReceiverPluginTest {
    class HostActivity : Activity(), IntentReceiverHost {
        override var isRestoredLaunch = false
    }

    private class RecordingMessenger : BinaryMessenger {
        val delivered = mutableListOf<PigeonIntent>()

        override fun send(channel: String, message: ByteBuffer?) = send(channel, message, null)

        override fun send(channel: String, message: ByteBuffer?, callback: BinaryMessenger.BinaryReply?) {
            val arguments = IntentEvents.codec.decodeMessage(message!!.duplicate().apply { flip() }) as List<*>
            delivered += arguments[1] as PigeonIntent
        }

        override fun setMessageHandler(channel: String, handler: BinaryMessenger.BinaryMessageHandler?) = Unit
    }

    @Before
    @After
    fun clearBacklog() {
        SimpleIntentReceiverPlugin().takePendingIntents()
    }

    private fun link() = Intent(Intent.ACTION_VIEW, Uri.parse("https://example.com/repeat"))

    private fun engineBinding(messenger: BinaryMessenger): FlutterPluginBinding {
        // The plugin only needs the context and messenger, not a native Flutter engine.
        return FlutterPluginBinding::class.java.constructors.single().newInstance(
            RuntimeEnvironment.getApplication(), null, messenger, null, null, null, null,
        ) as FlutterPluginBinding
    }

    private fun activityBinding(intent: Intent = link(), restored: Boolean = false): ActivityPluginBinding {
        val activity = Robolectric.buildActivity(HostActivity::class.java, intent).create().get()
        activity.isRestoredLaunch = restored
        return Proxy.newProxyInstance(
            ActivityPluginBinding::class.java.classLoader,
            arrayOf(ActivityPluginBinding::class.java),
        ) { _, method, _ ->
            when (method.name) {
                "getActivity" -> activity
                "addOnNewIntentListener", "removeOnNewIntentListener" -> null
                else -> error("Unexpected binding call: ${method.name}")
            }
        } as ActivityPluginBinding
    }

    @Test
    fun restoredActivityDoesNotReplayButFreshActivityAndNewIntentCanRepeatTheUrl() {
        val plugin = SimpleIntentReceiverPlugin()
        val messenger = RecordingMessenger()
        plugin.onAttachedToEngine(engineBinding(messenger))
        plugin.takePendingIntents()

        plugin.onAttachedToActivity(activityBinding())
        assertEquals(1, messenger.delivered.size)
        plugin.onDetachedFromActivity()

        // Android reconstructs its copy, not the Intent object first given to the plugin.
        plugin.onAttachedToActivity(activityBinding(restored = true))
        assertEquals(1, messenger.delivered.size)
        plugin.onNewIntent(link())
        assertEquals(2, messenger.delivered.size)
        plugin.onDetachedFromActivity()

        plugin.onAttachedToActivity(activityBinding())
        assertEquals(List(3) { link().dataString }, messenger.delivered.map { it.data })
    }

    @Test
    fun restoredLaunchIsSkippedBeforeRedeemingItsApproval() {
        val context = RuntimeEnvironment.getApplication()
        val approval = NotificationApproval("unused-token", "example.caller")
        IntentApprovals.restore(context, approval)
        val intent = link().putExtra(IntentApprovals.EXTRA_NOTIFICATION_APPROVAL_TOKEN, approval.token)
        val plugin = SimpleIntentReceiverPlugin()
        plugin.onAttachedToEngine(engineBinding(RecordingMessenger()))

        plugin.onAttachedToActivity(activityBinding(intent, restored = true))

        assertEquals(emptyList(), plugin.takePendingIntents())
        assertEquals(approval, IntentApprovals.consume(context, intent))
    }

    @Test
    fun engineReplacementKeepsPreparedBacklogWithoutReplayingTheRestoredLaunch() {
        val context = RuntimeEnvironment.getApplication()
        val approval = NotificationApproval("approved-token", "example.caller")
        IntentApprovals.restore(context, approval)
        val intent = link().putExtra(IntentApprovals.EXTRA_NOTIFICATION_APPROVAL_TOKEN, approval.token)
        val old = SimpleIntentReceiverPlugin()
        val oldBinding = engineBinding(RecordingMessenger())
        old.onAttachedToEngine(oldBinding)
        old.onAttachedToActivity(activityBinding(intent))
        assertNull(IntentApprovals.consume(context, intent))

        old.onDetachedFromActivity()
        old.onDetachedFromEngine(oldBinding)

        val replacement = SimpleIntentReceiverPlugin()
        val messenger = RecordingMessenger()
        replacement.onAttachedToEngine(engineBinding(messenger))
        replacement.onAttachedToActivity(activityBinding(Intent(intent), restored = true))
        replacement.onNewIntent(link())
        assertEquals(emptyList(), messenger.delivered)

        val pending = replacement.takePendingIntents()
        assertEquals(List(2) { link().dataString }, pending.map { it.data })
        assertNull(pending[0].fromPackageName)
        assertEquals("example.caller", pending[0].extra[IntentApprovals.EXTRA_ALWAYS_ALLOW_PACKAGE])
        assertNull(pending[0].extra[IntentApprovals.EXTRA_NOTIFICATION_APPROVAL_TOKEN])
        assertNull(pending[1].extra[IntentApprovals.EXTRA_ALWAYS_ALLOW_PACKAGE])
        assertEquals(emptyList(), replacement.takePendingIntents())
        replacement.onNewIntent(link())
        assertEquals(1, messenger.delivered.size)
    }

    @Test
    fun configReattachmentDoesNotReplayTheLaunch() {
        val plugin = SimpleIntentReceiverPlugin()
        plugin.onAttachedToEngine(engineBinding(RecordingMessenger()))
        plugin.onAttachedToActivity(activityBinding())
        plugin.onDetachedFromActivityForConfigChanges()
        plugin.onReattachedToActivityForConfigChanges(activityBinding())

        assertEquals(1, plugin.takePendingIntents().size)
    }

    @Test
    fun reattachingTheSamePluginToAnEngineResetsReadiness() {
        val plugin = SimpleIntentReceiverPlugin()
        val oldBinding = engineBinding(RecordingMessenger())
        plugin.onAttachedToEngine(oldBinding)
        plugin.takePendingIntents()
        plugin.onDetachedFromEngine(oldBinding)

        val messenger = RecordingMessenger()
        plugin.onAttachedToEngine(engineBinding(messenger))
        plugin.onAttachedToActivity(activityBinding())

        assertEquals(emptyList(), messenger.delivered)
        assertEquals(1, plugin.takePendingIntents().size)
    }
}
