@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS()
class RTCStats {
  external dynamic get timestamp;
  external String get type;
  external String get id;
}
