/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import eu.weblibre.simple_intent_receiver.pigeons.IntentHost
import eu.weblibre.simple_intent_receiver.pigeons.Intent as PigeonIntent
import eu.weblibre.simple_intent_receiver.pigeons.IntentGatekeeperHostApi

class SimpleIntentReceiverPlugin: FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener, IntentHost {
  companion object {
    private val EXTRA_NOTIFICATION_APPROVAL_TOKEN =
      IntentApprovals.EXTRA_NOTIFICATION_APPROVAL_TOKEN
    private val EXTRA_ALWAYS_ALLOW_PACKAGE = IntentApprovals.EXTRA_ALWAYS_ALLOW_PACKAGE
  }

  private lateinit var context: Context
  private var intentReceiver: IntentReceiver? = null
  private var activity: Activity? = null
  private var binaryMessenger: io.flutter.plugin.common.BinaryMessenger? = null

  /**
   * Whether Dart can be handed an intent, and where the ones that arrive before
   * it can go. See [IntentDeliveryGate]; every launch this plugin sees goes
   * through it.
   */
  private val gate = IntentDeliveryGate()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    intentReceiver = IntentReceiver(flutterPluginBinding.binaryMessenger)
    binaryMessenger = flutterPluginBinding.binaryMessenger
    IntentHost.setUp(flutterPluginBinding.binaryMessenger, this)
    IntentGatekeeperHostApi.setUp(
      flutterPluginBinding.binaryMessenger,
      IntentGatekeeperHostApiImpl(flutterPluginBinding.applicationContext),
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // The isolate that registered the handler is going away with the engine, so
    // the gate's answer about it stops being true here. What it is holding is
    // not that isolate's, and stays.
    gate.release()
    intentReceiver = null
    binaryMessenger?.let {
      IntentHost.setUp(it, null)
      IntentGatekeeperHostApi.setUp(it, null)
    }
    binaryMessenger = null
  }

  override fun takePendingIntents(): List<PigeonIntent> = gate.drain()

  override fun releaseDelivery() = gate.release()

  /**
   * Picks up the intent that created this activity, if it has not been picked
   * up already.
   *
   * `onNewIntent` never fires for the launch that built the activity, so this
   * is the only place it can be seen — but "an activity attached" is not the
   * same thing as "the app just started". The engine deliberately outlives
   * `MainActivity` (`shouldDestroyEngineWithHost` is false there), so a link
   * opened after the task was swiped from Recents can build a brand new
   * activity on top of a Dart side that has been listening the whole time.
   * Assuming otherwise and filing every launch away as a cold-start intent left
   * exactly those links in a slot nothing would ever read again: the app came
   * to the foreground and nothing happened, until a *second* link arrived
   * through `onNewIntent` and was delivered live (#589).
   *
   * So this asks the gate rather than the lifecycle. Cold start buffers,
   * because nothing is listening yet; everything else goes straight out.
   *
   * Nothing guards against taking the same launch twice, because each activity
   * instance is attached once and is handed its own `Intent` by the system. The
   * two guards that have stood here both cost more than they bought: a
   * once-only flag lost the *next* link after one had been handled, and the URI
   * comparison that replaced it swallowed the user opening one link twice —
   * which is an ordinary thing to do and was half of #589.
   *
   * One case is left uncovered, knowingly. If the system destroys
   * `MainActivity` while something else still holds the engine
   * (`FlutterEngineCoordinator.retainForExternalTask`, e.g. a Custom Tab in a
   * proxied container), the activity is later rebuilt from the launch intent
   * the system kept, and this takes it again — one duplicate tab. It cannot be
   * recognised from here: the system's copy of the intent is not the one this
   * process annotated, so no marker written on an `Intent` survives to be read.
   * `MainActivity.onCreate` *can* tell, from a non-null `savedInstanceState`,
   * and that is where a fix would go.
   */
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)

    binding.activity.intent?.let(::handleIntent)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onNewIntent(intent: Intent): Boolean {
    activity?.setIntent(intent)
    return handleIntent(intent)
  }

  private fun grantUriPermissions(intent: Intent) {
    intent.data?.let { uri ->
      if (uri.scheme == "content") {
        try {
          activity?.grantUriPermission(
            context.packageName,
            uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION
          )
        } catch (e: Exception) {
          Log.w("SimpleIntentReceiver", "Could not grant URI permission for: $uri", e)
        }
      }
    }

    intent.getStringExtra(Intent.EXTRA_STREAM)?.let { streamUri ->
      try {
        val uri = Uri.parse(streamUri)
        if (uri.scheme == "content") {
          activity?.grantUriPermission(
            context.packageName,
            uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION
          )
        }
      } catch (e: Exception) {
        Log.w("SimpleIntentReceiver", "Could not grant URI permission for stream: $streamUri", e)
      }
    }
  }

  /**
   * Delivers [intent] to Dart, or holds it until Dart can take it.
   *
   * The `onNewIntent` half of the same question the gate answers for
   * `onAttachedToActivity`: a profile is committed well before the app's intent
   * consumers are built, so a link arriving in between used to be sent to a
   * channel with no handler on the other end and vanish.
   *
   * The conversion runs before the gate is asked, and that is the order that
   * matters: it redeems the one-shot approval token and resolves the calling
   * package, both of which have to be settled while the launch is still here.
   * A launch that ends up held is therefore held complete, and comes back out
   * of [takePendingIntents] carrying everything a live one would.
   */
  private fun handleIntent(intent: Intent): Boolean {
    val pigeonIntent = prepareIntentForDelivery(intent)

    if (gate.offer(pigeonIntent)) {
      intentReceiver?.sendIntent(pigeonIntent)
    }

    return true
  }

  private fun prepareIntentForDelivery(intent: Intent): PigeonIntent {
    grantUriPermissions(intent)

    if (intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0) {
      intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
    }

    // Shared with the startup broker, which has to redeem the same token when it
    // queues a launch the plugin will never see.
    val notificationApproval = IntentApprovals.consume(context, intent)
    return convertToPigeonIntent(intent, notificationApproval)
  }

  /**
   * Delegates to [IntentCallerResolver] rather than resolving here, because the
   * native startup broker has to record the same answer for a launch it replays
   * later. Two copies of this would agree only until one was edited.
   */
  private fun resolveCallerPackage(intent: Intent, notificationApproval: NotificationApproval?): String? {
    if (notificationApproval != null) {
      return null
    }

    return IntentCallerResolver.resolve(context, activity, intent)
  }

  private fun convertToPigeonIntent(intent: Intent, notificationApproval: NotificationApproval?): PigeonIntent {
    val action = intent.action
    val data = intent.dataString
    val fromPackageName = resolveCallerPackage(intent, notificationApproval)

    val categories = ArrayList<String>()
    intent.categories?.let {
      categories.addAll(it)
    }

    val extras = HashMap<String, Any?>()
    intent.extras?.let { bundle ->
      for (key in bundle.keySet()) {
        try {
          if (key == EXTRA_NOTIFICATION_APPROVAL_TOKEN) {
            continue
          }
          if (key == EXTRA_ALWAYS_ALLOW_PACKAGE) {
            continue
          }

          when (val value = bundle.get(key)) {
            is Bundle -> {
              val bundleMap = HashMap<String, Any?>()
              for (bundleKey in value.keySet()) {
                val bundleValue = value.get(bundleKey)
                if (bundleValue == null || bundleValue is String ||
                  bundleValue is Boolean || bundleValue is Int ||
                  bundleValue is Long || bundleValue is Double ||
                  bundleValue is Float) {
                  bundleMap[bundleKey] = bundleValue
                } else {
                  bundleMap[bundleKey] = bundleValue.toString()
                }
              }
              extras[key] = bundleMap
            }
            null, is String, is Boolean, is Int, is Long, is Double, is Float,
            is ByteArray, is IntArray, is LongArray, is DoubleArray, is FloatArray -> {
              extras[key] = value
            }
            else -> {
              extras[key] = value.toString()
            }
          }
        } catch (e: Exception) {
          Log.w("SimpleIntentReceiver", "Could not extract extra with key: $key", e)
          extras["${key}_error"] = e.message ?: "Unknown error"
        }
      }
    }

    notificationApproval?.alwaysAllowPackage?.let {
      extras[EXTRA_ALWAYS_ALLOW_PACKAGE] = it
    }

    return PigeonIntent(
      fromPackageName = fromPackageName,
      action = action,
      data = data,
      categories = categories,
      mimeType = intent.type,
      extra = extras
    )
  }
}
