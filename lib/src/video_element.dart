@JS()
library dart_webrtc;

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:js/js.dart';
import 'dart:html' as html;

@JS('Element')
abstract class RTCVideoElement {
  external set srcObject(MediaStream stream);
}

@JS('Document')
class Document {
  external RTCVideoElement querySelector(String id);
}

@JS('window.document')
class Window {
  external Document get document;
}

@JS('window')
external Window get window;

RTCVideoElement ConvertToRTCVideoElement(html.VideoElement video) {
  return window.document.querySelector('#${video.id}');
}
