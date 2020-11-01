@JS()
library dart_webrtc;

import 'dart:html' as html;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS('Element')
abstract class RTCVideoElement {
  external set srcObject(MediaStream stream);
}

@JS('window.document.querySelector')
external RTCVideoElement querySelector(String id);

RTCVideoElement ConvertToRTCVideoElement(html.VideoElement video) {
  return querySelector('#${video.id}');
}
