@JS()
library dart_webrtc;

import 'dart:collection';

import 'package:js/js.dart';

@JS('RTCStats')
abstract class RTCStats extends Object {
  external dynamic get timestamp;
  external String get type;
  external String get id;
}

@JS('RTCStatsReport')
abstract class RTCStatsReport extends ListBase<RTCStats> {
  external int get size;
}
