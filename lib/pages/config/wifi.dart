import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartconfig/smartconfig.dart';

class MyConfigWifiPage extends StatefulWidget {
  MyConfigWifiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyConfigWifiPageState createState() => _MyConfigWifiPageState();
}

class _MyConfigWifiPageState extends MyState<MyConfigWifiPage> {
  TextEditingController passController = TextEditingController();

  bool legacy = false;

  String ssid;
  String bssid;
  String pass = '';
  bool showPass = false;

  bool isSubmitting = false;

  void _onLoad() async {
    indicate(null);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String ssid = prefs.getString("/config/wifi/ssid");
    final String pass = prefs.getString("/config/wifi/pass") ?? '';

    String wifiName;
    String wifiBSSID;

    if (legacy) {
      wifiName = await Platform.homeSSID();
    } else {
      final List<String> connectivity = await getConnectivity();
      wifiName = connectivity[0];
      wifiBSSID = connectivity[1];
    }

    if (wifiName == null) {
      toast("permission required");
      return;
    }

    setState(() {
      if (ssid == wifiName) {
        this.ssid = ssid;
        this.pass = pass;
        passController.value = new TextEditingValue(text: pass);
      } else {
        this.ssid = wifiName;
      }

      this.bssid = wifiBSSID;
    });
  }

  void _onSubmit() async {
    if (ssid == null) {
      indicate(null);
      toast("please select SSID");
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("/config/wifi/ssid", ssid);
    prefs.setString("/config/wifi/pass", pass);

    if (isSubmitting) {
      return;
    }

    isSubmitting = true;

    if (legacy) {
      await indicateSuccess(Platform.apConfig(ssid, pass));
    } else {
      await indicateSuccess(smartConfig(ssid, bssid, pass));
    }

    isSubmitting = false;
  }

  Future<bool> smartConfig(final String ssid, final String bssid, final String pass) async {
    return (await Smartconfig.start(ssid, bssid, pass)) || (await Api.mdnsQuery()) != null;
  }

  Future<bool> getConnectivityPermission() async {
    if (Platform.isAndroid) {
      return Platform.requireLocation();
    }

    if (Platform.isIOS) {
      final Connectivity connectivity = Connectivity();
      LocationAuthorizationStatus status = await connectivity.getLocationServiceAuthorization();

      if (status == LocationAuthorizationStatus.notDetermined) {
        status = await connectivity.requestLocationServiceAuthorization();
      }

      if (status != LocationAuthorizationStatus.authorizedAlways &&
          status != LocationAuthorizationStatus.authorizedWhenInUse) {
        return false;
      }
    }

    return true;
  }

  Future<List<String>> getConnectivity() async {
    final bool permission = await getConnectivityPermission();

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
    return [wifiName, wifiBSSID];
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return scaffold(
      widget.title,
      Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "SSID",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(ssid ?? "</>"),
            ),
            const Text(
              "Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    autocorrect: false,
                    controller: passController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(63),
                    ],
                    obscureText: !showPass,
                    onChanged: (password) {
                      indicate(null);
                      setState(() {
                        this.pass = password;
                      });
                    },
                    textAlign: TextAlign.center,
                  ),
                  CheckboxListTile(
                    value: showPass,
                    onChanged: (value) {
                      indicate(null);
                      setState(() {
                        this.showPass = value;
                      });
                    },
                    title: const Text("Show Password"),
                    controlAffinity: ListTileControlAffinity.platform,
                  ),
                ],
              ),
            ),
            OutlineButton(
              borderSide: const BorderSide(),
              onPressed: _onSubmit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
