@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_transceiver.dart';

@JS('RTCTrackEvent')
class RTCTrackEvent {
  external RTCRtpReceiver get receiver;
  external List<MediaStreamJs> get streams;
  external MediaStreamTrack get track;
  external RTCRtpTransceiver get transceiver;
}

/*
class RTCTrackEvent {
  RTCTrackEvent(this._js);
  RTCRtpReceiver get receiver => _js.receiver;
  List<MediaStream> get streams => _js.streams;
  MediaStreamTrack get track => _js.track;
  RTCRtpTransceiver get transceiver => _js.transceiver;
  final RTCTrackEventJs _js;
}
*/
