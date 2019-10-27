import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/platform.dart';
import 'package:http/http.dart';
import 'package:multicast_dns/multicast_dns.dart';


import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';
//import 'package:flutter/material.dart';
import 'dart:async';

const String discovery_service = "_googlecast._tcp";

class Api {

  static Future<String> mdnsQuery() async {
    //if (Platform.isAndroid) {
      return await Platform.discoverWifi();
    //}

    final String name = "smart-thermo-control._http._tcp.local";

    final ResourceRecordQuery query = ResourceRecordQuery.addressIPv4(name);

    final MDnsClient client = MDnsClient();
    await client.start();

    await for (final IPAddressResourceRecord record in client.lookup<IPAddressResourceRecord>(query)) {
      client.stop();
      print("111");
      return "http://" + record.address.address;
    }
    print("222");
    client.stop();
//    final String name1 = "smart-thermo-control._http._tcp";
//    if (discoveryCallbacks == null) {
//      discoveryCallbacks = new DiscoveryCallbacks(
//        onDiscovered: (ServiceInfo info){
//          print("Discovered ${info.toString()}");
//        },
//        onDiscoveryStarted: (){
//          print("Discovery started");
//        },
//        onDiscoveryStopped: (){
//          print("Discovery stopped");
//        },
//        onResolved: (ServiceInfo info){
//          print("Resolved Service ${info.toString()}");
//        },
//      );
//    }
//
//
//    if (fmp == null){
//      fmp = new FlutterMdnsPlugin(discoveryCallbacks: discoveryCallbacks);
//      print("1111");
//    }
//
//    // cannot directly start discovery, have to wait for ios to be ready first...
//    Timer(Duration(seconds: 3), () => fmp.startDiscovery(name));
    // mdns.startDiscovery(serviceType);
    return null;
  }

//  FutureOr<bool> onTimeout(){
//
//    Fluttertoast.showToast(
//        msg: "request time out...",
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.CENTER,
//        timeInSecForIos: 1,
//        backgroundColor: Color(0xe74c3c),
//        textColor: Color(0xffffff)
//    );
//  }
  static Future<String> _request(final bool isPost, final String url, final Map<String, String> data) async {
    final String service = await mdnsQuery();
    
    if (service == null) {
      return null;
    }
    //else{
    //  return service;
    //}

    String dataEncoded = "";

    if (data != null && data.isNotEmpty) {
      dataEncoded = data.entries.map((entry) => entry.key + '=' + entry.value).join('&');
    }

    Response response;

    if (isPost) {
      response = await post(service + url, body: dataEncoded, headers: {
        "charset": "utf-8",
        "content-type": "application/x-www-form-urlencoded",
        "charset": dataEncoded.length.toString(),
      }).timeout(Duration(seconds: 10));
    } else if (dataEncoded.isNotEmpty) {
      response = await get(service + url + '?' + dataEncoded);
    } else {
      response = await get(service + url);
    }

    switch (response.statusCode) {
      case 200:
        return response.body;
      case 204:
        return "";
      default:
        return null;
    }
  }

  static Future<String> configInput(final String type) async {
    print("configInput <- $type");
    final String result = await _request(true, "/config/input", {
      'type': type == null ? "" : type.toString(),
    });
    print("configInput -> $result");
    return result;
  }

  static Future<bool> configMQTT(final String server, final int port, final String user, final String pass) async {
    print("configMQTT <- $server | $port | $user | $pass");
    final String result = await _request(true, "/config/mqtt", {
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
    final String result = await _request(true, "/config/sensor", {
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
    final String result = await _request(true, "/control", {
      'enabled': enabled == null ? "" : enabled.toString(),
      'noControlValue': noControlValue == null ? "" : (noControlValue + KELVIN).toString(),
      'controlValue': controlValue == null ? "" : (controlValue + KELVIN).toString(),
      'weekly': weekly == null ? "" : weekly.join(),
      'nightly': nightly == null ? "" : nightly.join(),
      'nightValue': nightValue == null ? "" : (nightValue + KELVIN).toString(),
    });
    final bool success = result != null;
    print("control -> $success");
    return success;
  }

  static Future<String> debugListen() async {
    print("listen");
    final String result = await _request(false, "/debug/listen", null);
    print("listen -> $result");
    return result;
  }

  static Future<String> debugQuery() async {
    print("query");
    final String result = await _request(false, "/debug/query", null);
    print("query -> $result");
    return result;
  }

  static Future<bool> restart() async {
    print("restart");
    final String result = await _request(true, "/restart", null);
    final bool success = result != null;
    print("restart -> $success");
    return success;
  }

  static Future<bool> update() async {
    print("update");
    final String result = await _request(true, "/update", null);
    final bool success = result != null;
    print("update -> $success");
    return success;
  }

  static Future<bool> submitFeedback(String url, String msg) async {
    print("submit feedback");

    final String result = await _request(true, url, {'feedback':msg});
    final bool success = result != null;
    print("submit -> $success");
    return success;
  }
}
