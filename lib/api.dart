import 'dart:async';

import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/http.dart';
import 'package:bavartec_stc/mqtt.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:bavartec_stc/wifi.dart';

const String discovery_service = '_googlecast._tcp';

class Api {
  static Future<bool> earlyAbort() async {
    final WiFi config = await WiFi.load();

    if (config == null) {
      return true;
    }

    final List<String> connectivity = await WiFi.getConnectivity();

    if (connectivity == null) {
      return false;
    }

    final String wifiName = connectivity[0];
    return wifiName != config.ssid;
  }

  static Future<String> mdnsQuery({
    final bool idle = false,
  }) async {
    if (idle && await earlyAbort()) {
      return null;
    }

    return await Platform.discoverWifi();
  }

  static Future<String> _request(final bool isPost, final String path, final Map<String, String> data) async {
    final String service = await mdnsQuery();

    if (service == null) {
      return null;
    }

    if (isPost) {
      return Http.requestPostForm(service + path, data);
    } else {
      return Http.requestGet(service + path, data);
    }
  }

  static Future<String> configInput(final String type) async {
    print("configInput <- $type");
    final String result = await _request(true, '/config/input', {
      'type': type?.toString(),
    });
    print("configInput -> $result");
    return result;
  }

  static Future<bool> configMQTT(final MQTT config) async {
    print("configMQTT <- ${config?.server} | ${config?.port} | ${config?.user} | ${config?.pass}");
    final String result = await _request(true, '/config/mqtt', {
      'server': config?.server,
      'port': config?.port?.toString(),
      'user': config?.user,
      'pass': config?.pass,
    });
    final bool success = result != null;
    print("configMQTT -> $success");
    return success;
  }

  static Future<String> configSensor(final String sensor) async {
    print("configSensor <- $sensor");
    final String result = await _request(true, '/config/sensor', {
      'sensor': sensor,
    });
    print("configSensor -> $result");
    return result;
  }

  static Future<bool> control(
      {final bool enabled,
      final double noControlValue,
      final double controlValue,
      final List<String> weekly,
      final List<String> nightly,
      final double nightValue}) async {
    print("control <- $enabled | $noControlValue | $controlValue | $weekly | $nightly | $nightValue");
    final String result = await _request(true, '/control', {
      'enabled': enabled?.toString(),
      'noControlValue': noControlValue == null ? null : (noControlValue + KELVIN).toString(),
      'controlValue': controlValue == null ? null : (controlValue + KELVIN).toString(),
      'weekly': weekly?.join(),
      'nightly': nightly?.join(),
      'nightValue': nightValue == null ? null : (nightValue + KELVIN).toString(),
    });
    final bool success = result != null;
    print("control -> $success");
    return success;
  }

  static Future<Map<String, String>> debugListen() async {
    print("listen");
    final String result = await _request(false, '/debug/listen', null);
    final bool success = result != null;
    print("listen -> $result");
    return success ? Uri.splitQueryString(result) : null;
  }

  static Future<Map<String, String>> debugQuery() async {
    print("query");
    final String result = await _request(false, '/debug/query', null);
    final bool success = result != null;
    print("query -> $result");
    return success ? Uri.splitQueryString(result) : null;
  }

  static Future<bool> restart() async {
    print("restart");
    final String result = await _request(true, '/restart', null);
    final bool success = result != null;
    print("restart -> $success");
    return success;
  }

  static Future<bool> update() async {
    print("update");
    final String result = await _request(true, '/update', null);
    final bool success = result != null;
    print("update -> $success");
    return success;
  }

  static Future<bool> submitFeedback(final String message, final String contactMethod) async {
    print("submitFeedback <- $message | $contactMethod");
    final String result = await Http.requestPostJson('https://www.bavartec.de/php/feedback.php', {
      'message': message,
      'contactMethod': contactMethod,
    });
    final bool success = result != null;
    print("submitFeedback -> $success");
    return success;
  }
}
