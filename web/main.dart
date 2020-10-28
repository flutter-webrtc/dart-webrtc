import 'dart:html';

import 'package:dart_webrtc/dart_webrtc.dart';

void main() {
  querySelector('#output').text = 'Your Dart app is running.';
  var pc = RTCPeerConnection();
  print(pc.connectionState);
}
