@JS()
library dart_webrtc;

import 'package:js/js.dart';
import '../dart_webrtc.dart';

@JS('RTCRtpReceiver')
class RTCRtpReceiver {
  external factory RTCRtpReceiver();
  external MediaStreamTrack get track;
  external RTCRtpEncodingParameters getParameters();
  external RTCStatsReport getStats();
  external static dynamic getCapabilities();
}
