@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS()
class RTCSessionDescription {
  external factory RTCSessionDescription({String type, String sdp});
  external String get type;
  external String get sdp;
}
