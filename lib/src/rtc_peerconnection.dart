@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS()
class RTCPeerConnection {
  external factory RTCPeerConnection();
  external dynamic get connectionState;
}
