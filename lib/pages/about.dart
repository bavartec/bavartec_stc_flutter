import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAboutPage extends StatefulWidget {
  MyAboutPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyAboutPageState createState() => _MyAboutPageState();
}

class _MyAboutPageState extends MyState<MyAboutPage> {
  static const String appVersion = "v1.0.1";

  String deviceFirmware;

  void _onLoad() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      deviceFirmware = prefs.getString('/debug/query/version');
    });
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    final String deviceFirmware = this.deviceFirmware ?? locale().unknown;
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(25.0),
            width: 250,
            height: 250,
            child: Image.asset(
              'assets/logo.png',
              width: 200,
              height: 120,
              alignment: Alignment.center,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: 550,
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              //设置四周边框
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: Text(
              locale().aboutContent,
              textAlign: TextAlign.left,
              style: TextStyle(
                backgroundColor: const Color(0xffffffff),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            width: 550,
            padding: const EdgeInsets.all(2.0),
            child: Text(
              "App version: $appVersion",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            width: 550,
            padding: const EdgeInsets.all(2.0),
            child: Text(
              "Device firmware: $deviceFirmware",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
