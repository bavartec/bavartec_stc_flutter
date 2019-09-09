import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/pages/config/mqtt.dart';
import 'package:bavartec_stc/pages/config/sensor.dart';
import 'package:bavartec_stc/pages/config/wifi.dart';
import 'package:bavartec_stc/pages/control.dart';
import 'package:bavartec_stc/pages/debug/listen.dart';
import 'package:bavartec_stc/pages/debug/query.dart';
import 'package:bavartec_stc/pages/index.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Smart Thermo Control',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(
          highlightColor: Colors.blue[100],
          splashColor: Colors.blue[200],
          height: 48.0,
          minWidth: 128.0,
        ),
        textTheme: TextTheme(
          body1: TextStyle(
            color: Colors.black87,
            fontSize: 16.0,
            height: 1.1,
          ),
          button: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            height: 1.0,
          ),
        ),
      ),
      home: MyIndexPage(
        title: 'STC Home',
        prefix: '/',
        labels: const <String>["Config", "Control", "Debug"],
      ),
      routes: {
        '/config': (context) => MyIndexPage(
              title: 'STC Config',
              prefix: '/config/',
              labels: const <String>["WiFi", "Sensor", "MQTT"],
            ),
        '/config/mqtt': (context) => MyConfigMQTTPage(title: 'STC Config MQTT'),
        '/config/sensor': (context) => MyConfigSensorPage(title: 'STC Config Sensor'),
        '/config/wifi': (context) => MyConfigWifiPage(title: 'STC Config WiFi'),
        '/control': (context) => MyControlPage(title: 'STC Control'),
        '/debug': (context) => MyIndexPage(
              title: 'STC Debug',
              prefix: '/debug/',
              labels: const <String>["Listen", "Query", "Restart", "Update"],
              actions: {
                'restart': Api.restart,
                'update': Api.update,
              },
            ),
        '/debug/listen': (context) => MyListenPage(title: 'STC Listen'),
        '/debug/query': (context) => MyQueryPage(title: 'STC Query'),
      },
    );
  }
}
