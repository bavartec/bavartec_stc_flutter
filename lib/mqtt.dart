import 'dart:io';
import 'dart:math';

import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/http.dart';
import 'package:bavartec_stc/i18n.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MQTT {
  static const String SERVER = 'mqtt.bavartec.de';
  static const int PORT = 8883;

  static String server;
  static int port;
  static String user;
  static String pass;

  static MqttClient _client;

  static int lastConnect = 0;
  static int retryCount = 0;
  static int retryWait = 0;

  static Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    server = prefs.getString('/config/mqtt/server');
    port = prefs.getInt('/config/mqtt/port');
    user = prefs.getString('/config/mqtt/user');
    pass = prefs.getString('/config/mqtt/pass');
  }

  static bool valid() {
    return server != null;
  }

  static String validate(
    final String server,
    final int port,
    final String user,
    final String pass, {
    final MyLocalizations locale,
  }) {
    if (!Regex.server.hasMatch(server)) {
      return locale.validateServer;
    }

    if (port == null || port <= 0) {
      return locale.validatePort;
    }

    if (server != SERVER) {
      return null;
    }

    if (user.length == 0) {
      return locale.validateUser;
    }

    if (pass.length == 0) {
      return locale.validatePass;
    }

    return null;
  }

  static void set(
    final String server,
    final int port,
    final String user,
    final String pass,
  ) {
    MQTT.server = server;
    MQTT.port = port;
    MQTT.user = user;
    MQTT.pass = pass;

    disconnect();
  }

  static Future<void> save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('/config/mqtt/server', server);
    prefs.setInt('/config/mqtt/port', port);
    prefs.setString('/config/mqtt/user', user);
    prefs.setString('/config/mqtt/pass', pass);
  }

  static bool connected() {
    return _client != null;
  }

  static bool maybeConnect() {
    if (connected()) {
      return true;
    }

    if (!MQTT.valid()) {
      return false;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastConnect >= retryWait) {
      MQTT.connect();
    }

    return false;
  }

  static Future<bool> connect() async {
    if (connected()) {
      return true;
    }

    lastConnect = DateTime.now().millisecondsSinceEpoch;

    final String clientId = await Platform.deviceIdentifier();
    _client = MqttClient.withPort(server, clientId, port);
    _client.secure = [443, 8883].contains(port);
    _client.onDisconnected = () {
      print(_client.connectionStatus.state);
      _client = null;
    };

    try {
      await _client.connect(user, pass);
    } on Exception {
      // MqttConnectionState.faulted
    }

    print(_client.connectionStatus.state);

    if (_client.connectionStatus.state != MqttConnectionState.connected) {
      _client = null;
      retryWait = 1 << (10 + min(retryCount, 5) as int);
      retryWait += Random().nextInt(retryWait);
      retryCount++;
      return false;
    }

    retryCount = 0;
    retryWait = 0;
    return true;
  }

  static void disconnect() async {
    if (connected()) {
      _client.disconnect();
    }

    retryCount = 0;
    retryWait = 0;
  }

  static Future<String> seed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('/debug/query/macSTA');
  }

  static void publish(final String topic, final String payload) async {
    final String device = await seed();

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _client.publishMessage('user/$user/device/$device/$topic', MqttQos.atLeastOnce, builder.payload);
  }

  static Future<String> register() async {
    final String registration = await Http.requestPostJson('https://api.mqtt.bavartec.de/register', {
      'user': user,
      'pass': pass,
    });
    return registration ?? 'no-response';
  }
}
