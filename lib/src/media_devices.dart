@JS()
library dart_webrtc;

import 'dart:js_util';
import 'package:js/js.dart';

@JS()
class MediaDevices {
  external factory MediaDevices();
  external List<dynamic> enumerateDevices();
  external dynamic getUserMedia();
  external dynamic getDisplayMedia();
  external set devicechange(Function func);
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
