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

  static MqttClient _client;

  static int lastConnect = 0;
  static int retryCount = 0;
  static int retryWait = 0;

  MQTT({
    this.server,
    this.port,
    this.user,
    this.pass,
  });

  String server = '';
  int port;
  String user = '';
  String pass = '';

  static Future<MQTT> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final MQTT config = MQTT();

    config.server = prefs.getString('/config/mqtt/server');
    config.port = prefs.getInt('/config/mqtt/port');
    config.user = prefs.getString('/config/mqtt/user');
    config.pass = prefs.getString('/config/mqtt/pass');

    return config.server == null ? null : config;
  }

  String validate(final MyLocalizations locale) {
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

  static Future<void> save(final MQTT config) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('/config/mqtt/server', config?.server);
    prefs.setInt('/config/mqtt/port', config?.port);
    prefs.setString('/config/mqtt/user', config?.user);
    prefs.setString('/config/mqtt/pass', config?.pass);

    disconnect();
  }

  static bool connected() {
    return _client != null && _client.connectionStatus.state == MqttConnectionState.connected;
  }

  static bool maybeConnect() {
    if (connected()) {
      return true;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastConnect >= retryWait) {
      connect();
    }

    return false;
  }

  static Future<bool> connect() async {
    if (_client != null) {
      return _client.connectionStatus.state == MqttConnectionState.connected;
    }

    lastConnect = DateTime.now().millisecondsSinceEpoch;

    final MQTT config = await load();
    final String clientId = await Platform.deviceIdentifier();

    _client = MqttClient.withPort(config.server, clientId, config.port);
    _client.secure = [443, 8883].contains(config.port);
    _client.onDisconnected = () {
      print(_client.connectionStatus.state);
      _client = null;
    };

    try {
      await _client.connect(config.user, config.pass);
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
    final MQTT config = await load();
    final String device = await seed();

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client.publishMessage('user/${config.user}/device/$device/$topic', MqttQos.atLeastOnce, builder.payload);
  }

  Future<String> register() async {
    final String registration = await Http.requestPostJson('https://api.mqtt.bavartec.de/register', {
      'user': user,
      'pass': pass,
    });
    return registration ?? 'no-response';
  }

  Future<String> unregister() async {
    final String unregistration = await Http.requestPostJson('https://api.mqtt.bavartec.de/unregister', {
      'user': user,
      'pass': pass,
    });
    return unregistration ?? 'no-response';
  }
}
