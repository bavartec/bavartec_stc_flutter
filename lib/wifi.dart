import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartconfig/smartconfig.dart';

class WiFi {
  WiFi({
    this.ssid,
    this.bssid,
    this.pass,
  });

  String ssid;
  String bssid;
  String pass;

  static Future<WiFi> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final WiFi config = WiFi();

    config.ssid = prefs.getString('/config/wifi/ssid');
    config.pass = prefs.getString('/config/wifi/pass');

    return config.ssid == null ? null : config;
  }

  static Future<void> save(final WiFi config) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('/config/wifi/ssid', config?.ssid);
    prefs.setString('/config/wifi/pass', config?.pass);
  }

  Future<bool> submit() async {
    if ((await Smartconfig.start(ssid, bssid, pass)) != null) {
      return true;
    }

    if ((await Api.mdnsQuery()) != null) {
      return true;
    }

    return false;
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
