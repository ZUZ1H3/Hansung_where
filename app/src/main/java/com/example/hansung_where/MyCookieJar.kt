package com.example.hansung_where

import okhttp3.*

class MyCookieJar : CookieJar {
    private val cookieStore: MutableMap<HttpUrl, MutableList<Cookie>> = mutableMapOf()

    override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
        cookieStore.putIfAbsent(url, mutableListOf())
        cookieStore[url]?.addAll(cookies)
    }

    override fun loadForRequest(url: HttpUrl): List<Cookie> {
        return cookieStore[url] ?: emptyList()
    }
}

