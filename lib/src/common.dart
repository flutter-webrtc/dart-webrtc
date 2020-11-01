@JS()
library dart_webrtc;

import 'dart:js_util';
import 'package:js/js.dart';

Future<T> PromiseToFuture<T>(dynamic promise) {
  return promiseToFuture(promise);
}
