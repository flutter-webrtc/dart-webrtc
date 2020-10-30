@JS()
library dart_webrtc;

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:js/js.dart';
import 'dart:html' as html;

@JS('Element')
abstract class RTCVideoElement {
  external set srcObject(MediaStream stream);
}

@JS('window.document.querySelector')
external RTCVideoElement querySelector(String id);

RTCVideoElement ConvertToRTCVideoElement(html.VideoElement video) {
  return querySelector('#${video.id}');
}
