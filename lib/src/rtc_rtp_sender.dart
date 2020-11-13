@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_rtp_parameters.dart';

@JS('RTCRtpSender')
class RTCRtpSender {
  external factory RTCRtpSender();
  external MediaStreamTrack get track;
  external RTCDTMFSender get dtmf;
  external RTCRtpEncodingParameters getParameters();
  external bool setParameters(RTCRtpEncodingParameters parameters);
  external dynamic getStats();
  external void setStreams(List<MediaStream> streams);
  external void replaceTrack(MediaStreamTrack track);
  external static dynamic getCapabilities();
}
