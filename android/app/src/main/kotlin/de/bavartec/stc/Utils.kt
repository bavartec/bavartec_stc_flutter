package de.bavartec.stc

import android.os.*
import java.net.*
import java.nio.*

object Utils {
    fun mainLoop(task: () -> Unit) {
        Handler(Looper.getMainLooper()).post(task)
    }

    fun urlEncode(data: Map<String, String>): String {
        val builder = StringBuilder()

        data.entries.forEachIndexed { index, entry ->
            if (index > 0) {
                builder.append('&')
            }

            val key = URLEncoder.encode(entry.key, "utf-8")
            val value = URLEncoder.encode(entry.value, "utf-8")
            builder.append(key)
            builder.append('=')
            builder.append(value)
        }

        return builder.toString()
    }

    fun Int.bytes() = ByteBuffer.allocate(4).putInt(this).array().reversedArray()
}