import 'dart:html';
import 'dart:js_util';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:dart_webrtc/src/media_stream.dart';
import 'package:js/js.dart';

void main() {
  querySelector('#output').text = 'Your Dart app is running.';
  dartWebRTCTest();
}

void dartWebRTCTest() async {
  var pc = RTCPeerConnection();
  print('connectionState: ${pc.connectionState}');
  pc.onaddstream = allowInterop((MediaStream stream) {});
  var stream = await PromiseToFuture<MediaStream>(
      navigator.mediaDevices.getDisplayMedia());
  print('getDisplayMedia: stream.id => ${stream.id}');
  stream.oninactive = allowInterop((Event event) {
    print('oninactive: stream.id => ${event.target.id}');
  });
}
