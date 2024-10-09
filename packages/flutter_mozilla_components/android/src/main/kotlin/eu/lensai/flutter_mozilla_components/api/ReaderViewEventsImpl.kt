package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.pigeons.ReaderViewEvents

// Interface for the listener
interface ReaderViewControllerListener {
    fun onReaderViewToggled(enabled: Boolean)
    fun onAppearanceButtonTap()
}

class ReaderViewEventsImpl : ReaderViewEvents {

    private val listeners = mutableSetOf<ReaderViewControllerListener>()

    override fun onToggleReaderView(enable: Boolean) {
        listeners.forEach { it.onReaderViewToggled(enable) }
    }

    override fun onAppearanceButtonTap() {
        listeners.forEach { it.onAppearanceButtonTap() }
    }

    // Method to add a listener
    fun addListener(listener: ReaderViewControllerListener) {
        listeners.add(listener)
    }

    // Method to remove a listener
    fun removeListener(listener: ReaderViewControllerListener) {
        listeners.remove(listener)
    }
}
