@JS()
library dart_webrtc;

import 'package:js/js.dart';
import '../dart_webrtc.dart';

@JS()
class RTCRtpReceiver {
  external factory RTCRtpReceiver();
  external MediaStreamTrack get track;
  external dynamic getParameters();
  external dynamic getStats();
  external static dynamic getCapabilities();
}
