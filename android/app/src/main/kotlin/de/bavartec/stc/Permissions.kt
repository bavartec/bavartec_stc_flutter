package de.bavartec.stc

import android.app.*
import android.content.*
import android.content.pm.*
import android.net.*
import android.os.*
import android.provider.*
import android.util.*
import androidx.core.app.*
import java.util.*

class Permissions(private val context: Activity) {
    private val permissionRequests = SparseArray<(Boolean) -> Unit>()

    private fun isXiaomi() = "Xiaomi".equals(Build.MANUFACTURER, ignoreCase = true)

    fun require(permission: String, callback: (Boolean) -> Unit) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return callback(true)
        }

        if (isXiaomi()) {
            if (!requireXiaomi(permission)) {
                return callback(false)
            }
        }

        if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
            return callback(true)
        }

        val requestCode = Random().nextInt(Integer.MAX_VALUE) + 1
        permissionRequests.put(requestCode, callback)
        context.requestPermissions(arrayOf(permission), requestCode)
    }

    private fun requireXiaomi(permission: String): Boolean {
        val permissionOp = AppOpsManagerCompat.permissionToOp(permission) ?: return true
        val noteOp = AppOpsManagerCompat.noteOp(context, permissionOp, Process.myUid(), context.packageName)
        return noteOp == AppOpsManagerCompat.MODE_ALLOWED
    }

    fun displayPopup() {
        try {
            // MIUI 8
            val localIntent = Intent("miui.intent.action.APP_PERM_EDITOR")
            localIntent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
            localIntent.putExtra("extra_pkgname", context.packageName)
            context.startActivity(localIntent)
            return
        } catch (ignore: Exception) {
        }

        try {
            // MIUI 5/6/7
            val localIntent = Intent("miui.intent.action.APP_PERM_EDITOR")
            localIntent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity")
            localIntent.putExtra("extra_pkgname", context.packageName)
            context.startActivity(localIntent)
            return
        } catch (ignore: Exception) {
        }

        // Otherwise jump to application details
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri = Uri.fromParts("package", context.packageName, null)
        intent.data = uri
        context.startActivity(intent)
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        val success = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        permissionRequests[requestCode]?.invoke(success)
        permissionRequests.delete(requestCode)
    }
}