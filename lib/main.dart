import 'dart:async';

import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/indicator.dart';
import 'package:bavartec_stc/i18n.dart';
import 'package:bavartec_stc/mqtt.dart';
import 'package:bavartec_stc/pages/config/mqtt.dart';
import 'package:bavartec_stc/pages/config/sensor.dart';
import 'package:bavartec_stc/pages/config/wifi.dart';
import 'package:bavartec_stc/pages/control.dart';
import 'package:bavartec_stc/pages/debug/listen.dart';
import 'package:bavartec_stc/pages/debug/query.dart';
import 'package:bavartec_stc/pages/index.dart';
import 'package:bavartec_stc/wifi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: "Smart Thermo Control",
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
      localizationsDelegates: [
        const MyLocalizationsDelegate(),
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      home: new MyAppPage(),
    );
  }
}

class MyAppPage extends StatefulWidget {
  MyAppPage({
    Key key,
  }) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState<T extends StatefulWidget> extends MyBaseState<T> {
  BuildContext innerContext;
  final Lights lights = Lights(
    mdns: Light.yellow,
    mqtt: Light.yellow,
    sync: Light.blue,
  );

  Indicator indicator() {
    Color color;

    switch (lights.shine()) {
      case Light.red:
        color = const Color(0xffff0000);
        break;
      case Light.yellow:
        color = const Color(0xffffff00);
        break;
      case Light.green:
        color = const Color(0xff00ff00);
        break;
      case Light.blue:
        color = null;
        break;
    }

    return Indicator(color: color);
  }

  void indicate({
    final Light mdns,
    final Light mqtt,
    final Light sync,
  }) {
    setState(() {
      lights.mdns = mdns ?? lights.mdns;
      lights.mqtt = mqtt ?? lights.mqtt;
      lights.sync = sync ?? lights.sync;
    });
  }

  void _onLoad() async {
    await MQTT.load();
    await WiFi.load();

    if (MQTT.valid()) {
      MQTT.connect();
    }

    periodic(Duration(seconds: 5), () async {
      final bool localLink = (await Api.mdnsQuery()) != null;
      final bool remoteLink = MQTT.connected();
      indicate(mdns: localLink ? Light.green : Light.red);
      indicate(mqtt: remoteLink ? Light.green : Light.red);
    });
  }

  void periodic(final Duration duration, Future<void> callback()) {
    Timer.run(() async {
      await callback();
      Timer(duration, () => periodic(duration, callback));
    });
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) {
              return scaffold(context, settings.name);
            },
          );
        },
      ),
      onWillPop: () async {
        indicate(sync: Light.blue);
        navigator().maybePop();
        return false;
      },
    );
  }

  NavigatorState navigator() => Navigator.of(innerContext);

  Widget scaffold(final BuildContext context, final String path) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(locale().routes[path]),
            Container(
              width: 20,
              height: 20,
              child: indicator(),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(1),
              child: Builder(
                builder: (BuildContext context) {
                  this.innerContext = context;
                  return routes[path];
                },
              ),
            ),
          ),
        ),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              MyIndex(label: "Config", route: '/config'),
              MyIndex(label: "Control", route: '/control'),
              MyIndex(label: "Debug", route: '/debug'),
            ]
                .map((index) => ListTile(
                      title: Text(index.label),
                      onTap: () {
                        navigator().popAndPushNamed(index.route);
                      },
                    ))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

Map<String, Widget> routes = {
  '/': MyIndexPage([
    MyIndex(label: "Config", route: '/config'),
    MyIndex(label: "Control", route: '/control'),
    MyIndex(label: "Debug", route: '/debug'),
  ]),
  '/config': MyIndexPage([
    MyIndex(label: "WiFi", route: '/config/wifi'),
    MyIndex(label: "Sensor", route: '/config/sensor'),
    MyIndex(label: "MQTT", route: '/config/mqtt'),
  ]),
  '/config/mqtt': MyConfigMQTTPage(),
  '/config/sensor': MyConfigSensorPage(),
  '/config/wifi': MyConfigWifiPage(),
  '/control': MyControlPage(),
  '/debug': MyIndexPage([
    MyIndex(label: "Listen", route: '/debug/listen'),
    MyIndex(label: "Query", route: '/debug/query'),
    MyIndex(label: "Restart", action: Api.restart),
    MyIndex(label: "Update", action: Api.update),
  ]),
  '/debug/listen': MyListenPage(),
  '/debug/query': MyQueryPage(),
};
