'use strict';

console.log("Connecting to native port...")
const port = browser.runtime.connectNative("cookieManager");
console.log("Native port connected!")

function cookieToMap(cookie) {
    let partitionKey = {}
    if (cookie.partitionKey) {
        partitionKey["topLevelSite"] = cookie.partitionKey.topLevelSite
    }

    return {
        "domain": cookie.domain,
        "expirationDate": cookie.expirationDate,
        "firstPartyDomain": cookie.firstPartyDomain,
        "hostOnly": cookie.hostOnly,
        "httpOnly": cookie.httpOnly,
        "name": cookie.name,
        "partitionKey": partitionKey,
        "path": cookie.path,
        "secure": cookie.secure,
        "session": cookie.session,
        "sameSite": cookie.sameSite,
        "storeId": cookie.storeId,
        "value": cookie.value
    }
}

function sendCookieResultForRequest(id) {
    return function (cookie) {
        port.postMessage({
            "id": id,
            "status": "success",
            "result": cookieToMap(cookie)
        })
    }
}

function sendCookieListResultForRequest(id) {
    return function (cookies) {
        port.postMessage({
            "id": id,
            "status": "success",
            "result": cookies.map((cookie) => cookieToMap(cookie))
        })
    }
}

function sendErrorForRequest(id) {
    return function (error) {
        console.error(error);
        port.postMessage({
            "id": id,
            "status": "error",
            "error": error
        });
    }
}

port.onMessage.addListener(message => {
    let requestId = message["id"]
    switch (message["action"]) {
        case "get":
            browser.cookies.get(message["args"])
                .then(sendCookieResultForRequest(requestId))
                .catch(sendErrorForRequest(requestId))
            break
        case "getAll":
            browser.cookies.getAll(message["args"])
                .then(sendCookieListResultForRequest(requestId))
                .catch(sendErrorForRequest(requestId))
            break
        case "remove":
            browser.cookies.remove(message["args"])
                .then(sendCookieResultForRequest(requestId))
                .catch(sendErrorForRequest(requestId))
            break
        case "set":
            browser.cookies.set(message["args"])
                .then(sendCookieResultForRequest(requestId))
                .catch(sendErrorForRequest(requestId))
            break
    }
});
