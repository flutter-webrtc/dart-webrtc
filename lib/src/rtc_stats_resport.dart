@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS('RTCStats')
class RTCStats {
  external dynamic get timestamp;
  external String get type;
  external String get id;
}
