package de.bavartec.stc

import android.os.*
import de.bavartec.stc.Utils.urlEncode
import java.io.*
import java.net.*
import java.net.HttpURLConnection.*

open class NetworkTask(
        private val url: String,
        private val data: Map<String, String>?
) : AsyncTask<Unit, Unit, String?>() {
    override fun doInBackground(vararg params: Unit?): String? {
        return try {
            httpRequest(url, data?.let { urlEncode(it) })
        } catch (e: InterruptedIOException) {
            null
        }
    }

    private fun httpRequest(url: String, data: String?): String? {
        val config: (HttpURLConnection) -> Unit = {
            it.requestMethod = "POST"
            it.instanceFollowRedirects = false
            it.useCaches = false
            it.connectTimeout = 2000
            it.readTimeout = 30000

            if (data != null) {
                it.doOutput = true

                it.setRequestProperty("charset", "utf-8")
                it.setRequestProperty("content-type", "application/x-www-form-urlencoded")
                it.setRequestProperty("content-length", data.length.toString())
            }

            it.connect()
        }

        val connection = URI.create(url).toURL().openConnection() as HttpURLConnection
        config(connection)

        if (data != null) {
            val output = connection.outputStream.bufferedWriter()
            output.write(data)
            output.flush()
        }

        val responseCode = connection.responseCode
        val input = connection.inputStream.bufferedReader()
        val body = input.readText()
        input.close()

        return when (responseCode) {
            HTTP_OK -> body
            HTTP_NO_CONTENT -> ""
            else -> throw IOException("HTTP Error $responseCode ${connection.responseMessage}")
        }
    }
}