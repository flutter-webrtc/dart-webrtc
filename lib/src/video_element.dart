@JS()
library dart_webrtc;

import 'dart:html' as html;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

class RTCVideoElement {
  RTCVideoElement() {
    _html = html.VideoElement()
      ..autoplay = true
      ..muted = false
      ..controls = false
      ..style.objectFit = 'contain' // contain or cover
      ..style.border = 'none'
      ..id = 'dart-webrtc-video-${_idx++}';

    // Allows Safari iOS to play the video inline
    _html.setAttribute('playsinline', 'true');
  }
  static int _idx = 0;
  html.VideoElement _html;
  Element _rtc;

  html.VideoElement get htmlElement => _html;

  set srcObject(MediaStream stream) {
    _rtc = querySelector('#${_html.id}');
    _rtc.srcObject = stream;
  }

  set muted(bool v) => _html.muted = v;

  set autoplay(bool v) => _html.autoplay = v;

  set controls(bool v) => _html.controls = v;
}

@JS('Element')
abstract class Element {
  external set srcObject(MediaStream stream);
}

@JS('window.document.querySelector')
external Element querySelector(String id);
