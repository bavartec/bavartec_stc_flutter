package de.bavartec.stc

import android.net.nsd.*
import android.net.nsd.NsdManager.*
import android.net.wifi.*
import android.util.*

class NSD(
    private val manager: NsdManager,
    wifi: WifiManager
) : DiscoveryListener {
    companion object {
        const val TAG = "NSD"
        const val SERVICE_TYPE = "_http._tcp"
        const val SERVICE_NAME = "smart-thermo-control"
    }

    private val multicastLock = wifi.createMulticastLock("nsd")

    private val discoveryRequests = ArrayList<(String?) -> Unit>()

    private var running = false
    private val timeout = Timeout(5000) {
        broadcast(null)
    }

    fun discoverWifi(callback: (String?) -> Unit) {
        discoveryRequests += callback
        startDiscovery()
    }

    private fun broadcast(service: NsdServiceInfo?) {
        val value = service?.let(this::format)
        Log.d(TAG, "broadcast: $value")
        discoveryRequests.forEach { it(value) }
        discoveryRequests.clear()
    }

    private fun format(service: NsdServiceInfo): String {
        val host = service.host.hostAddress
        val port = service.port

        return "http://$host:$port"
    }

    private fun startDiscovery() {
        if (running) {
            return
        }

        running = true
        multicastLock.acquire()
        manager.discoverServices(SERVICE_TYPE, PROTOCOL_DNS_SD, this)
        timeout.restart()
    }

    private fun stopDiscovery() {
        if (!running) {
            return
        }


        manager.stopServiceDiscovery(this)
        multicastLock.release()

    }

    override fun onDiscoveryStarted(regType: String) {
        Log.d(TAG, "Service discovery started")
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        Log.d(TAG, "Service discovery success | $service")

        if (service.serviceName != SERVICE_NAME) {
            return
        }

        manager.resolveService(service, object : ResolveListener {
            override fun onResolveFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {
                Log.e(TAG, "Resolve failed: $errorCode")
            }

            override fun onServiceResolved(serviceInfo: NsdServiceInfo) {
                Log.i(TAG, "Resolve Succeeded: $serviceInfo")
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

        broadcast(null)
    }

    override fun onDiscoveryStopped(serviceType: String) {
        Log.d(TAG, "Discovery stopped")
        timeout.stop()
        running = false
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