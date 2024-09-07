package eu.lensai.flutter_mozilla_components


import android.content.Context
import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import mozilla.components.browser.errorpages.ErrorPages
import mozilla.components.browser.errorpages.ErrorType
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.request.RequestInterceptor

class AppRequestInterceptor(private val context: Context) : RequestInterceptor {
    override fun onLoadRequest(
        engineSession: EngineSession,
        uri: String,
        lastUri: String?,
        hasUserGesture: Boolean,
        isSameDomain: Boolean,
        isRedirect: Boolean,
        isDirectNavigation: Boolean,
        isSubframeRequest: Boolean,
    ): RequestInterceptor.InterceptionResponse? {
        val components = GlobalComponents.components!!

        return when (uri) {
//            "about:privatebrowsing" -> {
//                val page = PrivatePage.createPrivateBrowsingPage(context, uri)
//                RequestInterceptor.InterceptionResponse.Content(page, encoding = "base64")
//            }

//            "about:crashes" -> {
//                val intent = Intent(context, CrashListActivity::class.java)
//                intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
//                context.startActivity(intent)
//
//                RequestInterceptor.InterceptionResponse.Url("about:blank")
//            }

            else -> {
                 components.appLinksInterceptor.onLoadRequest(
                    engineSession,
                    uri,
                    lastUri,
                    hasUserGesture,
                    isSameDomain,
                    isRedirect,
                    isDirectNavigation,
                    isSubframeRequest,
                )
            }
        }
    }

    override fun onErrorRequest(
        session: EngineSession,
        errorType: ErrorType,
        uri: String?,
    ): RequestInterceptor.ErrorResponse {
        val errorPage = ErrorPages.createUrlEncodedErrorPage(context, errorType, uri)
        return RequestInterceptor.ErrorResponse(errorPage)
    }

    override fun interceptsAppInitiatedRequests() = true
}