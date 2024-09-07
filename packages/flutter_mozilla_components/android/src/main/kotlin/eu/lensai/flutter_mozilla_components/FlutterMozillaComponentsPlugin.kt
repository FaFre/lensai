package eu.lensai.flutter_mozilla_components

import GeckoBrowserApi
import GeckoSessionApi
import GeckoTabsApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import eu.lensai.flutter_mozilla_components.api.GeckoBrowserApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoSessionApiImpl
import eu.lensai.flutter_mozilla_components.api.GeckoTabsApiImpl

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import mozilla.components.browser.engine.gecko.GeckoEngine
import mozilla.components.browser.engine.gecko.fetch.GeckoViewFetchClient
import mozilla.components.concept.engine.Engine
import mozilla.components.experiment.NimbusExperimentDelegate
import mozilla.components.feature.webcompat.WebCompatFeature
import mozilla.components.lib.crash.handler.CrashHandlerService
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.base.log.sink.AndroidLogSink
import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.GeckoRuntimeSettings

/**
 * Helper class for lazily instantiating components needed by the application.
 */
class Components(private val applicationContext: Context) : DefaultComponents(applicationContext) {
  private val runtime by lazy {
    // Allow for exfiltrating Gecko metrics through the Glean SDK.
    val builder = GeckoRuntimeSettings.Builder().aboutConfigEnabled(true)
    builder.experimentDelegate(NimbusExperimentDelegate())
    builder.crashHandler(CrashHandlerService::class.java)
    GeckoRuntime.create(applicationContext, builder.build())
  }

  override val engine: Engine by lazy {
    GeckoEngine(applicationContext, engineSettings, runtime).also {
//      it.installBuiltInWebExtension("borderify@mozac.org", "resource://android/assets/extensions/borderify/") {
//          throwable ->
//        Log.log(Log.Priority.ERROR, "SampleBrowser", throwable, "Failed to install borderify")
//      }
//
//      it.installBuiltInWebExtension("testext@mozac.org", "resource://android/assets/extensions/test/") {
//          throwable ->
//        Log.log(Log.Priority.ERROR, "SampleBrowser", throwable, "Failed to install testext")
//      }

      WebCompatFeature.install(it)
      //WebCompatReporterFeature.install(it)
    }
  }

  override val client by lazy { GeckoViewFetchClient(applicationContext, runtime) }
}


/** FlutterMozillaComponentsPlugin */
class FlutterMozillaComponentsPlugin: FlutterPlugin, ActivityAware {
  private var activity: Activity? = null

  private lateinit var _flutterPluginBinding: FlutterPlugin.FlutterPluginBinding;

  init {
    Log.addSink(AndroidLogSink())
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    _flutterPluginBinding = flutterPluginBinding

    GlobalComponents.setUp(flutterPluginBinding.applicationContext)

    val intent = Intent(flutterPluginBinding.applicationContext, NotificationActivity::class.java)
    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    flutterPluginBinding.applicationContext.startActivity(intent)

    GeckoBrowserApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoBrowserApiImpl {
      showNativeFragment()
    })

    GeckoSessionApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoSessionApiImpl())
    GeckoTabsApi.setUp(_flutterPluginBinding.binaryMessenger, GeckoTabsApiImpl())
  }

  private fun showNativeFragment() {
    if (activity == null) {
      //result.error("ACTIVITY_NOT_ATTACHED", "Activity is not attached", null)
      return
    }

    // Replace this with your actual Fragment
    val nativeFragment = BrowserFragment.create(activity!!)

    val fm = (activity as FragmentActivity).supportFragmentManager
    fm.beginTransaction()
      .replace(FRAGMENT_CONTAINER_ID, nativeFragment)
      .commitAllowingStateLoss()

  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity

    _flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "eu.lensai/gecko", GeckoViewFactory(binding.activity, FRAGMENT_CONTAINER_ID))
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    this.activity = null
  }

  companion object {
    private const val FRAGMENT_CONTAINER_ID = 0xBEEF
  }
}
