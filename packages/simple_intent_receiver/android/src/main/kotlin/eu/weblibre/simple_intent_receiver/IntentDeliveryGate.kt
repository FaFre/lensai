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

import eu.weblibre.simple_intent_receiver.pigeons.Intent as PigeonIntent

/** How many undelivered launches are worth keeping. */
const val MAX_PENDING_INTENTS = 16

/**
 * Whether Dart can be handed an intent right now, and what happens to the ones
 * that arrive while it cannot.
 *
 * Sending over Pigeon is not a delivery. `BinaryMessenger.send` to an isolate
 * with no handler registered for the channel neither throws nor reports — the
 * message is simply gone — so anything sent before Dart has subscribed is lost
 * silently. This is the one place that knows whether that has happened yet.
 *
 * Split out of [SimpleIntentReceiverPlugin] and free of `android.*` on purpose:
 * the ordering, readiness and bound can be tested without an Android runtime.
 * [pending] may outlive a gate to carry the backlog across engine replacement;
 * readiness always belongs to this gate's isolate. A shared queue requires a
 * single engine consumer and platform-thread access, as in WebLibre's coordinator.
 */
class IntentDeliveryGate(
    private val maxPending: Int = MAX_PENDING_INTENTS,
    private val pending: ArrayDeque<PigeonIntent> = ArrayDeque(),
) {
    init {
        require(maxPending > 0) { "maxPending must be positive" }
    }

    private var ready = false

    /** Whether Dart has declared itself able to receive live events. */
    val isReady: Boolean get() = ready

    /** How many launches are waiting for it to. */
    val pendingCount: Int get() = pending.size

    /**
     * Accounts for [intent] and reports whether the caller should send it now.
     *
     * `false` means it has been buffered and [drain] will produce it, so the
     * caller must not send it as well — a launch delivered twice opens two tabs.
     */
    fun offer(intent: PigeonIntent): Boolean {
        if (ready) return true

        // A buffer that only grows is a leak in a process whose Dart side may
        // never come up at all: a headless engine can be created, do its work
        // and be discarded without anything ever calling `drain`. The newest
        // launch is the one the user is waiting on, so the oldest goes.
        while (pending.size >= maxPending) {
            pending.removeFirst()
        }
        pending.addLast(intent)
        return false
    }

    /**
     * Marks Dart ready and hands over everything buffered, oldest first.
     *
     * Flipping and draining are one step because the gap between them is
     * precisely the window this class exists to close: a drain that left the
     * gate shut would buffer the next launch into a queue nobody drains again,
     * and a flip before the drain would let a live event overtake the backlog.
     */
    fun drain(): List<PigeonIntent> {
        ready = true

        val drained = pending.toList()
        pending.clear()
        return drained
    }

    /**
     * Forgets that Dart was ready, and goes back to holding.
     *
     * For an isolate going away — an engine detaching, or a Dart side shutting
     * down and unregistering its handler. Readiness is a claim about that
     * isolate and stops being true with it; anything sent afterwards would go
     * to a channel with no handler and be lost in the silence described above.
     *
     * The backlog deliberately survives. It was never handed to the isolate
     * that is leaving, so it is not something to replay — it is a launch the
     * user made that nobody has collected yet, and dropping it here is the
     * failure this whole class exists to prevent.
     */
    fun release() {
        ready = false
    }
}
