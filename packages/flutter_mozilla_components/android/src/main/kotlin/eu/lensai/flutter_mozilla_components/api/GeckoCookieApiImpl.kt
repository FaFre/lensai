package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.feature.CookieManagerFeature
import eu.lensai.flutter_mozilla_components.feature.ResultConsumer
import eu.lensai.flutter_mozilla_components.pigeons.Cookie
import eu.lensai.flutter_mozilla_components.pigeons.CookiePartitionKey
import eu.lensai.flutter_mozilla_components.pigeons.CookieSameSiteStatus
import eu.lensai.flutter_mozilla_components.pigeons.GeckoCookieApi
import org.json.JSONObject

class GeckoCookieApiImpl : GeckoCookieApi {
    private fun toValueOrNull(json: JSONObject, key: String): Any? {
        if (!json.has(key)) {
            throw RuntimeException("Invalid map key")
        }

        if (!json.isNull(key)) {
            return json.get(key)
        }

        return null
    }

    private fun cookiePartitionKeyFromJSON(inputJSON: JSONObject): CookiePartitionKey {
        return CookiePartitionKey(
            topLevelSite = inputJSON.getString("topLevelSite")
        )
    }

    private fun CookiePartitionKey.toJSON(): JSONObject {
        val json = JSONObject()
        json.put("topLevelSite", topLevelSite)
        return json
    }

    private fun cookieFromJSON(inputJSON: JSONObject): Cookie {
        val partitionKeyRaw = toValueOrNull(inputJSON, "partitionKey") as JSONObject?
        val partitionKey = if (partitionKeyRaw == null || partitionKeyRaw.length() == 0) null
                            else cookiePartitionKeyFromJSON(partitionKeyRaw)

        return Cookie (
            domain = inputJSON.getString("domain"),
            expirationDate = (toValueOrNull(inputJSON, "expirationDate") as Int?)?.toLong(),
            firstPartyDomain = inputJSON.getString("firstPartyDomain"),
            hostOnly = inputJSON.getBoolean("hostOnly"),
            httpOnly = inputJSON.getBoolean("httpOnly"),
            name = inputJSON.getString("name"),
            partitionKey = partitionKey,
            path = inputJSON.getString("path"),
            secure = inputJSON.getBoolean("secure"),
            session = inputJSON.getBoolean("session"),
            sameSite = when(inputJSON.getString("sameSite")) {
                "no_restriction" -> CookieSameSiteStatus.NO_RESTRICTION
                "lax" -> CookieSameSiteStatus.LAX
                "strict" -> CookieSameSiteStatus.STRICT
                else -> CookieSameSiteStatus.UNSPECIFIED
            },
            storeId = inputJSON.getString("storeId"),
            value = inputJSON.getString("value")
        )
    }

    override fun getCookie(
        firstPartyDomain: String?,
        name: String,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String,
        callback: (Result<Cookie>) -> Unit
    ) {
        val args = JSONObject()

        if (firstPartyDomain == null) {
            args.put("firstPartyDomain", JSONObject.NULL)
        } else {
            args.put("firstPartyDomain", firstPartyDomain)
        }
        args.put("name", name)

        if (partitionKey == null) {
            args.put("partitionKey", JSONObject.NULL)
        } else {
            args.put("partitionKey", partitionKey.toJSON())
        }

        if (storeId == null) {
            args.put("storeId", JSONObject.NULL)
        } else {
            args.put("storeId", storeId)
        }

        args.put("url", url)

        CookieManagerFeature.scheduleRequest("get", args, object: ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(cookieFromJSON(result.getJSONObject("result"))))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }

        })
    }

    override fun getAllCookies(
        domain: String?,
        firstPartyDomain: String?,
        name: String?,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String,
        callback: (Result<List<Cookie>>) -> Unit
    ) {
        val args = JSONObject()

        if (domain == null) {
            args.put("domain", JSONObject.NULL)
        } else {
            args.put("domain", domain)
        }

        if (firstPartyDomain == null) {
            args.put("firstPartyDomain", JSONObject.NULL)
        } else {
            args.put("firstPartyDomain", firstPartyDomain)
        }

        args.put("name", name)

        if (partitionKey == null) {
            args.put("partitionKey", JSONObject.NULL)
        } else {
            args.put("partitionKey", partitionKey.toJSON())
        }

        if (storeId == null) {
            args.put("storeId", JSONObject.NULL)
        } else {
            args.put("storeId", storeId)
        }

        args.put("url", url)

        CookieManagerFeature.scheduleRequest("getAll", args, object: ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                val jsonArray = result.getJSONArray("result")
                val cookies: MutableList<Cookie> = mutableListOf()

                repeat(jsonArray.length()) {
                        index ->
                    cookies.add(cookieFromJSON(jsonArray.getJSONObject(index)))
                }

                callback(Result.success(cookies))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }

        })
    }

    override fun setCookie(
        domain: String?,
        expirationDate: Long?,
        firstPartyDomain: String?,
        httpOnly: Boolean?,
        name: String?,
        partitionKey: CookiePartitionKey?,
        path: String?,
        sameSite: CookieSameSiteStatus?,
        secure: Boolean?,
        storeId: String?,
        url: String,
        value: String?,
        callback: (Result<Unit>) -> Unit
    ) {
        val args = JSONObject()

        if (domain == null) {
            args.put("domain", JSONObject.NULL)
        } else {
            args.put("domain", domain)
        }

        if (expirationDate == null) {
            args.put("expirationDate", JSONObject.NULL)
        } else {
            args.put("expirationDate", domain)
        }

        if (firstPartyDomain == null) {
            args.put("firstPartyDomain", JSONObject.NULL)
        } else {
            args.put("firstPartyDomain", firstPartyDomain)
        }

        if (httpOnly == null) {
            args.put("httpOnly", JSONObject.NULL)
        } else {
            args.put("httpOnly", httpOnly)
        }

        if (name == null) {
            args.put("name", JSONObject.NULL)
        } else {
            args.put("name", name)
        }

        if (partitionKey == null) {
            args.put("partitionKey", JSONObject.NULL)
        } else {
            args.put("partitionKey", partitionKey.toJSON())
        }

        if (path == null) {
            args.put("path", JSONObject.NULL)
        } else {
            args.put("path", path)
        }

        if (sameSite == null) {
            args.put("sameSite", JSONObject.NULL)
        } else {
            args.put("sameSite", when(sameSite) {
                CookieSameSiteStatus.NO_RESTRICTION -> "no_restriction"
                CookieSameSiteStatus.LAX -> "lax"
                CookieSameSiteStatus.STRICT -> "strict"
                CookieSameSiteStatus.UNSPECIFIED -> ""
            })
        }

        if (secure == null) {
            args.put("secure", JSONObject.NULL)
        } else {
            args.put("secure", secure)
        }

        if (storeId == null) {
            args.put("storeId", JSONObject.NULL)
        } else {
            args.put("storeId", storeId)
        }

        args.put("url", url)

        if (value == null) {
            args.put("value", JSONObject.NULL)
        } else {
            args.put("value", value)
        }

        CookieManagerFeature.scheduleRequest("set", args, object: ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(Unit))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun removeCookie(
        firstPartyDomain: String?,
        name: String,
        partitionKey: CookiePartitionKey?,
        storeId: String?,
        url: String,
        callback: (Result<Unit>) -> Unit
    ) {
        val args = JSONObject()

        if (firstPartyDomain == null) {
            args.put("firstPartyDomain", JSONObject.NULL)
        } else {
            args.put("firstPartyDomain", firstPartyDomain)
        }

        args.put("name", name)

        if (partitionKey == null) {
            args.put("partitionKey", JSONObject.NULL)
        } else {
            args.put("partitionKey", partitionKey.toJSON())
        }

        if (storeId == null) {
            args.put("storeId", JSONObject.NULL)
        } else {
            args.put("storeId", storeId)
        }

        args.put("url", url)

        CookieManagerFeature.scheduleRequest("remove", args, object: ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(Unit))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

}