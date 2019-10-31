import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartconfig/smartconfig.dart';

class WiFi {
  static String ssid;
  static String bssid;
  static String pass;

  static Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ssid = prefs.getString('/config/wifi/ssid');
    pass = prefs.getString('/config/wifi/pass');
  }

  static void set(
    final String ssid,
    final String bssid,
    final String pass,
  ) async {
    WiFi.ssid = ssid;
    WiFi.bssid = bssid;
    WiFi.pass = pass;
  }

  static Future<void> save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('/config/wifi/ssid', ssid);
    prefs.setString('/config/wifi/pass', pass);
  }

  static Future<bool> submit({
    final bool legacy = false,
  }) {
    if (legacy) {
      return Platform.apConfig(ssid, pass);
    } else {
      return smartConfig(ssid, bssid, pass);
    }
  }

  static Future<bool> smartConfig(
      final String ssid, final String bssid, final String pass) async {
    return (await Smartconfig.start(ssid, bssid, pass)) ||
        (await Api.mdnsQuery()) != null;
  }

  static Future<bool> _requestPermissions() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([
      PermissionGroup.storage,
      PermissionGroup.location,
    ]);

    print(permissions.values.toList().toString());

    List<bool> results = permissions.values.toList().map((status) {
      return status == PermissionStatus.granted;
    }).toList();

    return !results.contains(false);
  }

  static Future<bool> getConnectivityPermission() async {
    // _requestPermissions();

    // print("platform is Android: [" + Platform.isAndroid.toString() + "]");

    if (Platform.isAndroid) {
      return Platform.requireLocation();
    }

    if (Platform.isIOS) {
      // Platform messages may fail, so we use a try/catch PlatformException.

      final Connectivity connectivity = Connectivity();
      try {
        await connectivity.checkConnectivity();
      } on PlatformException catch (e) {
        print(e.toString());
      }

      print("[mike][ios...]");
      LocationAuthorizationStatus status =
          await connectivity.getLocationServiceAuthorization();

      if (status == LocationAuthorizationStatus.notDetermined ||
          status == LocationAuthorizationStatus.denied) {
        status = await connectivity.requestLocationServiceAuthorization();
      }

      print("[mike][" + status.toString() + "]");

      if (status != LocationAuthorizationStatus.authorizedAlways &&
          status != LocationAuthorizationStatus.authorizedWhenInUse) {
        return false;
      }
    }

    return true;
  }

  static Future<List<String>> getConnectivity() async {
    final bool permission = await getConnectivityPermission();
    print(permission.toString());

    if (!permission) {
      return [null, null];
    }

    final Connectivity connectivity = Connectivity();
    final ConnectivityResult result = await connectivity.checkConnectivity();

    if (result != ConnectivityResult.wifi) {
      return [null, null];
    }

    final String wifiName = await connectivity.getWifiName();
    final String wifiBSSID = await connectivity.getWifiBSSID();

    print(wifiName.toString());
    print(wifiBSSID.toString());

    return [wifiName, wifiBSSID];
  }
}
