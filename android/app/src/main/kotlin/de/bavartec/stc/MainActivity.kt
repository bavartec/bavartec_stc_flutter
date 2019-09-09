package de.bavartec.stc

import android.*
import android.net.nsd.*
import android.net.wifi.*
import android.os.*
import android.util.*
import android.widget.*
import io.flutter.app.*
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.*
import io.flutter.plugins.*

class MainActivity : FlutterActivity(), MethodCallHandler {
    companion object {
        const val TAG = "ANDROID"
    }

    private lateinit var platform: MethodChannel

    private lateinit var permissions: Permissions
    private lateinit var apConfig: APConfig
    private lateinit var mnsd: NSD

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        platform = MethodChannel(flutterView, "bavartec")
        platform.setMethodCallHandler(this)

        val wifi = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        val nsd = getSystemService(NSD_SERVICE) as NsdManager

        val toast = { text: String ->
            Utils.mainLoop {
                Toast.makeText(this, text, Toast.LENGTH_LONG).show()
            }
        }

        Thread.UncaughtExceptionHandler { _, e ->
            Log.e(TAG, e.message, e)
            toast(e.message ?: "An error occurred")
        }

        permissions = Permissions(this)
        apConfig = APConfig(wifi)
        mnsd = NSD(nsd, wifi)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        this.permissions.onRequestPermissionsResult(requestCode, grantResults)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            onMethodCallUnsafe(call, result)
        } catch (e: Exception) {
            Log.e(TAG, e.message, e)
            result.error(e.message, null, null)
        }
    }

    private fun onMethodCallUnsafe(call: MethodCall, result: Result) {
        val safeSuccess: (Any?) -> Unit = { ret ->
            Utils.mainLoop {
                result.success(ret)
            }
        }

        when (call.method) {
            "apConfig" -> {
                val ssid = call.argument<String>("ssid")!!
                val pass = call.argument<String>("pass")!!
                apConfig.run(ssid, pass, safeSuccess)
            }
            "discoverWifi" -> {
                mnsd.discoverWifi(false, safeSuccess)
            }
            "homeSSID" -> {
                result.success(apConfig.homeSSID())
            }
            "requireLocation" -> {
                permissions.require(Manifest.permission.ACCESS_FINE_LOCATION, result::success)
            }
            else -> result.notImplemented()
        }
    }
}