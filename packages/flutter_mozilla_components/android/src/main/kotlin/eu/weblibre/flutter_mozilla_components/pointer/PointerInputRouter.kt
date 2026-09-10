/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.pointer

import android.os.Handler
import android.os.Looper
import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import eu.weblibre.flutter_mozilla_components.ext.transformPosition
import eu.weblibre.flutter_mozilla_components.pigeons.PointerHitTest
import eu.weblibre.flutter_mozilla_components.pigeons.PointerInputHostApi
import eu.weblibre.flutter_mozilla_components.pigeons.PointerTarget
import eu.weblibre.flutter_mozilla_components.widget.PointerInputFrameLayout
import io.flutter.plugin.common.BinaryMessenger
import java.util.ArrayDeque

/**
 * Decides whether a mouse event belongs to a native surface or to the Flutter
 * tree drawn over it. One instance per engine, confined to the UI thread.
 *
 * Hybrid composition routes *touch* through Flutter: `FlutterMutatorView`
 * intercepts it, hit-tests the framework and re-dispatches. It has no
 * equivalent for pointer signals, so a wheel notch or a cursor movement is
 * walked down the *native* view hierarchy and lands in the engine view no
 * matter what Flutter paints on top. The page then scrolls under an open sheet,
 * and its links light up under a cursor that is over the sheet.
 *
 * [PointerInputFrameLayout] therefore holds every eligible event back and asks
 * here who owns it. The answer comes from Flutter's own hit test, which gives
 * two things a flag could not: opaque chrome blocks the surface underneath even
 * when it has no scroll handler of its own while an `IgnorePointer` decoration
 * does not, and the answer carries geometry, so chrome *beside* the page
 * blocks only the area it actually covers.
 *
 * A native winner receives the original event with its wheel axes and modifiers
 * intact, because Gecko has to scroll the element under the cursor rather than
 * the document. A Flutter winner goes through the embedding's ordinary pointer
 * pipeline.
 *
 * Arbitration is asynchronous, so most of what follows is about not letting a
 * late answer speak for a world that has moved on: replies are delivered in the
 * order the events arrived, and every answer is checked against the
 * registrations and the hover it was asked about.
 */
class PointerInputRouter internal constructor(private val host: PointerInputHost) :
    PointerInputHostApi {

    constructor(messenger: BinaryMessenger) : this(PigeonPointerInputHost(messenger))

    private val handler = Handler(Looper.getMainLooper())

    /** Every registered surface, by platform view id. */
    private val views = mutableMapOf<Long, RegisteredView>()

    /** Events waiting on an answer, oldest first. */
    private val queue = ArrayDeque<Arbitration>()

    /**
     * Bumped whenever everything in flight is abandoned at once. Answers
     * stamped with an older generation belong to a queue that no longer exists.
     */
    private var generation = 0L

    private val hover = HoverState()

    private var disposed = false

    /**
     * Set while an event is being handed back down to a native subtree, so that
     * the [PointerInputFrameLayout]s it passes through on the way — nested ones
     * included — let it past instead of arbitrating it a second time.
     */
    private var redispatching = false

    /**
     * One registered surface.
     *
     * [token] identifies *this registration*, rather than the id or the view:
     * platform view ids get reused and the same root can be re-attached, so
     * "is the answer Dart just gave still about the thing I asked about" can
     * only be settled by an object created once per registration.
     */
    private class RegisteredView(val view: PointerInputFrameLayout) {
        val token = Any()
    }

    /** A target Dart named, resolved to the live surface it belongs to. */
    private class ResolvedTarget(val view: PointerInputFrameLayout, val target: PointerTarget)

    /**
     * Where the cursor is resting and who owns it.
     *
     * A hover is not a one-shot delivery like a wheel notch. The cursor stays
     * where it is while Flutter opens and closes things over it, so the last
     * hover is retained, re-asked whenever that might have changed, and the
     * owner is driven to match with synthetic enter and exit events.
     */
    private class HoverState {
        /** The last raw hover, in Flutter view coordinates. Null when idle. */
        var event: MotionEvent? = null
        var flutterView: View? = null

        /**
         * The registration the raw hover events arrive through.
         *
         * Android enters the child the cursor moved *into* before it sends the
         * child it left a closing move and exit. Those trailing events must not
         * be allowed to take the hover back to the surface it has left.
         */
        var source: RegisteredView? = null

        /** The newest Dart decision applied. Older ones are ignored. */
        var revision = -1L

        /**
         * Bumped whenever the retained hover stops meaning anything, because
         * the cursor left or its source went away. Arbitrations stamped with an
         * older value are dropped rather than delivered.
         */
        var generation = 0L

        /** The surface holding the cursor, as Dart last decided it. */
        var owner: ResolvedTarget? = null

        /**
         * Registration tokens as of the current revision. An id here bound to a
         * token that is no longer live is an id Dart may still name from a
         * frame it rendered before the swap, and must not win the cursor with.
         */
        val tokens = mutableMapOf<Long, Any>()
    }

    /** One retained event and the hit test it is waiting on. */
    private class Arbitration(
        /** In Flutter view coordinates; every other field of the original is intact. */
        val event: MotionEvent,
        val flutterView: View,
        val generation: Long,
        val hoverGeneration: Long,
        /** The hover revision that was current when the hit test was asked. */
        val hoverRevision: Long,
        /** The registration the event arrived through, or null for a re-query. */
        val sourceToken: Any?,
        /** Registration tokens as they stood when the hit test was asked. */
        val tokens: Map<Long, Any>,
        /** Whether Flutter still sees the event when it does not win it. */
        val replayToFlutter: Boolean,
    ) {
        var settled = false
        var result: PointerHitTest? = null
        lateinit var expiry: Runnable
    }

    // ---- Registration -----------------------------------------------------

    internal fun register(id: Long, view: PointerInputFrameLayout) {
        if (disposed || views[id]?.view === view) return
        views[id]?.let { unregister(id, it.view) }

        val registration = RegisteredView(view)
        views[id] = registration
        if (hover.event == null) return

        // A surface that appears under a resting cursor can only take it once
        // Dart notices and reports the new target, so record the token now for
        // that report to be accepted against. Unless the id was already in use:
        // a report from a frame rendered before the swap would then still name
        // the view that went away, and only a fresh hit test separates them.
        if (hover.tokens.putIfAbsent(id, registration.token) != null) requeryHover()
    }

    internal fun unregister(id: Long, view: PointerInputFrameLayout) {
        val registration = views[id]?.takeIf { it.view === view } ?: return
        val heldCursor = hover.owner?.target?.viewId == id
        val wasHoverSource = hover.source === registration

        if (heldCursor) hover.event?.let { releaseOwner(it) }
        if (wasHoverSource) {
            hover.source = null
            hover.generation++
        }
        views.remove(id)
        discardQueued(registration.token)
        // Dropping a blocker can leave later answers ready to go out.
        deliverSettled()

        // The cursor is still resting somewhere. Ask who has it now.
        if (heldCursor || wasHoverSource) requeryHover()
    }

    /**
     * Drops everything still waiting that arrived through a registration which
     * is going away.
     *
     * Dropped rather than handed to Flutter: the input was aimed at a surface
     * that no longer exists, and replaying it into the framework would act on
     * whatever took its place.
     */
    private fun discardQueued(token: Any) {
        val iterator = queue.iterator()
        while (iterator.hasNext()) {
            val arbitration = iterator.next()
            if (arbitration.sourceToken !== token) continue
            iterator.remove()
            arbitration.settled = true
            handler.removeCallbacks(arbitration.expiry)
            arbitration.event.recycle()
        }
    }

    // ---- Interception -----------------------------------------------------

    /**
     * Offers a registered root's generic motion event to arbitration. Returns
     * true when the router has taken the event over, in which case the root
     * must not dispatch it any further itself.
     */
    internal fun intercept(root: PointerInputFrameLayout, event: MotionEvent): Boolean {
        if (redispatching || !event.isArbitratedMouseInput()) return false
        // Once the engine is gone there is no Flutter tree left to protect, and
        // plain native dispatch is better than swallowing the input entirely.
        if (disposed) return false

        val flutterView = root.pointerFlutterView
        val registration = views[root.platformViewId]?.takeIf { it.view === root }

        // A surface with neither a Flutter view nor a registration is not one
        // this router speaks for: the platform view has been laid out but not
        // yet attached, or it has been detached from the view it had. There is
        // no Flutter tree composited over it to keep the input from, and
        // swallowing it would be a wheel that quietly does nothing.
        if (flutterView == null && registration == null) return false

        // From here the event is the router's, and stays the router's even when
        // the state needed to arbitrate it is missing: handing a
        // half-arbitrated event back to native dispatch is the leak this whole
        // class exists to close. A root that is composited but no longer the
        // registered one for its id is exactly that case — its id has been
        // taken over by the surface replacing it.
        if (flutterView == null || registration == null) return true

        if (event.actionMasked == MotionEvent.ACTION_HOVER_EXIT) {
            if (hover.source === registration) {
                clearHover()
                host.pointerExit()
            }
            return true
        }

        val isHover = event.actionMasked != MotionEvent.ACTION_SCROLL
        if (isHover && !claimHoverSource(registration, event)) return true

        val retained = MotionEvent.obtain(event)
        retained.transformPosition(root, flutterView)
        if (isHover) retainHover(retained, flutterView)
        arbitrate(retained, flutterView, sourceToken = registration.token)
        return true
    }

    /**
     * Whether [registration] may speak for the hover, taking the role over when
     * the cursor genuinely entered it.
     */
    private fun claimHoverSource(registration: RegisteredView, event: MotionEvent): Boolean {
        val entering = event.actionMasked == MotionEvent.ACTION_HOVER_ENTER
        if (!entering && hover.source != null) return hover.source === registration

        if (hover.source !== registration) hover.generation++
        hover.source = registration
        return true
    }

    /** Keeps [retained] as the hover to re-ask about while the cursor rests. */
    private fun retainHover(retained: MotionEvent, flutterView: View) {
        hover.event?.recycle()
        hover.event = MotionEvent.obtain(retained)
        hover.flutterView = flutterView
        views.forEach { (id, registration) -> hover.tokens.putIfAbsent(id, registration.token) }
    }

    /**
     * Re-asks who owns the resting cursor, without replaying anything to
     * Flutter: the framework has already seen this hover once.
     */
    private fun requeryHover() {
        val event = hover.event ?: return
        val flutterView = hover.flutterView ?: return
        arbitrate(
            MotionEvent.obtain(event),
            flutterView,
            sourceToken = null,
            replayToFlutter = false,
        )
    }

    // ---- Arbitration ------------------------------------------------------

    private fun arbitrate(
        retained: MotionEvent,
        flutterView: View,
        sourceToken: Any?,
        replayToFlutter: Boolean = true,
    ) {
        if (queue.size >= MAX_IN_FLIGHT) {
            // Dart is not answering anywhere near fast enough to be arbitrating.
            try {
                abandonInFlight(replay = true)
                if (replayToFlutter) forwardToFlutter(flutterView, retained)
            } finally {
                retained.recycle()
            }
            return
        }

        val arbitration = Arbitration(
            event = retained,
            flutterView = flutterView,
            generation = generation,
            hoverGeneration = hover.generation,
            hoverRevision = hover.revision,
            sourceToken = sourceToken,
            tokens = views.mapValues { it.value.token },
            replayToFlutter = replayToFlutter,
        )
        arbitration.expiry = Runnable {
            if (arbitration.generation == generation && !arbitration.settled) {
                abandonInFlight(replay = true)
            }
        }
        queue.addLast(arbitration)
        handler.postDelayed(arbitration.expiry, ANSWER_TIMEOUT_MS)

        host.hitTest(
            retained.x.toDouble(),
            retained.y.toDouble(),
            retained.actionMasked != MotionEvent.ACTION_SCROLL,
        ) { settle(arbitration, it) }
    }

    private fun settle(arbitration: Arbitration, result: PointerHitTest?) {
        if (disposed || arbitration.generation != generation || arbitration.settled) return
        arbitration.result = result
        arbitration.settled = true
        deliverSettled()
    }

    /**
     * Delivers every answered event at the head of the queue.
     *
     * Answers can come back out of order; delivery must not, or two notches
     * land on the page in the order Dart happened to reply rather than the
     * order the user scrolled them.
     */
    private fun deliverSettled() {
        while (queue.peekFirst()?.settled == true) {
            val arbitration = queue.removeFirst()
            handler.removeCallbacks(arbitration.expiry)
            try {
                if (arbitration.event.actionMasked == MotionEvent.ACTION_SCROLL) {
                    deliverWheel(arbitration)
                } else {
                    deliverHover(arbitration)
                }
            } finally {
                arbitration.event.recycle()
            }
        }
    }

    private fun deliverWheel(arbitration: Arbitration) {
        val resolved = arbitration.result?.target?.let {
            resolveTarget(it, arbitration.tokens, arbitration.flutterView)
        }
        if (resolved == null) {
            forwardToFlutter(arbitration.flutterView, arbitration.event)
        } else {
            dispatchToNative(resolved.view, arbitration.event, resolved.target)
        }
    }

    private fun deliverHover(arbitration: Arbitration) {
        // The stream this belonged to is gone: the cursor moved on, or its
        // source went away, and something newer already speaks for it.
        if (arbitration.hoverGeneration != hover.generation) return

        // Flutter's own mouse tracking has to stay current even while a native
        // surface owns the cursor, or it keeps hovering what the pointer left.
        if (arbitration.replayToFlutter) {
            forwardToFlutter(arbitration.flutterView, arbitration.event)
        }

        val result = arbitration.result
        when {
            result != null -> applyHover(
                result,
                arbitration.event,
                tokens = arbitration.tokens,
                moveOwner = arbitration.replayToFlutter &&
                    arbitration.event.actionMasked == MotionEvent.ACTION_HOVER_MOVE,
            )
            // Dart never answered. Only give the cursor up if nothing newer has
            // decided it in the meantime.
            hover.revision == arbitration.hoverRevision -> clearHover()
        }
    }

    /**
     * Moves the cursor to the owner [hit] names, with the enter and exit events
     * the native surfaces need to update their own hover state.
     */
    private fun applyHover(
        hit: PointerHitTest,
        event: MotionEvent,
        tokens: Map<Long, Any>,
        moveOwner: Boolean,
    ) {
        if (hit.revision <= hover.revision) return
        hover.revision = hit.revision

        val owner = hit.target?.let { resolveTarget(it, tokens, hover.flutterView) }
        tokens.forEach { (id, token) -> if (views[id]?.token === token) hover.tokens[id] = token }

        if (hover.owner?.target?.viewId != owner?.target?.viewId) {
            releaseOwner(event)
            hover.owner = owner
            if (owner != null) {
                dispatchToNative(owner.view, event, owner.target, MotionEvent.ACTION_HOVER_ENTER)
            }
        } else {
            hover.owner = owner
        }
        if (owner != null && moveOwner) {
            dispatchToNative(owner.view, event, owner.target, MotionEvent.ACTION_HOVER_MOVE)
        }
    }

    /**
     * The surface [target] names, if it is still the registration the hit test
     * was asked about and still attached to the same Flutter view.
     *
     * A position that is not finite is refused too: a degenerate transform in
     * the Flutter tree would otherwise put the cursor nowhere at all, and no
     * position is better handled by falling back to the framework.
     */
    private fun resolveTarget(
        target: PointerTarget,
        tokens: Map<Long, Any>,
        flutterView: View?,
    ): ResolvedTarget? {
        if (!target.x.isFinite() || !target.y.isFinite()) return null
        return views[target.viewId]
            ?.takeIf { it.token === tokens[target.viewId] }
            ?.takeIf { it.view.pointerFlutterView === flutterView }
            ?.let { ResolvedTarget(it.view, target) }
    }

    /**
     * Takes the cursor away from the current owner with a synthetic exit, in
     * that owner's own coordinates.
     */
    private fun releaseOwner(event: MotionEvent) {
        val owner = hover.owner ?: return
        hover.owner = null

        val exit = MotionEvent.obtain(event)
        try {
            hover.flutterView?.let { exit.transformPosition(it, owner.view) }
            dispatchToNative(owner.view, exit, exit.x, exit.y, MotionEvent.ACTION_HOVER_EXIT)
        } finally {
            exit.recycle()
        }
    }

    /** Forgets the resting cursor entirely. */
    private fun clearHover() {
        hover.generation++
        hover.event?.let {
            releaseOwner(it)
            it.recycle()
        }
        hover.owner = null
        hover.event = null
        hover.flutterView = null
        hover.source = null
        hover.tokens.clear()
    }

    /**
     * Gives up on everything in flight.
     *
     * [replay] hands the retained events to Flutter on the way out, which is
     * the right answer when the bridge stalled: Flutter can still act on them,
     * and a *guessed* native target is the one outcome that must never happen.
     * A lifecycle invalidation drops them instead.
     */
    private fun abandonInFlight(replay: Boolean = false, notifyDart: Boolean = true) {
        generation++
        queue.forEach { arbitration ->
            handler.removeCallbacks(arbitration.expiry)
            try {
                val stillMeaningful =
                    arbitration.event.actionMasked == MotionEvent.ACTION_SCROLL ||
                        arbitration.hoverGeneration == hover.generation
                if (replay && arbitration.replayToFlutter && stillMeaningful) {
                    forwardToFlutter(arbitration.flutterView, arbitration.event)
                }
            } finally {
                arbitration.event.recycle()
            }
        }
        queue.clear()

        val hadHover = hover.event != null
        clearHover()
        if (notifyDart && hadHover && !disposed) host.pointerExit()
    }

    // ---- Delivery ---------------------------------------------------------

    private fun dispatchToNative(
        view: PointerInputFrameLayout,
        event: MotionEvent,
        target: PointerTarget,
        action: Int = event.action,
    ) = dispatchToNative(view, event, target.x.toFloat(), target.y.toFloat(), action)

    /**
     * Hands [event] to a native surface at [x]/[y] in that surface's own
     * coordinates.
     *
     * Through `dispatchGenericMotionEvent` so the surface's children still get
     * Android's normal walk. [redispatching] is what keeps that walk from
     * arbitrating the same event a second time on the way down.
     */
    private fun dispatchToNative(
        view: PointerInputFrameLayout,
        event: MotionEvent,
        x: Float,
        y: Float,
        action: Int,
    ) {
        val copy = MotionEvent.obtain(event)
        copy.setLocation(x, y)
        copy.action = action

        val wasRedispatching = redispatching
        redispatching = true
        try {
            view.dispatchGenericMotionEvent(copy)
        } finally {
            redispatching = wasRedispatching
            copy.recycle()
        }
    }

    /**
     * Hands [event] to the Flutter view, which feeds the framework's pointer
     * pipeline.
     *
     * Never through `dispatchGenericMotionEvent`: that would walk straight back
     * down into the platform views this just arbitrated the event away from.
     */
    private fun forwardToFlutter(view: View, event: MotionEvent) {
        if (event.actionMasked != MotionEvent.ACTION_HOVER_ENTER) {
            view.onGenericMotionEvent(event)
            return
        }

        // The embedding handles hover moves but drops enters. Normalise only
        // the copy Flutter sees: a genuine enter may have no move behind it,
        // and a native owner still needs a real enter.
        val move = MotionEvent.obtain(event)
        try {
            move.action = MotionEvent.ACTION_HOVER_MOVE
            view.onGenericMotionEvent(move)
        } finally {
            move.recycle()
        }
    }

    // ---- PointerInputHostApi ----------------------------------------------

    override fun reset() {
        abandonInFlight(notifyDart = false)
        hover.revision = -1L
    }

    override fun hoverTargetChanged(hit: PointerHitTest) {
        val event = hover.event ?: return

        // Dart reports against the frame it just rendered. If that names an id
        // this side has already re-registered, nothing here can tell whether
        // the new surface is really under the cursor — only a fresh hit test
        // can, and it establishes the revision boundary that lets it win.
        val staleRegistration = hit.revision > hover.revision &&
            hit.target?.viewId?.let { id -> views[id]?.let { it.token !== hover.tokens[id] } } == true

        applyHover(
            hit,
            event,
            tokens = hover.tokens,
            moveOwner = hover.owner?.target?.viewId == hit.target?.viewId,
        )
        if (staleRegistration) requeryHover()
    }

    fun dispose() {
        abandonInFlight(notifyDart = false)
        disposed = true
        views.clear()
    }

    private companion object {
        /**
         * High enough that a healthy bridge never reaches it, low enough to
         * bound how many events can be retained at once.
         */
        const val MAX_IN_FLIGHT = 64
        const val ANSWER_TIMEOUT_MS = 1000L
    }
}

/**
 * Whether the router arbitrates this event.
 *
 * Only what Android delivers *around* Flutter's touch pipeline: wheel notches
 * and cursor movement. Mouse buttons arrive as touch, which `FlutterMutatorView`
 * already routes, and a stylus hovers from its own source.
 *
 * The tool type is deliberately not pinned to [MotionEvent.TOOL_TYPE_MOUSE]. A
 * touchpad drives the same cursor and reports the same source but reports its
 * tool as a finger, and its two-finger scroll is exactly the input this exists
 * to arbitrate.
 */
private fun MotionEvent.isArbitratedMouseInput(): Boolean =
    source == InputDevice.SOURCE_MOUSE &&
        getToolType(0) !in STYLUS_TOOLS &&
        actionMasked in ARBITRATED_ACTIONS

private val STYLUS_TOOLS = setOf(MotionEvent.TOOL_TYPE_STYLUS, MotionEvent.TOOL_TYPE_ERASER)

private val ARBITRATED_ACTIONS = setOf(
    MotionEvent.ACTION_SCROLL,
    MotionEvent.ACTION_HOVER_ENTER,
    MotionEvent.ACTION_HOVER_MOVE,
    MotionEvent.ACTION_HOVER_EXIT,
)
