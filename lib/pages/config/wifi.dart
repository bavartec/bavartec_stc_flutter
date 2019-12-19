import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/main.dart';
import 'package:bavartec_stc/wifi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyConfigWifiPage extends StatefulWidget {
  MyConfigWifiPage({Key key}) : super(key: key);

  @override
  _MyConfigWifiPageState createState() => _MyConfigWifiPageState();
}

class _MyConfigWifiPageState extends MyState<MyConfigWifiPage> {
  TextEditingController passController = TextEditingController();

  String ssid;
  String bssid;
  String pass = '';
  bool showPass = false;

  bool isSubmitting = false;

  void _onLoad() async {
    periodicSafe(Duration(seconds: 1), () async {
      if (!await _refreshWifi()) {
        navigate(null);
        return false;
      }

      return true;
    });
  }

  Future<bool> _refreshWifi() async {
    final List<String> connectivity = await WiFi.getConnectivity();

    if (connectivity == null) {
      toast(locale().errorPermissionRequired);
      return false;
    }

    final String wifiName = connectivity[0];
    final String wifiBSSID = connectivity[1];

    final WiFi config = await WiFi.load() ?? WiFi();

    setState(() {
      if (wifiName == config.ssid && wifiName != ssid && wifiName != null) {
        pass = config.pass;
        passController.value = new TextEditingValue(text: pass);
      }

      ssid = wifiName;
      bssid = wifiBSSID;
    });
    return true;
  }

  void _onSubmit() async {
    indicateNull();

    if (ssid == null) {
      toast(locale().configWifiConnect);
      return;
    }

    if (isSubmitting) {
      return;
    }

    final WiFi config = WiFi(
      ssid: ssid,
      bssid: bssid,
      pass: pass,
    );

    isSubmitting = true;
    final bool success = await indicateSuccess(config.submit());
    isSubmitting = false;

    if (!success) {
      toast(locale().configWifiFail);
      return;
    }

    await WiFi.save(config);

    toast(locale().configWifiOk);
    await MyAppState.saveDebugQuery();
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          locale().ssid,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(ssid ?? "</>"),
        ),
        Text(
          locale().password,
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
                onChanged: (final String password) {
                  indicateNull();
                  setState(() {
                    this.pass = password;
                  });
                },
                textAlign: TextAlign.center,
              ),
              CheckboxListTile(
                value: showPass,
                onChanged: (final bool value) {
                  indicateNull();
                  setState(() {
                    this.showPass = value;
                  });
                },
                title: Text(locale().showPassword),
                controlAffinity: ListTileControlAffinity.platform,
              ),
            ],
          ),
        ),
        OutlineButton(
          borderSide: const BorderSide(),
          onPressed: _onSubmit,
          child: Text(locale().submit),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(locale().configWifiSmartconfig),
        ),
      ],
    );
  }
}
