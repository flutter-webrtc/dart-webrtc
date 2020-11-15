@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_rtp_parameters.dart';
import 'rtc_stats_resport.dart';

@JS('RTCRtpSender')
class RTCRtpSender {
  external factory RTCRtpSender();
  external MediaStreamTrack get track;
  external RTCDTMFSender get dtmf;
  external RTCRtpEncodingParameters getParameters();
  external bool setParameters(RTCRtpEncodingParameters parameters);
  external RTCStatsReportJs getStats();
  external void setStreams(List<MediaStreamJs> streams);
  external void replaceTrack(MediaStreamTrack track);
  external static dynamic getCapabilities();
}
