import 'dart:js_util' as jsutil;
import 'dart:math';

import 'package:web/web.dart' as web;

bool get isMobile {
  final toMatch = [
    'Android',
    'webOS',
    'iPhone',
    'iPad',
    'iPod',
    'BlackBerry',
    'Windows Phone'
  ];
  return toMatch.indexWhere((device) => web.window.navigator.userAgent
          .contains(RegExp(device, caseSensitive: false))) !=
      -1;
}

String randomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rnd = Random();
  final buf = StringBuffer();
  for (var i = 0; i < length; i++) {
    buf.write(chars[rnd.nextInt(chars.length)]);
  }
  return buf.toString();
}

web.RTCConfiguration convertRTCConfiguration(
    Map<String, dynamic> configuration) {
  final object = jsutil.newObject();
  for (var key in configuration.keys) {
    if (key == 'iceServers') {
      final servers = configuration[key] as List<dynamic>;
      final jsServers = <web.RTCIceServer>[];
      for (var server in servers) {
        var iceServer = web.RTCIceServer(urls: server['urls']);
        if (server['username'] != null) {
          iceServer.username = server['username'];
        }
        if (server['credential'] != null) {
          iceServer.credential = server['credential'];
        }
        jsServers.add(iceServer);
      }
      jsutil.setProperty(object, key, jsServers);
    } else {
      jsutil.setProperty(object, key, configuration[key]);
    }
  }
  return object as web.RTCConfiguration;
}
