@JS()
library dart_webrtc;

import '../dart_webrtc.dart';
import 'package:js/js.dart';

@JS()
class RTCTrackEvent {
  external RTCRtpReceiver get receiver;
  external List<MediaStream> get streams;
  external MediaStreamTrack get track;
  external RTCRtpTransceiver get transceiver;
}
