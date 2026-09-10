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

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue
import eu.weblibre.simple_intent_receiver.pigeons.Intent as PigeonIntent

/**
 * The lifecycle paths behind #589, stated as the only thing about them that is
 * testable without a device: what the gate answers, and in which order.
 *
 * Each test names the lifecycle it stands for. The activity callbacks that feed
 * the gate are Android's to make; what this fixes is the decision the plugin
 * makes when they arrive, and that decision lives here.
 */
class IntentDeliveryGateTest {
    @Test
    fun nonPositiveCapacityIsRejectedAtConstruction() {
        for (capacity in listOf(0, -1, Int.MIN_VALUE)) {
            assertFailsWith<IllegalArgumentException> {
                IntentDeliveryGate(maxPending = capacity)
            }
        }
    }

    private fun link(url: String) = PigeonIntent(
        fromPackageName = null,
        action = "android.intent.action.VIEW",
        data = url,
        categories = emptyList(),
        mimeType = null,
        extra = emptyMap(),
    )

    /** Process-dead cold start: nothing is listening, so nothing may be sent. */
    @Test
    fun aLaunchBeforeDartIsReadyIsHeldBackNotSent() {
        val gate = IntentDeliveryGate()

        assertFalse(gate.offer(link("https://example.com/a")))
        assertFalse(gate.isReady)
        assertEquals(1, gate.pendingCount)
    }

    /** ...and the app half picks it up when it comes up. */
    @Test
    fun drainHandsOverTheBacklogOldestFirst() {
        val gate = IntentDeliveryGate()

        gate.offer(link("https://example.com/a"))
        gate.offer(link("https://example.com/b"))

        assertEquals(
            listOf("https://example.com/a", "https://example.com/b"),
            gate.drain().map { it.data },
        )
        assertEquals(0, gate.pendingCount)
    }

    /**
     * Retained engine, replacement activity: the Dart side has been listening
     * the whole time, so the launch that built the new activity goes straight
     * out instead of into a cache nothing reads again (#589).
     */
    @Test
    fun aLaunchAfterDrainIsSentLive() {
        val gate = IntentDeliveryGate()
        gate.drain()

        assertTrue(gate.isReady)
        assertTrue(gate.offer(link("https://example.com/a")))
        assertEquals(0, gate.pendingCount)
    }

    /**
     * Reopening the same URL. The gate is deliberately blind to what a launch
     * points at: suppressing a repeat is what made the second tap on one link
     * do nothing at all.
     */
    @Test
    fun theSameLinkTwiceIsTwoDeliveries() {
        val gate = IntentDeliveryGate()
        gate.drain()

        assertTrue(gate.offer(link("https://example.com/a")))
        assertTrue(gate.offer(link("https://example.com/a")))
    }

    /** An intent arriving during Dart startup joins the backlog it is about to drain. */
    @Test
    fun drainIncludesWhatArrivedWhileItWasStillStarting() {
        val gate = IntentDeliveryGate()

        gate.offer(link("https://example.com/attached"))
        gate.offer(link("https://example.com/new-intent"))

        assertEquals(2, gate.drain().size)
        // And the window is shut behind it: the next one is live, not a second
        // backlog nothing will come back for.
        assertTrue(gate.offer(link("https://example.com/after")))
    }

    /** Draining twice is not a way to receive a launch twice. */
    @Test
    fun drainIsIdempotent() {
        val gate = IntentDeliveryGate()
        gate.offer(link("https://example.com/a"))

        assertEquals(1, gate.drain().size)
        assertEquals(emptyList(), gate.drain())
        assertTrue(gate.isReady)
    }

    /**
     * Headless engine that dies before Dart ever comes up: the buffer is a
     * bound, not a log.
     */
    @Test
    fun theBacklogIsBoundedAndKeepsTheNewest() {
        val gate = IntentDeliveryGate(maxPending = 2)

        gate.offer(link("https://example.com/1"))
        gate.offer(link("https://example.com/2"))
        gate.offer(link("https://example.com/3"))

        assertEquals(2, gate.pendingCount)
        assertEquals(
            listOf("https://example.com/2", "https://example.com/3"),
            gate.drain().map { it.data },
        )
    }

    /**
     * Engine detach, or a Dart side shutting down. Its successor must not be
     * told it is ready on that isolate's behalf.
     */
    @Test
    fun releaseSendsLaterLaunchesBackToTheBacklog() {
        val gate = IntentDeliveryGate()
        gate.drain()
        assertTrue(gate.offer(link("https://example.com/live")))

        gate.release()

        assertFalse(gate.isReady)
        // Back to holding, exactly as a fresh process would.
        assertFalse(gate.offer(link("https://example.com/held")))
        assertEquals(
            listOf("https://example.com/held"),
            gate.drain().map { it.data },
        )
    }

    /**
     * ...and it does not take the backlog with it. Those launches were never
     * handed to the isolate that is leaving, so they are not a replay — they
     * are a link the user opened that nobody has collected yet.
     */
    @Test
    fun releaseKeepsWhatWasNeverCollected() {
        val gate = IntentDeliveryGate()
        gate.offer(link("https://example.com/a"))

        gate.release()

        assertEquals(1, gate.pendingCount)
        assertEquals(listOf("https://example.com/a"), gate.drain().map { it.data })
    }

    /**
     * The engine-replacement sequence end to end: held, the isolate goes away
     * before it ever drained, and the next one gets it.
     */
    @Test
    fun aLaunchHeldAcrossAnIsolateSurvivesToTheNextOne() {
        val pending = ArrayDeque<PigeonIntent>()
        val gate = IntentDeliveryGate(pending = pending)
        gate.offer(link("https://example.com/a"))
        gate.release()

        val replacement = IntentDeliveryGate(pending = pending)
        assertFalse(replacement.isReady)
        replacement.offer(link("https://example.com/b"))
        assertEquals(
            listOf("https://example.com/a", "https://example.com/b"),
            replacement.drain().map { it.data },
        )
        assertTrue(replacement.isReady)
    }

    @Test
    fun replacementDoesNotInheritReadinessEvenBeforeOldGateIsReleased() {
        val pending = ArrayDeque<PigeonIntent>()
        val old = IntentDeliveryGate(pending = pending)
        old.drain()

        val replacement = IntentDeliveryGate(pending = pending)
        assertFalse(replacement.offer(link("https://example.com/a")))
        assertEquals(1, replacement.drain().size)

        old.release()
        assertTrue(replacement.isReady)
    }

    @Test
    fun capacityOneKeepsOnlyTheLatestIncludingRepeatedUrls() {
        val gate = IntentDeliveryGate(maxPending = 1)
        gate.offer(link("https://example.com/old"))
        gate.offer(link("https://example.com/latest"))
        gate.offer(link("https://example.com/latest"))

        assertEquals(listOf("https://example.com/latest"), gate.drain().map { it.data })
    }
}
