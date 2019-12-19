import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/indicator.dart';
import 'package:bavartec_stc/i18n.dart';
import 'package:bavartec_stc/mqtt.dart';
import 'package:bavartec_stc/pages/about.dart';
import 'package:bavartec_stc/pages/config/mqtt.dart';
import 'package:bavartec_stc/pages/config/sensor.dart';
import 'package:bavartec_stc/pages/config/wifi.dart';
import 'package:bavartec_stc/pages/control.dart';
import 'package:bavartec_stc/pages/debug/listen.dart';
import 'package:bavartec_stc/pages/debug/query.dart';
import 'package:bavartec_stc/pages/feedback.dart';
import 'package:bavartec_stc/pages/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static Future<bool> confirm(final BuildContext context, final String text) {
    final MyLocalizations locale = MyLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text(locale.confirmationRequired),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(locale.ok),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text(locale.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  static void doEspRestartConfirm(final BuildContext context) async {
    final MyLocalizations locale = MyLocalizations.of(context);
    final bool confirmed = await confirm(context, locale.confirmationRestart);

    if (!confirmed) {
      return;
    }

    Api.restart();
  }

  static void doEspUpdateConfirm(final BuildContext context) async {
    final MyLocalizations locale = MyLocalizations.of(context);
    final bool confirmed = await confirm(context, locale.confirmationUpdate);

    if (!confirmed) {
      return;
    }

    Api.update();
  }

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
    periodicSafe(Duration(seconds: 1), () async {
      indicate(mdns: (await Api.mdnsQuery(idle: true)) != null ? Light.green : Light.red);
      return mounted;
    });
    periodicSafe(Duration(seconds: 1), () async {
      indicate(mqtt: MQTT.maybeConnect() ? Light.green : Light.red);
      return mounted;
    });
    periodicSafe(Duration(seconds: 10), () async {
      if (lights.mdns == Light.green) {
        if (await saveDebugQuery()) {
          toast(
            locale().seeded,
            innerContext: innerContext,
          );
          return false;
        }
      }

      return mounted;
    });
  }

  static Future<bool> saveDebugQuery() async {
    final Map<String, String> queryData = await Api.debugQuery();

    if (queryData == null) {
      return false;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('/debug/query/keys', queryData.keys.toList(growable: false));
    queryData.entries.forEach((final MapEntry<String, String> entry) {
      prefs.setString('/debug/query/${entry.key}', entry.value);
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return WillPopScope(
      child: Navigator(
        onGenerateRoute: (final RouteSettings settings) {
          return MaterialPageRoute<dynamic>(
            builder: (final BuildContext context) {
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
                builder: (final BuildContext context) {
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
              MyIndex(route: '/about'),
              MyIndex(route: '/config'),
              MyIndex(route: '/control'),
              MyIndex(route: '/debug'),
              MyIndex(route: '/feedback'),
              MyIndex(
                route: '/privacy',
                action: (final BuildContext context) {
                  launch("https://www.bavartec.de/privacy/");
                },
              ),
            ].map((final MyIndex index) {
              return ListTile(
                title: Text(locale().routes[index.route]),
                onTap: () {
                  if (index.action != null) {
                    navigator().pop();
                    index.action(context);
                    return;
                  }

                  indicate(sync: Light.blue);
                  navigator().popAndPushNamed(index.route);
                },
              );
            }).toList(growable: false),
          ),
        ),
      ),
    );
  }
}

Map<String, Widget> routes = {
  '/': MyIndexPage([
    MyIndex(route: '/config'),
    MyIndex(route: '/control'),
    MyIndex(route: '/debug'),
  ]),
  '/about': MyAboutPage(),
  '/config': MyIndexPage([
    MyIndex(route: '/config/wifi'),
    MyIndex(route: '/config/sensor'),
    MyIndex(route: '/config/mqtt'),
  ]),
  '/config/mqtt': MyConfigMQTTPage(),
  '/config/sensor': MyConfigSensorPage(),
  '/config/wifi': MyConfigWifiPage(),
  '/control': MyControlPage(),
  '/debug': MyIndexPage([
    MyIndex(route: '/debug/listen'),
    MyIndex(route: '/debug/query'),
    MyIndex(
      route: '/restart',
      action: MyApp.doEspRestartConfirm,
    ),
    MyIndex(
      route: '/update',
      action: MyApp.doEspUpdateConfirm,
    ),
  ]),
  '/debug/listen': MyListenPage(),
  '/debug/query': MyQueryPage(),
  '/feedback': MyFeedbackPage(),
};
