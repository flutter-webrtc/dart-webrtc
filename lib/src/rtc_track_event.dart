@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'media_stream_js.dart';
import 'media_stream_track_js.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_transceiver.dart';

@JS('RTCTrackEvent')
class RTCTrackEvent {
  external RTCRtpReceiver get receiver;
  external List<MediaStream> get streams;
  external MediaStreamTrack get track;
  external RTCRtpTransceiver get transceiver;
}
