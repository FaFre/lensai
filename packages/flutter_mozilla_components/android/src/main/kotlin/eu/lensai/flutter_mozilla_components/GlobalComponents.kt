package eu.lensai.flutter_mozilla_components

import android.content.Context
import eu.lensai.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.lensai.flutter_mozilla_components.pigeons.ReaderViewController
import eu.lensai.flutter_mozilla_components.pigeons.SelectionAction
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import mozilla.components.feature.addons.update.GlobalAddonDependencyProvider
import mozilla.components.support.base.facts.Facts
import mozilla.components.support.base.facts.processor.LogFactProcessor
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.webextensions.WebExtensionSupport
import java.util.concurrent.TimeUnit

object GlobalComponents {
    private var _components: Components? = null

    val components: Components?
        get() = _components

    @DelicateCoroutinesApi
    private fun restoreBrowserState(newComponents: Components) = GlobalScope.launch(Dispatchers.Main) {
        newComponents.tabsUseCases.restore(newComponents.sessionStorage)

        newComponents.sessionStorage.autoSave(newComponents.store)
            .periodicallyInForeground(interval = 30, unit = TimeUnit.SECONDS)
            .whenGoingToBackground()
            .whenSessionsChange()
    }

    fun setUp(
        applicationContext: Context,
        flutterEvents: GeckoStateEvents,
        readerViewController: ReaderViewController,
        selectionAction: SelectionAction
    ) {
        val newComponents = Components(
            applicationContext,
            flutterEvents,
            readerViewController,
            selectionAction
        )

        newComponents.crashReporter.install(applicationContext)
        Facts.registerProcessor(LogFactProcessor())

        newComponents.engine.warmUp()

        restoreBrowserState(newComponents)
        newComponents.downloadsUseCases.restoreDownloads()

        try {
            GlobalAddonDependencyProvider.initialize(
                newComponents.addonManager,
                newComponents.addonUpdater,
            )

            WebExtensionSupport.initialize(
                newComponents.engine,
                newComponents.store,
                onNewTabOverride = {
                        _, engineSession, url ->
                    newComponents.tabsUseCases.addTab(url, selectTab = true, engineSession = engineSession)
                },
                onCloseTabOverride = {
                        _, sessionId ->
                    newComponents.tabsUseCases.removeTab(sessionId)
                },
                onSelectTabOverride = {
                        _, sessionId ->
                    newComponents.tabsUseCases.selectTab(sessionId)
                },
                onUpdatePermissionRequest = newComponents.addonUpdater::onUpdatePermissionRequest,
                onExtensionsLoaded = { extensions ->
                    newComponents.addonUpdater.registerForFutureUpdates(extensions)
                    newComponents.supportedAddonsChecker.registerForChecks()
                },
            )
        } catch (e: UnsupportedOperationException) {
            // Web extension support is only available for engine gecko
            Logger.error("Failed to initialize web extension support", e)
        }

        _components = newComponents
    }
}