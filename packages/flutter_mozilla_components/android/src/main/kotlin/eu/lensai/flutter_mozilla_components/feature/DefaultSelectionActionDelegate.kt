package eu.lensai.flutter_mozilla_components.feature

import eu.lensai.flutter_mozilla_components.pigeons.SelectionAction
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.suspendCancellableCoroutine
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import kotlin.coroutines.resume

class DefaultSelectionActionDelegate(
    private val selectionAction: SelectionAction
) : SelectionActionDelegate {
    override fun getActionTitle(id: String): CharSequence? = runBlocking {
        suspendCancellableCoroutine { continuation ->
            selectionAction.getActionTitle(id) { result ->
                continuation.resume(result.getOrNull())
            }
        }
    }

    override fun getAllActions(): Array<String> = runBlocking {
        suspendCancellableCoroutine { continuation ->
            selectionAction.getAllActions() { result ->
                continuation.resume(result.getOrNull()!!.toTypedArray())
            }
        }
    }

    override fun isActionAvailable(id: String, selectedText: String): Boolean = runBlocking {
        suspendCancellableCoroutine { continuation ->
            selectionAction.isActionAvailable(id, selectedText) { result ->
                continuation.resume(result.getOrNull()!!)
            }
        }
    }

    override fun performAction(id: String, selectedText: String): Boolean  = runBlocking {
        suspendCancellableCoroutine { continuation ->
            selectionAction.performAction(id, selectedText) { result ->
                continuation.resume(result.getOrNull()!!)
            }
        }
    }

    override fun sortedActions(actions: Array<String>): Array<String>  = runBlocking {
        suspendCancellableCoroutine { continuation ->
            selectionAction.sortedActions(actions.toList()) { result ->
                continuation.resume(result.getOrNull()!!.toTypedArray())
            }
        }
    }
}