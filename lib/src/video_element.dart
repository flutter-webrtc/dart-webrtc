@JS()
library dart_webrtc;

import 'dart:html' as html;

import 'package:js/js.dart';

import 'media_stream.dart';

class RTCVideoElement {
  RTCVideoElement() {
    _html = html.VideoElement()
      ..autoplay = true
      ..muted = false
      ..controls = false
      ..style.objectFit = 'contain'
      ..style.border = 'none'
      ..id = 'dart-webrtc-video-${_idx++}';

    // Allows Safari iOS to play the video inline
    _html.setAttribute('playsinline', 'true');
  }
  static int _idx = 0;
  Element _rtc;
  MediaStream _stream;

  html.VideoElement _html;
  html.VideoElement get htmlElement => _html;

  /// contain or cover
  set objectFit(String fit) => _html.style.objectFit = fit;

  set srcObject(MediaStream stream) {
    _stream = stream;
    _rtc = querySelector('#${_html.id}');
    _rtc.srcObject = _stream?.js;
  }

  int get videoWidth => _html.videoWidth;

  int get videoHeight => _html.videoHeight;

  Stream<html.Event> get onEnded => _html.onEnded;

  Stream<html.Event> get onError => _html.onError;

  Stream<html.Event> get onCanPlay => _html.onCanPlay;

  Stream<html.Event> get onResize => _html.onResize;

  dynamic get error => _html.error;

  MediaStream get srcObject => _stream;

  set muted(bool v) => _html.muted = v;
  bool get muted => _html.muted;

  set autoplay(bool v) => _html.autoplay = v;
  bool get autoplay => _html.autoplay;

  set controls(bool v) => _html.controls = v;
  bool get controls => _html.controls;

  void load() => _html.load();

  void removeAttribute(String name) => _html.removeAttribute(name);
}

@JS('Element')
abstract class Element {
  external set srcObject(MediaStreamJs stream);
}

@JS('window.document.querySelector')
external Element querySelector(String id);
