@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'media_stream_track.dart';
import 'rtc_rtp_parameters.dart';
import 'rtc_stats_resport.dart';

@JS('RTCRtpReceiver')
class RTCRtpReceiver {
  external factory RTCRtpReceiver();
  external MediaStreamTrack get track;
  external RTCRtpEncodingParameters getParameters();
  external RTCStatsReport getStats();
  external static dynamic getCapabilities();
}
