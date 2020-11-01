@JS()
library dart_webrtc;

import 'dart:js_util';
import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:js/js.dart';

@JS()
@anonymous
class MediaStreamConstraints {
  external factory MediaStreamConstraints({dynamic audio, dynamic video});
  external dynamic get audio;
  external dynamic get video;
}

@JS()
class InputDeviceInfo {
  external String get deviceId;
  external String get groupId;
  external String get kind;
  external String get label;
}

@JS()
class MediaDeviceInfo {
  external String get deviceId;
  external String get groupId;
  external String get kind;
  external String get label;
}

@JS()
class MediaDevices {
  external factory MediaDevices();
  external dynamic enumerateDevices();
  external dynamic getUserMedia(MediaStreamConstraints constraints);
  external dynamic getDisplayMedia();
  external set devicechange(Function(Event<MediaDevices> event) func);
}

@JS()
class Navigator {
  external MediaDevices get mediaDevices;
}

@JS()
external Navigator get navigator;

Future<T> PromiseToFuture<T>(dynamic promise) {
  return promiseToFuture(promise);
}
