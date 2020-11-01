@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS()
class RTCIceCandidate {
  external factory RTCIceCandidate(
      {String candidate, int sdpMLineIndex, String sdpMid});
  external String get candidate;
  external int get sdpMLineIndex;
  external String get sdpMid;
}
