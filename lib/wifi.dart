import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
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

  static bool valid() {
    return WiFi.ssid != null;
  }

  static void reset() {
    WiFi.ssid = null;
    WiFi.bssid = null;
    WiFi.pass = null;
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

  static Future<bool> submit() async {
    return (await Smartconfig.start(ssid, bssid, pass)) != null || (await Api.mdnsQuery()) != null;
  }

  static Future<bool> getConnectivityPermission() async {
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

      LocationAuthorizationStatus status = await connectivity.getLocationServiceAuthorization();

      if (status == LocationAuthorizationStatus.notDetermined || status == LocationAuthorizationStatus.denied) {
        status = await connectivity.requestLocationServiceAuthorization();
      }

      if (status != LocationAuthorizationStatus.authorizedAlways &&
          status != LocationAuthorizationStatus.authorizedWhenInUse) {
        return false;
      }
    }

    return true;
  }

  static Future<List<String>> getConnectivity() async {
    final bool permission = await getConnectivityPermission();

    if (!permission) {
      return null;
    }

    final Connectivity connectivity = Connectivity();
    final ConnectivityResult result = await connectivity.checkConnectivity();

    if (result != ConnectivityResult.wifi) {
      return [null, null];
    }

    final String wifiName = await connectivity.getWifiName();
    final String wifiBSSID = await connectivity.getWifiBSSID();

    return [wifiName, wifiBSSID];
  }
}
