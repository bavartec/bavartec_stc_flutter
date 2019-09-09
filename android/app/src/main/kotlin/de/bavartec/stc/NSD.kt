package de.bavartec.stc

import android.net.nsd.NsdManager
import android.net.nsd.NsdManager.PROTOCOL_DNS_SD
import android.net.nsd.NsdServiceInfo
import android.net.wifi.*
import android.util.Log

class NSD(
        private val manager: NsdManager,
        wifi: WifiManager
) : NsdManager.DiscoveryListener {
    companion object {
        const val TAG = "NSD"
        const val SERVICE_TYPE = "_http._tcp"
        const val SERVICE_NAME = "smart-thermo-control"
    }

    private val multicastLock = wifi.createMulticastLock("nsd")

    private var discoveredService: NsdServiceInfo? = null
    private val discoveryRequests = ArrayList<(String?) -> Unit>()

    private var running = false
    private val timeout = Timeout(5000) {
        broadcast(null)
    }

    fun discoverWifi(cache: Boolean, callback: (String?) -> Unit) {
        val cached = discoveredService

        if (cache && cached != null) {
            callback(format(cached))
            return
        }

        discoveryRequests += callback
        startDiscovery()
    }

    fun invalidateWifi() {
        discoveredService = null
        broadcast(null)
    }

    private fun broadcast(service: NsdServiceInfo?) {
        val value = service?.let(this::format)
        discoveryRequests.forEach { it(value) }
        discoveryRequests.clear()
    }

    private fun format(service: NsdServiceInfo): String {
        val host = service.host.hostAddress
        val port = service.port

        return "http://$host:$port"
    }

    private fun startDiscovery() {
        timeout.restart()

        if (running) {
            return
        }

        multicastLock.acquire()
        manager.discoverServices(SERVICE_TYPE, PROTOCOL_DNS_SD, this)
        running = true
    }

    private fun stopDiscovery() {
        timeout.stop()

        if (!running) {
            return
        }

        manager.stopServiceDiscovery(this)
        multicastLock.release()
        running = false
    }

    override fun onDiscoveryStarted(regType: String) {
        Log.d(TAG, "Service discovery started")
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        Log.d(TAG, "Service discovery success | $service")

        if (service.serviceName != SERVICE_NAME) {
            return
        }

        manager.resolveService(service, object : NsdManager.ResolveListener {
            override fun onResolveFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {
                Log.e(TAG, "Resolve failed: $errorCode")
            }

            override fun onServiceResolved(serviceInfo: NsdServiceInfo) {
                Log.i(TAG, "Resolve Succeeded: $serviceInfo")

                discoveredService = serviceInfo
                broadcast(serviceInfo)

                stopDiscovery()
            }
        })
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        Log.e(TAG, "Service lost: $service")

        if (service.serviceName != SERVICE_NAME) {
            return
        }

        invalidateWifi()
    }

    override fun onDiscoveryStopped(serviceType: String) {
        Log.d(TAG, "Discovery stopped")
    }

    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
        Log.e(TAG, "Discovery failed: Error $errorCode")
        stopDiscovery()
    }

    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
        Log.e(TAG, "Discovery failed: Error $errorCode")
        stopDiscovery()
    }
}