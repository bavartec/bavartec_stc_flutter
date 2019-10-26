import 'dart:async';
import 'dart:io' as dartio;

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

class Platform {
  static const platform = MethodChannel('bavartec');

  static final isAndroid = dartio.Platform.isAndroid;
  static final isIOS = dartio.Platform.isIOS;

  static Future<bool> apConfig(final String ssid, final String pass) async {
    final bool location = await requireLocation();
    return location &&
        await platform.invokeMethod('apConfig', {
          'ssid': ssid,
          'pass': pass,
        });
  }

  static Future<String> deviceIdentifier() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (isAndroid) {
      return (await deviceInfo.androidInfo).androidId;
    }

    if (isIOS) {
      return (await deviceInfo.iosInfo).identifierForVendor;
    }

    return null;
  }

  static Future<String> discoverWifi() async {
    return await platform.invokeMethod('discoverWifi');
  }

  static Future<String> homeSSID() async {
    final bool location = await requireLocation();
    return location ? await platform.invokeMethod('homeSSID') : null;
  }

  static Future<bool> requireLocation() async {
    return await platform.invokeMethod('requireLocation');
  }
}
