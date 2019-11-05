import 'dart:async';

import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/http.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:multicast_dns/multicast_dns.dart';

const String discovery_service = '_googlecast._tcp';

class Api {
  static Future<String> mdnsQuery() async {
    if (Platform.isAndroid || true) {
      return await Platform.discoverWifi();
    }

    final String name = 'smart-thermo-control._http._tcp.local';
    final ResourceRecordQuery query = ResourceRecordQuery.addressIPv4(name);

    final MDnsClient client = MDnsClient();
    await client.start();

    await for (final IPAddressResourceRecord record in client.lookup<IPAddressResourceRecord>(query)) {
      client.stop();
      return 'http://${record.address.address}';
    }

    client.stop();
    return null;
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
      'type': type == null ? '' : type.toString(),
    });
    print("configInput -> $result");
    return result;
  }

  static Future<bool> configMQTT(final String server, final int port, final String user, final String pass) async {
    print("configMQTT <- $server | $port | $user | $pass");
    final String result = await _request(true, '/config/mqtt', {
      'server': server,
      'port': port.toString(),
      'user': user,
      'pass': pass,
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
      'enabled': enabled == null ? '' : enabled.toString(),
      'noControlValue': noControlValue == null ? '' : (noControlValue + KELVIN).toString(),
      'controlValue': controlValue == null ? '' : (controlValue + KELVIN).toString(),
      'weekly': weekly == null ? '' : weekly.join(),
      'nightly': nightly == null ? '' : nightly.join(),
      'nightValue': nightValue == null ? '' : (nightValue + KELVIN).toString(),
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

  static Future<bool> submitFeedback(final String url, final String msg) async {
    print("submit feedback");
    final String result = await _request(true, url, {
      'feedback': msg,
    });
    final bool success = result != null;
    print("submit -> $success");
    return success;
  }
}
