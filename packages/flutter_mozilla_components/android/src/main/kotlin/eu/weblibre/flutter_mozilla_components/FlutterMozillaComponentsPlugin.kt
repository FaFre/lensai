/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import eu.weblibre.flutter_mozilla_components.api.GeckoBrowserApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoEngineSettingsApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoProfileApiImpl
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureFeature
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProfileApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushApi
import eu.weblibre.flutter_mozilla_components.pigeons.PointerInputHostApi
import eu.weblibre.flutter_mozilla_components.pointer.PointerInputRouter
import eu.weblibre.flutter_mozilla_components.startup.DartStartupProgress

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** FlutterMozillaComponentsPlugin */
class FlutterMozillaComponentsPlugin: FlutterPlugin, ActivityAware {
  private val browserApi = GeckoBrowserApiImpl()
  private var pointerRouter: PointerInputRouter? = null

  /**
   * Held so the leases this engine took — profile access, and whatever the
   * arbiter granted it — can be handed back when the isolate that took them
   * stops existing: [GeckoProfileApiImpl.onEngineDetached] when the engine goes
   * away, [GeckoProfileApiImpl.onEngineRestarting] when only the isolate does.
   */
  private var profileApi: GeckoProfileApiImpl? = null

  /**
   * The engine this plugin is attached to, and the hot-restart listener on it.
   *
   * Held only so the listener can be taken off again on detach: a plugin that
   * left one behind would keep a destroyed engine reachable from its own
   * listener set.
   */
  private var engine: FlutterEngine? = null
  private var engineLifecycle: FlutterEngine.EngineLifecycleListener? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Registered first, and unconditionally: this is the arbitration API Dart
    // `main()` calls before it opens a database, creates a profile, or asks for
    // anything else. Everything below it is profile-bound and therefore only
    // legal after a commitment this API hands out.
    val profileApiImpl = GeckoProfileApiImpl(flutterPluginBinding.applicationContext)
    profileApi = profileApiImpl
    GeckoProfileApi.setUp(flutterPluginBinding.binaryMessenger, profileApiImpl)

    // A hot restart throws the isolate away and runs another one inside this
    // same engine. Nothing else reports that: the plugin is not re-attached, so
    // the leases the dead isolate took would be held against its replacement for
    // the life of the process, and a debug session would answer every restart
    // with "profile is in use".
    val lifecycle = object : FlutterEngine.EngineLifecycleListener {
      override fun onPreEngineRestart() {
        pointerRouter?.reset()
        profileApi?.onEngineRestarting()
        // A new isolate starts its own cold start, exactly as it does on a fresh
        // engine; carrying the old one's progress into it would report a stage
        // nothing has reached.
        DartStartupProgress.reset()
        // Replaced rather than merely disposed: the old instance holds the dead
        // isolate's `nextRoutingDemand` waiter, which would take the next
        // launch's demand and answer nobody — and an engine whose Gecko is
        // already initialized never re-runs the setup that registers this, so
        // leaving the channel bare would fail every routing call the
        // replacement makes.
        browserApi.reinstallContainerProxyApi()
        // The routing on the extension was pushed by that same isolate, and the
        // proxies its endpoints name are about to be restarted by another one.
        // Until they are, the snapshot reads as live and would wave a launch
        // through to ports that no longer mean what they meant; the seed this
        // installs blocks the proxied contexts and leaves the direct ones
        // direct. The replaced form, because it has to land before the
        // replacement's first push rather than whenever it reaches the lock.
        ContainerProxyFeature.onAppHalfReplaced()
      }

      // Destruction is followed by `onDetachedFromEngine`, which hands the same
      // leases back with the binding still valid. Nothing to add here.
      override fun onEngineWillDestroy() = Unit
    }
    flutterPluginBinding.engine().also {
      engine = it
      it.addEngineLifecycleListener(lifecycle)
    }
    engineLifecycle = lifecycle

    val router = PointerInputRouter(flutterPluginBinding.binaryMessenger)
    pointerRouter = router
    PointerInputHostApi.setUp(flutterPluginBinding.binaryMessenger, router)
    browserApi.attachBinding(flutterPluginBinding, router)
    GeckoBrowserApi.setUp(flutterPluginBinding.binaryMessenger, browserApi)
    SandboxCaptureFeature.wireFlutterEvents(flutterPluginBinding.binaryMessenger)

    // Register the engine-settings API at attach time (before GeckoBrowserService
    // .initialize) so Dart can push the history-exclusion snapshot to native
    // *before* the engine starts recording restored-tab visits, closing the
    // startup window where an excluded container could leak to Places.
    // setHistoryExclusions only writes HistoryExclusions state and needs
    // no initialized components; the remaining settings methods resolve
    // components lazily and are not invoked until after initialize. The same
    // instance is reused by GeckoBrowserApiImpl.initialize.
    val engineSettingsApiImpl = GeckoEngineSettingsApiImpl(
      flutterPluginBinding.applicationContext,
    )
    GeckoEngineSettingsApi.setUp(flutterPluginBinding.binaryMessenger, engineSettingsApiImpl)
    GlobalComponents.engineSettingsApi = engineSettingsApiImpl
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    PointerInputHostApi.setUp(binding.binaryMessenger, null)
    pointerRouter?.dispose()
    pointerRouter = null
    GeckoProfileApi.setUp(binding.binaryMessenger, null)
    // Before anything else: the profile-access lease and the arbiter's selection
    // and maintenance leases are all process-global and keyed on the isolate, so
    // an engine that detaches without handing them back locks every later engine
    // out until the process dies. MainActivity destroys the cached engine on any
    // non-finishing destroy, so that is a routine event.
    profileApi?.onEngineDetached()
    profileApi = null
    engineLifecycle?.let { listener -> engine?.removeEngineLifecycleListener(listener) }
    engineLifecycle = null
    engine = null
    SandboxCaptureFeature.detachFlutterEvents(binding.binaryMessenger)
    GeckoPushApi.setUp(binding.binaryMessenger, null)
    browserApi.disposePushApi()
    browserApi.disposeContainerProxyApi()
    browserApi.disposeEngineViewVisibility()
    GlobalComponents.historyEvents = null
    // The availability event is optimisation-only; once Flutter detaches, the surface
    // re-queries pending prompts on its next attach/resume, so dropping the sink is safe.
    GlobalComponents.appLinkEvents = null
    // The UnifiedPush receiver outlives the Flutter engine; without this it would keep dispatching
    // onto a dead messenger. Failures are still retained on Push.lastError.
    GlobalComponents.pushEvents = null
    // An import in flight keeps reporting after detach, and would otherwise hold
    // the old messenger across an engine restart. Progress is advisory, so
    // dropping the sink only costs the percentage, never the import itself.
    GlobalComponents.bookmarksEvents = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    browserApi.attachActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    browserApi.detachActivity()
  }

  /**
   * The engine behind a binding.
   *
   * Deprecated in favour of the narrower accessors the binding also offers, and
   * none of them reach the engine lifecycle a hot restart is reported on. If it
   * is ever removed, the listener moves to whatever creates the engine —
   * `FlutterEngineCoordinator` and `MainActivity` — which is strictly more
   * wiring for the same callback.
   */
  @Suppress("DEPRECATION")
  private fun FlutterPlugin.FlutterPluginBinding.engine(): FlutterEngine = flutterEngine
}
