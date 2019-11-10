package de.bavartec.stc

import android.net.nsd.NsdManager
import android.net.nsd.NsdManager.*
import android.net.nsd.NsdServiceInfo
import android.net.wifi.WifiManager
import android.util.Log
import java.util.*

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

    private var running = false

    private val cached: MutableList<NsdServiceInfo> = ArrayList()

    fun discoverWifi(callback: (String?) -> Unit) {
        callback(cached.firstOrNull()?.let(this::format))
        startDiscovery()
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
    }

    private fun stopDiscovery() {
        if (!running) {
            return
        }

        running = false
        multicastLock.release()
        manager.stopServiceDiscovery(this)
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
                cached += serviceInfo
            }
        })
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        Log.e(TAG, "Service lost: $service")

        if (service.serviceName != SERVICE_NAME) {
            return
        }

        cached -= service
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