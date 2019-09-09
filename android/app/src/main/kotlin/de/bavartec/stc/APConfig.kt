package de.bavartec.stc

import android.net.wifi.*
import android.util.*
import de.bavartec.stc.Utils.bytes
import java.net.*

class APConfig(
        private val wifi: WifiManager
) {
    companion object {
        const val TAG = "APConfig"
        const val SSID = "\"Smart Thermo Control\""
        const val PASSWORD = "\"smart-thermo-control\""
    }

    // @RequiresPermission(Manifest.permission.ACCESS_FINE_LOCATION)
    private fun findNetwork(ssid: String): Int? {
        return wifi.configuredNetworks?.find { it.SSID == ssid }?.networkId
    }

    private fun waitForTraffic(timeout: Int): Boolean {
        val address = gateway()
        val start = System.currentTimeMillis()
        var time = 0L
        var count = 1

        Log.d(TAG, "PING ${address.hostAddress}")

        while (!address.isReachable(timeout)) {
            time = System.currentTimeMillis() - start
            count++

            if (time > timeout) {
                Log.d(TAG, "$count PING timed out")
                return false
            }

            Thread.sleep(100)
        }

        Log.d(TAG, "$count PING took $time ms")
        return true
    }

    private fun waitForWifi(ssid: String, timeout1: Int, timeout2: Int, callback: (Boolean) -> Unit) {
        val thread = Thread {
            val start = System.currentTimeMillis()
            var completed = false

            var lastSupplicantState: SupplicantState? = null

            while (System.currentTimeMillis() - start < timeout1 || completed) {
                val connectionInfo = wifi.connectionInfo
                val supplicantState = connectionInfo?.supplicantState

                if (supplicantState != lastSupplicantState) {
                    Log.d(TAG, "S: " + supplicantState?.name)
                    lastSupplicantState = supplicantState
                }

                completed = supplicantState == SupplicantState.COMPLETED

                if (completed && wifi.dhcpInfo.ipAddress != 0) {
                    Log.d(TAG, connectionInfo?.ssid)

                    if (connectionInfo?.ssid != ssid) {
                        callback(false)
                    }

                    callback(waitForTraffic(timeout2))
                    return@Thread
                } else if (supplicantState in arrayOf(
                                SupplicantState.DISCONNECTED,
                                SupplicantState.INACTIVE,
                                SupplicantState.SCANNING)) {
                    val id = findNetwork(ssid)

                    if (id == null) {
                        callback(false)
                        return@Thread
                    }

                    wifi.enableNetwork(id, true)
                }

                Thread.sleep(100)
            }

            callback(false)
        }
        thread.isDaemon = true
        thread.start()
    }

    // @RequiresPermission(Manifest.permission.ACCESS_FINE_LOCATION)
    private fun connect(callback: (Boolean) -> Unit) {
        Log.d(TAG, "connect")

        wifi.disconnect()

        var id = findNetwork(SSID)

        if (id != null) {
            wifi.disableNetwork(id)
            wifi.removeNetwork(id)
        }

        val config = WifiConfiguration()
        config.SSID = SSID
        config.preSharedKey = PASSWORD
        config.hiddenSSID = true

        id = wifi.addNetwork(config)

        if (id < 0) {
            return callback(false)
        }

        wifi.enableNetwork(id, true)
        wifi.reconnect()
        waitForWifi(SSID, 30000, 5000, callback)
    }

    // @RequiresPermission(Manifest.permission.ACCESS_FINE_LOCATION)
    private fun disconnect(ssid: String, callback: (Boolean) -> Unit) {
        Log.d(TAG, "disconnect: $ssid")

        wifi.disconnect()

        val id = findNetwork(SSID)

        if (id != null) {
            wifi.disableNetwork(id)
            wifi.removeNetwork(id)
        }

        wifi.reconnect()
        waitForWifi('"' + ssid + '"', 12000, 2000, callback)
    }

    private fun gateway(): InetAddress {
        return InetAddress.getByAddress(null, wifi.dhcpInfo.gateway.bytes())
    }

    // @RequiresPermission(Manifest.permission.ACCESS_FINE_LOCATION)
    fun homeSSID(): String? {
        return wifi.connectionInfo.ssid
                .takeIf { it != "<unknown ssid>" && it != SSID }
                ?.removeSurrounding("\"")
    }

    private fun request(url: String, data: Map<String, String>?, callback: (String?) -> Unit) {
        Log.d(TAG, "request: $url")

        class Task : NetworkTask(url, data) {
            override fun onPostExecute(result: String?) {
                callback(result)
            }
        }

        Task().execute()
    }

    fun run(ssid: String, pass: String, callback: (Boolean) -> Unit) {
        connect { connected ->
            if (!connected) {
                disconnect(ssid) {
                    callback(false)
                }
                return@connect
            }

            val gateway = gateway().hostAddress

            request("http://$gateway/config/wifi", mapOf(
                    "ssid" to ssid,
                    "pass" to pass
            )) { body ->
                disconnect(ssid) {
                    callback(body != null)
                }
            }
        }
    }
}