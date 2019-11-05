import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

class Http {
  static String urlEncode(final Map<String, String> data) {
    return data.entries.map((entry) => entry.key + '=' + entry.value).join('&');
  }

  static Future<Response> getRequest(final String url, final Map<String, String> data) {
    return get(data == null || data.isEmpty ? url : url + '?' + urlEncode(data));
  }

  static Future<Response> postRequest(final String url, final String data, {final String type = 'text/plain'}) {
    return post(url, body: data, headers: {
      'charset': 'utf-8',
      'content-type': type,
      'content-length': data.length.toString(),
    });
  }

  static Future<Response> postFormRequest(final String url, final Map<String, String> data) {
    return postRequest(url, urlEncode(data), type: 'application/x-www-form-urlencoded');
  }

  static Future<Response> postJsonRequest(final String url, final Map<String, String> data) {
    return postRequest(url, jsonEncode(data), type: 'application/json');
  }

  static Future<String> requestGet(final String url, final Map<String, String> data) {
    return response(getRequest(url, data));
  }

  static Future<String> requestPostForm(final String url, final Map<String, String> data) {
    return response(postFormRequest(url, data));
  }

  static Future<String> requestPostJson(final String url, final Map<String, String> data) {
    return response(postJsonRequest(url, data));
  }

  static Future<String> response(final Future<Response> request,
      {final Duration timeout = const Duration(seconds: 5)}) async {
    final Response response = await request.timeout(timeout, onTimeout: () => null);

    if (response == null) {
      return null;
    }

    switch (response.statusCode) {
      case 200:
        return response.body;
      case 204:
        return '';
      default:
        return null;
    }
  }
}
