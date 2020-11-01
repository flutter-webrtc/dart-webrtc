@JS()
library dart_webrtc;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS('RTCTrackEvent')
class RTCTrackEvent {
  external RTCRtpReceiver get receiver;
  external List<MediaStream> get streams;
  external MediaStreamTrack get track;
  external RTCRtpTransceiver get transceiver;
}
