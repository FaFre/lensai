/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.pointer

import android.content.Context
import android.os.Looper
import android.view.InputDevice
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.pigeons.PointerHitTest
import eu.weblibre.flutter_mozilla_components.pigeons.PointerTarget
import eu.weblibre.flutter_mozilla_components.widget.PointerInputFrameLayout
import java.time.Duration
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.annotation.LooperMode

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
@LooperMode(LooperMode.Mode.PAUSED)
class PointerInputRouterTest {
    /** Stands in for Dart, so every answer's timing and content is the test's choice. */
    private class FakeHost : PointerInputHost {
        class Query(
            val x: Double,
            val y: Double,
            val tracksHover: Boolean,
            val onResult: (PointerHitTest?) -> Unit,
        ) {
            val position get() = Triple(x, y, tracksHover)
        }

        val hitTests = mutableListOf<Query>()
        var exits = 0

        override fun hitTest(
            x: Double,
            y: Double,
            tracksHover: Boolean,
            onResult: (PointerHitTest?) -> Unit,
        ) {
            hitTests += Query(x, y, tracksHover, onResult)
        }

        override fun pointerExit() {
            exits++
        }

        /** Answers hit test [index], defaulting to a revision that keeps them ordered. */
        fun answer(index: Int, revision: Long = index.toLong(), target: PointerTarget? = null) =
            hitTests[index].onResult(PointerHitTest(revision, target))

        /** Answers hit test [index] with nothing, as an unreachable Dart half would. */
        fun fail(index: Int) = hitTests[index].onResult(null)
    }

    private val context: Context = RuntimeEnvironment.getApplication()
    private val host = FakeHost()
    private val router = PointerInputRouter(host)

    private val retained = mutableListOf<MotionEvent>()
    private fun save(event: MotionEvent): MotionEvent = MotionEvent.obtain(event).also { retained += it }

    private val flutterEvents = mutableListOf<MotionEvent>()
    private val rootDispatches = mutableListOf<Pair<Int, Int>>()

    private val flutterView = object : FrameLayout(context) {
        override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean =
            error("Flutter fallback must not redispatch into native children")
        override fun onGenericMotionEvent(event: MotionEvent): Boolean {
            flutterEvents += save(event)
            return true
        }
    }.apply { layout(10, 20, 1010, 1020) }

    /** A child of a registered root, standing in for the engine or add-on view. */
    private inner class Recorder : View(context) {
        val events = mutableListOf<MotionEvent>()
        val touches = mutableListOf<Int>()
        var handles = true
        override fun onGenericMotionEvent(event: MotionEvent): Boolean {
            events += save(event)
            return handles
        }
        override fun onHoverEvent(event: MotionEvent): Boolean {
            events += save(event)
            return handles
        }
        override fun onTouchEvent(event: MotionEvent): Boolean {
            touches += event.actionMasked
            return true
        }
    }

    private fun root(
        id: Int,
        left: Int = 0,
        top: Int = 0,
        parent: FrameLayout = flutterView,
    ): Pair<PointerInputFrameLayout, Recorder> {
        val root = object : PointerInputFrameLayout(context, id, router) {
            override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
                rootDispatches += id to event.actionMasked
                return super.dispatchGenericMotionEvent(event)
            }
        }
        val child = Recorder()
        parent.addView(root)
        root.layout(left, top, left + 400, top + 400)
        root.addView(child)
        child.layout(0, 0, 400, 400)
        root.attachPointerInput(flutterView)
        return root to child
    }

    private fun event(
        action: Int = MotionEvent.ACTION_SCROLL,
        source: Int = InputDevice.SOURCE_MOUSE,
        tool: Int = MotionEvent.TOOL_TYPE_MOUSE,
        x: Float = 30f,
        y: Float = 40f,
        time: Long = 200,
    ): MotionEvent {
        val properties = MotionEvent.PointerProperties().apply { id = 3; toolType = tool }
        val coordinates = MotionEvent.PointerCoords().apply {
            this.x = x
            this.y = y
            pressure = 0.4f
            setAxisValue(MotionEvent.AXIS_VSCROLL, -2.75f)
            setAxisValue(MotionEvent.AXIS_HSCROLL, 1.25f)
            setAxisValue(MotionEvent.AXIS_DISTANCE, 0.3f)
        }
        return MotionEvent.obtain(
            100, time, action, 1, arrayOf(properties), arrayOf(coordinates),
            KeyEvent.META_CTRL_ON or KeyEvent.META_SHIFT_ON, MotionEvent.BUTTON_SECONDARY,
            0.5f, 0.75f, 42, MotionEvent.EDGE_LEFT, source, 0,
        ).also { retained += it }
    }

    private fun target(id: Int, x: Double = 30.0, y: Double = 40.0) =
        PointerTarget(id.toLong(), x, y)

    private fun hoverTarget(revision: Long, target: PointerTarget?) =
        router.hoverTargetChanged(PointerHitTest(revision, target))

    private fun actions(recorder: Recorder) = recorder.events.map { it.actionMasked }

    @After
    fun tearDown() {
        router.dispose()
        retained.forEach { it.recycle() }
    }

    @Test
    fun wheelRetainsAxesAndMetadataAndOnlyChangesLocalPosition() {
        val (root, child) = root(1, 50, 60)
        val original = event()
        assertTrue(root.dispatchGenericMotionEvent(original))
        assertTrue(child.events.isEmpty())
        assertEquals(Triple(80.0, 100.0, false), host.hitTests.single().position)
        host.answer(0, target = target(1, 12.0, 14.0))

        val routed = child.events.single()
        assertEquals(12f, routed.x)
        assertEquals(14f, routed.y)
        assertEquals(original.action, routed.action)
        assertEquals(original.source, routed.source)
        assertEquals(original.deviceId, routed.deviceId)
        assertEquals(original.getPointerId(0), routed.getPointerId(0))
        assertEquals(original.getToolType(0), routed.getToolType(0))
        assertEquals(original.metaState, routed.metaState)
        assertEquals(original.buttonState, routed.buttonState)
        assertEquals(original.downTime, routed.downTime)
        assertEquals(original.eventTime, routed.eventTime)
        assertEquals(original.xPrecision, routed.xPrecision)
        assertEquals(original.yPrecision, routed.yPrecision)
        assertEquals(original.edgeFlags, routed.edgeFlags)
        for (axis in listOf(MotionEvent.AXIS_VSCROLL, MotionEvent.AXIS_HSCROLL, MotionEvent.AXIS_DISTANCE)) {
            assertEquals(original.getAxisValue(axis), routed.getAxisValue(axis))
        }
        assertEquals(30f, original.x)
        assertEquals(40f, original.y)
        assertTrue(flutterEvents.isEmpty())
    }

    @Test
    fun touchpadScrollIsArbitratedEvenThoughItReportsAFingerTool() {
        val (root, child) = root(1)
        assertTrue(
            root.dispatchGenericMotionEvent(
                event(tool = MotionEvent.TOOL_TYPE_FINGER),
            ),
        )
        assertEquals(1, host.hitTests.size)
        host.answer(0, target = target(1))
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(child))
    }

    @Test
    fun flutterFallbackIsExactlyOnceAndUsesTransformedCoordinatesWithoutChangingAxes() {
        val (root, child) = root(1, 50, 60)
        root.pivotX = 0f
        root.pivotY = 0f
        root.scaleX = 2f
        root.scaleY = 3f
        root.dispatchGenericMotionEvent(event())
        host.answer(0)
        assertTrue(child.events.isEmpty())
        assertEquals(110f, flutterEvents.single().x)
        assertEquals(180f, flutterEvents.single().y)
        assertEquals(-2.75f, flutterEvents.single().getAxisValue(MotionEvent.AXIS_VSCROLL))
        host.answer(0)
        assertEquals(1, flutterEvents.size)
    }

    @Test
    fun unhandledSelectedNativeTargetDoesNotLeakToFlutterOrSiblings() {
        val (root, child) = root(1)
        val (_, sibling) = root(2)
        child.handles = false
        root.dispatchGenericMotionEvent(event())
        host.answer(0, target = target(1))
        assertEquals(1, child.events.size)
        assertTrue(sibling.events.isEmpty())
        assertTrue(flutterEvents.isEmpty())
    }

    @Test
    fun nestedRegisteredTargetBypassesArbitration() {
        val (outer, outerChild) = root(1)
        val (nested, nestedChild) = root(2)
        flutterView.removeView(nested)
        outer.addView(nested)
        nested.layout(0, 0, 200, 200)
        nestedChild.layout(0, 0, 200, 200)

        outer.dispatchGenericMotionEvent(event())
        host.answer(0, target = target(2, 15.0, 16.0))
        assertEquals(1, host.hitTests.size)
        assertTrue(outerChild.events.isEmpty())
        assertEquals(15f, nestedChild.events.single().x)

        outer.dispatchGenericMotionEvent(event())
        host.answer(1, target = target(1))
        assertEquals(2, host.hitTests.size)
        assertEquals(2, nestedChild.events.size)
    }

    @Test
    fun wheelsExecuteInFifoOrderRegardlessOfAnswerOrderOrRevision() {
        val (root, child) = root(1)
        root.dispatchGenericMotionEvent(event(time = 201))
        root.dispatchGenericMotionEvent(event(time = 202))
        host.answer(1, revision = 50, target = target(1))
        assertTrue(child.events.isEmpty())
        host.answer(0, revision = 99, target = target(1))
        assertEquals(listOf(201L, 202L), child.events.map { it.eventTime })
    }

    @Test
    fun flutterHoverDoesNotOvertakePendingWheelFallback() {
        val (root, _) = root(1)
        root.dispatchGenericMotionEvent(event(time = 201))
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE, time = 202))
        host.answer(1)
        assertTrue(flutterEvents.isEmpty())
        host.answer(0)
        assertEquals(listOf(201L, 202L), flutterEvents.map { it.eventTime })
    }

    @Test
    fun hoverMovesReachFlutterAndOwnershipTransitionsUseRetainedMouseEvent() {
        val (root, first) = root(1)
        val (_, second) = root(2)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        assertEquals(listOf(MotionEvent.ACTION_HOVER_MOVE), flutterEvents.map { it.actionMasked })
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER, MotionEvent.ACTION_HOVER_MOVE), actions(first))

        hoverTarget(2, target(2, 70.0, 80.0))
        assertEquals(MotionEvent.ACTION_HOVER_EXIT, first.events.last().actionMasked)
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(second))
        assertEquals(70f, second.events.single().x)
        assertEquals(42, second.events.single().deviceId)

        hoverTarget(3, target(2, 71.0, 81.0))
        assertEquals(MotionEvent.ACTION_HOVER_MOVE, second.events.last().actionMasked)
        hoverTarget(4, null)
        assertEquals(MotionEvent.ACTION_HOVER_EXIT, second.events.last().actionMasked)
        assertEquals(1, flutterEvents.size)
    }

    @Test
    fun commonParentTraversalDoesNotLetOldRootsFinalMoveAndExitStealNewHover() {
        val parent = FrameLayout(context).apply {
            flutterView.addView(this)
            layout(0, 0, 1000, 1000)
        }
        val (_, first) = root(1, parent = parent)
        val (_, second) = root(2, left = 400, parent = parent)
        assertTrue(parent.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE)))
        assertEquals(listOf(1 to 9, 1 to 7), rootDispatches)
        host.answer(0, revision = 1, target = target(1))
        host.answer(1, revision = 2, target = target(1))
        assertEquals(listOf(9, 7), actions(first))

        rootDispatches.clear()
        assertTrue(parent.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE, x = 430f, time = 201)))
        // Exercise Android's real hover-target traversal, including its final old-root MOVE.
        assertEquals(listOf(2 to 9, 2 to 7, 1 to 7, 1 to 10), rootDispatches)
        assertEquals(4, host.hitTests.size)
        assertEquals(Triple(430.0, 40.0, true), host.hitTests[2].position)
        assertEquals(Triple(430.0, 40.0, true), host.hitTests[3].position)
        host.answer(3, revision = 4, target = target(2))
        host.answer(2, revision = 3, target = target(2))
        assertEquals(listOf(9, 7, 10), actions(first))
        assertEquals(listOf(9, 7), actions(second))
        assertEquals(430f, flutterEvents.last().x)
        assertEquals(0, host.exits)

        parent.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_EXIT, x = 430f))
        assertEquals(listOf(9, 7, 10), actions(second))
        assertEquals(1, host.exits)
    }

    @Test
    fun standaloneEnterInitializesNativeAndFlutterWithoutWaitingForMove() {
        val parent = FrameLayout(context).apply {
            flutterView.addView(this)
            layout(0, 0, 1000, 1000)
        }
        val (_, child) = root(1, parent = parent)
        val original = event(MotionEvent.ACTION_HOVER_ENTER)
        parent.dispatchGenericMotionEvent(original)
        assertEquals(listOf(1 to MotionEvent.ACTION_HOVER_ENTER), rootDispatches)
        assertEquals(Triple(30.0, 40.0, true), host.hitTests.single().position)
        host.answer(0, revision = 1, target = target(1))
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(child))
        assertEquals(MotionEvent.ACTION_HOVER_ENTER, original.actionMasked)
        assertEquals(MotionEvent.ACTION_HOVER_MOVE, flutterEvents.single().actionMasked)
        for (copy in listOf(child.events.single(), flutterEvents.single())) {
            assertEquals(original.source, copy.source)
            assertEquals(original.getToolType(0), copy.getToolType(0))
            assertEquals(original.deviceId, copy.deviceId)
            assertEquals(original.metaState, copy.metaState)
            assertEquals(original.buttonState, copy.buttonState)
            assertEquals(original.eventTime, copy.eventTime)
            assertEquals(original.getAxisValue(MotionEvent.AXIS_HSCROLL), copy.getAxisValue(MotionEvent.AXIS_HSCROLL))
        }

        // A subsequent ordinary move must not create a second native enter.
        parent.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE, time = 201))
        host.answer(1, revision = 2, target = target(1))
        assertEquals(listOf(9, 7), actions(child))
        assertEquals(listOf(7, 7), flutterEvents.map { it.actionMasked })
    }

    @Test
    fun enterWithoutNativeTargetStillInitializesFlutterAndSupportsStationaryOwnership() {
        val (root, child) = root(1)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_ENTER))
        host.answer(0, revision = 1)
        assertTrue(child.events.isEmpty())
        assertEquals(MotionEvent.ACTION_HOVER_MOVE, flutterEvents.single().actionMasked)
        hoverTarget(2, target(1))
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(child))
        hoverTarget(3, target(1))
        assertEquals(listOf(9, 7), actions(child))
    }

    @Test
    fun newerPostFrameHoverOwnershipRejectsLateHitTestAnswer() {
        val (root, first) = root(1)
        val (_, second) = root(2)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        hoverTarget(10, target(2))
        host.answer(0, revision = 9, target = target(1))
        hoverTarget(10, null)
        assertTrue(first.events.isEmpty())
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(second))
    }

    @Test
    fun newlyRegisteredOverlayCanAcquireStationaryHover() {
        val (root, first) = root(1)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        val (_, overlay) = root(2)
        hoverTarget(2, target(2))
        assertEquals(MotionEvent.ACTION_HOVER_EXIT, first.events.last().actionMasked)
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(overlay))
        assertEquals(0, host.exits)
    }

    @Test
    fun oldFailedHitTestDoesNotClearNewerPostFrameOwnership() {
        val (root, child) = root(1)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        hoverTarget(10, target(1))
        host.fail(0)
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(child))
    }

    @Test
    fun unreachableDartUnknownTargetsAndBadCoordinatesFallBackOnceWithoutNativeDelivery() {
        val (root, child) = root(1)
        repeat(4) { root.dispatchGenericMotionEvent(event(time = 200L + it)) }
        host.fail(1)
        host.fail(0)
        host.answer(2, target = target(99))
        host.answer(3, target = target(1, Double.NaN, 0.0))
        assertEquals(listOf(200L, 201L, 202L, 203L), flutterEvents.map { it.eventTime })
        assertTrue(child.events.isEmpty())
    }

    @Test
    fun nativeExitClearsOwnershipAndInvalidatesPendingHoverButNotWheel() {
        val (root, child) = root(1)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        root.dispatchGenericMotionEvent(event())
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_EXIT))
        host.answer(1, revision = 2, target = target(1))
        host.answer(2, target = target(1))
        hoverTarget(3, target(1))
        assertEquals(listOf(9, 7, 10, 8), actions(child))
        assertEquals(1, host.exits)
    }

    @Test
    fun detachAndReusedIdRejectOldCallbacksUntilFreshStationaryHitTest() {
        val (old, child) = root(1)
        old.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        old.dispatchGenericMotionEvent(event())
        old.detachPointerInput()
        val (_, replacement) = root(1)
        host.answer(1, target = target(1))
        hoverTarget(5, target(1))
        assertEquals(MotionEvent.ACTION_HOVER_EXIT, child.events.last().actionMasked)
        assertTrue(replacement.events.isEmpty())
        assertTrue(flutterEvents.none { it.actionMasked == MotionEvent.ACTION_SCROLL })
        assertEquals(0, host.exits)
        assertEquals(Triple(30.0, 40.0, true), host.hitTests.last().position)
        host.answer(2, revision = 4, target = target(1))
        assertTrue(replacement.events.isEmpty())
        host.answer(3, revision = 6, target = target(1))
        host.answer(4, revision = 7, target = target(1))
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(replacement))
        hoverTarget(5, null)
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(replacement))
    }

    @Test
    fun reusedIdNotificationOvertakingFreshAnswerRequeriesInsteadOfLeavingHoverStuck() {
        val (old, _) = root(1)
        old.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        old.detachPointerInput()
        val (_, replacement) = root(1)
        hoverTarget(5, target(1))
        assertTrue(replacement.events.isEmpty())
        host.answer(1, revision = 2)
        host.answer(2, revision = 4, target = target(1))
        assertTrue(replacement.events.isEmpty())
        host.answer(3, revision = 6, target = target(1))
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(replacement))
        assertEquals(1, flutterEvents.size)
    }

    @Test
    fun unrelatedDisposalPreservesBrowserWheelFifoAndStationaryHover() {
        val (browser, child) = root(1)
        val (addon, _) = root(2)
        browser.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        browser.dispatchGenericMotionEvent(event(time = 201))
        browser.dispatchGenericMotionEvent(event(time = 202))
        host.answer(2, revision = 3, target = target(1))
        addon.detachPointerInput()
        assertEquals(listOf(9, 7), actions(child))
        assertEquals(3, host.hitTests.size)
        host.answer(1, revision = 2, target = target(1))
        assertEquals(listOf(201L, 202L), child.events.filter { it.actionMasked == 8 }.map { it.eventTime })
        hoverTarget(4, target(1, 31.0, 41.0))
        assertEquals(listOf(9, 7, 8, 8, 7), actions(child))
        assertEquals(0, host.exits)
    }

    @Test
    fun removingQueuedOriginUnblocksUnrelatedCompletedInputAndRejectsItsLateAnswer() {
        val (browser, child) = root(1)
        val (addon, removed) = root(2)
        addon.dispatchGenericMotionEvent(event())
        browser.dispatchGenericMotionEvent(event())
        host.answer(1, target = target(1))
        assertTrue(child.events.isEmpty())
        addon.detachPointerInput()
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(child))
        host.answer(0, target = target(2))
        assertTrue(removed.events.isEmpty())
        assertTrue(flutterEvents.isEmpty())
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(1001))
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(child))
    }

    @Test
    fun wheelTargetSnapshotRejectsReusedIdButAllowsNewRequests() {
        val (browser, _) = root(1)
        val (old, removed) = root(2)
        browser.dispatchGenericMotionEvent(event())
        old.detachPointerInput()
        val (_, replacement) = root(2)
        host.answer(0, target = target(2))
        assertTrue(removed.events.isEmpty())
        assertTrue(replacement.events.isEmpty())
        assertEquals(1, flutterEvents.size)
        browser.dispatchGenericMotionEvent(event())
        old.detachPointerInput()
        host.answer(1, target = target(2))
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(replacement))
    }

    @Test
    fun reattachingSameRootCreatesNewRegistrationIdentity() {
        val (browser, _) = root(1)
        val (addon, child) = root(2)
        browser.dispatchGenericMotionEvent(event())
        addon.detachPointerInput()
        addon.attachPointerInput(flutterView)
        host.answer(0, target = target(2))
        assertTrue(child.events.isEmpty())
        assertEquals(1, flutterEvents.size)
        browser.dispatchGenericMotionEvent(event())
        host.answer(1, target = target(2))
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(child))
    }

    @Test
    fun removingDartSelectedOwnerRequeriesRetainedHoverWithoutFlutterReplay() {
        val (browser, child) = root(1)
        val (addon, removed) = root(2)
        browser.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(2))
        addon.detachPointerInput()
        assertEquals(listOf(9, 7, 10), actions(removed))
        assertEquals(Triple(30.0, 40.0, true), host.hitTests[1].position)
        host.answer(1, revision = 2, target = target(1))
        assertEquals(listOf(MotionEvent.ACTION_HOVER_ENTER), actions(child))
        assertEquals(1, flutterEvents.size)
        assertEquals(0, host.exits)
    }

    @Test
    fun removingHoverSourceDoesNotExitDifferentDartSelectedOwner() {
        val (_, child) = root(1)
        val (addon, _) = root(2)
        addon.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        addon.detachPointerInput()
        host.answer(1, revision = 2, target = target(1))
        assertEquals(listOf(9, 7), actions(child))
        assertEquals(0, host.exits)
        hoverTarget(3, null)
        assertEquals(listOf(9, 7, 10), actions(child))
    }

    @Test
    fun resetPreservesViewsResetsRevisionAndRejectsPreviousIsolateAnswers() {
        val (root, child) = root(1)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 100, target = target(1))
        root.dispatchGenericMotionEvent(event())
        router.reset()
        host.answer(1, target = target(1))
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(2, revision = 0, target = target(1))
        assertEquals(listOf(9, 7, 10, 9, 7), actions(child))
    }

    @Test
    fun timeoutClearsAllRetainedInputAndRejectsLateAnswers() {
        val (root, child) = root(1)
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE))
        host.answer(0, revision = 1, target = target(1))
        root.dispatchGenericMotionEvent(event())
        root.dispatchGenericMotionEvent(event())
        host.answer(2, target = target(1))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(1001))
        host.answer(1, target = target(1))
        hoverTarget(9, target(1))
        assertEquals(listOf(9, 7, 10), actions(child))
        assertEquals(2, flutterEvents.count { it.actionMasked == MotionEvent.ACTION_SCROLL })
        root.dispatchGenericMotionEvent(event())
        host.answer(3, target = target(1))
        assertEquals(MotionEvent.ACTION_SCROLL, child.events.last().actionMasked)
    }

    @Test
    fun queueIsBounded() {
        val (root, child) = root(1)
        repeat(65) { root.dispatchGenericMotionEvent(event()) }
        assertEquals(64, host.hitTests.size)
        repeat(64) { host.answer(it, target = target(1)) }
        assertTrue(child.events.isEmpty())
        assertEquals(65, flutterEvents.size)
    }

    @Test
    fun disposalInvalidatesCallbacksAndReturnsInputToOrdinaryNativeDispatch() {
        val (root, child) = root(1)
        root.dispatchGenericMotionEvent(event())
        router.dispose()
        host.answer(0, target = target(1))
        assertTrue(child.events.isEmpty())

        // No Flutter tree is left to protect, so the engine view gets its wheel
        // through Android's ordinary dispatch instead of having it swallowed.
        assertTrue(root.dispatchGenericMotionEvent(event()))
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(child))
        assertEquals(1, host.hitTests.size)
    }

    @Test
    fun touchStylusAccessibilityAndOtherGenericActionsAreNotArbitrated() {
        val (root, child) = root(1)
        for ((source, tool) in listOf(
            InputDevice.SOURCE_TOUCHSCREEN to MotionEvent.TOOL_TYPE_FINGER,
            InputDevice.SOURCE_STYLUS to MotionEvent.TOOL_TYPE_STYLUS,
            InputDevice.SOURCE_MOUSE to MotionEvent.TOOL_TYPE_STYLUS,
            InputDevice.SOURCE_MOUSE_RELATIVE to MotionEvent.TOOL_TYPE_MOUSE,
        )) {
            root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_HOVER_MOVE, source, tool))
        }
        root.dispatchGenericMotionEvent(event(MotionEvent.ACTION_BUTTON_PRESS))
        assertTrue(host.hitTests.isEmpty())
        assertTrue(child.events.isNotEmpty())
        assertTrue(
            root.dispatchTouchEvent(
                event(MotionEvent.ACTION_DOWN, InputDevice.SOURCE_TOUCHSCREEN, MotionEvent.TOOL_TYPE_FINGER),
            ),
        )
        assertEquals(listOf(MotionEvent.ACTION_DOWN), child.touches)
        assertTrue(host.hitTests.isEmpty())
        assertTrue(flutterEvents.isEmpty())
        assertFalse(root.isAccessibilityFocused)
        assertNotNull(root.createAccessibilityNodeInfo())
    }

    @Test
    fun surfaceThatIsNotYetAttachedKeepsPlainNativeDispatch() {
        // Laid out by the platform view factory, not yet handed a Flutter view.
        // Nothing is composited over it to protect, so swallowing the notch
        // would only lose it.
        val root = PointerInputFrameLayout(context, 9, router)
        val child = Recorder()
        flutterView.addView(root)
        root.layout(0, 0, 400, 400)
        root.addView(child)
        child.layout(0, 0, 400, 400)

        assertTrue(root.dispatchGenericMotionEvent(event()))
        assertTrue(host.hitTests.isEmpty())
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(child))
        assertTrue(flutterEvents.isEmpty())
    }

    @Test
    fun detachedSurfaceKeepsPlainNativeDispatch() {
        val (root, child) = root(1)
        root.detachPointerInput()

        assertTrue(root.dispatchGenericMotionEvent(event()))
        assertTrue(host.hitTests.isEmpty())
        assertEquals(listOf(MotionEvent.ACTION_SCROLL), actions(child))
    }

    @Test
    fun surfaceDisplacedByItsReplacementStillHasItsInputTakenOver() {
        val (displaced, displacedChild) = root(1)
        // The same id, registered by the surface replacing this one. The old
        // root is still composited, so its input may not reach the page.
        root(1)

        assertTrue(displaced.dispatchGenericMotionEvent(event()))
        assertTrue(host.hitTests.isEmpty())
        assertTrue(displacedChild.events.isEmpty())
        assertTrue(flutterEvents.isEmpty())
    }
}
